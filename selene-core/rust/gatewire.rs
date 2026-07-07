//! Standalone gate definition and gateset transport library.
//!
//! The public Rust API is typed and enum-oriented. The C ABI is deliberately
//! explicit: raw views, opaque handles, status codes, and stable wire bytes.

extern crate self as gatewire;

pub mod builtin;
pub mod ffi;

mod decl;
mod dynamic;
mod error;
mod id;
mod instance;
mod metadata;
mod operand;
mod typed;
mod wire;

pub use decl::{GateDecl, OperandSpec, SmallOperandSpecs};
pub use dynamic::{DynamicGateSet, LocalGateId};
pub use error::GateError;
pub use ffi::{
    GwDecodedGate, GwGateDeclInfo, GwGateDeclView, GwGateInstanceView, GwGateMetadata, GwGateSet,
    GwGateValue, GwGateValueData, GwMetadataValueData, GwOperandDeclInfo, GwOperandDeclView,
    GwSemanticId, GwStatus,
};
pub use id::GateSemanticId;
pub use instance::OwnedGateInstance;
pub use metadata::{
    GW_METADATA_VALUE_KIND_BOOL, GW_METADATA_VALUE_KIND_BYTES, GW_METADATA_VALUE_KIND_F64,
    GW_METADATA_VALUE_KIND_I64, GW_METADATA_VALUE_KIND_STRING, GW_METADATA_VALUE_KIND_U64,
    GateMetadata, MetadataValue, SmallGateMetadata,
};
pub use operand::{
    Angle, GW_OPERAND_KIND_BOOL, GW_OPERAND_KIND_F64, GW_OPERAND_KIND_I64, GW_OPERAND_KIND_QUBIT,
    GW_OPERAND_KIND_U8, GW_OPERAND_KIND_U64, GateOperand, GateValue, OperandKind, Qubit,
    SmallGateValues,
};
pub use typed::{GateSet, GateSetSpec, GateSpec, GateView, TryDecode};

pub mod prelude {
    pub use crate::gatewire::builtin;
    pub use crate::gatewire::{
        Angle, DynamicGateSet, GateDecl, GateError, GateOperand, GateSemanticId, GateSet,
        GateSetSpec, GateSpec, GateValue, GateView, MetadataValue, OperandKind, OperandSpec,
        OwnedGateInstance, Qubit, TryDecode,
    };
}

#[cfg(test)]
mod tests;
