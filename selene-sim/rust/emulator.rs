use crate::event_hooks::{EventHook, MultiEventHook, Operation};
use crate::selene_instance::configuration::Configuration;
use anyhow::{Result, anyhow};
use selene_core::error_model::plugin::ErrorModelPluginInterface;
use selene_core::error_model::{ErrorModel, ErrorModelInterface};
use selene_core::metadata::BacktraceEngine;
use selene_core::runtime::plugin::RuntimePluginInterface;
use selene_core::runtime::{Runtime, RuntimeInterface as _};

/// Number of frames captured per gate-site backtrace.
const FRAME_CAP: usize = 2;

pub struct Emulator {
    pub runtime: Runtime,
    pub error_model: ErrorModel,
    pub event_hooks: MultiEventHook,
    /// Optional backtrace engine used to attach opaque metadata
    /// handles to every user-issued op. Populated only when
    /// `event_hooks.provide_backtraces` is enabled in the
    /// configuration.
    pub backtrace_engine: Option<BacktraceEngine<'static>>,
}

// User-issued function calls
impl Emulator {
    pub fn from_configuration(config: &Configuration) -> Result<Self> {
        let n_qubits = config.n_qubits;
        let error_model_plugin =
            ErrorModelPluginInterface::new_from_file(&config.error_model.file)?;
        let error_model = ErrorModel::new(
            error_model_plugin,
            n_qubits,
            config.error_model.args.as_ref(),
            &config.simulator.file,
            config.simulator.args.as_ref(),
        )?;

        let runtime_plugin = RuntimePluginInterface::new_from_file(&config.runtime.file)?;
        let runtime = Runtime::new(
            runtime_plugin,
            n_qubits,
            selene_core::time::Instant::default(),
            config.runtime.args.as_ref(),
        )?;

        // Set up the event hooks
        let mut event_hooks = MultiEventHook::default();
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

        // Construct the backtrace engine when enabled. The system backtrace
        // functions are called directly from `capture_backtrace`, so there is
        // no variable library overhead to account for.
        let backtrace_engine = if config.event_hooks.provide_backtraces {
            Some(BacktraceEngine::new(&config.event_hooks.interface_fns))
        } else {
            None
        };

        Ok(Self {
            runtime,
            error_model,
            event_hooks,
            backtrace_engine,
        })
    }
    pub fn poke(&mut self) -> Result<()> {
        self.process_runtime()
    }

    /// Capture a backtrace handle for the upcoming gate, if the engine
    /// is configured. Returns `NO_METADATA` (0) otherwise.
    ///
    /// Marked `#[inline(never)]` so the frame distance between this
    /// function and `capture_backtrace` is stable across build
    /// configurations (the engine's calibration assumes a fixed
    /// `user_skip`).
    #[inline(never)]
    fn capture_metadata(&mut self) -> selene_core::runtime::OpMetadata {
        match self.backtrace_engine.as_mut() {
            Some(engine) => engine.capture_backtrace(FRAME_CAP),
            None => selene_core::runtime::NO_METADATA,
        }
    }
    pub fn dump_quantum_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        self.runtime.global_barrier(0)?;
        self.process_runtime()?;
        self.error_model.dump_simulator_state(file, qubits)
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
        let metadata = self.capture_metadata();
        self.runtime.rxy_gate(q0, theta, phi, metadata)?;
        self.event_hooks
            .on_user_call(&Operation::RXY(q0, theta, phi));
        self.process_runtime()
    }
    pub fn user_issued_rzz(&mut self, q0: u64, q1: u64, theta: f64) -> Result<()> {
        let metadata = self.capture_metadata();
        self.runtime.rzz_gate(q0, q1, theta, metadata)?;
        self.event_hooks
            .on_user_call(&Operation::RZZ(q0, q1, theta));
        self.process_runtime()
    }
    pub fn user_issued_rpp(&mut self, q0: u64, q1: u64, theta: f64, phi: f64) -> Result<()> {
        let metadata = self.capture_metadata();
        self.runtime.rpp_gate(q0, q1, theta, phi, metadata)?;
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
        let metadata = self.capture_metadata();
        self.runtime
            .tk2_gate(q0, q1, alpha, beta, gamma, metadata)?;
        self.event_hooks
            .on_user_call(&Operation::TK2(q0, q1, alpha, beta, gamma));
        self.process_runtime()
    }
    pub fn user_issued_rz(&mut self, q0: u64, theta: f64) -> Result<()> {
        let metadata = self.capture_metadata();
        self.runtime.rz_gate(q0, theta, metadata)?;
        self.event_hooks.on_user_call(&Operation::RZ(q0, theta));
        self.process_runtime()
    }
    pub fn user_issued_reset(&mut self, q0: u64) -> Result<()> {
        let metadata = self.capture_metadata();
        self.runtime.reset(q0, metadata)?;
        self.event_hooks.on_user_call(&Operation::Reset(q0));
        self.process_runtime()
    }
    pub fn user_issued_lazy_measure(&mut self, q0: u64) -> Result<u64> {
        let metadata = self.capture_metadata();
        let result_id = self.runtime.measure(q0, metadata)?;
        self.event_hooks
            .on_user_call(&Operation::MeasureRequest(q0));
        self.process_runtime()?;
        Ok(result_id)
    }
    pub fn user_issued_lazy_measure_leaked(&mut self, q0: u64) -> Result<u64> {
        let metadata = self.capture_metadata();
        let result_id = self.runtime.measure_leaked(q0, metadata)?;
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
        self.runtime.increment_future_refcount(result_id).unwrap();
        self.process_runtime()
    }
    pub fn user_issued_decrement_measurement_refcount(&mut self, result_id: u64) -> Result<()> {
        self.runtime.decrement_future_refcount(result_id).unwrap();
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
        self.event_hooks
            .on_user_call(&Operation::Custom(tag, data.to_vec()));
        let result = self.runtime.custom_call(tag, data)?;
        self.process_runtime()?;
        Ok(result)
    }

    pub fn log_custom_call(&mut self, tag: u64, data: &[u8]) {
        self.event_hooks
            .on_user_call(&Operation::Custom(tag, data.to_vec()))
    }

    pub fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        self.runtime.simulate_delay(delay_ns)?;
        self.event_hooks
            .on_user_call(&Operation::ClassicalDelay(delay_ns));
        self.process_runtime()
    }
}

// Handling of runtime-issued instructions
impl Emulator {
    fn process_runtime(&mut self) -> Result<()> {
        while let Some(batch) = self.runtime.get_next_operations()? {
            self.event_hooks.on_runtime_batch(&batch);
            //self.post_runtime_metrics.update(&batch);
            let results = self.error_model.handle_operations(batch)?;
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
