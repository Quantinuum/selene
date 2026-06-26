use crate::gatewire::{GateError, GateSemanticId, GateValue, SmallGateValues, wire};

#[derive(Clone, Debug, PartialEq)]
pub struct OwnedGateInstance {
    pub semantic_id: GateSemanticId,
    pub operands: SmallGateValues,
}

impl OwnedGateInstance {
    pub fn new<I>(semantic_id: GateSemanticId, operands: I) -> Self
    where
        I: IntoIterator<Item = GateValue>,
    {
        Self {
            semantic_id,
            operands: operands.into_iter().collect(),
        }
    }

    pub fn qubit_operands(&self) -> impl Iterator<Item = u32> + '_ {
        self.operands.iter().filter_map(|value| match value {
            GateValue::Qubit(qubit) => Some(*qubit),
            _ => None,
        })
    }

    pub fn qubit_operand_count(&self) -> usize {
        self.qubit_operands().count()
    }

    pub fn single_qubit_operand(&self) -> Option<u32> {
        let mut qubits = self.qubit_operands();
        let qubit = qubits.next()?;
        if qubits.next().is_none() {
            Some(qubit)
        } else {
            None
        }
    }

    pub fn serialize(&self) -> Vec<u8> {
        wire::serialize_gate_instance(self)
    }
    pub fn deserialize(data: &[u8]) -> Result<Self, GateError> {
        wire::deserialize_gate_instance(data)
    }
}
