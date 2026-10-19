use super::HookedSimulator;
use crate::{event_hooks::SharedEventHook, selene_instance::configuration::Configuration};
use anyhow::Result;
use selene_core::{
    error_model::{BatchResult, ErrorModel, ErrorModelInterface},
    peripheral::{
        QuantumPeripheralFFIAdapter, QuantumPeripheralHandle, QuantumPeripheralInterface,
    },
    runtime::{
        BatchOperation,
        pipeline::{self, RuntimeInterface},
    },
    simulator::{Simulator, SimulatorInterface},
    utils::MetricValue,
};
use std::{
    path::Path,
    thread::{self, ThreadId},
};

pub(super) struct PeripheralState {
    simulator: Simulator,
    error_model: ErrorModel,
    hooks: SharedEventHook,
    owner: ThreadId,
    active: bool,
}

impl PeripheralState {
    fn check_thread(&self) -> Result<()> {
        anyhow::ensure!(
            self.owner == thread::current().id(),
            "Peripheral accessed on a different execution thread"
        );
        Ok(())
    }
    pub(super) fn start(&mut self, shot: u64, simulator_seed: u64, error_seed: u64) -> Result<()> {
        self.check_thread()?;
        self.simulator.shot_start(shot, simulator_seed)?;
        if let Err(error) = self.error_model.shot_start(shot, error_seed) {
            let _ = self.simulator.shot_end();
            return Err(error);
        }
        self.active = true;
        Ok(())
    }
    pub(super) fn end(&mut self) -> Result<()> {
        self.check_thread()?;
        if !self.active {
            return Ok(());
        }
        self.active = false;
        let error_model = self.error_model.shot_end();
        let simulator = self.simulator.shot_end();
        error_model.and(simulator)
    }
    pub(super) fn metrics(&mut self) -> Result<Vec<(&'static str, String, MetricValue)>> {
        self.check_thread()?;
        let mut metrics = Vec::new();
        for nth in 0..255 {
            let Some((tag, value)) = self.error_model.get_metric(nth)? else {
                break;
            };
            metrics.push(("error_model", tag, value));
        }
        for nth in 0..255 {
            let Some((tag, value)) = self.simulator.get_metric(nth)? else {
                break;
            };
            metrics.push(("simulator", tag, value));
        }
        Ok(metrics)
    }
}

impl QuantumPeripheralInterface for PeripheralState {
    fn handle_operations(&mut self, batch: BatchOperation) -> Result<BatchResult> {
        self.check_thread()?;
        self.hooks.on_runtime_batch(&batch);
        let results = self
            .error_model
            .handle_operations_with_simulator(batch, &mut self.simulator)?;
        self.hooks.on_runtime_results(&results);
        self.hooks.drain_pending()?;
        Ok(results)
    }
    fn dump_state(&mut self, file: &Path, qubits: &[u64]) -> Result<()> {
        self.check_thread()?;
        self.simulator.dump_state(file, qubits)
    }
}

// This is only an address to send back to the execution thread. No safe method
// on the handle accesses the plugins; the runtime's shot contract governs use.
pub(super) struct PeripheralHandle(pub QuantumPeripheralHandle);
unsafe impl Send for PeripheralHandle {}

/// Owns storage whose contents stay on the runtime's execution thread. Host
/// lifecycle operations go through synchronous callbacks on that thread, and
/// inspection during a shot goes through the runtime's separate borrow API.
pub(super) struct PeripheralStorage {
    address: usize,
}
impl PeripheralStorage {
    pub(super) fn new(
        runtime: &dyn RuntimeInterface,
        config: &Configuration,
        hooks: SharedEventHook,
    ) -> Result<Self> {
        let simulator_file = config.simulator.file.clone();
        let simulator_args = config.simulator.args.clone();
        let error_file = config.error_model.file.clone();
        let error_args = config.error_model.args.clone();
        let n_qubits = config.n_qubits;
        let address = pipeline::on_execution_thread(runtime, move || {
            let mut error_model = ErrorModel::load_from_file(&error_file, n_qubits, &error_args)?;
            let simulator =
                match Simulator::load_from_file(&simulator_file, n_qubits, &simulator_args) {
                    Ok(simulator) => simulator,
                    Err(error) => {
                        let _ = error_model.exit();
                        return Err(error);
                    }
                };
            let simulator = Simulator::from_boxed(Box::new(HookedSimulator::new(
                simulator.into_boxed(),
                hooks.clone(),
            )));
            let state = PeripheralState {
                simulator,
                error_model,
                hooks,
                owner: thread::current().id(),
                active: false,
            };
            Ok(Box::into_raw(Box::new(QuantumPeripheralFFIAdapter::new(state))) as usize)
        })?;
        Ok(Self { address })
    }

    pub(super) fn with<T: Send>(
        &self,
        runtime: &dyn RuntimeInterface,
        operation: impl FnOnce(&mut QuantumPeripheralFFIAdapter<PeripheralState>) -> Result<T> + Send,
    ) -> Result<T> {
        let address = self.address;
        pipeline::on_execution_thread(runtime, move || {
            let state =
                unsafe { &mut *(address as *mut QuantumPeripheralFFIAdapter<PeripheralState>) };
            state.inner.check_thread()?;
            operation(state)
        })
    }

    pub(super) fn borrow<T: Send>(
        &self,
        runtime: &dyn RuntimeInterface,
        operation: impl FnOnce(&mut PeripheralState) -> Result<T> + Send,
    ) -> Result<T> {
        let address = self.address;
        pipeline::borrow_peripheral(runtime, &Default::default(), move |_| {
            let state =
                unsafe { &mut *(address as *mut QuantumPeripheralFFIAdapter<PeripheralState>) };
            state.inner.check_thread()?;
            operation(&mut state.inner)
        })
    }

    pub(super) fn clear(&mut self, runtime: &dyn RuntimeInterface) -> Result<()> {
        let address = std::mem::take(&mut self.address);
        if address == 0 {
            return Ok(());
        }
        pipeline::on_execution_thread(runtime, move || {
            let pointer = address as *mut QuantumPeripheralFFIAdapter<PeripheralState>;
            unsafe { &*pointer }.inner.check_thread()?;
            let mut state = unsafe { Box::from_raw(pointer) };
            let ended = state.inner.end();
            let error_model = state.inner.error_model.exit();
            let simulator = state.inner.simulator.exit();
            ended.and(error_model).and(simulator)
        })
    }
}
