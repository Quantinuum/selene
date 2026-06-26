use crate::gatewire::OperandKind;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum GateError {
    #[error("duplicate gate declaration `{0}`")]
    DuplicateGate(String),
    #[error("unknown gate")]
    UnknownGate,
    #[error("invalid operand kind `{0}`")]
    InvalidKind(u32),
    #[error("wrong arity for gate `{gate}`: expected {expected}, got {actual}")]
    WrongArity {
        gate: String,
        expected: usize,
        actual: usize,
    },
    #[error(
        "wrong operand kind for gate `{gate}` operand {index}: expected {expected:?}, got {actual:?}"
    )]
    WrongOperandKind {
        gate: String,
        index: usize,
        expected: OperandKind,
        actual: OperandKind,
    },
    #[error("decode error: {0}")]
    Decode(&'static str),
    #[error("invalid UTF-8 string")]
    Utf8(#[from] std::string::FromUtf8Error),
    #[error("invalid UTF-8 slice")]
    Utf8Slice(#[from] std::str::Utf8Error),
    #[error("buffer too small")]
    BufferTooSmall,
    #[error("null pointer")]
    NullPointer,
}
