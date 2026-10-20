use super::{
    ExecutionCallback, RuntimeInstruction, RuntimeInstructionResult, RuntimeInterface,
    instruction::{RuntimeInstructionRaw, RuntimeInstructionResultRaw},
    output::OutputSinkHandle,
};
use crate::{
    endpoint::{EndpointBorrowCallback, EndpointBorrowRequest, QuantumEndpointHandle},
    utils::{
        MetricValue, check_errno, load_plugin_descriptor, read_raw_metric, with_strings_to_cargs,
    },
};
use anyhow::{Result, anyhow};
use std::{
    ffi,
    sync::{Arc, atomic::AtomicBool},
};

use super::version::RUNTIME_V0_4_API_VERSION;

pub type RuntimeInstance = *mut ffi::c_void;
pub type Errno = i32;

/// A runtime that owns endpoint execution. All operational functions are
/// thread safe. Lifecycle calls exclude submissions. Callbacks and endpoint
/// calls run on one fixed execution thread, including between shots.
///
/// shot_start borrows the endpoint and output sink until shot_end returns.
/// A failed start must retain neither handle. shot_end relinquishes
/// both even on failure. destroy must finish all callbacks before unloading code.
/// Input buffers and output pointers are borrowed only for the duration of
/// their call. A runtime that queues work copies the inputs before returning.
/// The endpoint and output sink remain borrowed until shot end.
/// Every function pointer is required. Return zero on success; never unwind.
/// get_metrics_fn uses a nonzero return to indicate the end of enumeration.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimePluginDescriptorV2 {
    /// Must be `sizeof(SeleneRuntimePluginDescriptorV2)`.
    pub struct_size: u64,
    /// Must be `SELENE_RUNTIME_V0_4_API_VERSION`.
    pub api_version: u64,
    /// Create an instance and write its handle. start is the initial simulated
    /// time in nanoseconds. argv contains argc UTF-8 strings, without a program
    /// name; strings are borrowed for this call only. Return no live instance
    /// on failure.
    pub init_fn: Option<
        unsafe extern "C" fn(
            handle: *mut RuntimeInstance,
            n_qubits: u64,
            start: u64,
            argc: u32,
            argv: *const *const ffi::c_char,
        ) -> Errno,
    >,
    /// Finish internal requests and destroy the runtime instance. The host has
    /// already ended the shot and cleaned up its endpoint. No subsequent call
    /// may use this instance.
    pub destroy_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    /// Begin shot_id with the given seed and take exclusive access to the
    /// host-started endpoint and output sink. Keep them until shot_end_fn returns.
    /// A failed start must not keep either handle or leave callbacks using it.
    pub shot_start_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            shot_id: u64,
            seed: u64,
            endpoint: QuantumEndpointHandle,
            output: OutputSinkHandle,
        ) -> Errno,
    >,
    /// Finish queued work, publish its results and relinquish both shot handles,
    /// even if execution fails. Do not call simulator or error-model lifecycle
    /// methods: the host performs those after this call.
    pub shot_end_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    /// Enumerate metrics from index zero. Return nonzero when enumeration ends.
    /// On success, write a NUL-terminated UTF-8 tag of at most 255 bytes to the
    /// caller's 256-byte tag_out buffer. datatype_out is 0 for bool, 1 for i64,
    /// 2 for u64 or 3 for f64. value_out holds the value's bits in 64-bit storage
    /// (zero for false, nonzero for true). Operational calls are excluded.
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    /// Handle one program instruction. Copy borrowed inputs before returning.
    /// Write the matching result to result_out on success. Gate and print
    /// instructions may return once queued. ForceResult makes its result
    /// available before returning. Exit closes submissions and flushes all
    /// earlier quantum work and output before returning, even though it keeps
    /// the endpoint and sink until shot_end. On failure, quiesce the worker
    /// so shot_end remains safe. Never longjmp or unwind through this call.
    pub handle_instruction_fn: Option<
        unsafe extern "C" fn(
            RuntimeInstance,
            *const RuntimeInstructionRaw,
            *mut RuntimeInstructionResultRaw,
        ) -> Errno,
    >,
    /// Run the host callback exactly once on the endpoint execution thread
    /// and return only after it finishes. Available between shots for plugin
    /// creation, lifecycle calls and destruction. Do not retain the callback
    /// or its context, or overlap it with another endpoint operation. The host
    /// uses borrow_endpoint_fn for access during a shot.
    pub on_execution_thread_fn:
        Option<unsafe extern "C" fn(RuntimeInstance, ExecutionCallback, *mut ffi::c_void) -> Errno>,
    /// During a shot, invoke callback exclusively on the execution thread.
    /// The request and opaque callback context have separate lifetimes and
    /// meanings. A forced flush finishes all work ordered before this borrow
    /// and publishes its results; an unforced borrow may leave work pending.
    /// Unsupported requirements fail without invoking callback. Wait for the
    /// callback to return, propagate failure and resume without retaining the
    /// handle, callback or context. The callback must not re-enter this runtime.
    pub borrow_endpoint_fn: Option<
        unsafe extern "C" fn(
            RuntimeInstance,
            *const EndpointBorrowRequest,
            EndpointBorrowCallback,
            *mut ffi::c_void,
        ) -> Errno,
    >,
}

pub struct Runtime {
    _library: Arc<libloading::Library>,
    descriptor: RuntimePluginDescriptorV2,
    instance: RuntimeInstance,
    destroyed: AtomicBool,
    access: std::sync::RwLock<()>,
}

// The v2 contract requires concurrent entry and synchronised lifecycle handover.
// The library stays loaded until the instance has finished its destroy callback.
unsafe impl Send for Runtime {}
unsafe impl Sync for Runtime {}

impl Runtime {
    pub(crate) fn load_from_library(
        library: Arc<libloading::Library>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Option<Self>> {
        let descriptor = unsafe {
            load_plugin_descriptor::<RuntimePluginDescriptorV2>(
                &library,
                b"selene_runtime_plugin_descriptor_v2",
                b"selene_runtime_get_plugin_descriptor_v2",
                "Runtime v2",
            )
        }?;
        let Some(descriptor) = descriptor else {
            let advertised = unsafe {
                library
                    .get::<*const ffi::c_void>(b"selene_runtime_plugin_descriptor_v2")
                    .is_ok()
                    || library
                        .get::<*const ffi::c_void>(b"selene_runtime_get_plugin_descriptor_v2")
                        .is_ok()
            };
            anyhow::ensure!(!advertised, "Runtime v2 getter returned a null descriptor");
            return Ok(None);
        };
        anyhow::ensure!(
            descriptor.api_version >> 8 == RUNTIME_V0_4_API_VERSION >> 8,
            "Unsupported endpoint runtime API version"
        );
        anyhow::ensure!(descriptor.init_fn.is_some(), "Runtime v2 requires init_fn");
        anyhow::ensure!(
            descriptor.destroy_fn.is_some(),
            "Runtime v2 requires destroy_fn"
        );
        anyhow::ensure!(
            descriptor.shot_start_fn.is_some(),
            "Runtime v2 requires shot_start_fn"
        );
        anyhow::ensure!(
            descriptor.shot_end_fn.is_some(),
            "Runtime v2 requires shot_end_fn"
        );
        anyhow::ensure!(
            descriptor.get_metrics_fn.is_some(),
            "Runtime v2 requires get_metrics_fn"
        );
        anyhow::ensure!(
            descriptor.handle_instruction_fn.is_some(),
            "Runtime v2 requires handle_instruction_fn"
        );
        anyhow::ensure!(
            descriptor.on_execution_thread_fn.is_some(),
            "Runtime v2 requires on_execution_thread_fn"
        );
        anyhow::ensure!(
            descriptor.borrow_endpoint_fn.is_some(),
            "Runtime v2 requires borrow_endpoint_fn"
        );
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe {
                    (descriptor.init_fn.unwrap())(&mut instance, n_qubits, start.into(), argc, argv)
                },
                || anyhow!("Runtime v2 initialisation failed"),
            )
        })?;
        anyhow::ensure!(!instance.is_null(), "Runtime v2 returned a null instance");
        Ok(Some(Self {
            _library: library,
            descriptor,
            instance,
            destroyed: AtomicBool::new(false),
            access: std::sync::RwLock::new(()),
        }))
    }
}
impl Drop for Runtime {
    fn drop(&mut self) {
        let _ = self.destroy();
    }
}
unsafe impl RuntimeInterface for Runtime {
    fn destroy(&self) -> Result<()> {
        let _access = self
            .access
            .write()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        if self
            .destroyed
            .swap(true, std::sync::atomic::Ordering::AcqRel)
        {
            return Ok(());
        }
        check_errno(
            unsafe { (self.descriptor.destroy_fn.unwrap())(self.instance) },
            || anyhow!("Runtime: destroy failed"),
        )
    }

    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        endpoint: QuantumEndpointHandle,
        output: OutputSinkHandle,
    ) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        check_errno(
            unsafe {
                (self.descriptor.shot_start_fn.unwrap())(
                    self.instance,
                    shot_id,
                    seed,
                    endpoint,
                    output,
                )
            },
            || anyhow!("Runtime: shot_start failed"),
        )
    }

    fn shot_end(&self) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        check_errno(
            unsafe { (self.descriptor.shot_end_fn.unwrap())(self.instance) },
            || anyhow!("Runtime: shot_end failed"),
        )
    }

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.descriptor.get_metrics_fn.unwrap())(
                self.instance,
                nth_metric,
                tag_ptr,
                datatype_ptr,
                data_ptr,
            )
        })
    }

    fn handle_instruction(
        &self,
        instruction: RuntimeInstruction,
    ) -> Result<RuntimeInstructionResult> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        let mut result = RuntimeInstructionResultRaw {
            tag: 0,
            available: false,
            value: 0,
        };
        instruction.with_raw(|raw| {
            check_errno(
                unsafe {
                    (self.descriptor.handle_instruction_fn.unwrap())(
                        self.instance,
                        raw,
                        &mut result,
                    )
                },
                || anyhow!("Runtime instruction failed"),
            )
        })?;
        RuntimeInstructionResult::from_raw(result)
    }

    unsafe fn on_execution_thread(
        &self,
        callback: ExecutionCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        check_errno(
            unsafe {
                (self.descriptor.on_execution_thread_fn.unwrap())(self.instance, callback, context)
            },
            || anyhow!("Runtime: execution-thread callback failed"),
        )
    }
    unsafe fn borrow_endpoint(
        &self,
        request: &EndpointBorrowRequest,
        callback: EndpointBorrowCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.destroyed.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has been destroyed"
        );
        anyhow::ensure!(
            request.struct_size >= size_of::<EndpointBorrowRequest>() as u64,
            "Undersized endpoint borrow request"
        );
        check_errno(
            unsafe {
                (self.descriptor.borrow_endpoint_fn.unwrap())(
                    self.instance,
                    request,
                    callback,
                    context,
                )
            },
            || anyhow!("Runtime: endpoint borrow failed"),
        )
    }
}
