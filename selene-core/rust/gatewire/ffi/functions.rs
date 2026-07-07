use super::convert::*;
use super::status::ffi_result;
use super::types::*;
use crate::gatewire::{
    DynamicGateSet, GateError, GateSemanticId, GateSpec, OwnedGateInstance, builtin,
};
use std::ffi::c_char;
use std::mem;

#[unsafe(no_mangle)]
pub extern "C" fn gw_status_message(status: GwStatus) -> *const c_char {
    let message: &'static [u8] = match status {
        GW_STATUS_OK => b"ok\0",
        GW_STATUS_NULL_POINTER => b"null pointer\0",
        GW_STATUS_INVALID_ARGUMENT => b"invalid argument\0",
        GW_STATUS_DUPLICATE_GATE => b"duplicate gate\0",
        GW_STATUS_NOT_FOUND => b"not found\0",
        GW_STATUS_BUFFER_TOO_SMALL => b"buffer too small\0",
        GW_STATUS_DECODE_ERROR => b"decode error\0",
        GW_STATUS_VALIDATION_ERROR => b"validation error\0",
        GW_STATUS_PANIC => b"panic across FFI boundary\0",
        _ => b"unknown status\0",
    };
    message.as_ptr() as *const c_char
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_semantic_id_from_text(
    ptr: *const c_char,
    len: usize,
    out: *mut GwSemanticId,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let text = read_text(ptr, len)?;
        *out = GateSemanticId::from_text(text).into();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_semantic_id_eq(a: GwSemanticId, b: GwSemanticId) -> u8 {
    u8::from(a.bytes == b.bytes)
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_builtin_rz_semantic_id() -> GwSemanticId {
    builtin::RZ::semantic_id().into()
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_builtin_phased_x_semantic_id() -> GwSemanticId {
    builtin::PhasedX::semantic_id().into()
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_builtin_zz_phase_semantic_id() -> GwSemanticId {
    builtin::ZZPhase::semantic_id().into()
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_builtin_phased_xx_semantic_id() -> GwSemanticId {
    builtin::PhasedXX::semantic_id().into()
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_new(out: *mut *mut GwGateSet) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = Box::into_raw(Box::new(DynamicGateSet::new())) as *mut GwGateSet;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_builtin_gateset_new(out: *mut *mut GwGateSet) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = Box::into_raw(Box::new(builtin::QuantinuumGateSet::dynamic())) as *mut GwGateSet;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_free(set: *mut GwGateSet) {
    if !set.is_null() {
        unsafe {
            drop(Box::from_raw(set as *mut DynamicGateSet));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_add_decl(
    set: *mut GwGateSet,
    decl: *const GwGateDeclView,
) -> GwStatus {
    ffi_result(|| unsafe {
        if decl.is_null() {
            return Err(GateError::NullPointer);
        }
        let set = as_set_mut(set)?;
        let decl = gate_decl_from_view(&*decl)?;
        set.add(decl)?;
        Ok(())
    })
}

fn add_builtin_gate<G: GateSpec>(set: *mut GwGateSet) -> GwStatus {
    ffi_result(|| unsafe {
        let set = as_set_mut(set)?;
        set.add(G::declaration())?;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_gateset_add_builtin_rz(set: *mut GwGateSet) -> GwStatus {
    add_builtin_gate::<builtin::RZ>(set)
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_gateset_add_builtin_phased_x(set: *mut GwGateSet) -> GwStatus {
    add_builtin_gate::<builtin::PhasedX>(set)
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_gateset_add_builtin_zz_phase(set: *mut GwGateSet) -> GwStatus {
    add_builtin_gate::<builtin::ZZPhase>(set)
}

#[unsafe(no_mangle)]
pub extern "C" fn gw_gateset_add_builtin_phased_xx(set: *mut GwGateSet) -> GwStatus {
    add_builtin_gate::<builtin::PhasedXX>(set)
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_len(set: *const GwGateSet, out: *mut usize) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_set(set)?.len();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_contains(
    set: *const GwGateSet,
    id: GwSemanticId,
    out: *mut u8,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = u8::from(as_set(set)?.contains(GateSemanticId::from(id)));
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_decl_at(
    set: *const GwGateSet,
    index: usize,
    out: *mut GwGateDeclInfo,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let decl = as_set(set)?
            .declaration_at(index)
            .ok_or(GateError::UnknownGate)?;
        *out = GwGateDeclInfo {
            abi_size: mem::size_of::<GwGateDeclInfo>(),
            semantic_id: decl.semantic_id.into(),
            name_ptr: decl.name.as_ptr().cast::<c_char>(),
            name_len: decl.name.len(),
            operands_len: decl.operands.len(),
            version: decl.version,
        };
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_decl_operand_at(
    set: *const GwGateSet,
    decl_index: usize,
    operand_index: usize,
    out: *mut GwOperandDeclInfo,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let decl = as_set(set)?
            .declaration_at(decl_index)
            .ok_or(GateError::UnknownGate)?;
        let operand = decl
            .operands
            .get(operand_index)
            .ok_or(GateError::UnknownGate)?;
        *out = GwOperandDeclInfo {
            abi_size: mem::size_of::<GwOperandDeclInfo>(),
            name_ptr: operand.name.as_ptr().cast::<c_char>(),
            name_len: operand.name.len(),
            kind: operand.kind.as_u32(),
        };
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_serialized_len(
    set: *const GwGateSet,
    out: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_set(set)?.serialize().len();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_serialize(
    set: *const GwGateSet,
    buffer: *mut u8,
    buffer_len: usize,
    written: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        let bytes = as_set(set)?.serialize();
        write_to_out(&bytes, buffer, buffer_len, written)
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_deserialize(
    data: *const u8,
    len: usize,
    out: *mut *mut GwGateSet,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let set = DynamicGateSet::deserialize(read_bytes(data, len)?)?;
        *out = Box::into_raw(Box::new(set)) as *mut GwGateSet;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gate_serialized_len(
    view: *const GwGateInstanceView,
    out: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if view.is_null() || out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = gate_instance_from_view(view)?.serialize().len();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gate_serialize(
    view: *const GwGateInstanceView,
    buffer: *mut u8,
    buffer_len: usize,
    written: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if view.is_null() {
            return Err(GateError::NullPointer);
        }
        let bytes = gate_instance_from_view(view)?.serialize();
        write_to_out(&bytes, buffer, buffer_len, written)
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gate_deserialize(
    data: *const u8,
    len: usize,
    out: *mut *mut GwDecodedGate,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let instance = OwnedGateInstance::deserialize(read_bytes(data, len)?)?;
        *out = Box::into_raw(Box::new(instance)) as *mut GwDecodedGate;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_free(gate: *mut GwDecodedGate) {
    if !gate.is_null() {
        unsafe {
            drop(Box::from_raw(gate as *mut OwnedGateInstance));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_semantic_id(
    gate: *const GwDecodedGate,
    out: *mut GwSemanticId,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_decoded(gate)?.semantic_id.into();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_value_count(
    gate: *const GwDecodedGate,
    out: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_decoded(gate)?.operands.len();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_value_at(
    gate: *const GwDecodedGate,
    index: usize,
    out: *mut GwGateValue,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let gate = as_decoded(gate)?;
        let value = gate.operands.get(index).ok_or(GateError::UnknownGate)?;
        *out = value_to_view(value);
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_metadata_count(
    gate: *const GwDecodedGate,
    out: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_decoded(gate)?.metadata.len();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_metadata_at(
    gate: *const GwDecodedGate,
    index: usize,
    out: *mut GwGateMetadata,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let gate = as_decoded(gate)?;
        let metadata = gate.metadata.get(index).ok_or(GateError::UnknownGate)?;
        *out = metadata_to_view(metadata);
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_metadata_find(
    gate: *const GwDecodedGate,
    key_ptr: *const c_char,
    key_len: usize,
    out: *mut GwGateMetadata,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        let key = read_text(key_ptr, key_len)?;
        let metadata = as_decoded(gate)?
            .metadata
            .iter()
            .find(|entry| entry.key == key)
            .ok_or(GateError::UnknownGate)?;
        *out = metadata_to_view(metadata);
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_qubit_operand_count(
    gate: *const GwDecodedGate,
    out: *mut usize,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_decoded(gate)?.qubit_operand_count();
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_decoded_gate_qubit_operand_at(
    gate: *const GwDecodedGate,
    qubit_index: usize,
    out: *mut u32,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out.is_null() {
            return Err(GateError::NullPointer);
        }
        *out = as_decoded(gate)?
            .qubit_operands()
            .nth(qubit_index)
            .ok_or(GateError::UnknownGate)?;
        Ok(())
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn gw_gateset_validate_decoded(
    set: *const GwGateSet,
    gate: *const GwDecodedGate,
    out_matches: *mut u8,
) -> GwStatus {
    ffi_result(|| unsafe {
        if out_matches.is_null() {
            return Err(GateError::NullPointer);
        }
        *out_matches = u8::from(as_set(set)?.validate_instance(as_decoded(gate)?)?);
        Ok(())
    })
}
