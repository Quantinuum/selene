use crate::gatewire::{DynamicGateSet, OwnedGateInstance};
pub use crate::operation::Operation;
pub use crate::operation::plugin::{
    BatchBuilder, BatchExtractor, RuntimeExtractOperationHandle, RuntimeExtractOperationInstance,
    RuntimeExtractOperationInterface, RuntimeGetOperationHandle, RuntimeGetOperationInstance,
    RuntimeGetOperationInterface,
};
use crate::plugin::{
    LastErrorFn, NegotiateGatesetFn, PluginDescriptorHeaderV1, PluginDescriptorV1,
    check_plugin_errno, load_descriptor_v1, load_library, negotiate_gateset, read_plugin_name,
    require_callback, validate_descriptor_v1,
};
use crate::utils::{MetricValue, read_raw_metric, with_strings_to_cargs};

use super::{BatchOperation, RuntimeAPIVersion, RuntimeInterface, RuntimeInterfaceFactory};
use anyhow::{Result, anyhow};
use std::ffi::OsStr;
use std::{ffi, sync::Arc};

pub type RuntimeInstance = *mut ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimePluginDescriptorV1 {
    pub header: PluginDescriptorHeaderV1,
    pub init_fn: Option<
        unsafe extern "C" fn(
            handle: *mut RuntimeInstance,
            n_qubits: u64,
            start: u64,
            argc: u32,
            argv: *const *const ffi::c_char,
        ) -> Errno,
    >,
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    pub get_next_operations_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, ops: RuntimeGetOperationHandle) -> Errno,
    >,
    pub shot_start_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno>,
    pub shot_end_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    pub qalloc_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno>,
    pub qfree_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno>,
    pub local_barrier_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            qubits: *const u64,
            qubits_len: u64,
            sleep_ns: u64,
        ) -> Errno,
    >,
    pub global_barrier_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno>,
    pub measure_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    >,
    pub measure_leaked_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    >,
    pub reset_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno>,
    pub force_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
    pub get_bool_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno>,
    pub get_u64_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno>,
    pub set_bool_result_fn: Option<
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: bool) -> Errno,
    >,
    pub set_u64_result_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: u64) -> Errno>,
    pub increment_future_refcount_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
    pub decrement_future_refcount_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno>,
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
    pub gate_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, data: *const u8, len: usize) -> Errno>,
    pub negotiate_gateset_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            input: *const u8,
            input_len: usize,
            output: *mut u8,
            output_len: usize,
            written: *mut usize,
        ) -> Errno,
    >,
}

impl PluginDescriptorV1 for RuntimePluginDescriptorV1 {
    const KIND: &'static str = "Runtime";

    fn header(&self) -> &PluginDescriptorHeaderV1 {
        &self.header
    }
}

/// Provides a runtime engine backend that controls a plugin, in the form of a shared object.
/// The plugin must expose a struct of type [RuntimePluginDescriptorV1], either as a symbol named
/// `selene_runtime_plugin_descriptor_v1` or as a pointer returned by a function named
/// `selene_runtime_get_plugin_descriptor_v1`.
///
/// Users should be cautious about the plugins they use, as it is possible that mistakes
/// or malicious code could be present in the plugin, and as with all external libraries, due
/// diligence must be done to verify the source and the trustworthiness of the provider.
pub struct RuntimePluginInterface {
    _lib: libloading::Library,
    last_error_fn: LastErrorFn,
    name: String,
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
    gate_fn: unsafe extern "C" fn(handle: RuntimeInstance, data: *const u8, len: usize) -> Errno,
    negotiate_gateset_fn: NegotiateGatesetFn<RuntimeInstance>,
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
        let lib = load_library("runtime", &plugin_file)?;
        let descriptor = unsafe {
            load_descriptor_v1::<RuntimePluginDescriptorV1>(
                &lib,
                &plugin_file,
                b"selene_runtime_plugin_descriptor_v1",
                b"selene_runtime_get_plugin_descriptor_v1",
            )
        }?;
        validate_descriptor_v1(&descriptor, |api_version| {
            RuntimeAPIVersion::from(api_version).validate()
        })?;
        let name = read_plugin_name("Runtime", descriptor.header.get_name_fn)?;
        Ok(Arc::new(Self {
            _lib: lib,
            last_error_fn: descriptor.header.last_error_fn,
            name,
            init_fn: require_callback("Runtime", "init_fn", descriptor.init_fn)?,
            exit_fn: descriptor.exit_fn,
            get_next_operations_fn: require_callback(
                "Runtime",
                "get_next_operations_fn",
                descriptor.get_next_operations_fn,
            )?,
            shot_start_fn: require_callback("Runtime", "shot_start_fn", descriptor.shot_start_fn)?,
            shot_end_fn: require_callback("Runtime", "shot_end_fn", descriptor.shot_end_fn)?,
            get_metrics_fn: descriptor.get_metrics_fn,
            qalloc_fn: require_callback("Runtime", "qalloc_fn", descriptor.qalloc_fn)?,
            qfree_fn: require_callback("Runtime", "qfree_fn", descriptor.qfree_fn)?,
            local_barrier_fn: require_callback(
                "Runtime",
                "local_barrier_fn",
                descriptor.local_barrier_fn,
            )?,
            global_barrier_fn: require_callback(
                "Runtime",
                "global_barrier_fn",
                descriptor.global_barrier_fn,
            )?,
            gate_fn: require_callback("Runtime", "gate_fn", descriptor.gate_fn)?,
            negotiate_gateset_fn: require_callback(
                "Runtime",
                "negotiate_gateset_fn",
                descriptor.negotiate_gateset_fn,
            )?,
            measure_fn: require_callback("Runtime", "measure_fn", descriptor.measure_fn)?,
            measure_leaked_fn: require_callback(
                "Runtime",
                "measure_leaked_fn",
                descriptor.measure_leaked_fn,
            )?,
            reset_fn: require_callback("Runtime", "reset_fn", descriptor.reset_fn)?,
            force_result_fn: require_callback(
                "Runtime",
                "force_result_fn",
                descriptor.force_result_fn,
            )?,
            get_bool_result_fn: require_callback(
                "Runtime",
                "get_bool_result_fn",
                descriptor.get_bool_result_fn,
            )?,
            get_u64_result_fn: require_callback(
                "Runtime",
                "get_u64_result_fn",
                descriptor.get_u64_result_fn,
            )?,
            set_bool_result_fn: require_callback(
                "Runtime",
                "set_bool_result_fn",
                descriptor.set_bool_result_fn,
            )?,
            set_u64_result_fn: require_callback(
                "Runtime",
                "set_u64_result_fn",
                descriptor.set_u64_result_fn,
            )?,
            increment_future_refcount_fn: require_callback(
                "Runtime",
                "increment_future_refcount_fn",
                descriptor.increment_future_refcount_fn,
            )?,
            decrement_future_refcount_fn: require_callback(
                "Runtime",
                "decrement_future_refcount_fn",
                descriptor.decrement_future_refcount_fn,
            )?,
            custom_call_fn: descriptor.custom_call_fn,
            simulate_delay_fn: descriptor.simulate_delay_fn,
        }))
    }
}

impl RuntimeInterfaceFactory for RuntimePluginInterface {
    type Interface = RuntimePlugin;

    fn name(&self) -> &str {
        &self.name
    }

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_plugin_errno(
                unsafe { (self.init_fn)(&mut instance, n_qubits, start.into(), argc, argv) },
                self.last_error_fn,
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
        check_plugin_errno(
            unsafe { exit_fn(self.instance) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: exit failed"),
        )
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        check_plugin_errno(
            unsafe { (self.interface.get_next_operations_fn)(self.instance, ops) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: get_next_operations failed"),
        )?;
        Ok(Some(batch_builder.finish()).filter(|b| !b.is_empty()))
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: shot_end failed"),
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        negotiate_gateset(
            "RuntimePlugin",
            self.instance,
            self.interface.negotiate_gateset_fn,
            self.interface.last_error_fn,
            gateset,
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
        check_plugin_errno(
            unsafe { (self.interface.qalloc_fn)(self.instance, result_ref as *mut _) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.qfree_fn)(self.instance, qubit_id) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: qfree failed"),
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.global_barrier_fn)(self.instance, sleep_ns) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: global barrier failed"),
        )
    }

    fn local_barrier(&mut self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let qubit_ids_len = qubit_ids.len() as u64;
        let qubit_ids_ptr = qubit_ids.as_ptr();
        check_plugin_errno(
            unsafe {
                (self.interface.local_barrier_fn)(
                    self.instance,
                    qubit_ids_ptr,
                    qubit_ids_len,
                    sleep_ns,
                )
            },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: local barrier failed"),
        )
    }

    fn gate(&mut self, gate: &OwnedGateInstance) -> Result<()> {
        let data = gate.serialize();
        check_plugin_errno(
            unsafe { (self.interface.gate_fn)(self.instance, data.as_ptr(), data.len()) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: gate failed"),
        )
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_plugin_errno(
            unsafe { (self.interface.measure_fn)(self.instance, qubit_id, result_ref as *mut _) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_plugin_errno(
            unsafe {
                (self.interface.measure_leaked_fn)(self.instance, qubit_id, result_ref as *mut _)
            },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit_id) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.force_result_fn)(self.instance, result_id) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = 0i8;
        let result_ref = &mut result;
        check_plugin_errno(
            unsafe {
                (self.interface.get_bool_result_fn)(self.instance, result_id, result_ref as *mut _)
            },
            self.interface.last_error_fn,
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
        check_plugin_errno(
            unsafe {
                (self.interface.get_u64_result_fn)(self.instance, result_id, result_ref as *mut u64)
            },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: get_u64_result failed"),
        )?;
        // TODO document this
        Ok(match result {
            u64::MAX => None,
            n => Some(n),
        })
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.set_bool_result_fn)(self.instance, result_id, result) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.set_u64_result_fn)(self.instance, result_id, result) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.increment_future_refcount_fn)(self.instance, future_ref) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.decrement_future_refcount_fn)(self.instance, future_ref) },
            self.interface.last_error_fn,
            || anyhow!("RuntimePlugin: decrement_future_refcount failed"),
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        if let Some(custom_call_fn) = self.interface.custom_call_fn {
            check_plugin_errno(
                unsafe {
                    custom_call_fn(
                        self.instance,
                        custom_tag,
                        data.as_ptr() as *const ffi::c_void,
                        data.len(),
                        result_ref as *mut _,
                    )
                },
                self.interface.last_error_fn,
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
            check_plugin_errno(
                unsafe { simulate_delay_fn(self.instance, delay_ns) },
                self.interface.last_error_fn,
                || anyhow!("RuntimePlugin: simulate_delay failed"),
            )
        } else {
            Err(anyhow!(
                "RuntimePlugin: simulate_delay not supported by plugin"
            ))
        }
    }
}
