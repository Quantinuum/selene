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
    duration_ns_measure: u64,
    #[arg(long)]
    duration_ns_reset: u64,
    #[arg(long)]
    duration_ns_measure_leaked: u64,
    #[arg(long)]
    max_batch_size: usize,
}

#[derive(Debug, Clone, PartialEq)]
enum QubitStatus {
    Free,
    Active { phase: f64 },
}

// Encompass both bool and u64 results in a single type.
// The u64 value can be cast appropriately for boolean results.
#[derive(Debug, Clone)]
struct FutureResult {
    is_set: bool,
    value: u64,
}

struct SoftRZRuntimeState {
    qubits: Vec<QubitStatus>,
    operation_queue: VecDeque<BatchOperation>,
    flush_size: usize,
    start: selene_core::time::Instant,
    params: Params,
}

struct AppendSearchResult {
    can_append: bool,
    can_continue_search: bool,
}

impl SoftRZRuntimeState {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            qubits: vec![QubitStatus::Free; n_qubits as usize],
            operation_queue: VecDeque::with_capacity(10000),
            flush_size: 0,
            start,
            params,
        }
    }

    pub fn push(&mut self, op: Operation) {
        // In this runtime we aim to schedule an operation as early as possible.
        // As such, we search backwards through the operation queue for the earliest
        // batch that op can be appended to, taking into account the batch's operations' types, the batch's qubits,
        // and the max batch size.
        let mut append_idx = self.operation_queue.len();
        for (i, operation) in self.operation_queue.iter().enumerate().rev() {
            let append_result = self.append_search_impl(&op, operation);
            if append_result.can_append {
                append_idx = i;
            }
            if !append_result.can_continue_search {
                break;
            }
        }

        if append_idx < self.operation_queue.len() {
            // We found a batch to append to!
            self.operation_queue[append_idx].add_operation(op);
        } else {
            // We didn't find a batch to append to, so we need to create a new batch for this operation.
            let duration = match op {
                Operation::RXYGate { .. } => self.params.duration_ns_rxy,
                Operation::RZZGate { .. } => self.params.duration_ns_rzz,
                Operation::Measure { .. } => self.params.duration_ns_measure,
                Operation::Reset { .. } => self.params.duration_ns_reset,
                Operation::MeasureLeaked { .. } => self.params.duration_ns_measure_leaked,
                _ => 0, // Unhandled ops have no duration, since we don't know their semantics.
            };
            self.operation_queue.push_back(BatchOperation::runtime(
                vec![op],
                self.start,
                duration.into(),
            ));
            self.start += duration.into();
        }
    }

    fn append_search_impl(&self, op: &Operation, batch: &BatchOperation) -> AppendSearchResult {
        // first, check if the current batch operates intersects op's qubits.
        // if it does, we can't append and we can't continue searching due to causality.
        if batch
            .get_qubit_ids()
            .intersection(&op.get_qubit_ids())
            .next()
            .is_some()
        {
            return AppendSearchResult {
                can_append: false,
                can_continue_search: false,
            };
        }
        // next, check if there's space in this batch to append op. If there isn't, we can't append, but we can continue searching for an earlier batch that op might fit into.
        if batch.len() >= self.params.max_batch_size {
            return AppendSearchResult {
                can_append: false,
                can_continue_search: true,
            };
        }
        // next, check the type of the operations in this batch. If they aren't the same type as op, we can't append, but we can continue searching for an earlier batch that op might fit into.
        let same_type = batch.iter_ops().all(|batch_op| match (batch_op, op) {
            (Operation::RXYGate { .. }, Operation::RXYGate { .. }) => true,
            (Operation::RZGate { .. }, Operation::RZGate { .. }) => true,
            (Operation::RZZGate { .. }, Operation::RZZGate { .. }) => true,
            (Operation::Measure { .. }, Operation::Measure { .. }) => true,
            (Operation::MeasureLeaked { .. }, Operation::MeasureLeaked { .. }) => true,
            (Operation::Reset { .. }, Operation::Reset { .. }) => true,
            // don't allow custom ops to be batched, since we don't know their semantics
            _ => false,
        });
        if !same_type {
            AppendSearchResult {
                can_append: false,
                can_continue_search: true,
            }
        } else {
            AppendSearchResult {
                can_append: true,
                can_continue_search: true,
            }
        }
    }
}

// Keep scheduling and allocation under one lock so another thread can't see
// a queue update before its flush state has been updated too. Results have their
// own lock: the consumer can publish a value, and users can read it, without
// waiting for scheduling. When a call needs both locks, take state first and
// results second so two callers can't deadlock by taking them in opposite orders.
struct SoftRZRuntime {
    state: Mutex<SoftRZRuntimeState>,
    results: RwLock<Vec<FutureResult>>,
}

impl SoftRZRuntime {
    fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            state: Mutex::new(SoftRZRuntimeState::new(n_qubits, start, params)),
            results: RwLock::new(Vec::with_capacity(1000)),
        }
    }
}

impl RuntimeInterface for SoftRZRuntime {
    fn exit(&self) -> Result<()> {
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        state.operation_queue.clear();
        state.qubits.clear();
        state.flush_size = 0;
        results.clear();
        Ok(())
    }
    // Engine ops
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        let state = &mut *self.state.lock();
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
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        state.qubits = vec![QubitStatus::Free; state.qubits.len()];
        state.operation_queue.clear();
        state.flush_size = 0;
        results.clear();
        Ok(())
    }
    fn global_barrier(&self, _sleep_ns: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        state.flush_size = state.operation_queue.len();
        Ok(())
    }
    fn local_barrier(&self, qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        // Let the consumer collect every batch up to the last one touching
        // these qubits. A previous force request may cover more work, so keep
        // that larger range if one has already been requested.
        let qubits: std::collections::HashSet<u64> = qubits.iter().cloned().collect();
        let found = state
            .operation_queue
            .iter()
            .enumerate()
            .rev()
            .find(|(_, op)| op.get_qubit_ids().intersection(&qubits).next().is_some());
        if let Some((i, _)) = found {
            state.flush_size = state.flush_size.max(i + 1);
        }
        Ok(())
    }
    // Allocation
    fn qalloc(&self) -> Result<u64> {
        let state = &mut *self.state.lock();
        for (i, qubit) in state.qubits.iter_mut().enumerate() {
            if *qubit == QubitStatus::Free {
                *qubit = QubitStatus::Active { phase: 0.0 };
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
    fn rpp_gate(&self, _qubit_id_1: u64, _qubit_id_2: u64, _theta: f64, _phi: f64) -> Result<()> {
        bail!(
            "The RPP gate is not compatible with the SoftRZRuntime, as it relies on the properties of rz's interaction with (rxy, rzz)."
        );
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
        let state = &mut *self.state.lock();
        let mut results = self.results.write();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("leak-measuring out-of-bounds qubit {qubit_id}")
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
        let state = &mut *self.state.lock();
        if qubit_id >= state.qubits.len() as u64 {
            bail!("resetting out-of-bounds qubit {qubit_id}")
        }
        state.push(Operation::Reset { qubit_id });
        Ok(())
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        let state = &mut *self.state.lock();
        let results = self.results.read();
        if result_id >= results.len() as u64 {
            bail!("forcing out-of-bounds measurement {result_id}")
        }
        for (i, operation) in state.operation_queue.iter().enumerate().rev() {
            for op in operation.iter_ops() {
                if let Operation::Measure {
                    result_id: measure_result_id,
                    ..
                }
                | Operation::MeasureLeaked {
                    result_id: measure_result_id,
                    ..
                } = op
                    && result_id == *measure_result_id
                {
                    state.flush_size = std::cmp::max(state.flush_size, i + 1);
                    return Ok(());
                }
            }
        }
        // The consumer has already taken this measurement, so there is no work
        // left here to make available. Its value may still be pending.
        Ok(())
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let results = self.results.read();
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
    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        let mut results = self.results.write();
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize].value = if result { 1 } else { 0 };
        results[result_id as usize].is_set = true;
        Ok(())
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let results = self.results.read();
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
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        let mut results = self.results.write();
        if result_id >= results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        results[result_id as usize].value = result;
        results[result_id as usize].is_set = true;
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
struct SoftRZRuntimeFactory;

impl RuntimeInterfaceFactory for SoftRZRuntimeFactory {
    type Interface = SoftRZRuntime;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let args: Vec<String> = args.iter().map(|s| s.as_ref().to_string()).collect();

        match Params::try_parse_from(args) {
            Ok(params) => Ok(Box::new(SoftRZRuntime::new(n_qubits, start, params))),
            Err(e) => bail!("Failed to parse arguments for SoftRZRuntimeFactory: {e}"),
        }
    }
}

export_runtime_plugin!(crate::SoftRZRuntimeFactory);

#[cfg(test)]
#[path = "../../../../selene-core/tests/support/runtime_concurrency.rs"]
mod concurrency_support;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn concurrent_forcing_and_draining() {
        let runtime = selene_core::runtime::Runtime::from_boxed(Box::new(SoftRZRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
                max_batch_size: 8,
            },
        )));
        runtime.shot_start(0, 0).unwrap();
        concurrency_support::exercise(&runtime);
        runtime.shot_end().unwrap();
    }

    #[test]
    fn result_publication_does_not_take_scheduling_lock() {
        let runtime = SoftRZRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
                max_batch_size: 8,
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
        let runtime = SoftRZRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
                max_batch_size: 8,
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
        let runtime = SoftRZRuntime::new(
            4,
            Default::default(),
            Params {
                duration_ns_rxy: 1,
                duration_ns_rzz: 1,
                duration_ns_measure: 1,
                duration_ns_reset: 1,
                duration_ns_measure_leaked: 1,
                max_batch_size: 8,
            },
        );
        let qubit = runtime.qalloc().unwrap();
        runtime.rz_gate(qubit, 0.25).unwrap();
        runtime.rxy_gate(qubit, 0.5, 0.75).unwrap();
        runtime.global_barrier(0).unwrap();
        let rxy = runtime.get_next_operations().unwrap().unwrap();
        assert!(
            matches!(rxy.iter_ops().next(), Some(Operation::RXYGate { theta, phi, .. }) if *theta == 0.5 && *phi == 0.5)
        );
        assert!(runtime.get_next_operations().unwrap().is_none());
    }
}
