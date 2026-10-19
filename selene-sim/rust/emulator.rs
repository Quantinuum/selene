use crate::event_hooks::{Operation, SharedEventHook};
use crate::selene_instance::configuration::Configuration;
use anyhow::{Result, anyhow};
use parking_lot::Mutex;
use selene_core::error_model::BatchResult;
use selene_core::peripheral::{PeripheralBorrowRequest, QuantumPeripheralInterface};
use selene_core::runtime::{
    BatchOperation, Operation as RuntimeOperation,
    pipeline::{self, Runtime, RuntimeInterface},
};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;
use std::time::Instant;

mod peripheral;
use peripheral::PeripheralStorage;

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
    pub runtime: Box<dyn RuntimeInterface>,
    peripheral: PeripheralStorage,
    pub event_hooks: SharedEventHook,
    metrics: Mutex<Vec<(&'static str, String, MetricValue)>>,
    active: bool,
    collect_metrics: bool,
}

impl Emulator {
    pub fn from_configuration(config: &Configuration) -> Result<Self> {
        let event_hooks = SharedEventHook::default();
        if config.event_hooks.provide_metrics {
            event_hooks.add_hook(Box::new(
                crate::event_hooks::metrics::HighLevelMetrics::default(),
            ));
        }
        if config.event_hooks.provide_trace {
            event_hooks.add_hook(Box::new(crate::event_hooks::trace_log::TraceLog::new(
                config.artifact_dir.clone(),
            )));
        }
        if config.event_hooks.provide_measurement_log {
            event_hooks.add_hook(Box::new(
                crate::event_hooks::measurement_log::MeasurementLog::default(),
            ));
        }
        let runtime = Runtime::load_from_file(
            &config.runtime.file,
            config.n_qubits,
            selene_core::time::Instant::default(),
            &config.runtime.args,
        )?;
        let peripheral = PeripheralStorage::new(runtime.as_ref(), config, event_hooks.clone())?;
        Ok(Self {
            runtime,
            peripheral,
            event_hooks,
            metrics: Mutex::new(Vec::new()),
            active: false,
            collect_metrics: config.event_hooks.provide_metrics,
        })
    }

    pub fn shot_start(
        &mut self,
        shot_id: u64,
        runtime_seed: u64,
        simulator_seed: u64,
        error_model_seed: u64,
    ) -> Result<()> {
        anyhow::ensure!(!self.active, "Previous runtime shot is still active");
        self.metrics.lock().clear();
        self.event_hooks.on_shot_start(shot_id);
        let handle = self.peripheral.with(self.runtime.as_ref(), move |state| {
            state
                .inner
                .start(shot_id, simulator_seed, error_model_seed)?;
            Ok(peripheral::PeripheralHandle(state.ffi_interface()))
        })?;
        // This handle is only ever dereferenced by the runtime on the thread
        // where PeripheralStorage constructed the plugins. It stays live until
        // shot_end has returned, including when execution reports an error.
        let started = unsafe { self.runtime.shot_start(shot_id, runtime_seed, handle.0) };
        if let Err(error) = started {
            let _ = self
                .peripheral
                .with(self.runtime.as_ref(), |state| state.inner.end());
            return Err(error);
        }
        self.active = true;
        if let Err(error) = self.process_runtime() {
            let _ = self.shot_end();
            return Err(error);
        }
        Ok(())
    }

    pub fn shot_end(&mut self) -> Result<()> {
        if !self.active {
            return Ok(());
        }
        // Legacy plugins were historically sampled before shot_end. Keep that
        // order because an existing runtime may reset its counters there.
        let legacy_metrics = if self.collect_metrics && self.runtime.is_legacy() {
            self.runtime_metrics().and_then(|mut metrics| {
                metrics.extend(
                    self.peripheral
                        .borrow(self.runtime.as_ref(), |state| state.metrics())?,
                );
                Ok(metrics)
            })
        } else {
            Ok(Vec::new())
        };
        let runtime = self.runtime.shot_end();
        self.active = false;
        // The runtime has relinquished the peripheral. We can now inspect its
        // metrics and end the plugins' shots on their original execution thread.
        let collect_metrics = self.collect_metrics && !self.runtime.is_legacy();
        let collect = self.peripheral.with(self.runtime.as_ref(), move |state| {
            let metrics = if collect_metrics {
                state.inner.metrics()
            } else {
                Ok(Vec::new())
            };
            let ended = state.inner.end();
            let metrics = metrics?;
            ended?;
            Ok(metrics)
        });
        self.event_hooks.on_shot_end();
        runtime?;
        let mut metrics = legacy_metrics?;
        if collect_metrics {
            metrics.extend(self.runtime_metrics()?);
        }
        metrics.extend(collect?);
        *self.metrics.lock() = metrics;
        Ok(())
    }

    pub fn poke(&self) -> Result<()> {
        pipeline::borrow_peripheral(
            self.runtime.as_ref(),
            &PeripheralBorrowRequest {
                force_flush: true,
                ..Default::default()
            },
            |_| Ok(()),
        )
    }

    pub fn dump_quantum_state(&self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        pipeline::borrow_peripheral(
            self.runtime.as_ref(),
            &PeripheralBorrowRequest {
                force_flush: true,
                ..Default::default()
            },
            |peripheral| peripheral.dump_state(file, qubits),
        )
    }

    pub fn metrics(&self) -> Result<Vec<(&'static str, String, MetricValue)>> {
        Ok(self.metrics.lock().clone())
    }

    fn runtime_metrics(&self) -> Result<Vec<(&'static str, String, MetricValue)>> {
        let mut metrics = Vec::new();
        for nth in 0..255 {
            let Some((tag, value)) = self.runtime.get_metric(nth)? else {
                break;
            };
            metrics.push(("runtime", tag, value));
        }
        Ok(metrics)
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
        // Record the user call before the legacy runtime's batches are polled,
        // so the trace keeps its original order. New runtimes drive their own
        // peripherals and this checkpoint does not send them a request.
        self.runtime.process_pending()?;
        self.event_hooks.drain_pending()?;
        Ok(())
    }
}

impl Emulator {
    pub fn exit(&mut self) -> Result<()> {
        let shot = self.shot_end();
        let peripheral = self.peripheral.clear(self.runtime.as_ref());
        let runtime = self.runtime.exit();
        shot.and(peripheral).and(runtime)
    }
}

impl Drop for Emulator {
    fn drop(&mut self) {
        let _ = self.exit();
    }
}
