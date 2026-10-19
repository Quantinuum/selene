use super::{ExecutionCallback, RuntimeInterface};
use crate::runtime::plugin::{Errno, RuntimeInstance};
use crate::{
    peripheral::{PeripheralBorrowCallback, PeripheralBorrowRequest, QuantumPeripheralHandle},
    utils::{
        MetricValue, check_errno, load_plugin_descriptor, read_raw_metric, with_strings_to_cargs,
    },
};
use anyhow::{Context as _, Result, anyhow};
use std::{
    ffi,
    sync::{Arc, atomic::AtomicBool},
};

/// Runtime API with direct peripheral ownership. The v1 API remains 0.3.x.
pub const RUNTIME_V2_API_VERSION: u64 = 0x0000_0400;

/// A runtime that owns peripheral execution. All operational functions are
/// thread safe. Lifecycle calls exclude submissions. Callbacks and peripheral
/// calls run on one fixed execution thread, including between shots.
///
/// shot_start borrows the handle until shot_end returns. On any shot_start
/// failure it must return without retaining the handle. shot_end relinquishes
/// it even on failure. exit must finish all callbacks before unloading code.
/// Input buffers and output pointers are borrowed only for the duration of
/// their call. A runtime that queues work copies the inputs before returning.
/// The peripheral handle is the exception: it remains borrowed until shot end.
/// Every function pointer is required. Return zero on success; never unwind.
/// get_metrics_fn uses a nonzero return to indicate the end of enumeration.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimePluginDescriptorV2 {
    /// Must be `sizeof(SeleneRuntimePluginDescriptorV2)`.
    pub struct_size: u64,
    /// Must be `SELENE_RUNTIME_V2_API_VERSION`.
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
    /// already ended the shot and cleaned up its peripheral. No subsequent call
    /// may use this instance.
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    /// Begin shot_id with the given seed and take exclusive access to the
    /// host-started peripheral. Retain it only until shot_end_fn returns. A
    /// failed start must not retain it or leave callbacks using it.
    pub shot_start_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            shot_id: u64,
            seed: u64,
            peripheral: QuantumPeripheralHandle,
        ) -> Errno,
    >,
    /// Finish queued work, publish its results and relinquish the peripheral,
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
    /// Allocate a qubit and write its address, or UINT64_MAX if none is free.
    pub qalloc_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno>,
    /// Release a previously allocated qubit address.
    pub qfree_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno>,
    /// Place a scheduling barrier on these qubits, followed by sleep_ns.
    /// A forced peripheral borrow separately requests completed execution.
    pub local_barrier_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            qubits: *const u64,
            qubits_len: u64,
            sleep_ns: u64,
        ) -> Errno,
    >,
    /// Place a scheduling barrier on all allocated qubits, followed by sleep_ns.
    pub global_barrier_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno>,
    /// Schedule an RXY gate. theta and phi are in radians.
    pub rxy_gate_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    >,
    /// Schedule an RZZ gate. theta is in radians.
    pub rzz_gate_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
        ) -> Errno,
    >,
    /// Schedule an RZ gate. theta is in radians.
    pub rz_gate_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64) -> Errno>,
    /// Schedule an RPP gate. theta and phi are in radians.
    pub rpp_gate_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
            phi: f64,
        ) -> Errno,
    >,
    /// Schedule a measurement and write its new result identifier. The result
    /// starts with one reference and may not yet be available.
    pub measure_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    >,
    /// Schedule a leakage measurement with a new result identifier and one
    /// reference, following the same lifetime rules as measure_fn.
    pub measure_leaked_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    >,
    /// Schedule a reset of the allocated qubit.
    pub reset_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno>,
    /// Compile and execute the work needed for result_id, and publish its
    /// value before returning. The host does not retrieve batches itself.
    pub force_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
    /// Write -1 if unavailable, 0 for false or 1 for true. An unavailable
    /// result is not itself an error; force_result_fn makes it available.
    pub get_bool_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno>,
    /// Write UINT64_MAX if unavailable, or the result value. UINT64_MAX is
    /// reserved and cannot be represented as an available result in this ABI.
    pub get_u64_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno>,
    /// Add a reference to a live result identifier.
    pub increment_future_refcount_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
    /// Remove a reference. Once its count reaches zero, the identifier must
    /// not be used again, including to add another reference.
    pub decrement_future_refcount_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
    /// Perform a runtime-specific call. data is borrowed for data_len bytes;
    /// it may be null when data_len is zero. Write the return value to result.
    pub custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    /// Schedule delay_ns of simulated inactivity.
    pub simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
    /// Run the host callback exactly once on the peripheral execution thread
    /// and return only after it finishes. Available between shots for plugin
    /// creation, lifecycle calls and destruction. Do not retain the callback
    /// or its context, or overlap it with another peripheral operation. The host
    /// uses borrow_peripheral_fn for access during a shot.
    pub on_execution_thread_fn:
        Option<unsafe extern "C" fn(RuntimeInstance, ExecutionCallback, *mut ffi::c_void) -> Errno>,
    /// During a shot, invoke callback exclusively on the execution thread.
    /// The request and opaque callback context have separate lifetimes and
    /// meanings. A forced flush finishes all work ordered before this borrow
    /// and publishes its results; an unforced borrow may leave work pending.
    /// Unsupported requirements fail without invoking callback. Wait for the
    /// callback to return, propagate failure and resume without retaining the
    /// handle, callback or context. The callback must not re-enter this runtime.
    pub borrow_peripheral_fn: Option<
        unsafe extern "C" fn(
            RuntimeInstance,
            *const PeripheralBorrowRequest,
            PeripheralBorrowCallback,
            *mut ffi::c_void,
        ) -> Errno,
    >,
}

pub struct Runtime {
    _library: Arc<libloading::Library>,
    descriptor: RuntimePluginDescriptorV2,
    instance: RuntimeInstance,
    exited: AtomicBool,
    access: std::sync::RwLock<()>,
}

// The v2 contract requires concurrent entry and synchronised lifecycle handover.
// The library stays loaded until the instance has finished its exit callback.
unsafe impl Send for Runtime {}
unsafe impl Sync for Runtime {}

impl Runtime {
    /// Prefer v2 if advertised. A malformed v2 must not silently fall back to v1.
    pub fn load_from_file(
        path: &impl AsRef<std::ffi::OsStr>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<dyn RuntimeInterface>> {
        let library = Arc::new(
            unsafe { libloading::Library::new(path.as_ref()) }.with_context(|| {
                format!(
                    "Failed to load runtime plugin: {}",
                    path.as_ref().to_string_lossy()
                )
            })?,
        );
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
            return Ok(Box::new(super::LegacyRuntime::new(
                crate::runtime::Runtime::load_from_file(path, n_qubits, start, args)?,
            )));
        };
        anyhow::ensure!(
            descriptor.api_version >> 8 == RUNTIME_V2_API_VERSION >> 8,
            "Unsupported peripheral runtime API version"
        );
        anyhow::ensure!(descriptor.init_fn.is_some(), "Runtime v2 requires init_fn");
        anyhow::ensure!(descriptor.exit_fn.is_some(), "Runtime v2 requires exit_fn");
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
            descriptor.qalloc_fn.is_some(),
            "Runtime v2 requires qalloc_fn"
        );
        anyhow::ensure!(
            descriptor.qfree_fn.is_some(),
            "Runtime v2 requires qfree_fn"
        );
        anyhow::ensure!(
            descriptor.local_barrier_fn.is_some(),
            "Runtime v2 requires local_barrier_fn"
        );
        anyhow::ensure!(
            descriptor.global_barrier_fn.is_some(),
            "Runtime v2 requires global_barrier_fn"
        );
        anyhow::ensure!(
            descriptor.rxy_gate_fn.is_some(),
            "Runtime v2 requires rxy_gate_fn"
        );
        anyhow::ensure!(
            descriptor.rzz_gate_fn.is_some(),
            "Runtime v2 requires rzz_gate_fn"
        );
        anyhow::ensure!(
            descriptor.rz_gate_fn.is_some(),
            "Runtime v2 requires rz_gate_fn"
        );
        anyhow::ensure!(
            descriptor.rpp_gate_fn.is_some(),
            "Runtime v2 requires rpp_gate_fn"
        );
        anyhow::ensure!(
            descriptor.measure_fn.is_some(),
            "Runtime v2 requires measure_fn"
        );
        anyhow::ensure!(
            descriptor.measure_leaked_fn.is_some(),
            "Runtime v2 requires measure_leaked_fn"
        );
        anyhow::ensure!(
            descriptor.reset_fn.is_some(),
            "Runtime v2 requires reset_fn"
        );
        anyhow::ensure!(
            descriptor.force_result_fn.is_some(),
            "Runtime v2 requires force_result_fn"
        );
        anyhow::ensure!(
            descriptor.get_bool_result_fn.is_some(),
            "Runtime v2 requires get_bool_result_fn"
        );
        anyhow::ensure!(
            descriptor.get_u64_result_fn.is_some(),
            "Runtime v2 requires get_u64_result_fn"
        );
        anyhow::ensure!(
            descriptor.increment_future_refcount_fn.is_some(),
            "Runtime v2 requires increment_future_refcount_fn"
        );
        anyhow::ensure!(
            descriptor.decrement_future_refcount_fn.is_some(),
            "Runtime v2 requires decrement_future_refcount_fn"
        );
        anyhow::ensure!(
            descriptor.custom_call_fn.is_some(),
            "Runtime v2 requires custom_call_fn"
        );
        anyhow::ensure!(
            descriptor.simulate_delay_fn.is_some(),
            "Runtime v2 requires simulate_delay_fn"
        );
        anyhow::ensure!(
            descriptor.on_execution_thread_fn.is_some(),
            "Runtime v2 requires on_execution_thread_fn"
        );
        anyhow::ensure!(
            descriptor.borrow_peripheral_fn.is_some(),
            "Runtime v2 requires borrow_peripheral_fn"
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
        Ok(Box::new(Self {
            _library: library,
            descriptor,
            instance,
            exited: AtomicBool::new(false),
            access: std::sync::RwLock::new(()),
        }))
    }
}
impl Drop for Runtime {
    fn drop(&mut self) {
        let _ = self.exit();
    }
}
unsafe impl RuntimeInterface for Runtime {
    fn exit(&self) -> Result<()> {
        let _access = self
            .access
            .write()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        if self.exited.swap(true, std::sync::atomic::Ordering::AcqRel) {
            return Ok(());
        }
        check_errno(
            unsafe { (self.descriptor.exit_fn.unwrap())(self.instance) },
            || anyhow!("Runtime: exit failed"),
        )
    }

    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        peripheral: QuantumPeripheralHandle,
    ) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.shot_start_fn.unwrap())(self.instance, shot_id, seed, peripheral)
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
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.shot_end_fn.unwrap())(self.instance) },
            || anyhow!("Runtime: shot_end failed"),
        )
    }

    fn custom_call(&self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = 0;
        check_errno(
            unsafe {
                (self.descriptor.custom_call_fn.unwrap())(
                    self.instance,
                    custom_tag,
                    data.as_ptr().cast(),
                    data.len(),
                    &mut result,
                )
            },
            || anyhow!("Runtime: custom_call failed"),
        )?;
        Ok(result)
    }

    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.simulate_delay_fn.unwrap())(self.instance, delay_ns) },
            || anyhow!("Runtime: simulate_delay failed"),
        )
    }

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
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

    fn qalloc(&self) -> Result<u64> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = 0;
        check_errno(
            unsafe { (self.descriptor.qalloc_fn.unwrap())(self.instance, &mut result) },
            || anyhow!("Runtime: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&self, qubit_id: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.qfree_fn.unwrap())(self.instance, qubit_id) },
            || anyhow!("Runtime: qfree failed"),
        )
    }

    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.rxy_gate_fn.unwrap())(self.instance, qubit_id, theta, phi) },
            || anyhow!("Runtime: rxy_gate failed"),
        )
    }

    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.rzz_gate_fn.unwrap())(self.instance, qubit_id_1, qubit_id_2, theta)
            },
            || anyhow!("Runtime: rzz_gate failed"),
        )
    }

    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.rz_gate_fn.unwrap())(self.instance, qubit_id, theta) },
            || anyhow!("Runtime: rz_gate failed"),
        )
    }

    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.rpp_gate_fn.unwrap())(
                    self.instance,
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                )
            },
            || anyhow!("Runtime: rpp_gate failed"),
        )
    }

    fn measure(&self, qubit_id: u64) -> Result<u64> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = 0;
        check_errno(
            unsafe { (self.descriptor.measure_fn.unwrap())(self.instance, qubit_id, &mut result) },
            || anyhow!("Runtime: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = 0;
        check_errno(
            unsafe {
                (self.descriptor.measure_leaked_fn.unwrap())(self.instance, qubit_id, &mut result)
            },
            || anyhow!("Runtime: measure_leaked failed"),
        )?;
        Ok(result)
    }

    fn reset(&self, qubit_id: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.reset_fn.unwrap())(self.instance, qubit_id) },
            || anyhow!("Runtime: reset failed"),
        )
    }

    fn force_result(&self, result_id: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.force_result_fn.unwrap())(self.instance, result_id) },
            || anyhow!("Runtime: force_result failed"),
        )
    }

    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = -1;
        check_errno(
            unsafe {
                (self.descriptor.get_bool_result_fn.unwrap())(self.instance, result_id, &mut result)
            },
            || anyhow!("Runtime: get_bool_result failed"),
        )?;
        match result {
            -1 => Ok(None),
            0 => Ok(Some(false)),
            1 => Ok(Some(true)),
            _ => Err(anyhow!(
                "Runtime: get_bool_result returned an invalid value"
            )),
        }
    }

    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        let mut result = u64::MAX;
        check_errno(
            unsafe {
                (self.descriptor.get_u64_result_fn.unwrap())(self.instance, result_id, &mut result)
            },
            || anyhow!("Runtime: get_u64_result failed"),
        )?;
        if result == u64::MAX {
            Ok(None)
        } else {
            Ok(Some(result))
        }
    }

    fn increment_future_refcount(&self, future: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.increment_future_refcount_fn.unwrap())(self.instance, future)
            },
            || anyhow!("Runtime: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&self, future: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.decrement_future_refcount_fn.unwrap())(self.instance, future)
            },
            || anyhow!("Runtime: decrement_future_refcount failed"),
        )
    }

    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.local_barrier_fn.unwrap())(
                    self.instance,
                    qubits.as_ptr(),
                    qubits.len() as u64,
                    sleep_ns,
                )
            },
            || anyhow!("Runtime: local_barrier failed"),
        )
    }

    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe { (self.descriptor.global_barrier_fn.unwrap())(self.instance, sleep_ns) },
            || anyhow!("Runtime: global_barrier failed"),
        )
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
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        check_errno(
            unsafe {
                (self.descriptor.on_execution_thread_fn.unwrap())(self.instance, callback, context)
            },
            || anyhow!("Runtime: execution-thread callback failed"),
        )
    }
    unsafe fn borrow_peripheral(
        &self,
        request: &PeripheralBorrowRequest,
        callback: PeripheralBorrowCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        let _access = self
            .access
            .read()
            .map_err(|_| anyhow!("Runtime access lock poisoned"))?;
        anyhow::ensure!(
            !self.exited.load(std::sync::atomic::Ordering::Acquire),
            "Runtime has exited"
        );
        anyhow::ensure!(
            request.struct_size >= size_of::<PeripheralBorrowRequest>() as u64,
            "Undersized peripheral borrow request"
        );
        check_errno(
            unsafe {
                (self.descriptor.borrow_peripheral_fn.unwrap())(
                    self.instance,
                    request,
                    callback,
                    context,
                )
            },
            || anyhow!("Runtime: peripheral borrow failed"),
        )
    }
}
