use parking_lot::{Mutex, RwLock};
use std::collections::VecDeque;

use anyhow::{Result, bail};
use clap::Parser;
use selene_core::{
    export_runtime_plugin,
    runtime::{BatchOperation, Operation, RuntimeInterface, interface::RuntimeInterfaceFactory},
    utils::MetricValue,
};

#[derive(Parser, Debug)]
struct Params {
    #[arg(long)]
    duration_ns_rxy: u64,
    #[arg(long)]
    duration_ns_rzz: u64,
    #[arg(long)]
    duration_ns_rz: u64,
    #[arg(long)]
    duration_ns_rpp: u64,
    #[arg(long)]
    duration_ns_measure: u64,
    #[arg(long)]
    duration_ns_reset: u64,
    #[arg(long)]
    duration_ns_measure_leaked: u64,
}

#[derive(Debug, Clone, PartialEq)]
enum QubitStatus {
    Free,
    Active,
}

// We model bool and u64 results through the same
// interface, but change how we read/write them
// depending on the type of result requested.
#[derive(Debug, Clone)]
struct FutureResult {
    measured: bool,
    value: u64,
}

struct SimpleRuntimeState {
    qubits: Vec<QubitStatus>,
    operation_queue: VecDeque<BatchOperation>,
    start: selene_core::time::Instant,
    params: Params,
}

impl SimpleRuntimeState {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            qubits: vec![QubitStatus::Free; n_qubits as usize],
            operation_queue: VecDeque::with_capacity(10000),
            start,
            params,
        }
    }

    pub fn push(&mut self, op: Operation) {
        let duration_ns = match op {
            Operation::RXYGate { .. } => self.params.duration_ns_rxy,
            Operation::RZZGate { .. } => self.params.duration_ns_rzz,
            Operation::RZGate { .. } => self.params.duration_ns_rz,
            Operation::RPPGate { .. } => self.params.duration_ns_rpp,
            Operation::Measure { .. } => self.params.duration_ns_measure,
            Operation::Reset { .. } => self.params.duration_ns_reset,
            Operation::MeasureLeaked { .. } => self.params.duration_ns_measure_leaked,
            _ => 0,
        };
        self.operation_queue.push_back(BatchOperation::runtime(
            vec![op],
            self.start,
            duration_ns.into(),
        ));
        self.start += duration_ns.into();
    }
}

// Scheduling and allocation share one lock so queue/flush updates are atomic.
// Result access is independent: publication and concurrent readers do not need
// the scheduling lock. Calls needing both always lock state before results.
struct SimpleRuntime {
    state: Mutex<SimpleRuntimeState>,
    results: RwLock<Vec<FutureResult>>,
}

impl SimpleRuntime {
    fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            state: Mutex::new(SimpleRuntimeState::new(n_qubits, start, params)),
            results: RwLock::new(Vec::with_capacity(1000)),
        }
    }
}

impl RuntimeInterface for SimpleRuntime {
    fn exit(&self) -> Result<()> {
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        state.operation_queue.clear();
        state.qubits.clear();
        results.clear();
        Ok(())
    }
    // Engine ops
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        let state = &mut *self.state.lock();
        Ok(state.operation_queue.pop_front())
    }

    fn shot_start(&self, _shot_id: u64, _seed: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&self) -> Result<()> {
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        state.qubits = vec![QubitStatus::Free; state.qubits.len()];
        state.operation_queue.clear();
        results.clear();
        Ok(())
    }
    fn global_barrier(&self, _sleep_ns: u64) -> Result<()> {
        // This runtime isn't lazy, so a barrier is not relevant
        // to its operation.
        Ok(())
    }
    fn local_barrier(&self, _qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        // This runtime isn't lazy, so a barrier is not relevant
        // to its operation.
        Ok(())
    }
    // Allocation
    fn qalloc(&self) -> Result<u64> {
        let state = &mut *self.state.lock();
        for (i, qubit) in state.qubits.iter_mut().enumerate() {
            if *qubit == QubitStatus::Free {
                *qubit = QubitStatus::Active;
                return Ok(i as u64);
            }
        }
        Ok(u64::MAX)
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("freeing out-of-bounds qubit {qubit_id}")
        } else {
            state.qubits[qubit_id as usize] = QubitStatus::Free;
            Ok(())
        }
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("applying rxy gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active = state.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        state.push(Operation::RXYGate {
            qubit_id,
            theta,
            phi,
        });
        Ok(())
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id_1 >= state.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= state.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        state.push(Operation::RZZGate {
            qubit_id_1,
            qubit_id_2,
            theta,
        });
        Ok(())
    }
    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("applying rz gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active = state.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        state.push(Operation::RZGate { qubit_id, theta });
        Ok(())
    }
    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id_1 >= state.qubits.len() as u64 {
            bail!("applying rpp gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= state.qubits.len() as u64 {
            bail!("applying rpp gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        let QubitStatus::Active = state.qubits[qubit_id_1 as usize] else {
            bail!("Qubit {qubit_id_1} is not active");
        };
        let QubitStatus::Active = state.qubits[qubit_id_2 as usize] else {
            bail!("Qubit {qubit_id_2} is not active");
        };
        state.push(Operation::RPPGate {
            qubit_id_1,
            qubit_id_2,
            theta,
            phi,
        });
        Ok(())
    }
    // Lifetime ops
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = results.len() as u64;
        results.push(FutureResult {
            measured: false,
            value: 0,
        });
        state.push(Operation::Measure {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = results.len() as u64;
        results.push(FutureResult {
            measured: false,
            value: 0,
        });
        state.push(Operation::MeasureLeaked {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }

    fn reset(&self, qubit_id: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("resetting out-of-bounds qubit {qubit_id}")
        }
        state.push(Operation::Reset { qubit_id });
        Ok(())
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        let results = self.results.read();
        if result_id >= results.len() as u64 {
            bail!("forcing out-of-bounds measurement {result_id}")
        }
        // This runtime isn't lazy, so if a result has been defined,
        // the measurement is already eligible for draining.
        Ok(())
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let results = self.results.read();
        if result_id >= results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &results[result_id as usize];
        Ok(if result.measured {
            Some(result.value > 0)
        } else {
            None
        })
    }
    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        let mut results = self.results.write();
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize].value = if result { 1 } else { 0 };
        results[result_id as usize].measured = true;
        Ok(())
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let results = self.results.read();
        if result_id >= results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &results[result_id as usize];
        Ok(if result.measured {
            Some(result.value)
        } else {
            None
        })
    }
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        let mut results = self.results.write();
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize].value = result;
        results[result_id as usize].measured = true;
        Ok(())
    }

    fn increment_future_refcount(&self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn decrement_future_refcount(&self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn get_metric(&self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        state.start += selene_core::time::Duration::from(delay_ns);
        Ok(())
    }
}

#[derive(Default)]
struct SimpleRuntimeFactory;

impl RuntimeInterfaceFactory for SimpleRuntimeFactory {
    type Interface = SimpleRuntime;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let args: Vec<String> = args.iter().map(|s| s.as_ref().to_string()).collect();

        match Params::try_parse_from(args) {
            Ok(params) => Ok(Box::new(SimpleRuntime::new(n_qubits, start, params))),
            Err(e) => bail!("Failed to parse runtime parameters: {e}"),
        }
    }
}

export_runtime_plugin!(crate::SimpleRuntimeFactory);

#[cfg(test)]
#[path = "../../../../selene-core/tests/support/runtime_concurrency.rs"]
mod concurrency_support;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn concurrent_forcing_and_draining() {
        let runtime = selene_core::runtime::Runtime::from_boxed(Box::new(SimpleRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_rz: 1,
                duration_ns_rpp: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
            },
        )));
        runtime.shot_start(0, 0).unwrap();
        concurrency_support::exercise(&runtime);
        runtime.shot_end().unwrap();
    }

    #[test]
    fn result_publication_does_not_take_scheduling_lock() {
        let runtime = SimpleRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_rz: 1,
                duration_ns_rpp: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
            },
        );
        let qubit = runtime.qalloc().unwrap();
        let id = runtime.measure(qubit).unwrap();
        let _scheduling = runtime.state.lock();
        runtime.set_bool_result(id, true).unwrap();
        assert_eq!(runtime.get_bool_result(id).unwrap(), Some(true));
    }

    #[test]
    fn forcing_a_leakage_measurement_flushes_it() {
        let runtime = SimpleRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_rz: 1,
                duration_ns_rpp: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
            },
        );
        let qubit = runtime.qalloc().unwrap();
        let id = runtime.measure_leaked(qubit).unwrap();
        runtime.force_result(id).unwrap();
        let batch = runtime
            .get_next_operations()
            .unwrap()
            .expect("forced leakage measurement");
        assert!(
            matches!(batch.iter_ops().next(), Some(Operation::MeasureLeaked { result_id, .. }) if *result_id == id)
        );
        assert!(runtime.get_next_operations().unwrap().is_none());
        runtime.force_result(id).unwrap();
        runtime.set_bool_result(id, true).unwrap();
        assert_eq!(runtime.get_bool_result(id).unwrap(), Some(true));
    }

    #[test]
    fn sequential_gate_scheduling_is_preserved() {
        let runtime = SimpleRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_rz: 1,
                duration_ns_rpp: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
            },
        );
        let qubit = runtime.qalloc().unwrap();
        runtime.rz_gate(qubit, 0.25).unwrap();
        runtime.rxy_gate(qubit, 0.5, 0.75).unwrap();
        runtime.global_barrier(0).unwrap();
        let rz = runtime.get_next_operations().unwrap().unwrap();
        assert!(
            matches!(rz.iter_ops().next(), Some(Operation::RZGate { theta, .. }) if *theta == 0.25)
        );
        let rxy = runtime.get_next_operations().unwrap().unwrap();
        assert!(
            matches!(rxy.iter_ops().next(), Some(Operation::RXYGate { theta, phi, .. }) if *theta == 0.5 && *phi == 0.75)
        );
        assert!(runtime.get_next_operations().unwrap().is_none());
    }
}
