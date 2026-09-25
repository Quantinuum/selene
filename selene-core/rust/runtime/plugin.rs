pub use crate::operation::Operation;
pub use crate::operation::plugin::{
    BatchBuilder, BatchExtractor, RuntimeExtractOperationHandle, RuntimeExtractOperationInstance,
    RuntimeExtractOperationInterface, RuntimeGetOperationHandle, RuntimeGetOperationInstance,
    RuntimeGetOperationInterface,
};
use crate::utils::{
    MetricValue, check_errno, load_plugin_descriptor, read_raw_metric, with_strings_to_cargs,
};

use super::{BatchOperation, RuntimeAPIVersion, RuntimeInterface, RuntimeInterfaceFactory};
use anyhow::{Result, anyhow};
use libloading;
use std::ffi::OsStr;
use std::{ffi, sync::Arc};

/// A handle that lets several threads call the same runtime instance.
///
/// The pointer is const because access is shared. The runtime can still change
/// its state, but the plugin must synchronize those changes itself.
pub type RuntimeInstanceV2 = *const ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
/// The function table a runtime plugin exports for API 0.4.x.
///
/// Fill in every function pointer unless its documentation marks it optional.
/// Optional function pointers may be null.
///
/// # Concurrency and safety
///
/// Several threads can submit operations to the same instance at once. The
/// plugin must synchronize allocation, gates, measurements, barriers, delays,
/// custom calls, result forcing, result reads and writes, and reference counts.
/// Calls on separate instances must also be safe to run concurrently.
///
/// The host collects batches, executes them in order, and writes back results.
/// One thread does this work, which we call the consumer. User threads can keep
/// calling the runtime while it does this. After `force_result_fn` succeeds,
/// collecting batches must let the consumer reach the work needed for that
/// result. New submissions must not
/// postpone that work indefinitely. The work may already be with the consumer,
/// or its result may already be ready.
///
/// Once the consumer has executed the work and written back its result, the
/// result getter must report that value as available. An empty batch only means
/// there is no more work to collect right now. The consumer may still be working
/// on an earlier batch. Never wait for a result while holding a runtime lock
/// that the consumer needs to produce it.
///
/// Finish initialization before sharing the instance. The host must pause all
/// other calls during `shot_start_fn`, `shot_end_fn`, and `exit_fn`. It must also
/// keep the instance idle throughout a whole `get_metrics_fn` enumeration,
/// including between calls for individual metrics. Only these calls can assume
/// they have exclusive access to the instance.
///
/// Keep the instance alive until every call has finished. Input buffers must
/// stay readable and unchanged for the duration of their call. Output buffers
/// must be writable, and no other call may access them at the same time.
/// The plugin may use the operation callback handle and its buffers only while
/// retrieving a batch. It must not keep them afterwards or invoke callbacks
/// concurrently.
pub struct RuntimePluginDescriptorV2 {
    /// Must be `sizeof(SeleneRuntimePluginDescriptorV2)`.
    pub struct_size: u64,
    /// Must be `SELENE_RUNTIME_CURRENT_API_VERSION`.
    pub api_version: u64,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstanceV2,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    /// Optional. If null, no plugin-specific cleanup is performed.
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstanceV2) -> Errno>,
    pub get_next_operations_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, ops: RuntimeGetOperationHandle) -> Errno,
    pub shot_start_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2) -> Errno,
    /// Optional. A null pointer means the plugin exposes no metrics.
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstanceV2,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    pub qalloc_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2, qaddress_out: *mut u64) -> Errno,
    pub qfree_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2, qaddress: u64) -> Errno,
    pub local_barrier_fn: unsafe extern "C" fn(
        handle: RuntimeInstanceV2,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno,
    pub global_barrier_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2, sleep_ns: u64) -> Errno,
    pub rxy_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, qubit: u64, theta: f64, phi: f64) -> Errno,
    pub rzz_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstanceV2,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno,
    pub rz_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, qubit: u64, theta: f64) -> Errno,
    pub rpp_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstanceV2,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    pub measure_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, qubit: u64, result_id: *mut u64) -> Errno,
    pub measure_leaked_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, qubit: u64, result_id: *mut u64) -> Errno,
    pub reset_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2, qubit: u64) -> Errno,
    pub force_result_fn: unsafe extern "C" fn(handle: RuntimeInstanceV2, result_id: u64) -> Errno,
    pub get_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, id: u64, result: *mut i8) -> Errno,
    pub get_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, id: u64, result: *mut u64) -> Errno,
    pub set_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, result_id: u64, result: bool) -> Errno,
    pub set_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, result_id: u64, result: u64) -> Errno,
    pub increment_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, result_id: u64) -> Errno,
    pub decrement_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstanceV2, result_id: u64) -> Errno,
    /// Optional. A null pointer means custom calls are unsupported.
    pub custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstanceV2,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    /// Optional. A null pointer means simulated delays are unsupported.
    pub simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstanceV2, delay_ns: u64) -> Errno>,
}

/// Legacy opaque runtime instance (API 0.3.x).
pub type RuntimeInstance = *mut ffi::c_void;

#[repr(C)]
#[derive(Clone, Copy)]
/// The function table used by older runtime plugins, built for API 0.3.x.
///
/// The host gives each instance its own thread. Initialization, every call, and
/// cleanup happen on that thread, so calls on an instance never overlap.
///
/// Function pointer fields documented as optional may be null. All other
/// function pointer fields must be populated.
pub struct RuntimePluginDescriptorV1 {
    /// Must be `sizeof(SeleneRuntimePluginDescriptorV1)`.
    pub struct_size: u64,
    /// Must be `SELENE_RUNTIME_V1_API_VERSION`.
    pub api_version: u64,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    /// Optional. If null, no plugin-specific cleanup is performed.
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    pub get_next_operations_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, ops: RuntimeGetOperationHandle) -> Errno,
    pub shot_start_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstance) -> Errno,
    /// Optional. A null pointer means the plugin exposes no metrics.
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    pub qalloc_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno,
    pub qfree_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno,
    pub local_barrier_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno,
    pub global_barrier_fn: unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno,
    pub rxy_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    pub rzz_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno,
    pub rz_gate_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64) -> Errno,
    pub rpp_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    pub measure_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    pub measure_leaked_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    pub reset_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno,
    pub force_result_fn: unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    pub get_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno,
    pub get_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno,
    pub set_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: bool) -> Errno,
    pub set_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: u64) -> Errno,
    pub increment_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    pub decrement_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    /// Optional. A null pointer means custom calls are unsupported.
    pub custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    /// Optional. A null pointer means simulated delays are unsupported.
    pub simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
}

mod legacy;

#[derive(Clone, Copy)]
enum Descriptor {
    V1(RuntimePluginDescriptorV1),
    V2(RuntimePluginDescriptorV2),
}

/// Loads a runtime plugin from a shared library and creates its instances.
///
/// The loader first looks for a v2 descriptor, for API 0.4.x. If neither the v2
/// descriptor nor its getter is exported, it tries v1, for API 0.3.x. If a plugin
/// exports a broken v2 interface, loading fails even if it also exports v1.
/// Either descriptor can be exported as data or through its getter function.
///
/// V2 instances can be called directly from several threads. Each v1 instance
/// gets its own thread, and a compatibility adapter sends calls to it. In both
/// cases the library stays loaded for as long as its instances need it.
/// Only load plugins you trust: they run native code in the host process.
pub struct RuntimePluginInterface {
    _lib: libloading::Library,
    descriptor: Descriptor,
}

impl RuntimePluginInterface {
    pub fn new_from_file(plugin_file: impl AsRef<OsStr>) -> Result<Arc<Self>> {
        let lib = unsafe { libloading::Library::new(plugin_file.as_ref()) }?;
        let descriptor = unsafe {
            if let Some(descriptor) = load_plugin_descriptor::<RuntimePluginDescriptorV2>(
                &lib,
                b"selene_runtime_plugin_descriptor_v2",
                b"selene_runtime_get_plugin_descriptor_v2",
                "Runtime v2",
            )? {
                RuntimeAPIVersion::from(descriptor.api_version).validate()?;
                Descriptor::V2(descriptor)
            } else if let Some(descriptor) = load_plugin_descriptor::<RuntimePluginDescriptorV1>(
                &lib,
                b"selene_runtime_plugin_descriptor_v1",
                b"selene_runtime_get_plugin_descriptor_v1",
                "Runtime v1",
            )? {
                RuntimeAPIVersion::from(descriptor.api_version).validate_v1()?;
                Descriptor::V1(descriptor)
            } else {
                return Err(anyhow!(
                    "Runtime plugin '{}' exports neither a v2 nor a v1 descriptor or getter",
                    plugin_file.as_ref().to_string_lossy()
                ));
            }
        };
        Ok(Arc::new(Self {
            _lib: lib,
            descriptor,
        }))
    }
}

impl RuntimeInterfaceFactory for RuntimePluginInterface {
    type Interface = RuntimePlugin;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let inner: Box<dyn RuntimeInterface> = match self.descriptor {
            Descriptor::V1(descriptor) => Box::new(legacy::LegacyRuntime::new(
                self, descriptor, n_qubits, start, args,
            )?),
            Descriptor::V2(descriptor) => {
                let mut instance = std::ptr::null();
                with_strings_to_cargs(args, |argc, argv| {
                    check_errno(
                        unsafe {
                            (descriptor.init_fn)(&mut instance, n_qubits, start.into(), argc, argv)
                        },
                        || anyhow!("RuntimePluginInterface: init failed"),
                    )
                })?;
                Box::new(ConcurrentRuntimePlugin {
                    _interface: self,
                    descriptor,
                    instance,
                    retrieval: parking_lot::Mutex::new(()),
                    access: parking_lot::RwLock::new(()),
                })
            }
        };
        Ok(Box::new(RuntimePlugin { inner }))
    }
}

/// A loaded plugin that you can use through [`RuntimeInterface`].
///
/// For a legacy plugin, each call waits for the plugin's own thread to reply.
/// Slice inputs are copied before sending them to that thread. Returned batches
/// own their operations and buffers, so they don't borrow the plugin's memory.
///
/// The legacy adapter runs cleanup when you call `exit`, or when you drop it if
/// you haven't called `exit`. Cleanup runs at most once. After an explicit exit,
/// further calls return an error.
pub struct RuntimePlugin {
    inner: Box<dyn RuntimeInterface>,
}

impl RuntimeInterface for RuntimePlugin {
    delegate::delegate! {
        to self.inner {
            fn exit(&self) -> Result<()>;
            fn get_next_operations(&self) -> Result<Option<BatchOperation>>;
            fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()>;
            fn shot_end(&self) -> Result<()>;
            fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;
            fn qalloc(&self) -> Result<u64>;
            fn qfree(&self, qubit_id: u64) -> Result<()>;
            fn global_barrier(&self, sleep_ns: u64) -> Result<()>;
            fn local_barrier(&self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()>;
            fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()>;
            fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()>;
            fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()>;
            fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()>;
            fn measure(&self, qubit_id: u64) -> Result<u64>;
            fn measure_leaked(&self, qubit_id: u64) -> Result<u64>;
            fn reset(&self, qubit_id: u64) -> Result<()>;
            fn force_result(&self, result_id: u64) -> Result<()>;
            fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>>;
            fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>>;
            fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()>;
            fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()>;
            fn increment_future_refcount(&self, future_ref: u64) -> Result<()>;
            fn decrement_future_refcount(&self, future_ref: u64) -> Result<()>;
            fn custom_call(&self, custom_tag: u64, data: &[u8]) -> Result<u64>;
            fn simulate_delay(&self, delay_ns: u64) -> Result<()>;
        }
    }
}

struct ConcurrentRuntimePlugin {
    _interface: Arc<RuntimePluginInterface>,
    descriptor: RuntimePluginDescriptorV2,
    instance: RuntimeInstanceV2,
    retrieval: parking_lot::Mutex<()>,
    access: parking_lot::RwLock<()>,
}

// SAFETY: we only construct this wrapper for a v2 plugin, which promises to
// support concurrent operational calls. The Arc keeps its library loaded.
// Our locks keep lifecycle and metric calls from overlapping other calls and
// allow only one batch retrieval at a time.
unsafe impl Send for ConcurrentRuntimePlugin {}
unsafe impl Sync for ConcurrentRuntimePlugin {}

impl RuntimeInterface for ConcurrentRuntimePlugin {
    fn exit(&self) -> Result<()> {
        let _access = self.access.write();
        let Some(exit_fn) = self.descriptor.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("RuntimePlugin: exit failed")
        })
    }

    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        let _access = self.access.read();
        // Rust callers can ask for batches at the same time, but the C plugin
        // expects one consumer. Let only one retrieval through at a time.
        // The host still needs to execute the returned batches in order and
        // write back their results.
        let _retrieval = self.retrieval.lock();
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        check_errno(
            unsafe { (self.descriptor.get_next_operations_fn)(self.instance, ops) },
            || anyhow!("RuntimePlugin: get_next_operations failed"),
        )?;
        Ok(Some(batch_builder.finish()).filter(|b| !b.is_empty()))
    }

    fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()> {
        let _access = self.access.write();
        check_errno(
            unsafe { (self.descriptor.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("RuntimePlugin: shot_start failed"),
        )
    }

    fn shot_end(&self) -> Result<()> {
        let _access = self.access.write();
        check_errno(
            unsafe { (self.descriptor.shot_end_fn)(self.instance) },
            || anyhow!("RuntimePlugin: shot_end failed"),
        )
    }

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let _access = self.access.write();
        let Some(get_metrics_fn) = self.descriptor.get_metrics_fn else {
            return Ok(None);
        };
        read_raw_metric(|tag, data_type, data| unsafe {
            get_metrics_fn(self.instance, nth_metric, tag, data_type, data)
        })
    }

    fn qalloc(&self) -> Result<u64> {
        let _access = self.access.read();
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.descriptor.qalloc_fn)(self.instance, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&self, qubit_id: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.qfree_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: qfree failed"),
        )
    }

    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.global_barrier_fn)(self.instance, sleep_ns) },
            || anyhow!("RuntimePlugin: global barrier failed"),
        )
    }

    fn local_barrier(&self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let _access = self.access.read();
        let qubit_ids_len = qubit_ids.len() as u64;
        let qubit_ids_ptr = qubit_ids.as_ptr();
        check_errno(
            unsafe {
                (self.descriptor.local_barrier_fn)(
                    self.instance,
                    qubit_ids_ptr,
                    qubit_ids_len,
                    sleep_ns,
                )
            },
            || anyhow!("RuntimePlugin: local barrier failed"),
        )
    }

    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.rxy_gate_fn)(self.instance, qubit_id, theta, phi) },
            || anyhow!("RuntimePlugin: rxy_gate failed"),
        )
    }

    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.rzz_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta) },
            || anyhow!("RuntimePlugin: rzz_gate failed"),
        )
    }

    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.rz_gate_fn)(self.instance, qubit_id, theta) },
            || anyhow!("RuntimePlugin: rz_gate failed"),
        )
    }

    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe {
                (self.descriptor.rpp_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta, phi)
            },
            || anyhow!("RuntimePlugin: rpp_gate failed"),
        )
    }

    fn measure(&self, qubit_id: u64) -> Result<u64> {
        let _access = self.access.read();
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.descriptor.measure_fn)(self.instance, qubit_id, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        let _access = self.access.read();
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.measure_leaked_fn)(self.instance, qubit_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn reset(&self, qubit_id: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.reset_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: reset failed"),
        )
    }

    fn force_result(&self, result_id: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.force_result_fn)(self.instance, result_id) },
            || anyhow!("RuntimePlugin: force_result failed"),
        )
    }

    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let _access = self.access.read();
        let mut result = 0i8;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.get_bool_result_fn)(self.instance, result_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: get_bool_result failed"),
        )?;
        // The C interface uses 0 and 1 for ready values. Anything else means
        // the measurement is not ready yet.
        Ok(match result {
            0 => Some(false),
            1 => Some(true),
            _ => None,
        })
    }

    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let _access = self.access.read();
        let mut result = 0u64;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.get_u64_result_fn)(
                    self.instance,
                    result_id,
                    result_ref as *mut u64,
                )
            },
            || anyhow!("RuntimePlugin: get_u64_result failed"),
        )?;
        // The C interface reserves u64::MAX for a result that is not ready yet.
        Ok(match result {
            u64::MAX => None,
            n => Some(n),
        })
    }

    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.set_bool_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_bool_result failed"),
        )
    }

    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.set_u64_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&self, future_ref: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.increment_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&self, future_ref: u64) -> Result<()> {
        let _access = self.access.read();
        check_errno(
            unsafe { (self.descriptor.decrement_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: decrement_future_refcount failed"),
        )
    }

    fn custom_call(&self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let _access = self.access.read();
        let mut result = 0;
        let result_ref = &mut result;
        if let Some(custom_call_fn) = self.descriptor.custom_call_fn {
            check_errno(
                unsafe {
                    custom_call_fn(
                        self.instance,
                        custom_tag,
                        data.as_ptr() as *const ffi::c_void,
                        data.len(),
                        result_ref as *mut _,
                    )
                },
                || anyhow!("RuntimePlugin: custom_call failed"),
            )?;
            Ok(result)
        } else {
            Err(anyhow!(
                "RuntimePlugin: custom_call not supported by plugin"
            ))
        }
    }

    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        let _access = self.access.read();
        if let Some(simulate_delay_fn) = self.descriptor.simulate_delay_fn {
            check_errno(
                unsafe { simulate_delay_fn(self.instance, delay_ns) },
                || anyhow!("RuntimePlugin: simulate_delay failed"),
            )
        } else {
            Err(anyhow!(
                "RuntimePlugin: simulate_delay not supported by plugin"
            ))
        }
    }
}

#[cfg(all(test, unix))]
#[path = "plugin_tests.rs"]
mod access_tests;
