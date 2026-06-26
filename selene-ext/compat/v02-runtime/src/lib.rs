use std::{
    ffi::{c_char, c_void},
    path::{Path, PathBuf},
    sync::Arc,
};

use anyhow::{Result, anyhow};
use clap::Parser;
use selene_core::{
    export_runtime_plugin,
    gatewire::{DynamicGateSet, OwnedGateInstance},
    runtime::{
        BatchOperation, Operation, RuntimeBatchSource, RuntimeInterface,
        interface::RuntimeInterfaceFactory,
    },
    utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs},
};
use selene_v02_compat_common::{
    Errno, Instance, LegacyGate, LegacyRuntimeGetOperationInterface, V02_RUNTIME_API_VERSION,
    load_library, negotiate_legacy_gateset, optional_symbol, required_symbol, validate_api_version,
};

type InitFn = unsafe extern "C" fn(*mut Instance, u64, u64, u32, *const *const c_char) -> Errno;
type ExitFn = unsafe extern "C" fn(Instance) -> Errno;
type ShotStartFn = unsafe extern "C" fn(Instance, u64, u64) -> Errno;
type ShotEndFn = unsafe extern "C" fn(Instance, u64, u64) -> Errno;
type GetNextOperationsFn =
    unsafe extern "C" fn(Instance, Instance, *const LegacyRuntimeGetOperationInterface) -> Errno;
type MetricFn = unsafe extern "C" fn(Instance, u8, *mut c_char, *mut u8, *mut u64) -> Errno;
type QallocFn = unsafe extern "C" fn(Instance, *mut u64) -> Errno;
type QfreeFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type LocalBarrierFn = unsafe extern "C" fn(Instance, *const u64, u64, u64) -> Errno;
type GlobalBarrierFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type RxyGateFn = unsafe extern "C" fn(Instance, u64, f64, f64) -> Errno;
type RzGateFn = unsafe extern "C" fn(Instance, u64, f64) -> Errno;
type RzzGateFn = unsafe extern "C" fn(Instance, u64, u64, f64) -> Errno;
type MeasureFn = unsafe extern "C" fn(Instance, u64, *mut u64) -> Errno;
type ResetFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type ForceResultFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type GetBoolResultFn = unsafe extern "C" fn(Instance, u64, *mut i8) -> Errno;
type GetU64ResultFn = unsafe extern "C" fn(Instance, u64, *mut u64) -> Errno;
type SetBoolResultFn = unsafe extern "C" fn(Instance, u64, bool) -> Errno;
type SetU64ResultFn = unsafe extern "C" fn(Instance, u64, u64) -> Errno;
type RefcountFn = unsafe extern "C" fn(Instance, u64) -> Errno;
type CustomCallFn = unsafe extern "C" fn(Instance, u64, *const u8, usize, *mut u64) -> Errno;
type SimulateDelayFn = unsafe extern "C" fn(Instance, u64) -> Errno;

#[derive(Parser, Debug)]
struct Params {
    #[arg(long)]
    old_plugin: PathBuf,

    #[arg(long = "old-arg")]
    old_args: Vec<String>,
}

struct LegacyRuntimeLibrary {
    _lib: libloading::Library,
    init: InitFn,
    exit: Option<ExitFn>,
    shot_start: ShotStartFn,
    shot_end: ShotEndFn,
    get_next_operations: GetNextOperationsFn,
    metric: Option<MetricFn>,
    qalloc: QallocFn,
    qfree: QfreeFn,
    local_barrier: LocalBarrierFn,
    global_barrier: GlobalBarrierFn,
    rxy_gate: RxyGateFn,
    rz_gate: RzGateFn,
    rzz_gate: RzzGateFn,
    measure: MeasureFn,
    measure_leaked: MeasureFn,
    reset: ResetFn,
    force_result: ForceResultFn,
    get_bool_result: GetBoolResultFn,
    get_u64_result: GetU64ResultFn,
    set_bool_result: SetBoolResultFn,
    set_u64_result: SetU64ResultFn,
    increment_future_refcount: RefcountFn,
    decrement_future_refcount: RefcountFn,
    custom_call: Option<CustomCallFn>,
    simulate_delay: Option<SimulateDelayFn>,
}

impl LegacyRuntimeLibrary {
    fn load(path: &Path) -> Result<Arc<Self>> {
        let lib = load_library("runtime", path.as_os_str())?;
        unsafe {
            validate_api_version(
                &lib,
                b"selene_runtime_get_api_version",
                V02_RUNTIME_API_VERSION,
                "runtime",
            )?;
            Ok(Arc::new(Self {
                init: required_symbol(&lib, b"selene_runtime_init")?,
                exit: optional_symbol(&lib, b"selene_runtime_exit"),
                shot_start: required_symbol(&lib, b"selene_runtime_shot_start")?,
                shot_end: required_symbol(&lib, b"selene_runtime_shot_end")?,
                get_next_operations: required_symbol(&lib, b"selene_runtime_get_next_operations")?,
                metric: optional_symbol(&lib, b"selene_runtime_get_metrics"),
                qalloc: required_symbol(&lib, b"selene_runtime_qalloc")?,
                qfree: required_symbol(&lib, b"selene_runtime_qfree")?,
                local_barrier: required_symbol(&lib, b"selene_runtime_local_barrier")?,
                global_barrier: required_symbol(&lib, b"selene_runtime_global_barrier")?,
                rxy_gate: required_symbol(&lib, b"selene_runtime_rxy_gate")?,
                rz_gate: required_symbol(&lib, b"selene_runtime_rz_gate")?,
                rzz_gate: required_symbol(&lib, b"selene_runtime_rzz_gate")?,
                measure: required_symbol(&lib, b"selene_runtime_measure")?,
                measure_leaked: required_symbol(&lib, b"selene_runtime_measure_leaked")?,
                reset: required_symbol(&lib, b"selene_runtime_reset")?,
                force_result: required_symbol(&lib, b"selene_runtime_force_result")?,
                get_bool_result: required_symbol(&lib, b"selene_runtime_get_bool_result")?,
                get_u64_result: required_symbol(&lib, b"selene_runtime_get_u64_result")?,
                set_bool_result: required_symbol(&lib, b"selene_runtime_set_bool_result")?,
                set_u64_result: required_symbol(&lib, b"selene_runtime_set_u64_result")?,
                increment_future_refcount: required_symbol(
                    &lib,
                    b"selene_runtime_increment_future_refcount",
                )?,
                decrement_future_refcount: required_symbol(
                    &lib,
                    b"selene_runtime_decrement_future_refcount",
                )?,
                custom_call: optional_symbol(&lib, b"selene_runtime_custom_call"),
                simulate_delay: optional_symbol(&lib, b"selene_runtime_simulate_delay"),
                _lib: lib,
            }))
        }
    }

    fn init_instance(
        self: Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[String],
    ) -> Result<LegacyRuntime> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe { (self.init)(&mut instance, n_qubits, start.into(), argc, argv) },
                || anyhow!("v02 runtime adapter: legacy init failed"),
            )
        })?;
        Ok(LegacyRuntime {
            library: self,
            instance,
        })
    }
}

struct LegacyBatchBuilder {
    ops: Vec<Operation>,
    source: RuntimeBatchSource,
}

impl Default for LegacyBatchBuilder {
    fn default() -> Self {
        Self {
            ops: Vec::new(),
            source: RuntimeBatchSource::new(0.into(), 0.into()),
        }
    }
}

impl LegacyBatchBuilder {
    fn with_instance(instance: Instance, go: impl FnOnce(&mut Self)) {
        let builder = unsafe { &mut *(instance as *mut Self) };
        go(builder)
    }

    unsafe extern "C" fn rzz(instance: Instance, qubit0: u64, qubit1: u64, theta: f64) {
        Self::with_instance(instance, |builder| {
            if let Ok(op) = Operation::zz_phase(qubit0, qubit1, theta) {
                builder.ops.push(op);
            }
        })
    }

    unsafe extern "C" fn rxy(instance: Instance, qubit: u64, theta: f64, phi: f64) {
        Self::with_instance(instance, |builder| {
            if let Ok(op) = Operation::phased_x(qubit, theta, phi) {
                builder.ops.push(op);
            }
        })
    }

    unsafe extern "C" fn rz(instance: Instance, qubit: u64, theta: f64) {
        Self::with_instance(instance, |builder| {
            if let Ok(op) = Operation::rz(qubit, theta) {
                builder.ops.push(op);
            }
        })
    }

    unsafe extern "C" fn measure(instance: Instance, qubit_id: u64, result_id: u64) {
        Self::with_instance(instance, |builder| {
            builder.ops.push(Operation::Measure {
                qubit_id,
                result_id,
            });
        })
    }

    unsafe extern "C" fn measure_leaked(instance: Instance, qubit_id: u64, result_id: u64) {
        Self::with_instance(instance, |builder| {
            builder.ops.push(Operation::MeasureLeaked {
                qubit_id,
                result_id,
            });
        })
    }

    unsafe extern "C" fn reset(instance: Instance, qubit_id: u64) {
        Self::with_instance(instance, |builder| {
            builder.ops.push(Operation::Reset { qubit_id });
        })
    }

    unsafe extern "C" fn custom(
        instance: Instance,
        custom_tag: usize,
        data: *const c_void,
        len: usize,
    ) {
        let data = unsafe { std::slice::from_raw_parts(data as *const u8, len) }
            .to_vec()
            .into_boxed_slice();
        Self::with_instance(instance, |builder| {
            builder.ops.push(Operation::Custom { custom_tag, data });
        })
    }

    unsafe extern "C" fn set_batch_time(instance: Instance, start: u64, duration: u64) {
        Self::with_instance(instance, |builder| {
            builder.source = RuntimeBatchSource::new(start.into(), duration.into());
        })
    }

    fn interface() -> LegacyRuntimeGetOperationInterface {
        LegacyRuntimeGetOperationInterface {
            rzz_fn: Self::rzz,
            rxy_fn: Self::rxy,
            rz_fn: Self::rz,
            measure_fn: Self::measure,
            measure_leaked_fn: Self::measure_leaked,
            reset_fn: Self::reset,
            custom_fn: Self::custom,
            set_batch_time_fn: Self::set_batch_time,
        }
    }

    fn finish(self) -> BatchOperation {
        BatchOperation::runtime_with_source(self.ops, self.source)
    }
}

struct LegacyRuntime {
    library: Arc<LegacyRuntimeLibrary>,
    instance: Instance,
}

impl RuntimeInterface for LegacyRuntime {
    fn exit(&mut self) -> Result<()> {
        if let Some(exit) = self.library.exit {
            check_errno(unsafe { exit(self.instance) }, || {
                anyhow!("v02 runtime adapter: legacy exit failed")
            })?;
        }
        Ok(())
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut builder = LegacyBatchBuilder::default();
        let interface = LegacyBatchBuilder::interface();
        check_errno(
            unsafe {
                (self.library.get_next_operations)(
                    self.instance,
                    &mut builder as *mut _ as Instance,
                    &interface,
                )
            },
            || anyhow!("v02 runtime adapter: legacy get_next_operations failed"),
        )?;
        if builder.ops.is_empty() {
            Ok(None)
        } else {
            Ok(Some(builder.finish()))
        }
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.shot_start)(self.instance, shot_id, seed) },
            || anyhow!("v02 runtime adapter: legacy shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.library.shot_end)(self.instance, 0, 0) },
            || anyhow!("v02 runtime adapter: legacy shot_end failed"),
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        negotiate_legacy_gateset("Runtime", gateset)
    }

    fn custom_call(&mut self, tag: u64, data: &[u8]) -> Result<u64> {
        let Some(custom_call) = self.library.custom_call else {
            return Err(anyhow!(
                "v02 runtime adapter: legacy runtime has no custom_call"
            ));
        };
        let mut result = 0;
        check_errno(
            unsafe { custom_call(self.instance, tag, data.as_ptr(), data.len(), &mut result) },
            || anyhow!("v02 runtime adapter: legacy custom_call failed"),
        )?;
        Ok(result)
    }

    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        let Some(simulate_delay) = self.library.simulate_delay else {
            return Err(anyhow!(
                "v02 runtime adapter: legacy runtime has no simulate_delay"
            ));
        };
        check_errno(unsafe { simulate_delay(self.instance, delay_ns) }, || {
            anyhow!("v02 runtime adapter: legacy simulate_delay failed")
        })
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(metric) = self.library.metric else {
            return Ok(None);
        };
        read_raw_metric(|tag, datatype, value| unsafe {
            metric(self.instance, nth_metric, tag, datatype, value)
        })
    }

    fn qalloc(&mut self) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe { (self.library.qalloc)(self.instance, &mut result) },
            || anyhow!("v02 runtime adapter: legacy qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.qfree)(self.instance, qubit_id) },
            || anyhow!("v02 runtime adapter: legacy qfree failed"),
        )
    }

    fn gate(&mut self, gate: &OwnedGateInstance) -> Result<()> {
        match LegacyGate::from_gate_instance(gate)? {
            LegacyGate::Rz { qubit, theta } => check_errno(
                unsafe { (self.library.rz_gate)(self.instance, qubit, theta) },
                || anyhow!("v02 runtime adapter: legacy rz_gate failed"),
            ),
            LegacyGate::Rxy { qubit, theta, phi } => check_errno(
                unsafe { (self.library.rxy_gate)(self.instance, qubit, theta, phi) },
                || anyhow!("v02 runtime adapter: legacy rxy_gate failed"),
            ),
            LegacyGate::Rzz {
                qubit0,
                qubit1,
                theta,
            } => check_errno(
                unsafe { (self.library.rzz_gate)(self.instance, qubit0, qubit1, theta) },
                || anyhow!("v02 runtime adapter: legacy rzz_gate failed"),
            ),
        }
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe { (self.library.measure)(self.instance, qubit_id, &mut result) },
            || anyhow!("v02 runtime adapter: legacy measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe { (self.library.measure_leaked)(self.instance, qubit_id, &mut result) },
            || anyhow!("v02 runtime adapter: legacy measure_leaked failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.reset)(self.instance, qubit_id) },
            || anyhow!("v02 runtime adapter: legacy reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.force_result)(self.instance, result_id) },
            || anyhow!("v02 runtime adapter: legacy force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = -1;
        check_errno(
            unsafe { (self.library.get_bool_result)(self.instance, result_id, &mut result) },
            || anyhow!("v02 runtime adapter: legacy get_bool_result failed"),
        )?;
        Ok(match result {
            0 => Some(false),
            1 => Some(true),
            _ => None,
        })
    }

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        let mut result = u64::MAX;
        check_errno(
            unsafe { (self.library.get_u64_result)(self.instance, result_id, &mut result) },
            || anyhow!("v02 runtime adapter: legacy get_u64_result failed"),
        )?;
        Ok((result != u64::MAX).then_some(result))
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        check_errno(
            unsafe { (self.library.set_bool_result)(self.instance, result_id, result) },
            || anyhow!("v02 runtime adapter: legacy set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.set_u64_result)(self.instance, result_id, result) },
            || anyhow!("v02 runtime adapter: legacy set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.increment_future_refcount)(self.instance, future) },
            || anyhow!("v02 runtime adapter: legacy increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.decrement_future_refcount)(self.instance, future) },
            || anyhow!("v02 runtime adapter: legacy decrement_future_refcount failed"),
        )
    }

    fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.library.local_barrier)(
                    self.instance,
                    qubits.as_ptr(),
                    qubits.len() as u64,
                    sleep_ns,
                )
            },
            || anyhow!("v02 runtime adapter: legacy local_barrier failed"),
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.library.global_barrier)(self.instance, sleep_ns) },
            || anyhow!("v02 runtime adapter: legacy global_barrier failed"),
        )
    }
}

#[derive(Default)]
struct LegacyRuntimeFactory;

impl RuntimeInterfaceFactory for LegacyRuntimeFactory {
    type Interface = LegacyRuntime;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let params = Params::try_parse_from(args.iter().map(|arg| arg.as_ref()))?;
        let library = LegacyRuntimeLibrary::load(&params.old_plugin)?;
        Ok(Box::new(library.init_instance(
            n_qubits,
            start,
            &params.old_args,
        )?))
    }
}

export_runtime_plugin!(crate::LegacyRuntimeFactory);
