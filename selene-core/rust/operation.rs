pub mod plugin;

use std::collections::HashSet;
use std::iter;

use crate::gatewire::{Angle, GateSetSpec, GateSpec, GateView, OwnedGateInstance, Qubit, builtin};
use anyhow::{Result, bail};

pub use plugin::{
    BatchBuilder, BatchExtractor, OperationResultBuilder, OperationResultHandle,
    OperationResultInstance, OperationResultInterface, RuntimeExtractOperationInstance,
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
pub enum BuiltinGate {
    RZ {
        qubit_id: u64,
        theta: f64,
    },
    PhasedX {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    ZZPhase {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
    PhasedXX {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
}

#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
#[repr(C)]
pub enum Operation {
    Measure { qubit_id: u64, result_id: u64 },
    Postselect { qubit_id: u64, target_value: bool },
    Reset { qubit_id: u64 },
    Custom { custom_tag: usize, data: Box<[u8]> },
    MeasureLeaked { qubit_id: u64, result_id: u64 },
    Gate { gate: OwnedGateInstance },
}

impl Operation {
    pub fn from_gate_instance(gate: OwnedGateInstance) -> Result<Self> {
        Ok(Self::Gate { gate })
    }

    fn qubit(qubit_id: u64) -> Result<Qubit> {
        Ok(Qubit(qubit_id.try_into()?))
    }

    pub fn rz(qubit_id: u64, theta: f64) -> Result<Self> {
        Ok(Self::Gate {
            gate: builtin::RZ {
                q0: Self::qubit(qubit_id)?,
                theta: Angle(theta),
            }
            .to_instance(),
        })
    }

    pub fn phased_x(qubit_id: u64, theta: f64, phi: f64) -> Result<Self> {
        Ok(Self::Gate {
            gate: builtin::PhasedX {
                q0: Self::qubit(qubit_id)?,
                theta: Angle(theta),
                phi: Angle(phi),
            }
            .to_instance(),
        })
    }

    pub fn zz_phase(qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<Self> {
        Ok(Self::Gate {
            gate: builtin::ZZPhase {
                q0: Self::qubit(qubit_id_1)?,
                q1: Self::qubit(qubit_id_2)?,
                theta: Angle(theta),
            }
            .to_instance(),
        })
    }

    pub fn phased_xx(qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<Self> {
        Ok(Self::Gate {
            gate: builtin::PhasedXX {
                q0: Self::qubit(qubit_id_1)?,
                q1: Self::qubit(qubit_id_2)?,
                theta: Angle(theta),
                phi: Angle(phi),
            }
            .to_instance(),
        })
    }

    pub fn to_gate_instance(&self) -> Result<OwnedGateInstance> {
        match self {
            Self::Gate { gate } => Ok(gate.clone()),
            _ => bail!("operation is not a gate"),
        }
    }

    pub fn with_gate_metadata_from(mut self, source: &OwnedGateInstance) -> Self {
        if let Self::Gate { gate } = &mut self {
            gate.metadata = source.metadata.clone();
        }
        self
    }

    pub fn as_gate<G: GateSetSpec>(&self) -> Result<Option<G>> {
        let Self::Gate { gate } = self else {
            return Ok(None);
        };
        Ok(G::try_from_instance(gate)?)
    }

    pub fn gate_as<G: GateSetSpec>(gate: &OwnedGateInstance) -> Result<Option<G>> {
        Ok(G::try_from_instance(gate)?)
    }

    pub fn as_gate_view<V: GateView>(&self) -> Result<Option<V>> {
        Ok(self.as_gate::<V::GateSet>()?.map(V::from_gate))
    }

    pub fn gate_as_view<V: GateView>(gate: &OwnedGateInstance) -> Result<Option<V>> {
        Ok(Self::gate_as::<V::GateSet>(gate)?.map(V::from_gate))
    }

    pub fn as_builtin_gate(&self) -> Result<Option<BuiltinGate>> {
        let Self::Gate { gate } = self else {
            return Ok(None);
        };
        if let Some(gate) = builtin::RZ::try_from_instance(gate)? {
            return Ok(Some(BuiltinGate::RZ {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
            }));
        }
        if let Some(gate) = builtin::PhasedX::try_from_instance(gate)? {
            return Ok(Some(BuiltinGate::PhasedX {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            }));
        }
        if let Some(gate) = builtin::ZZPhase::try_from_instance(gate)? {
            return Ok(Some(BuiltinGate::ZZPhase {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
            }));
        }
        if let Some(gate) = builtin::PhasedXX::try_from_instance(gate)? {
            return Ok(Some(BuiltinGate::PhasedXX {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            }));
        }
        Ok(None)
    }

    pub fn get_qubit_ids(&self) -> HashSet<u64> {
        match self {
            Operation::Measure { qubit_id, .. }
            | Operation::Postselect { qubit_id, .. }
            | Operation::Reset { qubit_id }
            | Operation::MeasureLeaked { qubit_id, .. } => {
                let mut set = HashSet::new();
                set.insert(*qubit_id);
                set
            }
            Operation::Gate { gate } => gate
                .operands
                .iter()
                .filter_map(|operand| match operand {
                    crate::gatewire::GateValue::Qubit(q) => Some((*q).into()),
                    _ => None,
                })
                .collect(),
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
