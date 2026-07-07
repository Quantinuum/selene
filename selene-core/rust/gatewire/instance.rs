use crate::gatewire::{
    GateError, GateMetadata, GateSemanticId, GateValue, MetadataValue, SmallGateMetadata,
    SmallGateValues, wire,
};

#[derive(Clone, Debug, PartialEq)]
pub struct OwnedGateInstance {
    pub semantic_id: GateSemanticId,
    pub operands: SmallGateValues,
    pub metadata: SmallGateMetadata,
}

impl OwnedGateInstance {
    pub fn new<I>(semantic_id: GateSemanticId, operands: I) -> Self
    where
        I: IntoIterator<Item = GateValue>,
    {
        Self {
            semantic_id,
            operands: operands.into_iter().collect(),
            metadata: SmallGateMetadata::new(),
        }
    }

    pub fn with_metadata(
        mut self,
        key: impl Into<String>,
        value: impl Into<MetadataValue>,
    ) -> Self {
        self.set_metadata(key, value);
        self
    }

    pub fn set_metadata(&mut self, key: impl Into<String>, value: impl Into<MetadataValue>) {
        let key = key.into();
        if let Some(entry) = self.metadata.iter_mut().find(|entry| entry.key == key) {
            entry.value = value.into();
        } else {
            self.metadata.push(GateMetadata::new(key, value));
        }
    }

    pub fn metadata(&self, key: &str) -> Option<&MetadataValue> {
        self.metadata
            .iter()
            .find(|entry| entry.key == key)
            .map(|entry| &entry.value)
    }

    pub fn metadata_iter(&self) -> impl ExactSizeIterator<Item = (&str, &MetadataValue)> + '_ {
        self.metadata
            .iter()
            .map(|entry| (entry.key.as_str(), &entry.value))
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
