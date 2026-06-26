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
mod operand;
mod typed;
mod wire;

pub use decl::{GateDecl, OperandSpec, SmallOperandSpecs};
pub use dynamic::{DynamicGateSet, LocalGateId};
pub use error::GateError;
pub use ffi::{
    GwDecodedGate, GwGateDeclInfo, GwGateDeclView, GwGateInstanceView, GwGateSet, GwGateValue,
    GwGateValueData, GwOperandDeclInfo, GwOperandDeclView, GwSemanticId, GwStatus,
};
pub use id::GateSemanticId;
pub use instance::OwnedGateInstance;
pub use operand::{
    Angle, GW_OPERAND_KIND_BOOL, GW_OPERAND_KIND_F64, GW_OPERAND_KIND_I64, GW_OPERAND_KIND_QUBIT,
    GW_OPERAND_KIND_U8, GW_OPERAND_KIND_U64, GateOperand, GateValue, OperandKind, Qubit,
    SmallGateValues,
};
pub use typed::{GateSet, GateSetSpec, GateSpec, TryDecode};

pub mod prelude {
    pub use crate::gatewire::builtin;
    pub use crate::gatewire::{
        Angle, DynamicGateSet, GateDecl, GateError, GateOperand, GateSemanticId, GateSet,
        GateSetSpec, GateSpec, GateValue, OperandKind, OperandSpec, OwnedGateInstance, Qubit,
        TryDecode,
    };
}

#[cfg(test)]
mod tests;
