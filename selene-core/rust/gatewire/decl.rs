use crate::gatewire::{GateSemanticId, OperandKind};
use smallvec::SmallVec;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct OperandSpec {
    pub name: String,
    pub kind: OperandKind,
}

pub type SmallOperandSpecs = SmallVec<[OperandSpec; 4]>;

impl OperandSpec {
    pub fn new(name: impl Into<String>, kind: OperandKind) -> Self {
        Self {
            name: name.into(),
            kind,
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GateDecl {
    pub semantic_id: GateSemanticId,
    pub name: String,
    pub operands: SmallOperandSpecs,
    pub version: u32,
}

impl GateDecl {
    pub fn new<I>(
        semantic_id: GateSemanticId,
        name: impl Into<String>,
        operands: I,
        version: u32,
    ) -> Self
    where
        I: IntoIterator<Item = OperandSpec>,
    {
        Self {
            semantic_id,
            name: name.into(),
            operands: operands.into_iter().collect(),
            version,
        }
    }
}
