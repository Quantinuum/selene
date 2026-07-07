use smallvec::SmallVec;

pub const GW_METADATA_VALUE_KIND_BOOL: u32 = 1;
pub const GW_METADATA_VALUE_KIND_I64: u32 = 2;
pub const GW_METADATA_VALUE_KIND_U64: u32 = 3;
pub const GW_METADATA_VALUE_KIND_F64: u32 = 4;
pub const GW_METADATA_VALUE_KIND_STRING: u32 = 5;
pub const GW_METADATA_VALUE_KIND_BYTES: u32 = 6;

#[derive(Clone, Debug, PartialEq)]
pub enum MetadataValue {
    Bool(bool),
    I64(i64),
    U64(u64),
    F64(f64),
    String(String),
    Bytes(Vec<u8>),
}

impl MetadataValue {
    pub const fn kind(&self) -> u32 {
        match self {
            Self::Bool(_) => GW_METADATA_VALUE_KIND_BOOL,
            Self::I64(_) => GW_METADATA_VALUE_KIND_I64,
            Self::U64(_) => GW_METADATA_VALUE_KIND_U64,
            Self::F64(_) => GW_METADATA_VALUE_KIND_F64,
            Self::String(_) => GW_METADATA_VALUE_KIND_STRING,
            Self::Bytes(_) => GW_METADATA_VALUE_KIND_BYTES,
        }
    }
}

impl From<bool> for MetadataValue {
    fn from(value: bool) -> Self {
        Self::Bool(value)
    }
}

impl From<i64> for MetadataValue {
    fn from(value: i64) -> Self {
        Self::I64(value)
    }
}

impl From<u64> for MetadataValue {
    fn from(value: u64) -> Self {
        Self::U64(value)
    }
}

impl From<f64> for MetadataValue {
    fn from(value: f64) -> Self {
        Self::F64(value)
    }
}

impl From<String> for MetadataValue {
    fn from(value: String) -> Self {
        Self::String(value)
    }
}

impl From<&str> for MetadataValue {
    fn from(value: &str) -> Self {
        Self::String(value.to_owned())
    }
}

impl From<Vec<u8>> for MetadataValue {
    fn from(value: Vec<u8>) -> Self {
        Self::Bytes(value)
    }
}

impl From<&[u8]> for MetadataValue {
    fn from(value: &[u8]) -> Self {
        Self::Bytes(value.to_vec())
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct GateMetadata {
    pub key: String,
    pub value: MetadataValue,
}

impl GateMetadata {
    pub fn new(key: impl Into<String>, value: impl Into<MetadataValue>) -> Self {
        Self {
            key: key.into(),
            value: value.into(),
        }
    }
}

pub type SmallGateMetadata = SmallVec<[GateMetadata; 2]>;
