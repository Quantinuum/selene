pub use crate::operation::Operation;
pub use crate::operation::plugin::{
    BatchBuilder, BatchExtractor, RuntimeExtractOperationHandle, RuntimeExtractOperationInstance,
    RuntimeExtractOperationInterface, RuntimeGetOperationHandle, RuntimeGetOperationInstance,
    RuntimeGetOperationInterface,
};
use crate::utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs};

use super::{BatchOperation, RuntimeAPIVersion, RuntimeInterface, RuntimeInterfaceFactory};
use anyhow::{Result, anyhow};
use libloading;
use std::ffi::OsStr;
use std::{ffi, sync::Arc};

pub type RuntimeInstance = *mut ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimePluginDescriptorV1 {
    pub struct_size: u64,
    pub api_version: u64,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    pub get_next_operations_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, ops: RuntimeGetOperationHandle) -> Errno,
    pub shot_start_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstance) -> Errno,
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
    pub custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    pub simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
}

/// Provides a runtime engine backend that controls a plugin, in the form of a shared object.
/// The plugin must expose a struct of type [RuntimePluginDescriptorV1], either as a symbol named
/// `selene_runtime_plugin_descriptor_v1` or as a pointer returned by a function named
/// `selene_runtime_get_plugin_descriptor_v1`.
///
/// Users should be cautious about the plugins they use, as it is possible that mistakes
/// or malicious code could be present in the plugin, and as with all external libraries, due
/// dilligence must be done to verify the source and the trustworthiness of the provider.
pub struct RuntimePluginInterface {
    _lib: libloading::Library,
    init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    get_next_operations_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, ops: RuntimeGetOperationHandle) -> Errno,
    shot_start_fn: unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno,
    shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstance) -> Errno,
    get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    qalloc_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno,
    qfree_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno,
    local_barrier_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno,
    global_barrier_fn: unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno,
    rxy_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    rzz_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno,
    rz_gate_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64) -> Errno,
    rpp_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    measure_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    measure_leaked_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    reset_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno,
    force_result_fn: unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    get_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno,
    get_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno,
    set_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: bool) -> Errno,
    set_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: u64) -> Errno,
    increment_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    decrement_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
}

impl RuntimePluginInterface {
    /// Loads a runtime plugin from a file.
    pub fn new_from_file(plugin_file: impl AsRef<OsStr>) -> Result<Arc<Self>> {
        let lib = unsafe { libloading::Library::new(plugin_file.as_ref()) }.map_err(|e| {
            anyhow!(
                "Failed to load runtime plugin: {}. Error: {}",
                plugin_file.as_ref().to_string_lossy(),
                e
            )
        })?;
        let descriptor = unsafe {
            lib.get::<RuntimePluginDescriptorV1>(b"selene_runtime_plugin_descriptor_v1")
                .ok()
                .map(|d| *d)
                .or_else(|| {
                    lib.get::<unsafe extern "C" fn() -> *const RuntimePluginDescriptorV1>(
                        b"selene_runtime_get_plugin_descriptor_v1",
                    )
                    .ok()
                    .and_then(|f| {
                        let ptr = f();
                        if ptr.is_null() { None } else { Some(*ptr) }
                    })
                })
        };
        let descriptor = descriptor.ok_or_else(|| {
            anyhow!(
                "Runtime plugin '{}' does not expose either selene_runtime_plugin_descriptor_v1 or selene_runtime_get_plugin_descriptor_v1",
                plugin_file.as_ref().to_string_lossy()
            )
        })?;
        let version: RuntimeAPIVersion = descriptor.api_version.into();
        version.validate()?;
        if descriptor.struct_size < core::mem::size_of::<RuntimePluginDescriptorV1>() as u64 {
            return Err(anyhow!("Runtime plugin descriptor is too small for v1 ABI"));
        }
        Ok(Arc::new(Self {
            _lib: lib,
            init_fn: descriptor.init_fn,
            exit_fn: descriptor.exit_fn,
            get_next_operations_fn: descriptor.get_next_operations_fn,
            shot_start_fn: descriptor.shot_start_fn,
            shot_end_fn: descriptor.shot_end_fn,
            get_metrics_fn: descriptor.get_metrics_fn,
            qalloc_fn: descriptor.qalloc_fn,
            qfree_fn: descriptor.qfree_fn,
            local_barrier_fn: descriptor.local_barrier_fn,
            global_barrier_fn: descriptor.global_barrier_fn,
            rxy_gate_fn: descriptor.rxy_gate_fn,
            rzz_gate_fn: descriptor.rzz_gate_fn,
            rz_gate_fn: descriptor.rz_gate_fn,
            rpp_gate_fn: descriptor.rpp_gate_fn,
            measure_fn: descriptor.measure_fn,
            measure_leaked_fn: descriptor.measure_leaked_fn,
            reset_fn: descriptor.reset_fn,
            force_result_fn: descriptor.force_result_fn,
            get_bool_result_fn: descriptor.get_bool_result_fn,
            get_u64_result_fn: descriptor.get_u64_result_fn,
            set_bool_result_fn: descriptor.set_bool_result_fn,
            set_u64_result_fn: descriptor.set_u64_result_fn,
            increment_future_refcount_fn: descriptor.increment_future_refcount_fn,
            decrement_future_refcount_fn: descriptor.decrement_future_refcount_fn,
            custom_call_fn: descriptor.custom_call_fn,
            simulate_delay_fn: descriptor.simulate_delay_fn,
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
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe { (self.init_fn)(&mut instance, n_qubits, start.into(), argc, argv) },
                || anyhow!("RuntimePluginInterface: init failed"),
            )
        })?;
        Ok(Box::new(RuntimePlugin {
            interface: self.clone(),
            instance,
        }))
    }
}

pub struct RuntimePlugin {
    interface: Arc<RuntimePluginInterface>,
    instance: RuntimeInstance,
}

impl RuntimeInterface for RuntimePlugin {
    fn exit(&mut self) -> Result<()> {
        let Some(exit_fn) = self.interface.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("RuntimePlugin: exit failed")
        })
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        check_errno(
            unsafe { (self.interface.get_next_operations_fn)(self.instance, ops) },
            || anyhow!("RuntimePlugin: get_next_operations failed"),
        )?;
        Ok(Some(batch_builder.finish()).filter(|b| !b.is_empty()))
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("RuntimePlugin: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("RuntimePlugin: shot_end failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(get_metrics_fn) = self.interface.get_metrics_fn else {
            return Ok(None);
        };
        read_raw_metric(|tag, data_type, data| unsafe {
            get_metrics_fn(self.instance, nth_metric, tag, data_type, data)
        })
    }

    fn qalloc(&mut self) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.interface.qalloc_fn)(self.instance, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.qfree_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: qfree failed"),
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.global_barrier_fn)(self.instance, sleep_ns) },
            || anyhow!("RuntimePlugin: global barrier failed"),
        )
    }

    fn local_barrier(&mut self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let qubit_ids_len = qubit_ids.len() as u64;
        let qubit_ids_ptr = qubit_ids.as_ptr();
        check_errno(
            unsafe {
                (self.interface.local_barrier_fn)(
                    self.instance,
                    qubit_ids_ptr,
                    qubit_ids_len,
                    sleep_ns,
                )
            },
            || anyhow!("RuntimePlugin: local barrier failed"),
        )
    }

    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rxy_gate_fn)(self.instance, qubit_id, theta, phi) },
            || anyhow!("RuntimePlugin: rxy_gate failed"),
        )
    }

    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rzz_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta) },
            || anyhow!("RuntimePlugin: rzz_gate failed"),
        )
    }

    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rz_gate_fn)(self.instance, qubit_id, theta) },
            || anyhow!("RuntimePlugin: rz_gate failed"),
        )
    }

    fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.interface.rpp_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta, phi)
            },
            || anyhow!("RuntimePlugin: rpp_gate failed"),
        )
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.interface.measure_fn)(self.instance, qubit_id, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.measure_leaked_fn)(self.instance, qubit_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.force_result_fn)(self.instance, result_id) },
            || anyhow!("RuntimePlugin: force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = 0i8;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.get_bool_result_fn)(self.instance, result_id, result_ref as *mut _)
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

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        let mut result = 0u64;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.get_u64_result_fn)(self.instance, result_id, result_ref as *mut u64)
            },
            || anyhow!("RuntimePlugin: get_u64_result failed"),
        )?;
        // TODO document this
        Ok(match result {
            u64::MAX => None,
            n => Some(n),
        })
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        check_errno(
            unsafe { (self.interface.set_bool_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.set_u64_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.increment_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.decrement_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: decrement_future_refcount failed"),
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        if let Some(custom_call_fn) = self.interface.custom_call_fn {
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

    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        if let Some(simulate_delay_fn) = self.interface.simulate_delay_fn {
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
