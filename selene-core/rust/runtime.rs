pub mod helper;
pub mod interface;
pub mod plugin;
pub mod version;

use std::collections::HashSet;
use std::{iter, sync};

use anyhow::Result;
use delegate::delegate;
pub use interface::{RuntimeInterface, RuntimeInterfaceFactory};
pub use version::RuntimeAPIVersion;

/// We assume that operations of the same type can be done in parallel.
/// The level of parallelism is decided by the runtime - i.e. it can
/// choose to provide just one element at a time, or up to some limit N,
/// or even an unbounded number.
///
/// [BatchOperation]s are provided to the error model, as it may
/// find this information pertinent. However, there is no requirement
/// that simulation of the operations itself is done in parallel; in fact,
/// the interface is currently limited to individual operations, but this
/// may change in future if it is found to be beneficial for performance.
#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
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

/// Opaque per-op metadata handle threaded from selene's user-program
/// boundary through the runtime and back out via [`BatchOperation`].
///
/// The handle is a plain `u64` on the wire. The sentinel value `0`
/// means "no metadata"; non-zero values are issued by selene and are
/// meaningful only to selene (the runtime must treat them as opaque).
pub type OpMetadata = u64;

/// Sentinel meaning "no metadata attached to this op".
pub const NO_METADATA: OpMetadata = 0;

#[derive(Default, Clone, Debug)]
pub struct BatchOperation {
    ops: Vec<Operation>,
    /// Parallel to `ops`; carries an opaque metadata handle (or
    /// [`NO_METADATA`]) for each op.
    metadata: Vec<OpMetadata>,
    start: crate::time::Instant,
    duration: crate::time::Duration,
}

impl BatchOperation {
    delegate! {
        to self.ops {
            pub fn len(&self) -> usize;
            pub fn is_empty(&self) -> bool;
            #[call(iter)]
            pub fn iter_ops(&self) -> impl iter::DoubleEndedIterator<Item=&Operation> + '_;
        }
    }

    pub fn iter_metadata(&self) -> impl iter::DoubleEndedIterator<Item = OpMetadata> + '_ {
        self.metadata.iter().copied()
    }

    pub fn iter_ops_with_metadata(
        &self,
    ) -> impl iter::DoubleEndedIterator<Item = (&Operation, OpMetadata)> + '_ {
        self.ops.iter().zip(self.metadata.iter().copied())
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

    /// Construct a batch where every op has [`NO_METADATA`].
    pub fn new(
        ops: Vec<Operation>,
        start: crate::time::Instant,
        duration: crate::time::Duration,
    ) -> Self {
        let metadata = vec![NO_METADATA; ops.len()];
        Self {
            ops,
            metadata,
            start,
            duration,
        }
    }

    /// Construct a batch from parallel `ops` + `metadata` vectors. The
    /// two must have the same length.
    pub fn new_with_metadata(
        ops: Vec<Operation>,
        metadata: Vec<OpMetadata>,
        start: crate::time::Instant,
        duration: crate::time::Duration,
    ) -> Self {
        assert_eq!(
            ops.len(),
            metadata.len(),
            "BatchOperation: ops and metadata length mismatch"
        );
        Self {
            ops,
            metadata,
            start,
            duration,
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

    /// Add an op with no associated metadata.
    pub fn add_operation(&mut self, op: Operation) {
        self.ops.push(op);
        self.metadata.push(NO_METADATA);
    }

    /// Add an op together with an opaque metadata handle.
    pub fn add_operation_with_metadata(&mut self, op: Operation, metadata: OpMetadata) {
        self.ops.push(op);
        self.metadata.push(metadata);
    }
}

impl IntoIterator for BatchOperation {
    type Item = Operation;

    type IntoIter = <Vec<Operation> as IntoIterator>::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        self.ops.into_iter()
    }
}

/// An instance of a runtime plugin, ready to be used for emulation.
///
/// `Runtime`'s impl [RuntimeInterface] delegates to a wrapped `dyn
/// RuntimeInterface`.
///
/// Usually the wrapped [RuntimeInterface] will be an instance
/// delegating to an external runtime plugin as defined by
/// [plugin::RuntimeInterfacePlugin)].
pub struct Runtime(Box<dyn RuntimeInterface>);

impl Runtime {
    /// Constructs a new Runtime from a [RuntimeInterfaceFactory].
    pub fn new(
        factory: sync::Arc<impl RuntimeInterfaceFactory + 'static>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        Ok(Self(factory.init(n_qubits, start, args)?))
    }
}

impl AsRef<dyn RuntimeInterface> for Runtime {
    fn as_ref(&self) -> &(dyn RuntimeInterface + 'static) {
        self.0.as_ref()
    }
}

impl AsMut<dyn RuntimeInterface> for Runtime {
    fn as_mut(&mut self) -> &mut (dyn RuntimeInterface + 'static) {
        &mut *self.0
    }
}

impl RuntimeInterface for Runtime {
    delegate! {
        to self.0.as_mut() {
            fn exit(&mut self) -> Result<()>;
            fn get_next_operations(&mut self) -> Result<Option<BatchOperation>>;
            fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()>;
            fn shot_end(&mut self) -> Result<()>;
            fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, crate::utils::MetricValue)>>;
            fn qalloc(&mut self) -> Result<u64>;
            fn qfree(&mut self, qubit_id: u64) -> Result<()>;
            fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()>;
            fn global_barrier(&mut self, sleep_ns: u64) -> Result<()>;
            fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64, metadata: OpMetadata) -> Result<()>;
            fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, metadata: OpMetadata) -> Result<()>;
            fn rz_gate(&mut self, qubit_id: u64, theta: f64, metadata: OpMetadata) -> Result<()>;
            fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64, metadata: OpMetadata) -> Result<()>;
            fn tk2_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, alpha: f64, beta: f64, gamma: f64, metadata: OpMetadata) -> Result<()>;
            fn measure(&mut self, qubit_id: u64, metadata: OpMetadata) -> Result<u64>;
            fn measure_leaked(&mut self, qubit_id: u64, metadata: OpMetadata) -> Result<u64>;
            fn reset(&mut self, qubit_id: u64, metadata: OpMetadata) -> Result<()>;
            fn force_result(&mut self, result_id: u64) -> Result<()>;
            fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>>;
            fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()>;
            fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>>;
            fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()>;
            fn increment_future_refcount(&mut self, future: u64) -> Result<()>;
            fn decrement_future_refcount(&mut self, future: u64) -> Result<()>;
            fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64>;
            fn simulate_delay(&mut self, delay_ns: u64) -> Result<()>;
        }
    }
}
