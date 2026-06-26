use std::collections::VecDeque;

use anyhow::{Result, bail};
use selene_core::gatewire::{DynamicGateSet, OwnedGateInstance};
use selene_core::runtime::{
    BatchOperation, Operation, RuntimeInterface, interface::RuntimeInterfaceFactory,
};
use selene_core::utils::MetricValue;

use crate::gates::{clifford_t_gateset, decode_clifford_t, gate_qubits, require_clifford_t};

#[derive(Clone, Debug, PartialEq)]
enum QueuedOperation {
    Gate(OwnedGateInstance),
    Measure { qubit_id: u64, result_id: u64 },
    Reset { qubit_id: u64 },
}

#[derive(Debug)]
pub struct CliffordTRuntime {
    n_qubits: u64,
    allocated: Vec<bool>,
    queue: VecDeque<QueuedOperation>,
    ready: usize,
    next_result: u64,
    results: Vec<Option<u64>>,
    start: selene_core::time::Instant,
}

impl CliffordTRuntime {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant) -> Self {
        Self {
            n_qubits,
            allocated: vec![false; n_qubits as usize],
            queue: VecDeque::new(),
            ready: 0,
            next_result: 0,
            results: Vec::new(),
            start,
        }
    }

    fn check_qubit(&self, q: u64) -> Result<()> {
        if q >= self.n_qubits {
            bail!("qubit {q} is out of bounds");
        }
        if !self.allocated[q as usize] {
            bail!("qubit {q} is not allocated");
        }
        Ok(())
    }

    fn operation_from_queued(queued: QueuedOperation) -> Result<Operation> {
        match queued {
            QueuedOperation::Gate(gate) => Operation::from_gate_instance(gate),
            QueuedOperation::Measure {
                qubit_id,
                result_id,
            } => Ok(Operation::Measure {
                qubit_id,
                result_id,
            }),
            QueuedOperation::Reset { qubit_id } => Ok(Operation::Reset { qubit_id }),
        }
    }
}

impl RuntimeInterface for CliffordTRuntime {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        if self.ready == 0 {
            return Ok(None);
        }
        self.ready -= 1;
        let Some(queued) = self.queue.pop_front() else {
            return Ok(None);
        };
        Ok(Some(BatchOperation::runtime(
            vec![Self::operation_from_queued(queued)?],
            self.start,
            Default::default(),
        )))
    }

    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
        self.queue.clear();
        self.ready = 0;
        self.next_result = 0;
        self.results.clear();
        self.allocated.fill(false);
        Ok(())
    }

    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        require_clifford_t(gateset)?;
        Ok(clifford_t_gateset())
    }

    fn gate(&mut self, gate: &OwnedGateInstance) -> Result<()> {
        decode_clifford_t(gate)?;
        for q in gate_qubits(gate) {
            self.check_qubit(q)?;
        }
        self.queue.push_back(QueuedOperation::Gate(gate.clone()));
        Ok(())
    }

    fn qalloc(&mut self) -> Result<u64> {
        for (index, allocated) in self.allocated.iter_mut().enumerate() {
            if !*allocated {
                *allocated = true;
                return Ok(index as u64);
            }
        }
        Ok(u64::MAX)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        self.check_qubit(qubit_id)?;
        self.allocated[qubit_id as usize] = false;
        Ok(())
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        self.check_qubit(qubit_id)?;
        let result_id = self.next_result;
        self.next_result += 1;
        self.results.push(None);
        self.queue.push_back(QueuedOperation::Measure {
            qubit_id,
            result_id,
        });
        Ok(result_id)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        self.measure(qubit_id)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        self.check_qubit(qubit_id)?;
        self.queue.push_back(QueuedOperation::Reset { qubit_id });
        Ok(())
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        if result_id as usize >= self.results.len() {
            bail!("unknown result id {result_id}");
        }
        self.ready = self.queue.len();
        Ok(())
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        Ok(self
            .results
            .get(result_id as usize)
            .and_then(|value| value.map(|value| value != 0)))
    }

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        Ok(self
            .results
            .get(result_id as usize)
            .and_then(|value| *value))
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        let Some(slot) = self.results.get_mut(result_id as usize) else {
            bail!("unknown result id {result_id}");
        };
        *slot = Some(result.into());
        Ok(())
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        let Some(slot) = self.results.get_mut(result_id as usize) else {
            bail!("unknown result id {result_id}");
        };
        *slot = Some(result);
        Ok(())
    }

    fn increment_future_refcount(&mut self, _future: u64) -> Result<()> {
        Ok(())
    }

    fn decrement_future_refcount(&mut self, _future: u64) -> Result<()> {
        Ok(())
    }

    fn get_metric(&mut self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }

    fn local_barrier(&mut self, _qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        self.ready = self.queue.len();
        Ok(())
    }

    fn global_barrier(&mut self, _sleep_ns: u64) -> Result<()> {
        self.ready = self.queue.len();
        Ok(())
    }
}

#[derive(Default)]
pub struct CliffordTRuntimeFactory;

impl RuntimeInterfaceFactory for CliffordTRuntimeFactory {
    type Interface = CliffordTRuntime;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        _args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::new(CliffordTRuntime::new(n_qubits, start)))
    }
}

selene_core::export_runtime_plugin!(crate::CliffordTRuntimeFactory);
