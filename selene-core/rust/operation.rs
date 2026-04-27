pub mod plugin;

use std::collections::HashSet;
use std::iter;

pub use plugin::{
    BatchBuilder, BatchExtractor, RuntimeExtractOperationInstance,
    RuntimeExtractOperationInterface, RuntimeGetOperationInstance, RuntimeGetOperationInterface,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub struct ErrorModelBatchSource;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub struct SimulatorBatchSource;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub struct RuntimeBatchSource {
    start: crate::time::Instant,
    duration: crate::time::Duration,
}

impl RuntimeBatchSource {
    pub fn new(start: crate::time::Instant, duration: crate::time::Duration) -> Self {
        Self { start, duration }
    }

    pub fn start(&self) -> crate::time::Instant {
        self.start
    }

    pub fn end(&self) -> crate::time::Instant {
        self.start + self.duration
    }

    pub fn duration(&self) -> crate::time::Duration {
        self.duration
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[non_exhaustive]
pub enum BatchSource {
    Runtime(RuntimeBatchSource),
    ErrorModel(ErrorModelBatchSource),
    Simulator(SimulatorBatchSource),
}

impl Default for BatchSource {
    fn default() -> Self {
        Self::Simulator(SimulatorBatchSource)
    }
}

#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
#[repr(C)]
pub enum Operation {
    Measure {
        qubit_id: u64,
        result_id: u64,
    },
    Reset {
        qubit_id: u64,
    },
    RXYGate {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    RZGate {
        qubit_id: u64,
        theta: f64,
    },
    RZZGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
    Custom {
        custom_tag: usize,
        data: Box<[u8]>,
    },
    MeasureLeaked {
        qubit_id: u64,
        result_id: u64,
    },
    RPPGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
    TK2Gate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    },
}

impl Operation {
    pub fn get_qubit_ids(&self) -> HashSet<u64> {
        match self {
            Operation::Measure { qubit_id, .. }
            | Operation::Reset { qubit_id }
            | Operation::RXYGate { qubit_id, .. }
            | Operation::RZGate { qubit_id, .. }
            | Operation::MeasureLeaked { qubit_id, .. } => {
                let mut set = HashSet::new();
                set.insert(*qubit_id);
                set
            }
            Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                ..
            }
            | Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                ..
            }
            | Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                ..
            } => {
                let mut set = HashSet::new();
                set.insert(*qubit_id_1);
                set.insert(*qubit_id_2);
                set
            }
            Operation::Custom { .. } => HashSet::new(),
        }
    }
}

#[derive(Default, Clone, Debug)]
pub struct BatchOperation {
    ops: Vec<Operation>,
    source: BatchSource,
}

impl BatchOperation {
    pub fn len(&self) -> usize {
        self.ops.len()
    }

    pub fn is_empty(&self) -> bool {
        self.ops.is_empty()
    }

    pub fn iter_ops(&self) -> impl iter::DoubleEndedIterator<Item = &Operation> + '_ {
        self.ops.iter()
    }

    pub fn source(&self) -> BatchSource {
        self.source
    }

    pub fn runtime_source(&self) -> Option<RuntimeBatchSource> {
        match self.source {
            BatchSource::Runtime(source) => Some(source),
            _ => None,
        }
    }

    pub fn runtime(
        ops: Vec<Operation>,
        start: crate::time::Instant,
        duration: crate::time::Duration,
    ) -> Self {
        Self::runtime_with_source(ops, RuntimeBatchSource::new(start, duration))
    }

    pub fn runtime_with_source(ops: Vec<Operation>, source: RuntimeBatchSource) -> Self {
        Self {
            ops,
            source: BatchSource::Runtime(source),
        }
    }

    pub fn error_model(ops: Vec<Operation>) -> Self {
        Self {
            ops,
            source: BatchSource::ErrorModel(ErrorModelBatchSource),
        }
    }

    pub fn simulator(ops: Vec<Operation>) -> Self {
        Self {
            ops,
            source: BatchSource::Simulator(SimulatorBatchSource),
        }
    }

    pub fn get_qubit_ids(&self) -> HashSet<u64> {
        self.ops.iter().fold(HashSet::new(), |mut acc, op| {
            for qubit_id in op.get_qubit_ids() {
                acc.insert(qubit_id);
            }
            acc
        })
    }

    pub fn add_operation(&mut self, op: Operation) {
        self.ops.push(op);
    }
}

impl IntoIterator for BatchOperation {
    type Item = Operation;
    type IntoIter = <Vec<Operation> as IntoIterator>::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        self.ops.into_iter()
    }
}
