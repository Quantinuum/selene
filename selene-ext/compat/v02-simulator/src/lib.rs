use std::{
    ffi::c_char,
    path::{Path, PathBuf},
    sync::Arc,
};

use anyhow::{Result, anyhow, bail};
use clap::Parser;
use selene_core::{
    error_model::BatchResult,
    export_simulator_plugin,
    gatewire::DynamicGateSet,
    runtime::{BatchOperation, Operation},
    simulator::{SimulatorInterface, interface::SimulatorInterfaceFactory},
    utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs},
};
use selene_v02_compat_common::{
    Errno, Instance, LegacyGate, V02_SIMULATOR_API_VERSION, load_library, negotiate_legacy_gateset,
    optional_symbol, required_symbol, validate_api_version,
};

type InitFn = unsafe extern "C" fn(*mut Instance, u64, u32, *const *const c_char) -> Errno;
type ExitFn = unsafe extern "C" fn(Instance) -> Errno;
type ShotStartFn = unsafe extern "C" fn(Instance, u64, u64) -> Errno;
type ShotEndFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type RxyFn = unsafe extern "C" fn(Instance, u64, f64, f64) -> Errno;
type RzFn = unsafe extern "C" fn(Instance, u64, f64) -> Errno;
type RzzFn = unsafe extern "C" fn(Instance, u64, u64, f64) -> Errno;
type MeasureFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type PostselectFn = unsafe extern "C" fn(Instance, u64, bool) -> Errno;
type ResetFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type MetricFn = unsafe extern "C" fn(Instance, u8, *mut c_char, *mut u8, *mut u64) -> Errno;
type DumpStateFn = unsafe extern "C" fn(Instance, *const c_char, *const u64, u64) -> Errno;

#[derive(Parser, Debug)]
struct Params {
    #[arg(long)]
    old_plugin: PathBuf,

    #[arg(long = "old-arg")]
    old_args: Vec<String>,
}

struct LegacySimulatorLibrary {
    _lib: libloading::Library,
    init: InitFn,
    exit: Option<ExitFn>,
    shot_start: ShotStartFn,
    shot_end: ShotEndFn,
    rxy: RxyFn,
    rz: RzFn,
    rzz: RzzFn,
    measure: MeasureFn,
    postselect: Option<PostselectFn>,
    reset: ResetFn,
    metric: Option<MetricFn>,
    dump_state: Option<DumpStateFn>,
}

impl LegacySimulatorLibrary {
    fn load(path: &Path) -> Result<Arc<Self>> {
        let lib = load_library("simulator", path.as_os_str())?;
        unsafe {
            validate_api_version(
                &lib,
                b"selene_simulator_get_api_version",
                V02_SIMULATOR_API_VERSION,
                "simulator",
            )?;
            Ok(Arc::new(Self {
                init: required_symbol(&lib, b"selene_simulator_init")?,
                exit: optional_symbol(&lib, b"selene_simulator_exit"),
                shot_start: required_symbol(&lib, b"selene_simulator_shot_start")?,
                shot_end: required_symbol(&lib, b"selene_simulator_shot_end")?,
                rxy: required_symbol(&lib, b"selene_simulator_operation_rxy")?,
                rz: required_symbol(&lib, b"selene_simulator_operation_rz")?,
                rzz: required_symbol(&lib, b"selene_simulator_operation_rzz")?,
                measure: required_symbol(&lib, b"selene_simulator_operation_measure")?,
                postselect: optional_symbol(&lib, b"selene_simulator_operation_postselect"),
                reset: required_symbol(&lib, b"selene_simulator_operation_reset")?,
                metric: optional_symbol(&lib, b"selene_simulator_get_metrics"),
                dump_state: optional_symbol(&lib, b"selene_simulator_dump_state"),
                _lib: lib,
            }))
        }
    }

    fn init_instance(self: Arc<Self>, n_qubits: u64, args: &[String]) -> Result<LegacySimulator> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe { (self.init)(&mut instance, n_qubits, argc, argv) },
                || anyhow!("v02 simulator adapter: legacy init failed"),
            )
        })?;
        Ok(LegacySimulator {
            library: self,
            instance,
        })
    }
}

struct LegacySimulator {
    library: Arc<LegacySimulatorLibrary>,
    instance: Instance,
}

impl LegacySimulator {
    fn apply_gate(&mut self, gate: LegacyGate) -> Result<()> {
        match gate {
            LegacyGate::Rz { qubit, theta } => check_errno(
                unsafe { (self.library.rz)(self.instance, qubit, theta) },
                || anyhow!("v02 simulator adapter: legacy rz failed"),
            ),
            LegacyGate::Rxy { qubit, theta, phi } => check_errno(
                unsafe { (self.library.rxy)(self.instance, qubit, theta, phi) },
                || anyhow!("v02 simulator adapter: legacy rxy failed"),
            ),
            LegacyGate::Rzz {
                qubit0,
                qubit1,
                theta,
            } => check_errno(
                unsafe { (self.library.rzz)(self.instance, qubit0, qubit1, theta) },
                || anyhow!("v02 simulator adapter: legacy rzz failed"),
            ),
        }
    }

    fn measure(&mut self, qubit: u64) -> Result<bool> {
        match unsafe { (self.library.measure)(self.instance, qubit) } {
            0 => Ok(false),
            1 => Ok(true),
            errno => bail!("v02 simulator adapter: legacy measure failed with code {errno}"),
        }
    }
}

impl SimulatorInterface for LegacySimulator {
    fn exit(&mut self) -> Result<()> {
        if let Some(exit) = self.library.exit {
            check_errno(unsafe { exit(self.instance) }, || {
                anyhow!("v02 simulator adapter: legacy exit failed")
            })?;
        }
        Ok(())
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.shot_start)(self.instance, shot_id, seed) },
            || anyhow!("v02 simulator adapter: legacy shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(unsafe { (self.library.shot_end)(self.instance, 0) }, || {
            anyhow!("v02 simulator adapter: legacy shot_end failed")
        })
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        negotiate_legacy_gateset("Simulator", gateset)
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::Gate { gate } => {
                    self.apply_gate(LegacyGate::from_gate_instance(&gate)?)?
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => results.set_bool_result(result_id, self.measure(qubit_id)?),
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => results.set_u64_result(result_id, self.measure(qubit_id)? as u64),
                Operation::Reset { qubit_id } => check_errno(
                    unsafe { (self.library.reset)(self.instance, qubit_id) },
                    || anyhow!("v02 simulator adapter: legacy reset failed"),
                )?,
                Operation::Custom { .. } => {}
                _ => bail!("v02 simulator adapter: unsupported operation kind"),
            }
        }
        Ok(results)
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        let Some(postselect) = self.library.postselect else {
            bail!("v02 simulator adapter: legacy simulator does not support postselection");
        };
        check_errno(
            unsafe { postselect(self.instance, qubit, target_value) },
            || anyhow!("v02 simulator adapter: legacy postselect failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(metric) = self.library.metric else {
            return Ok(None);
        };
        read_raw_metric(|tag, datatype, value| unsafe {
            metric(self.instance, nth_metric, tag, datatype, value)
        })
    }

    fn dump_state(&mut self, file: &Path, qubits: &[u64]) -> Result<()> {
        let Some(dump_state) = self.library.dump_state else {
            bail!("v02 simulator adapter: legacy simulator does not support state dumps");
        };
        let file = std::ffi::CString::new(file.as_os_str().as_encoded_bytes())?;
        check_errno(
            unsafe {
                dump_state(
                    self.instance,
                    file.as_ptr(),
                    qubits.as_ptr(),
                    qubits.len() as u64,
                )
            },
            || anyhow!("v02 simulator adapter: legacy dump_state failed"),
        )
    }
}

#[derive(Default)]
struct LegacySimulatorFactory;

impl SimulatorInterfaceFactory for LegacySimulatorFactory {
    type Interface = LegacySimulator;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let params = Params::try_parse_from(args.iter().map(|arg| arg.as_ref()))?;
        let library = LegacySimulatorLibrary::load(&params.old_plugin)?;
        Ok(Box::new(library.init_instance(n_qubits, &params.old_args)?))
    }
}

export_simulator_plugin!(crate::LegacySimulatorFactory);
