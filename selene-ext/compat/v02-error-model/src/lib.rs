use std::{
    cell::RefCell,
    ffi::{CStr, CString, c_char, c_void},
    path::{Path, PathBuf},
    sync::Arc,
};

use anyhow::{Result, anyhow, bail};
use clap::Parser;
use selene_core::{
    error_model::{BatchResult, ErrorModelInterface, interface::ErrorModelInterfaceFactory},
    export_error_model_plugin,
    gatewire::DynamicGateSet,
    runtime::{BatchOperation, Operation},
    simulator::SimulatorInterface,
    utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs},
};
use selene_v02_compat_common::{
    Errno, Instance, LegacyErrorModelSetResultInterface, LegacyGate,
    LegacyRuntimeExtractOperationInterface, LegacyRuntimeGetOperationInterface,
    V02_ERROR_MODEL_API_VERSION, V02_SIMULATOR_API_VERSION, load_library, negotiate_legacy_gateset,
    optional_symbol, required_symbol, validate_api_version,
};

type InitFn = unsafe extern "C" fn(
    *mut Instance,
    u64,
    u32,
    *const *const c_char,
    *const c_char,
    u32,
    *const *const c_char,
) -> Errno;
type ExitFn = unsafe extern "C" fn(Instance) -> Errno;
type ShotStartFn = unsafe extern "C" fn(Instance, u64, u64, u64) -> Errno;
type ShotEndFn = unsafe extern "C" fn(Instance) -> Errno;
type HandleOperationsFn = unsafe extern "C" fn(
    Instance,
    Instance,
    *const LegacyRuntimeExtractOperationInterface,
    Instance,
    *const LegacyErrorModelSetResultInterface,
) -> Errno;
type MetricFn = unsafe extern "C" fn(Instance, u8, *mut c_char, *mut u8, *mut u64) -> Errno;

type SimulatorPtr = *mut (dyn SimulatorInterface + 'static);

thread_local! {
    static CURRENT_SIMULATOR: RefCell<Option<SimulatorPtr>> = const { RefCell::new(None) };
}

#[derive(Parser, Debug)]
struct Params {
    #[arg(long)]
    old_plugin: PathBuf,

    #[arg(long = "old-arg")]
    old_args: Vec<String>,

    #[arg(long)]
    bridge_simulator: Option<PathBuf>,
}

struct LegacyErrorModelLibrary {
    _lib: libloading::Library,
    init: InitFn,
    exit: Option<ExitFn>,
    shot_start: ShotStartFn,
    shot_end: ShotEndFn,
    handle_operations: HandleOperationsFn,
    metric: Option<MetricFn>,
}

impl LegacyErrorModelLibrary {
    fn load(path: &Path) -> Result<Arc<Self>> {
        let lib = load_library("error model", path.as_os_str())?;
        unsafe {
            validate_api_version(
                &lib,
                b"selene_error_model_get_api_version",
                V02_ERROR_MODEL_API_VERSION,
                "error model",
            )?;
            Ok(Arc::new(Self {
                init: required_symbol(&lib, b"selene_error_model_init")?,
                exit: optional_symbol(&lib, b"selene_error_model_exit"),
                shot_start: required_symbol(&lib, b"selene_error_model_shot_start")?,
                shot_end: required_symbol(&lib, b"selene_error_model_shot_end")?,
                handle_operations: required_symbol(&lib, b"selene_error_model_handle_operations")?,
                metric: optional_symbol(&lib, b"selene_error_model_get_metrics"),
                _lib: lib,
            }))
        }
    }

    fn init_instance(
        self: Arc<Self>,
        n_qubits: u64,
        error_model_args: &[String],
        bridge_simulator: &Path,
    ) -> Result<LegacyErrorModel> {
        let mut instance = std::ptr::null_mut();
        let bridge_simulator = CString::new(bridge_simulator.as_os_str().as_encoded_bytes())?;
        with_strings_to_cargs(error_model_args, |argc, argv| {
            check_errno(
                unsafe {
                    (self.init)(
                        &mut instance,
                        n_qubits,
                        argc,
                        argv,
                        bridge_simulator.as_ptr(),
                        0,
                        std::ptr::null(),
                    )
                },
                || anyhow!("v02 error-model adapter: legacy init failed"),
            )
        })?;
        Ok(LegacyErrorModel {
            library: self,
            instance,
        })
    }
}

struct LegacyBatchExtractor(BatchOperation);

impl LegacyBatchExtractor {
    unsafe extern "C" fn extract(
        batch_instance: Instance,
        output_instance: Instance,
        output_interface: LegacyRuntimeGetOperationInterface,
    ) {
        let batch = unsafe { &*(batch_instance as *const BatchOperation) };
        if let Some(timing) = batch.runtime_source() {
            unsafe {
                (output_interface.set_batch_time_fn)(
                    output_instance,
                    timing.start().into(),
                    timing.duration().into(),
                );
            }
        }
        for operation in batch.iter_ops() {
            match operation {
                Operation::Gate { gate } => match LegacyGate::from_gate_instance(gate) {
                    Ok(LegacyGate::Rz { qubit, theta }) => unsafe {
                        (output_interface.rz_fn)(output_instance, qubit, theta)
                    },
                    Ok(LegacyGate::Rxy { qubit, theta, phi }) => unsafe {
                        (output_interface.rxy_fn)(output_instance, qubit, theta, phi)
                    },
                    Ok(LegacyGate::Rzz {
                        qubit0,
                        qubit1,
                        theta,
                    }) => unsafe {
                        (output_interface.rzz_fn)(output_instance, qubit0, qubit1, theta)
                    },
                    Err(error) => eprintln!(
                        "v02 error-model adapter: failed to translate gate for legacy batch: {error}"
                    ),
                },
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => unsafe {
                    (output_interface.measure_fn)(output_instance, *qubit_id, *result_id)
                },
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => unsafe {
                    (output_interface.measure_leaked_fn)(output_instance, *qubit_id, *result_id)
                },
                Operation::Reset { qubit_id } => unsafe {
                    (output_interface.reset_fn)(output_instance, *qubit_id)
                },
                Operation::Custom { custom_tag, data } => unsafe {
                    (output_interface.custom_fn)(
                        output_instance,
                        *custom_tag,
                        data.as_ptr() as *const c_void,
                        data.len(),
                    )
                },
                _ => {
                    eprintln!("v02 error-model adapter: unsupported operation kind in legacy batch")
                }
            }
        }
    }

    fn interface(&mut self) -> (Instance, LegacyRuntimeExtractOperationInterface) {
        (
            &mut self.0 as *mut BatchOperation as Instance,
            LegacyRuntimeExtractOperationInterface {
                extract_fn: Self::extract,
            },
        )
    }
}

#[derive(Default)]
struct LegacyResultBuilder(BatchResult);

impl LegacyResultBuilder {
    unsafe extern "C" fn set_bool_result(instance: Instance, result_id: u64, value: bool) {
        let result = unsafe { &mut *(instance as *mut BatchResult) };
        result.set_bool_result(result_id, value);
    }

    unsafe extern "C" fn set_u64_result(instance: Instance, result_id: u64, value: u64) {
        let result = unsafe { &mut *(instance as *mut BatchResult) };
        result.set_u64_result(result_id, value);
    }

    fn interface(&mut self) -> (Instance, LegacyErrorModelSetResultInterface) {
        (
            &mut self.0 as *mut BatchResult as Instance,
            LegacyErrorModelSetResultInterface {
                set_bool_result_fn: Self::set_bool_result,
                set_u64_result_fn: Self::set_u64_result,
            },
        )
    }

    fn finish(self) -> BatchResult {
        self.0
    }
}

struct SimulatorScope;

impl SimulatorScope {
    fn enter(simulator: &mut dyn SimulatorInterface) -> Self {
        let ptr: *mut dyn SimulatorInterface = simulator;
        let ptr: SimulatorPtr = unsafe { std::mem::transmute(ptr) };
        CURRENT_SIMULATOR.with(|slot| {
            *slot.borrow_mut() = Some(ptr);
        });
        Self
    }
}

impl Drop for SimulatorScope {
    fn drop(&mut self) {
        CURRENT_SIMULATOR.with(|slot| {
            *slot.borrow_mut() = None;
        });
    }
}

struct LegacyErrorModel {
    library: Arc<LegacyErrorModelLibrary>,
    instance: Instance,
}

impl ErrorModelInterface for LegacyErrorModel {
    fn exit(&mut self) -> Result<()> {
        if let Some(exit) = self.library.exit {
            check_errno(unsafe { exit(self.instance) }, || {
                anyhow!("v02 error-model adapter: legacy exit failed")
            })?;
        }
        Ok(())
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.shot_start)(self.instance, shot_id, seed, 0) },
            || anyhow!("v02 error-model adapter: legacy shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(unsafe { (self.library.shot_end)(self.instance) }, || {
            anyhow!("v02 error-model adapter: legacy shot_end failed")
        })
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        negotiate_legacy_gateset("Error model", gateset)
    }

    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult> {
        let _scope = SimulatorScope::enter(simulator);
        let mut extractor = LegacyBatchExtractor(operations);
        let (batch_instance, batch_interface) = extractor.interface();
        let mut result_builder = LegacyResultBuilder::default();
        let (result_instance, result_interface) = result_builder.interface();
        check_errno(
            unsafe {
                (self.library.handle_operations)(
                    self.instance,
                    batch_instance,
                    &batch_interface,
                    result_instance,
                    &result_interface,
                )
            },
            || anyhow!("v02 error-model adapter: legacy handle_operations failed"),
        )?;
        Ok(result_builder.finish())
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(metric) = self.library.metric else {
            return Ok(None);
        };
        read_raw_metric(|tag, datatype, value| unsafe {
            metric(self.instance, nth_metric, tag, datatype, value)
        })
    }
}

#[derive(Default)]
struct LegacyErrorModelFactory;

impl ErrorModelInterfaceFactory for LegacyErrorModelFactory {
    type Interface = LegacyErrorModel;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let params = Params::try_parse_from(args.iter().map(|arg| arg.as_ref()))?;
        let bridge_simulator = match params.bridge_simulator {
            Some(path) => path,
            None => this_library_path()?,
        };
        let library = LegacyErrorModelLibrary::load(&params.old_plugin)?;
        Ok(Box::new(library.init_instance(
            n_qubits,
            &params.old_args,
            &bridge_simulator,
        )?))
    }
}

fn with_current_simulator<T>(
    go: impl FnOnce(&mut dyn SimulatorInterface) -> Result<T>,
) -> Result<T> {
    CURRENT_SIMULATOR.with(|slot| {
        let Some(ptr) = *slot.borrow() else {
            bail!("v02 error-model adapter simulator bridge used outside handle_operations");
        };
        let simulator = unsafe { &mut *ptr };
        go(simulator)
    })
}

fn forward_gate(gate: LegacyGate) -> Result<()> {
    let operation = match gate {
        LegacyGate::Rz { qubit, theta } => Operation::rz(qubit, theta)?,
        LegacyGate::Rxy { qubit, theta, phi } => Operation::phased_x(qubit, theta, phi)?,
        LegacyGate::Rzz {
            qubit0,
            qubit1,
            theta,
        } => Operation::zz_phase(qubit0, qubit1, theta)?,
    };
    with_current_simulator(|simulator| {
        let results = simulator.handle_operations(BatchOperation::error_model(vec![operation]))?;
        if results.bool_results.is_empty() && results.u64_results.is_empty() {
            Ok(())
        } else {
            bail!("v02 simulator bridge: gate unexpectedly produced a result")
        }
    })
}

fn forward_reset(qubit: u64) -> Result<()> {
    with_current_simulator(|simulator| {
        let results =
            simulator.handle_operations(BatchOperation::error_model(vec![Operation::Reset {
                qubit_id: qubit,
            }]))?;
        if results.bool_results.is_empty() && results.u64_results.is_empty() {
            Ok(())
        } else {
            bail!("v02 simulator bridge: reset unexpectedly produced a result")
        }
    })
}

fn forward_measure(qubit: u64) -> Result<bool> {
    with_current_simulator(|simulator| {
        let results =
            simulator.handle_operations(BatchOperation::error_model(vec![Operation::Measure {
                qubit_id: qubit,
                result_id: 0,
            }]))?;
        if results.bool_results.len() == 1 && results.u64_results.is_empty() {
            Ok(results.bool_results[0].value)
        } else {
            bail!("v02 simulator bridge: measure expected exactly one bool result")
        }
    })
}

fn this_library_path() -> Result<PathBuf> {
    let mut info = std::mem::MaybeUninit::<libc::Dl_info>::zeroed();
    let rc = unsafe { libc::dladdr(selene_simulator_init as *const c_void, info.as_mut_ptr()) };
    if rc == 0 {
        bail!("v02 error-model adapter could not locate its simulator bridge library path");
    }
    let info = unsafe { info.assume_init() };
    if info.dli_fname.is_null() {
        bail!("v02 error-model adapter simulator bridge path is null");
    }
    let path = unsafe { CStr::from_ptr(info.dli_fname) };
    Ok(PathBuf::from(path.to_str()?))
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_get_api_version() -> u64 {
    V02_SIMULATOR_API_VERSION
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_init(
    instance: *mut Instance,
    _n_qubits: u64,
    _argc: u32,
    _argv: *const *const c_char,
) -> Errno {
    if instance.is_null() {
        return -1;
    }
    unsafe {
        *instance = Box::into_raw(Box::new(())) as Instance;
    }
    0
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_exit(instance: Instance) -> Errno {
    if !instance.is_null() {
        let _ = unsafe { Box::from_raw(instance as *mut ()) };
    }
    0
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_shot_start(
    _instance: Instance,
    _shot_id: u64,
    _seed: u64,
) -> Errno {
    0
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_shot_end(_instance: Instance, _seed: u64) -> Errno {
    0
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_rxy(
    _instance: Instance,
    qubit: u64,
    theta: f64,
    phi: f64,
) -> Errno {
    match forward_gate(LegacyGate::Rxy { qubit, theta, phi }) {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_rz(
    _instance: Instance,
    qubit: u64,
    theta: f64,
) -> Errno {
    match forward_gate(LegacyGate::Rz { qubit, theta }) {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_rzz(
    _instance: Instance,
    qubit0: u64,
    qubit1: u64,
    theta: f64,
) -> Errno {
    match forward_gate(LegacyGate::Rzz {
        qubit0,
        qubit1,
        theta,
    }) {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_measure(
    _instance: Instance,
    qubit: u64,
) -> Errno {
    match forward_measure(qubit) {
        Ok(false) => 0,
        Ok(true) => 1,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_postselect(
    _instance: Instance,
    qubit: u64,
    target_value: bool,
) -> Errno {
    match with_current_simulator(|simulator| simulator.postselect(qubit, target_value)) {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_operation_reset(
    _instance: Instance,
    qubit: u64,
) -> Errno {
    match forward_reset(qubit) {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("{error:#}");
            -1
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_get_metrics(
    _instance: Instance,
    _nth_metric: u8,
    _tag_out: *mut c_char,
    _datatype_out: *mut u8,
    _value_out: *mut u64,
) -> Errno {
    1
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_simulator_dump_state(
    _instance: Instance,
    _file: *const c_char,
    _qubits: *const u64,
    _n_qubits: u64,
) -> Errno {
    -1
}

export_error_model_plugin!(crate::LegacyErrorModelFactory);
