use crate::gatewire::{GateDecl, GateError, GateSemanticId, OwnedGateInstance, wire};
use indexmap::IndexMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct LocalGateId(pub u32);

#[derive(Clone, Debug)]
pub struct DynamicGateSet {
    declarations: IndexMap<GateSemanticId, GateDecl>,
}

impl DynamicGateSet {
    pub fn new() -> Self {
        Self {
            declarations: IndexMap::new(),
        }
    }

    pub fn from_declarations<I>(declarations: I) -> Result<Self, GateError>
    where
        I: IntoIterator<Item = GateDecl>,
    {
        let mut set = Self::new();
        for decl in declarations {
            set.add(decl)?;
        }
        Ok(set)
    }

    pub fn add(&mut self, decl: GateDecl) -> Result<LocalGateId, GateError> {
        if self.declarations.contains_key(&decl.semantic_id) {
            return Err(GateError::DuplicateGate(decl.name));
        }
        let local_id = LocalGateId(self.declarations.len() as u32);
        self.declarations.insert(decl.semantic_id, decl);
        Ok(local_id)
    }

    pub fn len(&self) -> usize {
        self.declarations.len()
    }
    pub fn is_empty(&self) -> bool {
        self.declarations.is_empty()
    }
    pub fn declarations(&self) -> impl ExactSizeIterator<Item = &GateDecl> + '_ {
        self.declarations.values()
    }
    pub fn declaration(&self, id: GateSemanticId) -> Option<&GateDecl> {
        self.declarations.get(&id)
    }
    pub fn declaration_at(&self, index: usize) -> Option<&GateDecl> {
        self.declarations.get_index(index).map(|(_, decl)| decl)
    }
    pub fn local_id(&self, id: GateSemanticId) -> Option<LocalGateId> {
        self.declarations
            .get_index_of(&id)
            .map(|index| LocalGateId(index as u32))
    }
    pub fn contains(&self, id: GateSemanticId) -> bool {
        self.declarations.contains_key(&id)
    }

    pub fn is_subset_of(&self, other: &Self) -> bool {
        self.declarations
            .keys()
            .all(|semantic_id| other.contains(*semantic_id))
    }

    pub fn is_superset_of(&self, other: &Self) -> bool {
        other.is_subset_of(self)
    }

    pub fn first_unsupported_by(&self, supported: &Self) -> Option<&GateDecl> {
        self.declarations()
            .find(|decl| !supported.contains(decl.semantic_id))
    }

    /// Returns Ok(false) when the gate is well-formed but not in this gateset.
    /// Returns Err when the gate claims to be in this gateset but has invalid operands.
    pub fn validate_instance(&self, gate: &OwnedGateInstance) -> Result<bool, GateError> {
        let Some(decl) = self.declaration(gate.semantic_id) else {
            return Ok(false);
        };
        if decl.operands.len() != gate.operands.len() {
            return Err(GateError::WrongArity {
                gate: decl.name.clone(),
                expected: decl.operands.len(),
                actual: gate.operands.len(),
            });
        }
        for (index, (expected, actual)) in
            decl.operands.iter().zip(gate.operands.iter()).enumerate()
        {
            if expected.kind != actual.kind() {
                return Err(GateError::WrongOperandKind {
                    gate: decl.name.clone(),
                    index,
                    expected: expected.kind,
                    actual: actual.kind(),
                });
            }
        }
        Ok(true)
    }

    pub fn serialize(&self) -> Vec<u8> {
        wire::serialize_gateset(self)
    }
    pub fn deserialize(data: &[u8]) -> Result<Self, GateError> {
        wire::deserialize_gateset(data)
    }
}

impl Default for DynamicGateSet {
    fn default() -> Self {
        Self::new()
    }
}
