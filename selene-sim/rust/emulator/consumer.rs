use super::HookedSimulator;
use crate::{event_hooks::SharedEventHook, selene_instance::configuration::Configuration};
use anyhow::{Result, anyhow};
use selene_core::{
    error_model::{ErrorModel, ErrorModelInterface},
    runtime::{Runtime, RuntimeInterface},
    simulator::{Simulator, SimulatorInterface},
    utils::MetricValue,
};
use std::{
    sync::{Arc, mpsc},
    thread::{self, JoinHandle},
    time::Duration,
};

type Request = Box<dyn FnOnce(&mut State) + Send>;

/// Owns the single batch consumer. Simulator and error-model objects are created,
/// called, and dropped on this thread; their interfaces need neither Send nor Sync.
pub(super) struct Consumer {
    requests: Option<mpsc::Sender<Request>>,
    thread: Option<JoinHandle<()>>,
}

impl Consumer {
    pub(super) fn new(
        config: &Configuration,
        runtime: Arc<Runtime>,
        hooks: SharedEventHook,
    ) -> Result<Self> {
        let n_qubits = config.n_qubits;
        let simulator_config = config.simulator.clone();
        let error_model_config = config.error_model.clone();
        Self::spawn(move || {
            let error_model = ErrorModel::load_from_file(
                &error_model_config.file,
                n_qubits,
                &error_model_config.args,
            )?;
            let simulator = Simulator::load_from_file(
                &simulator_config.file,
                n_qubits,
                &simulator_config.args,
            )?;
            let simulator = Simulator::from_boxed(Box::new(HookedSimulator::new(
                simulator.into_boxed(),
                hooks.clone(),
            )));
            Ok(State {
                runtime,
                simulator,
                error_model,
                hooks,
                active: false,
                failure: None,
            })
        })
    }

    pub(super) fn spawn(init: impl FnOnce() -> Result<State> + Send + 'static) -> Result<Self> {
        let (requests, receiver) = mpsc::channel::<Request>();
        let (ready, initialized) = mpsc::sync_channel(1);
        let thread = thread::Builder::new()
            .name("selene-consumer".into())
            .spawn(move || {
                let mut state = match init() {
                    Ok(state) => state,
                    Err(error) => {
                        let _ = ready.send(Err(error));
                        return;
                    }
                };
                if ready.send(Ok(())).is_err() {
                    return;
                }
                loop {
                    // Keep consuming while a runtime call is blocked on a result. The
                    // runtime API has no work-available notification, so idle shots poll.
                    let request = if state.active && state.failure.is_none() {
                        match receiver.recv_timeout(Duration::from_millis(1)) {
                            Ok(request) => Some(request),
                            Err(mpsc::RecvTimeoutError::Timeout) => None,
                            Err(mpsc::RecvTimeoutError::Disconnected) => break,
                        }
                    } else {
                        match receiver.recv() {
                            Ok(request) => Some(request),
                            Err(_) => break,
                        }
                    };
                    if let Some(request) = request {
                        request(&mut state);
                    }
                    if state.active {
                        // Retain failures so the next QIS/lifecycle call can report them.
                        let _ = state.process_runtime();
                    }
                }
            })?;
        let consumer = Self {
            requests: Some(requests),
            thread: Some(thread),
        };
        initialized
            .recv()
            .map_err(|_| anyhow!("Batch consumer failed during initialization"))??;
        Ok(consumer)
    }

    pub(super) fn call<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&mut State) -> Result<T> + Send + 'static,
    ) -> Result<T> {
        let (reply, result) = mpsc::sync_channel(1);
        self.requests
            .as_ref()
            .unwrap()
            .send(Box::new(move |state| {
                let _ = reply.send(operation(state));
            }))
            .map_err(|_| anyhow!("Batch consumer has stopped"))?;
        result
            .recv()
            .map_err(|_| anyhow!("Batch consumer stopped before replying"))?
    }
}

impl Drop for Consumer {
    fn drop(&mut self) {
        self.requests.take();
        if let Some(thread) = self.thread.take() {
            let _ = thread.join();
        }
    }
}

pub(super) struct State {
    pub(super) runtime: Arc<Runtime>,
    pub(super) simulator: Simulator,
    pub(super) error_model: ErrorModel,
    pub(super) hooks: SharedEventHook,
    pub(super) active: bool,
    pub(super) failure: Option<String>,
}

impl State {
    pub(super) fn shot_start(
        &mut self,
        shot: u64,
        runtime_seed: u64,
        simulator_seed: u64,
        error_seed: u64,
    ) -> Result<()> {
        self.failure = None;
        self.hooks.on_shot_start(shot);
        self.runtime.shot_start(shot, runtime_seed)?;
        self.simulator.shot_start(shot, simulator_seed)?;
        self.error_model.shot_start(shot, error_seed)?;
        self.process_runtime()?;
        self.active = true;
        Ok(())
    }

    pub(super) fn shot_end(&mut self) -> Result<()> {
        self.active = false;
        self.runtime.shot_end()?;
        self.process_runtime()?;
        self.error_model.shot_end()?;
        self.simulator.shot_end()?;
        self.hooks.on_shot_end();
        Ok(())
    }

    pub(super) fn process_runtime(&mut self) -> Result<()> {
        if let Some(error) = &self.failure {
            return Err(anyhow!("{error}"));
        }
        let result = self.drain();
        if let Err(error) = &result {
            self.failure = Some(format!("{error:#}"));
        }
        result
    }

    fn drain(&mut self) -> Result<()> {
        while let Some(batch) = self.runtime.get_next_operations()? {
            self.hooks.on_runtime_batch(&batch);
            let results = self
                .error_model
                .handle_operations_with_simulator(batch, &mut self.simulator)?;
            self.hooks.on_runtime_results(&results);
            for result in results.bool_results {
                self.runtime
                    .set_bool_result(result.result_id, result.value)?;
            }
            for result in results.u64_results {
                self.runtime
                    .set_u64_result(result.result_id, result.value)?;
            }
        }
        Ok(())
    }

    pub(super) fn metrics(&mut self) -> Result<Vec<(&'static str, String, MetricValue)>> {
        self.process_runtime()?;
        let mut metrics = Vec::new();
        for nth in 0..255 {
            let Some((tag, value)) = self.runtime.get_metric(nth)? else {
                break;
            };
            metrics.push(("runtime", tag, value));
        }
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
