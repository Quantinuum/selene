use crate::event_hooks::{Operation, SharedEventHook};
use crate::selene_instance::configuration::Configuration;
use anyhow::{Context as _, Result, anyhow};
use parking_lot::{Condvar, Mutex};
use selene_core::error_model::BatchResult;
use selene_core::runtime::{
    BatchOperation, Operation as RuntimeOperation, Runtime, RuntimeInterface,
};
use selene_core::simulator::SimulatorInterface;
use std::sync::{
    Arc,
    atomic::{AtomicU32, Ordering},
};
use std::time::Instant;

mod consumer;
use consumer::Consumer;

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

/// Tracks entered callbacks. Native drain/join protects workers not yet entered.
#[derive(Default)]
pub(super) struct ProgramState {
    cancellation: AtomicU32,
    workers: Mutex<usize>,
    workers_done: Condvar,
}

impl ProgramState {
    fn cancel(&self, code: u32) {
        let code = if code == 0 { 100001 } else { code };
        let _ = self
            .cancellation
            .compare_exchange(0, code, Ordering::AcqRel, Ordering::Acquire);
    }

    fn cancellation(&self) -> u32 {
        self.cancellation.load(Ordering::Acquire)
    }

    fn reset(&self) {
        assert_eq!(
            *self.workers.lock(),
            0,
            "previous worker callbacks remain active"
        );
        self.cancellation.store(0, Ordering::Release);
    }

    fn enter(&self) {
        *self.workers.lock() += 1;
    }

    fn leave(&self) {
        let mut workers = self.workers.lock();
        *workers = workers.checked_sub(1).expect("worker count underflow");
        if *workers == 0 {
            self.workers_done.notify_all();
        }
    }

    fn wait(&self) {
        let mut workers = self.workers.lock();
        while *workers != 0 {
            self.workers_done.wait(&mut workers);
        }
    }
}

pub struct Emulator {
    pub runtime: Arc<Runtime>,
    consumer: Consumer,
    program: Arc<ProgramState>,
    pub event_hooks: SharedEventHook,
}

// User-issued function calls
impl Emulator {
    pub fn from_configuration(config: &Configuration) -> Result<Self> {
        let n_qubits = config.n_qubits;
        let runtime = Arc::new(
            Runtime::load_from_file(
                &config.runtime.file,
                n_qubits,
                selene_core::time::Instant::default(),
                config.runtime.args.as_ref(),
            )
            .context("Failed to load runtime plugin")?,
        );

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

        let program = Arc::new(ProgramState::default());
        let consumer = Consumer::new(
            config,
            runtime.clone(),
            event_hooks.clone(),
            program.clone(),
        )?;
        Ok(Self {
            runtime,
            consumer,
            program,
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
        self.program.reset();
        self.consumer.call(move |state| {
            state.shot_start(shot_id, runtime_seed, simulator_seed, error_model_seed)
        })
    }
    pub fn cancel(&self, code: u32) {
        self.program.cancel(code);
        // Repeated notifications are intentional: cancellation can race an
        // operational error or the start of graceful completion.
        let _ = self.runtime.cancel();
    }

    pub fn cancellation(&self) -> u32 {
        self.program.cancellation()
    }

    pub fn worker_enter(&self) -> Result<u32> {
        anyhow::ensure!(
            self.runtime.supports_worker_cancellation(),
            "runtime lacks concurrent worker cancellation/drain support"
        );
        self.program.enter();
        Ok(self.cancellation())
    }

    pub fn worker_leave(&self) {
        self.program.leave();
    }
    pub fn shot_end(&self) -> Result<()> {
        // Joining on the consumer would prevent workers from delivering results.
        let runtime = self.runtime.shot_end();
        // Only the backend drain/join closes the launch gap. After it returns,
        // no delayed worker or descendant may newly enter this program.
        self.program.wait();
        let cleanup = self.consumer.call(|state| state.shot_end());
        runtime.and(cleanup)
    }
    pub fn poke(&self) -> Result<()> {
        self.process_runtime()
    }
    pub fn dump_quantum_state(&self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        self.runtime.global_barrier(0)?;
        let file = file.to_owned();
        let qubits = qubits.to_owned();
        self.consumer.call(move |state| {
            state.process_runtime()?;
            state.simulator.dump_state(&file, &qubits)
        })
    }
    pub fn metrics(&self) -> Result<Vec<(&'static str, String, selene_core::utils::MetricValue)>> {
        self.consumer.call(|state| state.metrics())
    }
    pub fn user_issued_qalloc(&self) -> Result<u64> {
        let address = self.runtime.qalloc()?;
        self.event_hooks.on_user_call(&Operation::QAlloc(address));
        self.process_runtime()?;
        Ok(address)
    }
    pub fn user_issued_qfree(&self, address: u64) -> Result<()> {
        self.runtime.qfree(address)?;
        self.event_hooks.on_user_call(&Operation::QFree(address));
        self.process_runtime()
    }
    pub fn user_issued_local_barrier(&self, qubits: &[u64], sleep_time: u64) -> Result<()> {
        self.runtime.local_barrier(qubits, sleep_time)?;
        self.event_hooks
            .on_user_call(&Operation::LocalBarrier(qubits.to_vec(), sleep_time));
        self.process_runtime()
    }
    pub fn user_issued_global_barrier(&self, sleep_time: u64) -> Result<()> {
        self.runtime.global_barrier(sleep_time)?;
        self.event_hooks
            .on_user_call(&Operation::GlobalBarrier(sleep_time));
        self.process_runtime()
    }
    pub fn user_issued_rxy(&self, q0: u64, theta: f64, phi: f64) -> Result<()> {
        self.runtime.rxy_gate(q0, theta, phi)?;
        self.event_hooks
            .on_user_call(&Operation::RXY(q0, theta, phi));
        self.process_runtime()
    }
    pub fn user_issued_rzz(&self, q0: u64, q1: u64, theta: f64) -> Result<()> {
        self.runtime.rzz_gate(q0, q1, theta)?;
        self.event_hooks
            .on_user_call(&Operation::RZZ(q0, q1, theta));
        self.process_runtime()
    }
    pub fn user_issued_rpp(&self, q0: u64, q1: u64, theta: f64, phi: f64) -> Result<()> {
        self.runtime.rpp_gate(q0, q1, theta, phi)?;
        self.event_hooks
            .on_user_call(&Operation::RPP(q0, q1, theta, phi));
        self.process_runtime()
    }
    pub fn user_issued_rz(&self, q0: u64, theta: f64) -> Result<()> {
        self.runtime.rz_gate(q0, theta)?;
        self.event_hooks.on_user_call(&Operation::RZ(q0, theta));
        self.process_runtime()
    }
    pub fn user_issued_reset(&self, q0: u64) -> Result<()> {
        self.runtime.reset(q0)?;
        self.event_hooks.on_user_call(&Operation::Reset(q0));
        self.process_runtime()
    }
    pub fn user_issued_lazy_measure(&self, q0: u64) -> Result<u64> {
        let result_id = self.runtime.measure(q0)?;
        self.event_hooks
            .on_user_call(&Operation::MeasureRequest(q0));
        self.process_runtime()?;
        Ok(result_id)
    }
    pub fn user_issued_lazy_measure_leaked(&self, q0: u64) -> Result<u64> {
        let result_id = self.runtime.measure_leaked(q0)?;
        self.event_hooks
            .on_user_call(&Operation::MeasureLeakedRequest(q0));
        self.process_runtime()?;
        Ok(result_id)
    }
    pub fn user_issued_eager_measure(&self, q0: u64) -> Result<bool> {
        let result_id = self.user_issued_lazy_measure(q0)?;
        self.user_issued_read_future_bool(result_id)
    }
    pub fn user_issued_increment_measurement_refcount(&self, result_id: u64) -> Result<()> {
        self.runtime.increment_future_refcount(result_id)?;
        self.process_runtime()
    }
    pub fn user_issued_decrement_measurement_refcount(&self, result_id: u64) -> Result<()> {
        self.runtime.decrement_future_refcount(result_id)?;
        self.process_runtime()
    }
    pub fn user_issued_read_future_bool(&self, result_id: u64) -> Result<bool> {
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
    pub fn user_issued_read_future_u64(&self, result_id: u64) -> Result<u64> {
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
    pub fn custom_runtime_call(&self, tag: u64, data: &[u8]) -> Result<u64> {
        self.event_hooks
            .on_user_call(&Operation::Custom(tag, data.to_vec()));
        let result = self.runtime.custom_call(tag, data)?;
        self.process_runtime()?;
        Ok(result)
    }

    pub fn log_custom_call(&self, tag: u64, data: &[u8]) {
        self.event_hooks
            .on_user_call(&Operation::Custom(tag, data.to_vec()))
    }

    pub fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        self.runtime.simulate_delay(delay_ns)?;
        self.event_hooks
            .on_user_call(&Operation::ClassicalDelay(delay_ns));
        self.process_runtime()
    }
}

impl Emulator {
    fn process_runtime(&self) -> Result<()> {
        self.consumer.call(|state| state.process_runtime())
    }
}

#[cfg(test)]
mod tests;
