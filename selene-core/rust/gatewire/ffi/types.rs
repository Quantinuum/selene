use crate::gatewire::GateSemanticId;
use crate::gatewire::metadata::{
    GW_METADATA_VALUE_KIND_BOOL, GW_METADATA_VALUE_KIND_BYTES, GW_METADATA_VALUE_KIND_F64,
    GW_METADATA_VALUE_KIND_I64, GW_METADATA_VALUE_KIND_STRING, GW_METADATA_VALUE_KIND_U64,
};
use std::ffi::c_char;
use std::{mem, ptr};

pub type GwStatus = i32;

pub const GW_STATUS_OK: GwStatus = 0;
pub const GW_STATUS_NULL_POINTER: GwStatus = 1;
pub const GW_STATUS_INVALID_ARGUMENT: GwStatus = 2;
pub const GW_STATUS_DUPLICATE_GATE: GwStatus = 3;
pub const GW_STATUS_NOT_FOUND: GwStatus = 4;
pub const GW_STATUS_BUFFER_TOO_SMALL: GwStatus = 5;
pub const GW_STATUS_DECODE_ERROR: GwStatus = 6;
pub const GW_STATUS_VALIDATION_ERROR: GwStatus = 7;
pub const GW_STATUS_PANIC: GwStatus = 255;

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct GwSemanticId {
    pub bytes: [u8; 16],
}

impl From<GwSemanticId> for GateSemanticId {
    fn from(value: GwSemanticId) -> Self {
        Self { bytes: value.bytes }
    }
}

impl From<GateSemanticId> for GwSemanticId {
    fn from(value: GateSemanticId) -> Self {
        Self { bytes: value.bytes }
    }
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct GwOperandDeclView {
    pub abi_size: usize,
    pub name_ptr: *const c_char,
    pub name_len: usize,
    pub kind: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct GwGateDeclView {
    pub abi_size: usize,
    pub semantic_id: GwSemanticId,
    pub name_ptr: *const c_char,
    pub name_len: usize,
    pub operands_ptr: *const GwOperandDeclView,
    pub operands_len: usize,
    pub version: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct GwGateDeclInfo {
    pub abi_size: usize,
    pub semantic_id: GwSemanticId,
    pub name_ptr: *const c_char,
    pub name_len: usize,
    pub operands_len: usize,
    pub version: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct GwOperandDeclInfo {
    pub abi_size: usize,
    pub name_ptr: *const c_char,
    pub name_len: usize,
    pub kind: u32,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub union GwGateValueData {
    pub qubit: u32,
    pub f64_value: f64,
    pub u64_value: u64,
    pub i64_value: i64,
    pub u8_value: u8,
    pub bool_value: u8,
}

impl Default for GwGateValueData {
    fn default() -> Self {
        Self { u64_value: 0 }
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GwGateValue {
    pub abi_size: usize,
    pub kind: u32,
    pub data: GwGateValueData,
    pub bytes_ptr: *const u8,
    pub bytes_len: usize,
}

impl Default for GwGateValue {
    fn default() -> Self {
        Self {
            abi_size: mem::size_of::<Self>(),
            kind: 0,
            data: GwGateValueData::default(),
            bytes_ptr: ptr::null(),
            bytes_len: 0,
        }
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GwGateInstanceView {
    pub abi_size: usize,
    pub semantic_id: GwSemanticId,
    pub values_ptr: *const GwGateValue,
    pub values_len: usize,
    pub metadata_ptr: *const GwGateMetadata,
    pub metadata_len: usize,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub union GwMetadataValueData {
    pub bool_value: u8,
    pub i64_value: i64,
    pub u64_value: u64,
    pub f64_value: f64,
}

impl Default for GwMetadataValueData {
    fn default() -> Self {
        Self { u64_value: 0 }
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GwGateMetadata {
    pub abi_size: usize,
    pub key_ptr: *const c_char,
    pub key_len: usize,
    pub value_kind: u32,
    pub data: GwMetadataValueData,
    pub bytes_ptr: *const u8,
    pub bytes_len: usize,
}

impl Default for GwGateMetadata {
    fn default() -> Self {
        Self {
            abi_size: mem::size_of::<Self>(),
            key_ptr: ptr::null(),
            key_len: 0,
            value_kind: 0,
            data: GwMetadataValueData::default(),
            bytes_ptr: ptr::null(),
            bytes_len: 0,
        }
    }
}

#[repr(C)]
pub struct GwGateSet {
    _private: [u8; 0],
}

#[repr(C)]
pub struct GwDecodedGate {
    _private: [u8; 0],
}

static_assertions::const_assert_eq!(std::mem::size_of::<GwSemanticId>(), 16);
static_assertions::assert_impl_all!(GwSemanticId: Copy, Clone);
static_assertions::assert_impl_all!(GwGateValue: Copy, Clone);
static_assertions::assert_impl_all!(GwGateMetadata: Copy, Clone);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_BOOL, 1);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_I64, 2);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_U64, 3);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_F64, 4);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_STRING, 5);
static_assertions::const_assert_eq!(GW_METADATA_VALUE_KIND_BYTES, 6);
