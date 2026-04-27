use crate::event_hooks::{Operation, SharedEventHook};
use crate::selene_instance::configuration::Configuration;
use anyhow::{Result, anyhow};
use selene_core::error_model::{BatchResult, ErrorModel, ErrorModelInterface};
use selene_core::runtime::{
    BatchOperation, Operation as RuntimeOperation, Runtime, RuntimeInterface,
};
use selene_core::simulator::{Simulator, SimulatorInterface};
use std::time::Instant;

struct HookedSimulator {
    inner: Box<dyn SimulatorInterface>,
    event_hooks: SharedEventHook,
}

impl HookedSimulator {
    fn new(inner: Box<dyn SimulatorInterface>, event_hooks: SharedEventHook) -> Self {
        Self { inner, event_hooks }
    }
}

fn time_simulator_call<T>(
    event_hooks: &SharedEventHook,
    operation: &Operation,
    callback: impl FnOnce() -> Result<T>,
) -> Result<T> {
    event_hooks.on_error_model_output(operation);
    let start = Instant::now();
    let result = callback();
    let duration_ns = start.elapsed().as_nanos().min(u128::from(u64::MAX)) as u64;
    event_hooks.on_simulator_call(operation, duration_ns);
    result
}

fn singleton_batch(operation: RuntimeOperation) -> BatchOperation {
    BatchOperation::simulator(vec![operation])
}

impl SimulatorInterface for HookedSimulator {
    fn exit(&mut self) -> Result<()> {
        self.inner.exit()
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        self.inner.shot_start(shot_id, seed)
    }

    fn shot_end(&mut self) -> Result<()> {
        self.inner.shot_end()
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            let event_operation = Operation::from_simulator_operation(&operation);
            let batch = singleton_batch(operation);
            let batch_results = time_simulator_call(&self.event_hooks, &event_operation, || {
                self.inner.handle_operations(batch)
            })?;
            results.extend(batch_results);
        }
        Ok(results)
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        let operation = Operation::Postselect(qubit, target_value);
        time_simulator_call(&self.event_hooks, &operation, || {
            self.inner.postselect(qubit, target_value)
        })
    }

    fn get_metric(
        &mut self,
        nth_metric: u8,
    ) -> Result<Option<(String, selene_core::utils::MetricValue)>> {
        self.inner.get_metric(nth_metric)
    }

    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        self.inner.dump_state(file, qubits)
    }
}

pub struct Emulator {
    pub runtime: Runtime,
    pub simulator: Simulator,
    pub error_model: ErrorModel,
    pub event_hooks: SharedEventHook,
}

// User-issued function calls
impl Emulator {
    pub fn from_configuration(config: &Configuration) -> Result<Self> {
        let n_qubits = config.n_qubits;
        let error_model = ErrorModel::load_from_file(
            &config.error_model.file,
            n_qubits,
            config.error_model.args.as_ref(),
        )?;

        let simulator = Simulator::load_from_file(
            &config.simulator.file,
            n_qubits,
            config.simulator.args.as_ref(),
        )?;

        let runtime = Runtime::load_from_file(
            &config.runtime.file,
            n_qubits,
            selene_core::time::Instant::default(),
            config.runtime.args.as_ref(),
        )?;

        // Set up the event hooks
        let event_hooks = SharedEventHook::default();
        if config.event_hooks.provide_metrics {
            event_hooks.add_hook(Box::new(
                crate::event_hooks::metrics::HighLevelMetrics::default(),
            ));
        }
        if config.event_hooks.provide_instruction_log {
            event_hooks.add_hook(Box::new(
                crate::event_hooks::instruction_log::InstructionLog::default(),
            ));
        }
        if config.event_hooks.provide_measurement_log {
            event_hooks.add_hook(Box::new(
                crate::event_hooks::measurement_log::MeasurementLog::default(),
            ));
        }

        let simulator = Simulator::from_boxed(Box::new(HookedSimulator::new(
            simulator.into_boxed(),
            event_hooks.clone(),
        )));

        Ok(Self {
            runtime,
            simulator,
            error_model,
            event_hooks,
        })
    }
    pub fn shot_start(
        &mut self,
        shot_id: u64,
        runtime_seed: u64,
        simulator_seed: u64,
        error_model_seed: u64,
    ) -> Result<()> {
        self.event_hooks.on_shot_start(shot_id);
        self.runtime.shot_start(shot_id, runtime_seed)?;
        self.simulator.shot_start(shot_id, simulator_seed)?;
        self.error_model.shot_start(shot_id, error_model_seed)?;
        // Process any operations that might be issued during shot start
        self.poke()?;
        Ok(())
    }
    pub fn shot_end(&mut self) -> Result<()> {
        // Tell the runtime that it's time to shut down.
        // This may flush additional operations as part of
        // the shutdown process.
        self.runtime.shot_end()?;
        // Handle any operations that resulted from the runtime's shot
        // end process
        self.poke()?;
        // Tell the error model, having already processed anything from
        // the current runtime shot, that the shot is ending. The error model
        // must also end the shot on its internal simulator.
        self.error_model.shot_end()?;
        self.simulator.shot_end()?;
        // Write out any stored metadata e.g. instruction logs
        // and inform event hooks that the shot has ended.
        self.event_hooks.on_shot_end();
        // Print shot boundary information so that the result stream
        // is properly delimited.
        Ok(())
    }
    pub fn poke(&mut self) -> Result<()> {
        self.process_runtime()
    }
    pub fn dump_quantum_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        self.runtime.global_barrier(0)?;
        self.process_runtime()?;
        self.simulator.dump_state(file, qubits)
    }
    pub fn user_issued_qalloc(&mut self) -> Result<u64> {
        let address = self.runtime.qalloc()?;
        self.event_hooks.on_user_call(&Operation::QAlloc(address));
        self.process_runtime()?;
        Ok(address)
    }
    pub fn user_issued_qfree(&mut self, address: u64) -> Result<()> {
        self.runtime.qfree(address)?;
        self.event_hooks.on_user_call(&Operation::QFree(address));
        self.process_runtime()
    }
    pub fn user_issued_local_barrier(&mut self, qubits: &[u64], sleep_time: u64) -> Result<()> {
        self.runtime.local_barrier(qubits, sleep_time)?;
        self.event_hooks
            .on_user_call(&Operation::LocalBarrier(qubits.to_vec(), sleep_time));
        self.process_runtime()
    }
    pub fn user_issued_global_barrier(&mut self, sleep_time: u64) -> Result<()> {
        self.runtime.global_barrier(sleep_time)?;
        self.event_hooks
            .on_user_call(&Operation::GlobalBarrier(sleep_time));
        self.process_runtime()
    }
    pub fn user_issued_rxy(&mut self, q0: u64, theta: f64, phi: f64) -> Result<()> {
        self.runtime.rxy_gate(q0, theta, phi)?;
        self.event_hooks
            .on_user_call(&Operation::RXY(q0, theta, phi));
        self.process_runtime()
    }
    pub fn user_issued_rzz(&mut self, q0: u64, q1: u64, theta: f64) -> Result<()> {
        self.runtime.rzz_gate(q0, q1, theta)?;
        self.event_hooks
            .on_user_call(&Operation::RZZ(q0, q1, theta));
        self.process_runtime()
    }
    pub fn user_issued_rpp(&mut self, q0: u64, q1: u64, theta: f64, phi: f64) -> Result<()> {
        self.runtime.rpp_gate(q0, q1, theta, phi)?;
        self.event_hooks
            .on_user_call(&Operation::RPP(q0, q1, theta, phi));
        self.process_runtime()
    }
    pub fn user_issued_tk2(
        &mut self,
        q0: u64,
        q1: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Result<()> {
        self.runtime.tk2_gate(q0, q1, alpha, beta, gamma)?;
        self.event_hooks
            .on_user_call(&Operation::TK2(q0, q1, alpha, beta, gamma));
        self.process_runtime()
    }
    pub fn user_issued_rz(&mut self, q0: u64, theta: f64) -> Result<()> {
        self.runtime.rz_gate(q0, theta)?;
        self.event_hooks.on_user_call(&Operation::RZ(q0, theta));
        self.process_runtime()
    }
    pub fn user_issued_reset(&mut self, q0: u64) -> Result<()> {
        self.runtime.reset(q0)?;
        self.event_hooks.on_user_call(&Operation::Reset(q0));
        self.process_runtime()
    }
    pub fn user_issued_lazy_measure(&mut self, q0: u64) -> Result<u64> {
        let result_id = self.runtime.measure(q0)?;
        self.event_hooks
            .on_user_call(&Operation::MeasureRequest(q0));
        self.process_runtime()?;
        Ok(result_id)
    }
    pub fn user_issued_lazy_measure_leaked(&mut self, q0: u64) -> Result<u64> {
        let result_id = self.runtime.measure_leaked(q0)?;
        self.event_hooks
            .on_user_call(&Operation::MeasureLeakedRequest(q0));
        self.process_runtime()?;
        Ok(result_id)
    }
    pub fn user_issued_eager_measure(&mut self, q0: u64) -> Result<bool> {
        let result_id = self.user_issued_lazy_measure(q0)?;
        self.user_issued_read_future_bool(result_id)
    }
    pub fn user_issued_increment_measurement_refcount(&mut self, result_id: u64) -> Result<()> {
        self.runtime.increment_future_refcount(result_id)?;
        self.process_runtime()
    }
    pub fn user_issued_decrement_measurement_refcount(&mut self, result_id: u64) -> Result<()> {
        self.runtime.decrement_future_refcount(result_id)?;
        self.process_runtime()
    }
    pub fn user_issued_read_future_bool(&mut self, result_id: u64) -> Result<bool> {
        self.event_hooks
            .on_user_call(&Operation::FutureRead(result_id));
        match self.runtime.get_bool_result(result_id)? {
            Some(value) => Ok(value),
            None => {
                self.runtime.force_result(result_id)?;
                self.process_runtime()?;
                let Some(result) = self.runtime.get_bool_result(result_id)? else {
                    return Err(anyhow!(
                        "Future bool result not available after attempting to force it."
                    ));
                };
                Ok(result)
            }
        }
    }
    pub fn user_issued_read_future_u64(&mut self, result_id: u64) -> Result<u64> {
        self.event_hooks
            .on_user_call(&Operation::FutureRead(result_id));
        match self.runtime.get_u64_result(result_id)? {
            Some(value) => Ok(value),
            None => {
                self.runtime.force_result(result_id)?;
                self.process_runtime()?;
                let Some(result) = self.runtime.get_u64_result(result_id)? else {
                    return Err(anyhow!(
                        "Future u64 result not available after attempting to force it."
                    ));
                };
                Ok(result)
            }
        }
    }
    pub fn custom_runtime_call(&mut self, tag: u64, data: &[u8]) -> Result<u64> {
        let result = self.runtime.custom_call(tag, data)?;
        self.process_runtime()?;
        Ok(result)
    }
    pub fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        self.runtime.simulate_delay(delay_ns)?;
        self.event_hooks
            .on_user_call(&Operation::ClassicalDelay(delay_ns));
        self.process_runtime()
    }
}

impl Emulator {
    fn process_runtime(&mut self) -> Result<()> {
        while let Some(batch) = self.runtime.get_next_operations()? {
            self.event_hooks.on_runtime_batch(&batch);
            let results = self
                .error_model
                .handle_operations_with_simulator(batch, &mut self.simulator)?;
            self.event_hooks.on_runtime_results(&results);
            for bool_result in results.bool_results {
                self.runtime
                    .set_bool_result(bool_result.result_id, bool_result.value)?;
            }
            for u64_result in results.u64_results {
                self.runtime
                    .set_u64_result(u64_result.result_id, u64_result.value)?;
            }
        }
        Ok(())
    }
}
