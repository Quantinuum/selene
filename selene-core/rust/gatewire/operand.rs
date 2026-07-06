use crate::gatewire::GateError;
use smallvec::SmallVec;

pub const GW_OPERAND_KIND_QUBIT: u32 = 1;
pub const GW_OPERAND_KIND_F64: u32 = 2;
pub const GW_OPERAND_KIND_U64: u32 = 3;
pub const GW_OPERAND_KIND_I64: u32 = 4;
pub const GW_OPERAND_KIND_U8: u32 = 5;
pub const GW_OPERAND_KIND_BOOL: u32 = 6;

#[repr(u32)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum OperandKind {
    Qubit = GW_OPERAND_KIND_QUBIT,
    F64 = GW_OPERAND_KIND_F64,
    U64 = GW_OPERAND_KIND_U64,
    I64 = GW_OPERAND_KIND_I64,
    U8 = GW_OPERAND_KIND_U8,
    Bool = GW_OPERAND_KIND_BOOL,
}

impl OperandKind {
    pub fn from_u32(value: u32) -> Result<Self, GateError> {
        match value {
            GW_OPERAND_KIND_QUBIT => Ok(Self::Qubit),
            GW_OPERAND_KIND_F64 => Ok(Self::F64),
            GW_OPERAND_KIND_U64 => Ok(Self::U64),
            GW_OPERAND_KIND_I64 => Ok(Self::I64),
            GW_OPERAND_KIND_U8 => Ok(Self::U8),
            GW_OPERAND_KIND_BOOL => Ok(Self::Bool),
            other => Err(GateError::InvalidKind(other)),
        }
    }

    pub const fn as_u32(self) -> u32 {
        self as u32
    }
}

#[derive(Clone, Debug, PartialEq)]
pub enum GateValue {
    Qubit(u32),
    F64(f64),
    U64(u64),
    I64(i64),
    U8(u8),
    Bool(bool),
}

pub type SmallGateValues = SmallVec<[GateValue; 4]>;

impl GateValue {
    pub fn kind(&self) -> OperandKind {
        match self {
            Self::Qubit(_) => OperandKind::Qubit,
            Self::F64(_) => OperandKind::F64,
            Self::U64(_) => OperandKind::U64,
            Self::I64(_) => OperandKind::I64,
            Self::U8(_) => OperandKind::U8,
            Self::Bool(_) => OperandKind::Bool,
        }
    }
}

pub trait GateOperand: Clone {
    const KIND: OperandKind;
    fn into_value(self) -> GateValue;
    fn from_value(value: &GateValue) -> Result<Self, GateError>;
}

#[repr(transparent)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Qubit(pub u32);

#[repr(transparent)]
#[derive(
    Clone,
    Copy,
    Debug,
    PartialEq,
    derive_more::Add,
    derive_more::Sub,
    derive_more::Mul,
    derive_more::Div,
)]
pub struct Angle(pub f64);

impl GateOperand for Qubit {
    const KIND: OperandKind = OperandKind::Qubit;
    fn into_value(self) -> GateValue {
        GateValue::Qubit(self.0)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::Qubit(v) => Ok(Self(*v)),
            _ => Err(GateError::Decode("expected qubit operand")),
        }
    }
}

impl GateOperand for Angle {
    const KIND: OperandKind = OperandKind::F64;
    fn into_value(self) -> GateValue {
        GateValue::F64(self.0)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::F64(v) => Ok(Self(*v)),
            _ => Err(GateError::Decode("expected angle operand")),
        }
    }
}

impl GateOperand for f64 {
    const KIND: OperandKind = OperandKind::F64;
    fn into_value(self) -> GateValue {
        GateValue::F64(self)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::F64(v) => Ok(*v),
            _ => Err(GateError::Decode("expected f64 operand")),
        }
    }
}

impl GateOperand for u64 {
    const KIND: OperandKind = OperandKind::U64;
    fn into_value(self) -> GateValue {
        GateValue::U64(self)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::U64(v) => Ok(*v),
            _ => Err(GateError::Decode("expected u64 operand")),
        }
    }
}

impl GateOperand for i64 {
    const KIND: OperandKind = OperandKind::I64;
    fn into_value(self) -> GateValue {
        GateValue::I64(self)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::I64(v) => Ok(*v),
            _ => Err(GateError::Decode("expected i64 operand")),
        }
    }
}

impl GateOperand for u8 {
    const KIND: OperandKind = OperandKind::U8;
    fn into_value(self) -> GateValue {
        GateValue::U8(self)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::U8(v) => Ok(*v),
            _ => Err(GateError::Decode("expected u8 operand")),
        }
    }
}

impl GateOperand for bool {
    const KIND: OperandKind = OperandKind::Bool;
    fn into_value(self) -> GateValue {
        GateValue::Bool(self)
    }
    fn from_value(value: &GateValue) -> Result<Self, GateError> {
        match value {
            GateValue::Bool(v) => Ok(*v),
            _ => Err(GateError::Decode("expected bool operand")),
        }
    }
}
