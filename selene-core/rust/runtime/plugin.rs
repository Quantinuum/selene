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

/// Shared opaque instance handle. Constness does not imply immutable state;
/// the plugin synchronizes mutation according to the descriptor contract.
pub type RuntimeInstanceV2 = *const ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
/// Concurrent runtime descriptor for API 0.4.x.
///
/// Function pointer fields documented as optional may be null. All other
/// function pointer fields must be populated.
///
/// # Concurrency and safety
///
/// All operational functions must be safe to call concurrently on the same
/// instance and across instances. This includes allocation, gates, measurements,
/// barriers, delays, custom calls, forcing, result access/publication, and reference
/// counts. The plugin is responsible for synchronizing its mutable state.
///
/// One consumer retrieves and executes batches in order and publishes results;
/// retrieval may overlap user calls. After force_result_fn succeeds, draining must
/// expose the work needed for that result unless already dispatched or resolved.
/// Concurrent submissions must not indefinitely postpone it. Executing the work
/// and publishing its results makes the result getter report availability; an
/// empty batch alone does not prove a dispatched result has been published.
///
/// Initialization completes before sharing the instance. The caller excludes all
/// other calls during shot_start_fn, shot_end_fn, and exit_fn, and throughout an
/// entire get_metrics_fn enumeration. Only these calls may access state exclusively.
/// No runtime lock may block the consumer while a user waits for a result.
///
/// Handles must remain live throughout calls. Output buffers must be writable and
/// exclusively accessible for the call; inputs must remain readable and unmodified.
/// The operation callback handle and its buffers are borrowed only for retrieval
/// and must not be retained or invoked concurrently by the plugin.
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
/// Legacy runtime descriptor for API 0.3.x. Calls on an instance must be serialized.
/// The host initializes, calls, and destroys each instance on one owning thread.
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

/// Loads a runtime shared library. V2 / API 0.4.x plugins are called directly;
/// V1 / API 0.3.x plugins run on an owning thread through a compatibility adapter.
/// A descriptor may be exported as data or through its corresponding getter.
/// V2 is preferred; an invalid advertised v2 interface is an error, not a reason
/// to fall back to v1. Both variants retain the library for the instance lifetime.
/// Plugins execute native code and must be trusted by the caller.
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

/// A loaded runtime instance implementing the current trait for either ABI.
///
/// Calls to legacy instances block for a reply from their owning thread. Slice
/// inputs are copied; returned batches own their operations and buffers.
/// Legacy cleanup runs at most once, on explicit exit or when this wrapper is
/// dropped; subsequent calls after explicit exit return an error.
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

// SAFETY: only v2 descriptors with the concurrent API contract reach this type.
// The Arc keeps the library loaded; locks exclude lifecycle/metric calls and
// serialize retrieval. Other operational calls rely on the plugin contract.
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
        // Safe shared Rust callers can race retrievals. Serialize the foreign
        // calls to uphold the ABI's single-consumer requirement. The host must
        // additionally preserve execution/publication order after retrieval.
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
        // TODO document this
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
        // TODO document this
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
