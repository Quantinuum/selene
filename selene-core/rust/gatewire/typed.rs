use crate::gatewire::{DynamicGateSet, GateDecl, GateError, GateSemanticId, OwnedGateInstance};
use std::marker::PhantomData;

pub trait GateSpec: Clone + Sized {
    fn id_text() -> &'static str;
    fn name() -> &'static str;
    fn version() -> u32;

    fn semantic_id() -> GateSemanticId {
        GateSemanticId::from_text(Self::id_text())
    }
    fn declaration() -> GateDecl;
    fn to_instance(&self) -> OwnedGateInstance;
    fn try_from_instance(instance: &OwnedGateInstance) -> Result<Option<Self>, GateError>;
}

pub trait GateSetSpec: Clone + Sized {
    fn declarations() -> Vec<GateDecl>;
    fn to_instance(&self) -> OwnedGateInstance;
    fn try_from_instance(instance: &OwnedGateInstance) -> Result<Option<Self>, GateError>;
}

pub trait GateView: Sized {
    type GateSet: GateSetSpec;

    fn from_gate(gate: Self::GateSet) -> Self;
}

#[derive(Clone, Debug, PartialEq)]
#[allow(clippy::large_enum_variant)]
pub enum TryDecode<G> {
    Decoded(G),
    Unknown(OwnedGateInstance),
}

#[derive(Clone, Debug)]
pub struct GateSet<G: GateSetSpec> {
    dynamic: DynamicGateSet,
    _marker: PhantomData<G>,
}

impl<G: GateSetSpec> GateSet<G> {
    pub fn new() -> Result<Self, GateError> {
        Ok(Self {
            dynamic: DynamicGateSet::from_declarations(G::declarations())?,
            _marker: PhantomData,
        })
    }

    pub fn dynamic(&self) -> &DynamicGateSet {
        &self.dynamic
    }

    pub fn serialize_gate(&self, gate: &G) -> Result<Vec<u8>, GateError> {
        let instance = gate.to_instance();
        if !self.dynamic.validate_instance(&instance)? {
            return Err(GateError::UnknownGate);
        }
        Ok(instance.serialize())
    }

    pub fn decode(&self, data: &[u8]) -> Result<TryDecode<G>, GateError> {
        let instance = OwnedGateInstance::deserialize(data)?;
        if !self.dynamic.validate_instance(&instance)? {
            return Ok(TryDecode::Unknown(instance));
        }
        match G::try_from_instance(&instance)? {
            Some(gate) => Ok(TryDecode::Decoded(gate)),
            None => Ok(TryDecode::Unknown(instance)),
        }
    }

    /// Deserializes a wire gate and attempts to return the concrete enum for this gateset.
    ///
    /// Ok(None) means the bytes were a valid gate instance, but not one in this gateset.
    /// Err means malformed bytes or a schema mismatch for a gate that claims to be in this gateset.
    pub fn try_deserialize(&self, data: &[u8]) -> Result<Option<G>, GateError> {
        match self.decode(data)? {
            TryDecode::Decoded(gate) => Ok(Some(gate)),
            TryDecode::Unknown(_) => Ok(None),
        }
    }

    pub fn serialize_gateset(&self) -> Vec<u8> {
        self.dynamic.serialize()
    }
}
