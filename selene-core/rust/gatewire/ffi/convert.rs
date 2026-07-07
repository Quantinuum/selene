use crate::gatewire::ffi::types::*;
use crate::gatewire::{
    DynamicGateSet, GateDecl, GateError, GateMetadata, GateSemanticId, GateValue, MetadataValue,
    OperandKind, OperandSpec, OwnedGateInstance,
    metadata::{
        GW_METADATA_VALUE_KIND_BOOL, GW_METADATA_VALUE_KIND_BYTES, GW_METADATA_VALUE_KIND_F64,
        GW_METADATA_VALUE_KIND_I64, GW_METADATA_VALUE_KIND_STRING, GW_METADATA_VALUE_KIND_U64,
    },
};
use std::ffi::c_char;
use std::{mem, ptr, slice, str};

pub(crate) unsafe fn as_set<'a>(set: *const GwGateSet) -> Result<&'a DynamicGateSet, GateError> {
    if set.is_null() {
        return Err(GateError::NullPointer);
    }
    unsafe { Ok(&*(set as *const DynamicGateSet)) }
}

pub(crate) unsafe fn as_set_mut<'a>(
    set: *mut GwGateSet,
) -> Result<&'a mut DynamicGateSet, GateError> {
    if set.is_null() {
        return Err(GateError::NullPointer);
    }
    unsafe { Ok(&mut *(set as *mut DynamicGateSet)) }
}

pub(crate) unsafe fn as_decoded<'a>(
    gate: *const GwDecodedGate,
) -> Result<&'a OwnedGateInstance, GateError> {
    if gate.is_null() {
        return Err(GateError::NullPointer);
    }
    unsafe { Ok(&*(gate as *const OwnedGateInstance)) }
}

pub(crate) unsafe fn read_bytes<'a>(ptr: *const u8, len: usize) -> Result<&'a [u8], GateError> {
    if len == 0 {
        return Ok(&[]);
    }
    if ptr.is_null() {
        return Err(GateError::NullPointer);
    }
    unsafe { Ok(slice::from_raw_parts(ptr, len)) }
}

pub(crate) unsafe fn read_text<'a>(ptr: *const c_char, len: usize) -> Result<&'a str, GateError> {
    unsafe { Ok(str::from_utf8(read_bytes(ptr.cast::<u8>(), len)?)?) }
}

unsafe fn read_str(ptr: *const c_char, len: usize) -> Result<String, GateError> {
    unsafe { Ok(read_text(ptr, len)?.to_owned()) }
}

fn check_abi_size(actual: usize, expected: usize) -> Result<(), GateError> {
    if actual != 0 && actual < expected {
        Err(GateError::Decode("ffi struct abi_size is too small"))
    } else {
        Ok(())
    }
}

pub(crate) unsafe fn gate_decl_from_view(view: &GwGateDeclView) -> Result<GateDecl, GateError> {
    check_abi_size(view.abi_size, mem::size_of::<GwGateDeclView>())?;
    unsafe {
        let name = read_str(view.name_ptr, view.name_len)?;
        let operands_raw = if view.operands_len == 0 {
            &[]
        } else {
            if view.operands_ptr.is_null() {
                return Err(GateError::NullPointer);
            }
            slice::from_raw_parts(view.operands_ptr, view.operands_len)
        };
        let mut operands = Vec::with_capacity(operands_raw.len());
        for raw in operands_raw {
            check_abi_size(raw.abi_size, mem::size_of::<GwOperandDeclView>())?;
            operands.push(OperandSpec::new(
                read_str(raw.name_ptr, raw.name_len)?,
                OperandKind::from_u32(raw.kind)?,
            ));
        }
        Ok(GateDecl::new(
            GateSemanticId::from(view.semantic_id),
            name,
            operands,
            view.version,
        ))
    }
}

pub(crate) unsafe fn gate_instance_from_view(
    view: *const GwGateInstanceView,
) -> Result<OwnedGateInstance, GateError> {
    unsafe {
        if view.is_null() {
            return Err(GateError::NullPointer);
        }
        let abi_size = ptr::addr_of!((*view).abi_size).read();
        check_abi_size(abi_size, legacy_gate_instance_view_size())?;

        let semantic_id = ptr::addr_of!((*view).semantic_id).read();
        let values_ptr = ptr::addr_of!((*view).values_ptr).read();
        let values_len = ptr::addr_of!((*view).values_len).read();

        let values_raw = if values_len == 0 {
            &[]
        } else {
            if values_ptr.is_null() {
                return Err(GateError::NullPointer);
            }
            slice::from_raw_parts(values_ptr, values_len)
        };
        let mut values = Vec::with_capacity(values_raw.len());
        for raw in values_raw {
            values.push(gate_value_from_view(raw)?);
        }

        let mut instance = OwnedGateInstance::new(GateSemanticId::from(semantic_id), values);
        if abi_size >= mem::size_of::<GwGateInstanceView>() {
            let metadata_ptr = ptr::addr_of!((*view).metadata_ptr).read();
            let metadata_len = ptr::addr_of!((*view).metadata_len).read();
            let metadata_raw = if metadata_len == 0 {
                &[]
            } else {
                if metadata_ptr.is_null() {
                    return Err(GateError::NullPointer);
                }
                slice::from_raw_parts(metadata_ptr, metadata_len)
            };
            for raw in metadata_raw {
                instance.metadata.push(gate_metadata_from_view(raw)?);
            }
        }
        Ok(instance)
    }
}

const fn legacy_gate_instance_view_size() -> usize {
    mem::size_of::<usize>()
        + mem::size_of::<GwSemanticId>()
        + mem::size_of::<*const GwGateValue>()
        + mem::size_of::<usize>()
}

unsafe fn gate_value_from_view(view: &GwGateValue) -> Result<GateValue, GateError> {
    check_abi_size(view.abi_size, mem::size_of::<GwGateValue>())?;
    unsafe {
        match OperandKind::from_u32(view.kind)? {
            OperandKind::Qubit => Ok(GateValue::Qubit(view.data.qubit)),
            OperandKind::F64 => Ok(GateValue::F64(view.data.f64_value)),
            OperandKind::U64 => Ok(GateValue::U64(view.data.u64_value)),
            OperandKind::I64 => Ok(GateValue::I64(view.data.i64_value)),
            OperandKind::U8 => Ok(GateValue::U8(view.data.u8_value)),
            OperandKind::Bool => match view.data.bool_value {
                0 => Ok(GateValue::Bool(false)),
                1 => Ok(GateValue::Bool(true)),
                _ => Err(GateError::Decode("invalid bool value")),
            },
        }
    }
}

unsafe fn gate_metadata_from_view(view: &GwGateMetadata) -> Result<GateMetadata, GateError> {
    check_abi_size(view.abi_size, mem::size_of::<GwGateMetadata>())?;
    unsafe {
        let key = read_str(view.key_ptr, view.key_len)?;
        let value = match view.value_kind {
            GW_METADATA_VALUE_KIND_BOOL => match view.data.bool_value {
                0 => MetadataValue::Bool(false),
                1 => MetadataValue::Bool(true),
                _ => return Err(GateError::Decode("invalid bool metadata value")),
            },
            GW_METADATA_VALUE_KIND_I64 => MetadataValue::I64(view.data.i64_value),
            GW_METADATA_VALUE_KIND_U64 => MetadataValue::U64(view.data.u64_value),
            GW_METADATA_VALUE_KIND_F64 => MetadataValue::F64(view.data.f64_value),
            GW_METADATA_VALUE_KIND_STRING => MetadataValue::String(
                read_text(view.bytes_ptr.cast::<c_char>(), view.bytes_len)?.to_owned(),
            ),
            GW_METADATA_VALUE_KIND_BYTES => {
                MetadataValue::Bytes(read_bytes(view.bytes_ptr, view.bytes_len)?.to_vec())
            }
            _ => return Err(GateError::Decode("invalid metadata value kind")),
        };
        Ok(GateMetadata { key, value })
    }
}

pub(crate) fn value_to_view(value: &GateValue) -> GwGateValue {
    let data = match value {
        GateValue::Qubit(v) => GwGateValueData { qubit: *v },
        GateValue::F64(v) => GwGateValueData { f64_value: *v },
        GateValue::U64(v) => GwGateValueData { u64_value: *v },
        GateValue::I64(v) => GwGateValueData { i64_value: *v },
        GateValue::U8(v) => GwGateValueData { u8_value: *v },
        GateValue::Bool(v) => GwGateValueData {
            bool_value: u8::from(*v),
        },
    };
    GwGateValue {
        kind: value.kind().as_u32(),
        data,
        ..Default::default()
    }
}

pub(crate) fn metadata_to_view(metadata: &GateMetadata) -> GwGateMetadata {
    let (data, bytes_ptr, bytes_len) = match &metadata.value {
        MetadataValue::Bool(v) => (
            GwMetadataValueData {
                bool_value: u8::from(*v),
            },
            ptr::null(),
            0,
        ),
        MetadataValue::I64(v) => (GwMetadataValueData { i64_value: *v }, ptr::null(), 0),
        MetadataValue::U64(v) => (GwMetadataValueData { u64_value: *v }, ptr::null(), 0),
        MetadataValue::F64(v) => (GwMetadataValueData { f64_value: *v }, ptr::null(), 0),
        MetadataValue::String(v) => (GwMetadataValueData::default(), v.as_ptr(), v.len()),
        MetadataValue::Bytes(v) => (GwMetadataValueData::default(), v.as_ptr(), v.len()),
    };
    GwGateMetadata {
        key_ptr: metadata.key.as_ptr().cast::<c_char>(),
        key_len: metadata.key.len(),
        value_kind: metadata.value.kind(),
        data,
        bytes_ptr,
        bytes_len,
        ..Default::default()
    }
}

pub(crate) fn write_to_out(
    bytes: &[u8],
    buffer: *mut u8,
    buffer_len: usize,
    written: *mut usize,
) -> Result<(), GateError> {
    if !written.is_null() {
        unsafe {
            *written = bytes.len();
        }
    }
    if buffer_len < bytes.len() {
        return Err(GateError::BufferTooSmall);
    }
    if bytes.is_empty() {
        return Ok(());
    }
    if buffer.is_null() {
        return Err(GateError::NullPointer);
    }
    unsafe {
        ptr::copy_nonoverlapping(bytes.as_ptr(), buffer, bytes.len());
    }
    Ok(())
}
