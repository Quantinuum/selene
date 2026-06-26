use super::{SimulatorAPIVersion, SimulatorInterface, SimulatorInterfaceFactory};
use crate::error_model::BatchResult;
use crate::gatewire::DynamicGateSet;
use crate::plugin::{
    NegotiateGatesetFn, PluginDescriptorV1, load_descriptor_v1, load_library, negotiate_gateset,
    require_callback, validate_descriptor_v1,
};
use crate::runtime::{BatchOperation, Operation};
use crate::utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs};
use anyhow::{Result, anyhow, bail};
use std::ffi::OsStr;
use std::ffi::c_char;
use std::sync::Arc;

pub type SimulatorInstance = *mut std::ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SimulatorPluginDescriptorV1 {
    pub struct_size: u64,
    pub api_version: u64,
    pub get_name_fn: Option<unsafe extern "C" fn() -> *const c_char>,
    pub init_fn: Option<
        unsafe extern "C" fn(
            handle: *mut SimulatorInstance,
            n_qubits: u64,
            argc: u32,
            argv: *const *const c_char,
        ) -> Errno,
    >,
    pub exit_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance) -> Errno>,
    pub shot_start_fn:
        Option<unsafe extern "C" fn(handle: SimulatorInstance, shot_id: u64, seed: u64) -> Errno>,
    pub shot_end_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance) -> Errno>,
    pub measure_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno>,
    pub postselect_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64, target_value: bool) -> Errno,
    >,
    pub reset_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno>,
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            nth_metric: u8,
            tag_out: *mut c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> Errno,
    >,
    pub dump_state_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            file: *const c_char,
            qubits: *const u64,
            n_qubits: u64,
        ) -> Errno,
    >,
    pub gate_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, data: *const u8, len: usize) -> Errno,
    >,
    pub negotiate_gateset_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            input: *const u8,
            input_len: usize,
            output: *mut u8,
            output_len: usize,
            written: *mut usize,
        ) -> Errno,
    >,
}

impl PluginDescriptorV1 for SimulatorPluginDescriptorV1 {
    const KIND: &'static str = "Simulator";

    fn struct_size(&self) -> u64 {
        self.struct_size
    }

    fn api_version(&self) -> u64 {
        self.api_version
    }
}

/// Provides a simulation engine backend that controls a plugin, in the form of a shared object.
/// Plugins should expose a struct of type [SimulatorPluginDescriptorV1] as the symbol
/// selene_simulator_plugin_descriptor_v1, or a function selene_simulator_get_plugin_descriptor_v1
/// that returns a pointer to such a struct. The descriptor provides function pointers for the
/// plugin's implementation of the simulator interface, as well as metadata about the plugin and
/// the ABI it implements.
///
/// Plugins allow implementations of simulation backends to be written and
/// distributed independently of selene. Users should be cautious about the plugins they use,
/// as it is possible that mistakes or malicious code could be present in the plugin, and, as
/// with all external libraries, due diligence must be done to verify the source and the
/// trustworthiness of the provider.
pub struct SimulatorPluginInterface {
    _lib: libloading::Library,
    name: String,
    init_fn: unsafe extern "C" fn(
        handle: *mut SimulatorInstance,
        n_qubits: u64,
        argc: u32,
        argv: *const *const c_char,
    ) -> Errno,
    exit_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance) -> Errno>,
    shot_start_fn:
        unsafe extern "C" fn(handle: SimulatorInstance, shot_id: u64, seed: u64) -> Errno,
    shot_end_fn: unsafe extern "C" fn(handle: SimulatorInstance) -> Errno,
    negotiate_gateset_fn: Option<NegotiateGatesetFn<SimulatorInstance>>,
    gate_fn: unsafe extern "C" fn(handle: SimulatorInstance, data: *const u8, len: usize) -> Errno,
    measure_fn: unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno,
    postselect_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64, target_value: bool) -> Errno,
    >,
    reset_fn: unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno,
    get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            nth_metric: u8,
            tag_out: *mut c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> Errno,
    >,
    dump_state_fn: unsafe extern "C" fn(
        handle: SimulatorInstance,
        file: *const c_char,
        qubits: *const u64,
        n_qubits: u64,
    ) -> Errno,
}

impl SimulatorPluginInterface {
    pub fn new_from_file(plugin_file: impl AsRef<OsStr>) -> Result<Arc<Self>> {
        let lib = load_library("simulator", &plugin_file)?;
        let descriptor = unsafe {
            load_descriptor_v1::<SimulatorPluginDescriptorV1>(
                &lib,
                &plugin_file,
                b"selene_simulator_plugin_descriptor_v1",
                b"selene_simulator_get_plugin_descriptor_v1",
            )
        }?;
        validate_descriptor_v1(&descriptor, |api_version| {
            SimulatorAPIVersion::from(api_version).validate()
        })?;
        let name = unsafe {
            descriptor
                .get_name_fn
                .and_then(|f| f().as_ref())
                .map_or_else(
                    || "Unknown".to_string(),
                    |name| {
                        std::ffi::CStr::from_ptr(name)
                            .to_string_lossy()
                            .into_owned()
                    },
                )
        };
        Ok(Arc::new(Self {
            _lib: lib,
            name,
            init_fn: require_callback("Simulator", "init_fn", descriptor.init_fn)?,
            exit_fn: descriptor.exit_fn,
            shot_start_fn: require_callback(
                "Simulator",
                "shot_start_fn",
                descriptor.shot_start_fn,
            )?,
            shot_end_fn: require_callback("Simulator", "shot_end_fn", descriptor.shot_end_fn)?,
            negotiate_gateset_fn: descriptor.negotiate_gateset_fn,
            gate_fn: require_callback("Simulator", "gate_fn", descriptor.gate_fn)?,
            measure_fn: require_callback("Simulator", "measure_fn", descriptor.measure_fn)?,
            postselect_fn: descriptor.postselect_fn,
            reset_fn: require_callback("Simulator", "reset_fn", descriptor.reset_fn)?,
            get_metrics_fn: descriptor.get_metrics_fn,
            dump_state_fn: require_callback(
                "Simulator",
                "dump_state_fn",
                descriptor.dump_state_fn,
            )?,
        }))
    }
}

pub struct SimulatorPlugin {
    interface: Arc<SimulatorPluginInterface>,
    instance: SimulatorInstance,
}

impl SimulatorPlugin {
    fn gate(&mut self, gate: &crate::gatewire::OwnedGateInstance) -> Result<()> {
        let data = gate.serialize();
        check_errno(
            unsafe { (self.interface.gate_fn)(self.instance, data.as_ptr(), data.len()) },
            || anyhow!("SimulatorPlugin({}): gate failed", &self.interface.name),
        )
    }

    fn measure(&mut self, qubit: u64) -> Result<bool> {
        let result = unsafe { (self.interface.measure_fn)(self.instance, qubit) };
        match result {
            0 => Ok(false),
            1 => Ok(true),
            _ => Err(anyhow!(
                "SimulatorPlugin({}): measure failed",
                &self.interface.name
            )),
        }
    }

    fn reset(&mut self, qubit: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit) },
            || anyhow!("SimulatorPlugin({}): reset failed", &self.interface.name),
        )
    }
}

impl SimulatorInterfaceFactory for SimulatorPluginInterface {
    type Interface = SimulatorPlugin;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe { (self.init_fn)(&mut instance, n_qubits, argc, argv) },
                || anyhow!("SimulatorPlugin: init failed"),
            )
        })?;
        Ok(Box::new(SimulatorPlugin {
            interface: self.clone(),
            instance,
        }))
    }
}

impl SimulatorInterface for SimulatorPlugin {
    fn exit(&mut self) -> Result<()> {
        let Some(exit_fn) = self.interface.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("SimulatorPlugin: exit failed")
        })
    }
    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            || {
                anyhow!(
                    "SimulatorPlugin({}): shot_start failed",
                    &self.interface.name
                )
            },
        )
    }
    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("SimulatorPlugin({}): shot_end failed", &self.interface.name),
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        let plugin = format!("SimulatorPlugin({})", &self.interface.name);
        negotiate_gateset(
            &plugin,
            self.instance,
            self.interface.negotiate_gateset_fn,
            gateset,
        )
    }
    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::Gate { gate } => self.gate(&gate)?,
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => results.set_bool_result(result_id, self.measure(qubit_id)?),
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => results.set_u64_result(result_id, self.measure(qubit_id)? as u64),
                Operation::Reset { qubit_id } => self.reset(qubit_id)?,
                Operation::Custom { .. } => {}
            }
        }
        Ok(results)
    }
    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        let Some(postselect_fn) = self.interface.postselect_fn else {
            bail!("The chosen simulator does not support postselection");
        };
        check_errno(
            unsafe { postselect_fn(self.instance, qubit, target_value) },
            || {
                anyhow!(
                    "SimulatorPlugin({}): postselect failed",
                    &self.interface.name
                )
            },
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
    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        let qubit_count = qubits.len() as u64;
        let filename = file.to_str().ok_or_else(|| {
            anyhow!(
                "SimulatorPlugin({}): dump_state failed: invalid filename: {}",
                &self.interface.name,
                file.to_string_lossy()
            )
        })?;
        let safe_filename = std::ffi::CString::new(filename).unwrap();
        check_errno(
            unsafe {
                (self.interface.dump_state_fn)(
                    self.instance,
                    safe_filename.as_ptr(),
                    qubits.as_ptr(),
                    qubit_count,
                )
            },
            || {
                anyhow!(
                    "SimulatorPlugin({}): dump_state failed",
                    &self.interface.name
                )
            },
        )
    }
}
