use super::{SimulatorAPIVersion, SimulatorInterface, SimulatorInterfaceFactory};
use crate::error_model::BatchResult;
use crate::runtime::{BatchOperation, Operation};
use crate::utils::{
    MetricValue, check_errno, load_plugin_descriptor, read_raw_metric, with_strings_to_cargs,
};
use anyhow::{Result, anyhow, bail};
use libloading;
use std::ffi::OsStr;
use std::ffi::c_char;
use std::sync::Arc;

pub type SimulatorInstance = *mut std::ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
/// The C ABI descriptor exported by a simulator plugin.
///
/// Function pointer fields documented as optional may be null. All other
/// function pointer fields must be populated.
pub struct SimulatorPluginDescriptorV1 {
    /// Must be `sizeof(SeleneSimulatorPluginDescriptorV1)`.
    pub struct_size: u64,
    /// Must be `SELENE_SIMULATOR_CURRENT_API_VERSION`.
    pub api_version: u64,
    /// Optional. Returns a static, null-terminated plugin name.
    pub get_name_fn: Option<unsafe extern "C" fn() -> *const c_char>,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut SimulatorInstance,
        n_qubits: u64,
        argc: u32,
        argv: *const *const c_char,
    ) -> Errno,
    /// Optional. If null, no plugin-specific cleanup is performed.
    pub exit_fn: Option<unsafe extern "C" fn(handle: SimulatorInstance) -> Errno>,
    pub shot_start_fn:
        unsafe extern "C" fn(handle: SimulatorInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: SimulatorInstance) -> Errno,
    /// Optional. A null pointer means the operation is unsupported.
    pub rxy_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    >,
    /// Optional. A null pointer means the operation is unsupported.
    pub rz_fn:
        Option<unsafe extern "C" fn(handle: SimulatorInstance, qubit0: u64, theta: f64) -> Errno>,
    /// Optional. A null pointer means the operation is unsupported.
    pub rzz_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
        ) -> Errno,
    >,
    /// Optional. A null pointer means the operation is unsupported.
    pub rpp_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
            phi: f64,
        ) -> Errno,
    >,
    pub measure_fn: unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno,
    /// Optional. A null pointer means postselection is unsupported.
    pub postselect_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64, target_value: bool) -> Errno,
    >,
    pub reset_fn: unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64) -> Errno,
    /// Optional. A null pointer means the plugin exposes no metrics.
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            nth_metric: u8,
            tag_out: *mut c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> Errno,
    >,
    pub dump_state_fn: unsafe extern "C" fn(
        handle: SimulatorInstance,
        file: *const c_char,
        qubits: *const u64,
        n_qubits: u64,
    ) -> Errno,
}

/// Provides a simulation engine backend that controls a plugin, in the form of a shared object.
/// Plugins should expose a struct of type [SimulatorPluginDescriptorV1] as the symbol
/// selene_simulator_plugin_descriptor_v1, or a function selene_simulator_get_plugin_descriptor_v1
/// that returns a pointer to such a struct. The descriptor provides function pointers for the
/// plugin's implementation of the simulator interface, as well as metadata about the plugin and
/// the ABI it implements.
///
/// Plugins are used allow implementations of simulation backends to be written and
/// distributed independently of selene. Users should be cautious about the plugins they use,
/// as it is possible that mistakes or malicious code could be present in the plugin, and, as
/// with all external libraries, due dilligence must be done to verify the source and the
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
    rxy_fn: Option<
        unsafe extern "C" fn(handle: SimulatorInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    >,
    rz_fn:
        Option<unsafe extern "C" fn(handle: SimulatorInstance, qubit0: u64, theta: f64) -> Errno>,
    rzz_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
        ) -> Errno,
    >,
    rpp_fn: Option<
        unsafe extern "C" fn(
            handle: SimulatorInstance,
            qubit0: u64,
            qubit1: u64,
            theta: f64,
            phi: f64,
        ) -> Errno,
    >,
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
        let lib = unsafe { libloading::Library::new(plugin_file.as_ref()) }.map_err(|e| {
            anyhow!(
                "Failed to load simulator plugin: {}. Error: {}",
                plugin_file.as_ref().to_string_lossy(),
                e
            )
        })?;
        let descriptor = unsafe {
            load_plugin_descriptor::<SimulatorPluginDescriptorV1>(
                &lib,
                b"selene_simulator_plugin_descriptor_v1",
                b"selene_simulator_get_plugin_descriptor_v1",
                "Simulator",
            )?
        };
        let descriptor = descriptor.ok_or_else(|| {
            anyhow!(
                "Simulator plugin '{}' does not expose either selene_simulator_plugin_descriptor_v1 or selene_simulator_get_plugin_descriptor_v1",
                plugin_file.as_ref().to_string_lossy()
            )
        })?;
        let version: SimulatorAPIVersion = descriptor.api_version.into();
        version.validate()?;
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
            init_fn: descriptor.init_fn,
            exit_fn: descriptor.exit_fn,
            shot_start_fn: descriptor.shot_start_fn,
            shot_end_fn: descriptor.shot_end_fn,
            rxy_fn: descriptor.rxy_fn,
            rz_fn: descriptor.rz_fn,
            rzz_fn: descriptor.rzz_fn,
            rpp_fn: descriptor.rpp_fn,
            measure_fn: descriptor.measure_fn,
            postselect_fn: descriptor.postselect_fn,
            reset_fn: descriptor.reset_fn,
            get_metrics_fn: descriptor.get_metrics_fn,
            dump_state_fn: descriptor.dump_state_fn,
        }))
    }
}

pub struct SimulatorPlugin {
    interface: Arc<SimulatorPluginInterface>,
    instance: SimulatorInstance,
}

impl SimulatorPlugin {
    fn rxy(&mut self, qubit: u64, theta: f64, phi: f64) -> Result<()> {
        let Some(rxy_fn) = self.interface.rxy_fn else {
            bail!(
                "SimulatorPlugin({}): The chosen simulator does not support the RXY gate",
                &self.interface.name
            );
        };
        check_errno(unsafe { rxy_fn(self.instance, qubit, theta, phi) }, || {
            anyhow!("SimulatorPlugin({}): rxy failed", &self.interface.name)
        })
    }

    fn rz(&mut self, qubit: u64, theta: f64) -> Result<()> {
        let Some(rz_fn) = self.interface.rz_fn else {
            bail!(
                "SimulatorPlugin({}): The chosen simulator does not support the RZ gate",
                &self.interface.name
            );
        };
        check_errno(unsafe { rz_fn(self.instance, qubit, theta) }, || {
            anyhow!("SimulatorPlugin({}): rz failed", &self.interface.name)
        })
    }

    fn rzz(&mut self, qubit1: u64, qubit2: u64, theta: f64) -> Result<()> {
        let Some(rzz_fn) = self.interface.rzz_fn else {
            bail!(
                "SimulatorPlugin({}): The chosen simulator does not support the RZZ gate",
                &self.interface.name
            );
        };
        check_errno(
            unsafe { rzz_fn(self.instance, qubit1, qubit2, theta) },
            || anyhow!("SimulatorPlugin({}): rzz failed", &self.interface.name),
        )
    }

    fn rpp(&mut self, qubit1: u64, qubit2: u64, theta: f64, phi: f64) -> Result<()> {
        let Some(rpp_fn) = self.interface.rpp_fn else {
            bail!(
                "SimulatorPlugin({}): The chosen simulator does not support the RPP gate",
                &self.interface.name
            );
        };
        check_errno(
            unsafe { rpp_fn(self.instance, qubit1, qubit2, theta, phi) },
            || anyhow!("SimulatorPlugin({}): rpp failed", &self.interface.name),
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
    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => self.rxy(qubit_id, theta, phi)?,
                Operation::RZGate { qubit_id, theta } => self.rz(qubit_id, theta)?,
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => self.rzz(qubit_id_1, qubit_id_2, theta)?,
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => self.rpp(qubit_id_1, qubit_id_2, theta, phi)?,
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
