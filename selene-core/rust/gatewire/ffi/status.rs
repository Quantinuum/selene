use crate::gatewire::{GateError, ffi::types::*};

use std::panic::{AssertUnwindSafe, catch_unwind};

pub(crate) fn ffi_result<F>(f: F) -> GwStatus
where
    F: FnOnce() -> Result<(), GateError>,
{
    match catch_unwind(AssertUnwindSafe(f)) {
        Ok(Ok(())) => GW_STATUS_OK,
        Ok(Err(error)) => status_from_error(error),
        Err(_) => GW_STATUS_PANIC,
    }
}

pub(crate) fn status_from_error(error: GateError) -> GwStatus {
    match error {
        GateError::DuplicateGate(_) => GW_STATUS_DUPLICATE_GATE,
        GateError::UnknownGate => GW_STATUS_NOT_FOUND,
        GateError::InvalidKind(_) => GW_STATUS_INVALID_ARGUMENT,
        GateError::WrongArity { .. } | GateError::WrongOperandKind { .. } => {
            GW_STATUS_VALIDATION_ERROR
        }
        GateError::Decode(_) | GateError::Utf8(_) | GateError::Utf8Slice(_) => {
            GW_STATUS_DECODE_ERROR
        }
        GateError::BufferTooSmall => GW_STATUS_BUFFER_TOO_SMALL,
        GateError::NullPointer => GW_STATUS_NULL_POINTER,
    }
}
