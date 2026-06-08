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

struct SoftRZRuntime {
    qubits: Vec<QubitStatus>,
    operation_queue: VecDeque<BatchOperation>,
    flush_size: usize,
    future_results: Vec<FutureResult>,
    start: selene_core::time::Instant,
    params: Params,
}

struct AppendSearchResult {
    can_append: bool,
    can_continue_search: bool,
}

impl SoftRZRuntime {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            qubits: vec![QubitStatus::Free; n_qubits as usize],
            operation_queue: VecDeque::with_capacity(10000),
            flush_size: 0,
            future_results: Vec::with_capacity(1000),
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

impl RuntimeInterface for SoftRZRuntime {
    fn exit(&mut self) -> Result<()> {
        self.operation_queue.clear();
        self.qubits.clear();
        self.flush_size = 0;
        self.future_results.clear();
        Ok(())
    }
    // Engine ops
    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        debug_assert!(
            self.flush_size <= self.operation_queue.len(),
            "flush size is greater than operation queue length"
        );
        if self.flush_size == 0 {
            return Ok(None);
        }
        self.flush_size -= 1;
        Ok(self.operation_queue.pop_front())
    }

    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        self.qubits = vec![QubitStatus::Free; self.qubits.len()];
        self.operation_queue.clear();
        self.flush_size = 0;
        self.future_results.clear();
        Ok(())
    }
    fn global_barrier(&mut self, _sleep_ns: u64) -> Result<()> {
        self.flush_size = self.operation_queue.len();
        Ok(())
    }
    fn local_barrier(&mut self, qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        // search backwards through the operation queue for the last operation that uses any of the barrier's qubits.
        // All operations up to and including that operation can be flushed.
        //
        // then set self.flush_size to the number of operations that can be flushed.
        // flush_size is kept monotonic to avoid reducing a previously larger flush window.
        let qubits: std::collections::HashSet<u64> = qubits.iter().cloned().collect();
        let found = self
            .operation_queue
            .iter()
            .enumerate()
            .rev()
            .find(|(_, op)| op.get_qubit_ids().intersection(&qubits).next().is_some());
        if let Some((i, _)) = found {
            self.flush_size = self.flush_size.max(i + 1);
        }
        Ok(())
    }
    // Allocation
    fn qalloc(&mut self) -> Result<u64> {
        for (i, qubit) in self.qubits.iter_mut().enumerate() {
            if *qubit == QubitStatus::Free {
                *qubit = QubitStatus::Active { phase: 0.0 };
                return Ok(i as u64);
            }
        }
        Ok(u64::MAX)
    }
    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("freeing out-of-bounds qubit {qubit_id}")
        } else {
            self.qubits[qubit_id as usize] = QubitStatus::Free;
            Ok(())
        }
    }
    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("applying rxy gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active { phase } = self.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        self.push(Operation::RXYGate {
            qubit_id,
            theta,
            phi: phi - phase, // The Z phase is enacted here.
        });
        Ok(())
    }
    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        if qubit_id_1 >= self.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= self.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        self.push(Operation::RZZGate {
            qubit_id_1,
            qubit_id_2,
            theta,
        });
        Ok(())
    }
    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("applying rz gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active { phase } = self.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        // We don't apply an RZ gate. Instead, we accumulate a phase, and mutate
        // RXY gates' phi parameters to account for the phase shift. RZZ and measurement
        // are unaffected.
        self.qubits[qubit_id as usize] = QubitStatus::Active {
            phase: phase + theta,
        };
        Ok(())
    }
    fn rpp_gate(
        &mut self,
        _qubit_id_1: u64,
        _qubit_id_2: u64,
        _theta: f64,
        _phi: f64,
    ) -> Result<()> {
        bail!(
            "The RPP gate is not compatible with the SoftRZRuntime, as it relies on the properties of rz's interaction with (rxy, rzz)."
        );
    }
    // Lifetime ops
    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = self.future_results.len() as u64;
        self.future_results.push(FutureResult {
            is_set: false,
            value: 0,
        });
        self.push(Operation::Measure {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }
    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("leak-measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = self.future_results.len() as u64;
        self.future_results.push(FutureResult {
            is_set: false,
            value: 0,
        });
        self.push(Operation::MeasureLeaked {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("resetting out-of-bounds qubit {qubit_id}")
        }
        self.push(Operation::Reset { qubit_id });
        Ok(())
    }
    fn force_result(&mut self, result_id: u64) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("forcing out-of-bounds measurement {result_id}")
        }
        for (i, operation) in self.operation_queue.iter().enumerate().rev() {
            for op in operation.iter_ops() {
                if let Operation::Measure {
                    result_id: measure_result_id,
                    ..
                } = op
                    && result_id == *measure_result_id
                {
                    self.flush_size = std::cmp::max(self.flush_size, i + 1);
                    return Ok(());
                }
            }
        }
        Ok(()) // If the measurement isn't in the queue, it has already been forced.
    }
    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        if result_id >= self.future_results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &self.future_results[result_id as usize];
        Ok(if result.is_set {
            Some(result.value > 0)
        } else {
            None
        })
    }
    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        self.future_results[result_id as usize].value = if result { 1 } else { 0 };
        self.future_results[result_id as usize].is_set = true;
        Ok(())
    }
    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        if result_id >= self.future_results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &self.future_results[result_id as usize];
        Ok(if result.is_set {
            Some(result.value)
        } else {
            None
        })
    }
    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        self.future_results[result_id as usize].value = result;
        self.future_results[result_id as usize].is_set = true;
        Ok(())
    }

    fn increment_future_refcount(&mut self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn decrement_future_refcount(&mut self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn get_metric(&mut self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        self.start += selene_core::time::Duration::from(delay_ns);
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
