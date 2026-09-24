use std::{
    collections::VecDeque,
    sync::{Mutex, RwLock},
};

use anyhow::{Result, bail};
use selene_core::{
    export_runtime_plugin,
    runtime::{BatchOperation, Operation, RuntimeInterface, interface::RuntimeInterfaceFactory},
    utils::MetricValue,
};

#[derive(Debug, Clone, PartialEq)]
enum QubitStatus {
    Free,
    Active { phase: f64 },
}

// We choose to encode a future bool or future u64
// result as a u64 value with a boolean 'is_set' flag.
// User code should be careful to read the correct type.
#[derive(Debug, Clone)]
struct FutureResult {
    is_set: bool,
    value: u64,
}

struct ExampleRuntimeState {
    qubits: Vec<QubitStatus>,
    operation_queue: VecDeque<BatchOperation>,
    flush_size: usize,
    start: selene_core::time::Instant,
}

impl ExampleRuntimeState {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant) -> Self {
        Self {
            qubits: vec![QubitStatus::Free; n_qubits as usize],
            operation_queue: VecDeque::with_capacity(10000),
            flush_size: 0,
            start,
        }
    }

    pub fn push(&mut self, op: Operation) {
        self.operation_queue.push_back(BatchOperation::runtime(
            vec![op],
            self.start,
            Default::default(),
        ));
    }
}

// Scheduling and allocation share one lock so queue/flush updates are atomic.
// Result access is independent: publication and concurrent readers do not need
// the scheduling lock. Calls needing both always lock state before results.
struct ExampleRuntime {
    state: Mutex<ExampleRuntimeState>,
    results: RwLock<Vec<FutureResult>>,
}

impl ExampleRuntime {
    fn new(n_qubits: u64, start: selene_core::time::Instant) -> Self {
        Self {
            state: Mutex::new(ExampleRuntimeState::new(n_qubits, start)),
            results: RwLock::new(Vec::with_capacity(1000)),
        }
    }
}

impl RuntimeInterface for ExampleRuntime {
    fn exit(&self) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        state.operation_queue.clear();
        state.qubits.clear();
        state.flush_size = 0;
        results.clear();
        Ok(())
    }
    // Engine ops
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        debug_assert!(
            state.flush_size <= state.operation_queue.len(),
            "flush size is greater than operation queue length"
        );
        if state.flush_size == 0 {
            return Ok(None);
        }
        state.flush_size -= 1;
        Ok(state.operation_queue.pop_front())
    }

    fn shot_start(&self, _shot_id: u64, _seed: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&self) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        state.qubits = vec![QubitStatus::Free; state.qubits.len()];
        state.operation_queue.clear();
        state.flush_size = 0;
        results.clear();
        Ok(())
    }
    fn global_barrier(&self, _sleep_ns: u64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        state.flush_size = state.operation_queue.len();
        Ok(())
    }
    fn local_barrier(&self, qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        // Flush through the last batch touching these qubits, without shrinking
        // an existing forced prefix. Enumerate before filtering to retain indices.
        let qubits: std::collections::HashSet<u64> = qubits.iter().copied().collect();
        if let Some((i, _)) = state
            .operation_queue
            .iter()
            .enumerate()
            .rev()
            .find(|(_, batch)| !batch.get_qubit_ids().is_disjoint(&qubits))
        {
            state.flush_size = state.flush_size.max(i + 1);
        }
        Ok(())
    }
    // Allocation
    fn qalloc(&self) -> Result<u64> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        for (i, qubit) in state.qubits.iter_mut().enumerate() {
            if *qubit == QubitStatus::Free {
                *qubit = QubitStatus::Active { phase: 0.0 };
                return Ok(i as u64);
            }
        }
        Ok(u64::MAX)
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("freeing out-of-bounds qubit {qubit_id}")
        } else {
            state.qubits[qubit_id as usize] = QubitStatus::Free;
            Ok(())
        }
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("applying rxy gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active { phase } = state.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        state.push(Operation::RXYGate {
            qubit_id,
            theta,
            phi: phi - phase, // The Z phase is enacted here.
        });
        Ok(())
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
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
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("applying rz gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active { phase } = state.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        // We don't apply an RZ gate. Instead, we accumulate a phase, and mutate
        // RXY gates' phi parameters to account for the phase shift. RZZ and measurement
        // are unaffected.
        state.qubits[qubit_id as usize] = QubitStatus::Active {
            phase: phase + theta,
        };
        Ok(())
    }
    // Lifetime ops
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = results.len() as u64;
        results.push(FutureResult {
            is_set: false,
            value: 0,
        });
        state.push(Operation::Measure {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = results.len() as u64;
        results.push(FutureResult {
            is_set: false,
            value: 0,
        });
        state.push(Operation::MeasureLeaked {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }
    fn reset(&self, qubit_id: u64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        if qubit_id >= state.qubits.len() as u64 {
            bail!("resetting out-of-bounds qubit {qubit_id}")
        }
        state.push(Operation::Reset { qubit_id });
        Ok(())
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        let state = &mut *self
            .state
            .lock()
            .map_err(|_| anyhow::anyhow!("Runtime state lock poisoned"))?;
        let results = self
            .results
            .read()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if result_id >= results.len() as u64 {
            bail!("forcing out-of-bounds measurement {result_id}")
        }
        for (i, operation) in state.operation_queue.iter().enumerate().rev() {
            for op in operation.iter_ops() {
                match op {
                    Operation::Measure { result_id: id, .. }
                    | Operation::MeasureLeaked { result_id: id, .. } => {
                        if *id == result_id {
                            state.flush_size = std::cmp::max(state.flush_size, i + 1);
                            return Ok(());
                        }
                    }
                    _ => {}
                }
            }
        }
        Ok(()) // Already dispatched or resolved.
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let results = self
            .results
            .read()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if result_id >= results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &results[result_id as usize];
        Ok(if result.is_set {
            Some(result.value > 0)
        } else {
            None
        })
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let results = self
            .results
            .read()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if result_id >= results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &results[result_id as usize];
        Ok(if result.is_set {
            Some(result.value)
        } else {
            None
        })
    }
    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize] = FutureResult {
            is_set: true,
            value: result.into(),
        };
        Ok(())
    }
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        let mut results = self
            .results
            .write()
            .map_err(|_| anyhow::anyhow!("Runtime results lock poisoned"))?;
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize] = FutureResult {
            is_set: true,
            value: result,
        };
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
}

#[derive(Default)]
struct ExampleRuntimeFactory;

impl RuntimeInterfaceFactory for ExampleRuntimeFactory {
    type Interface = ExampleRuntime;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        _args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::new(ExampleRuntime::new(n_qubits, start)))
    }
}

export_runtime_plugin!(crate::ExampleRuntimeFactory);

#[cfg(test)]
#[path = "../../../tests/support/runtime_concurrency.rs"]
mod concurrency_support;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn concurrent_forcing_and_draining() {
        let runtime = selene_core::runtime::Runtime::from_boxed(Box::new(ExampleRuntime::new(
            4,
            Default::default(),
        )));
        runtime.shot_start(0, 0).unwrap();
        concurrency_support::exercise(&runtime);
        runtime.shot_end().unwrap();
    }

    #[test]
    fn result_publication_does_not_take_scheduling_lock() {
        let runtime = ExampleRuntime::new(4, Default::default());
        let qubit = runtime.qalloc().unwrap();
        let id = runtime.measure(qubit).unwrap();
        let _scheduling = runtime.state.lock().unwrap();
        runtime.set_bool_result(id, true).unwrap();
        assert_eq!(runtime.get_bool_result(id).unwrap(), Some(true));
    }

    #[test]
    fn local_barriers_preserve_queue_indices() {
        let runtime = ExampleRuntime::new(2, Default::default());
        runtime.local_barrier(&[0], 0).unwrap();
        assert!(runtime.get_next_operations().unwrap().is_none());
        let q0 = runtime.qalloc().unwrap();
        let q1 = runtime.qalloc().unwrap();
        runtime.rxy_gate(q0, 0.5, 0.0).unwrap();
        runtime.rxy_gate(q1, 0.5, 0.0).unwrap();
        runtime.rxy_gate(q1, 0.5, 0.0).unwrap();
        runtime.local_barrier(&[q0], 0).unwrap();
        runtime.local_barrier(&[q1], 0).unwrap();
        for _ in 0..3 {
            assert!(runtime.get_next_operations().unwrap().is_some());
        }
        assert!(runtime.get_next_operations().unwrap().is_none());
    }
}
