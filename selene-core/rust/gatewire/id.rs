use std::fmt;

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct GateSemanticId {
    pub bytes: [u8; 16],
}

impl GateSemanticId {
    pub const fn from_bytes(bytes: [u8; 16]) -> Self {
        Self { bytes }
    }

    /// Deterministic 128-bit semantic ID derived from a stable semantic string.
    ///
    /// This uses BLAKE3 and truncates the digest to 16 bytes. Builtins use
    /// stable text identifiers such as `gatewire.builtin.PhasedX.v1`; user gates
    /// should use an owned prefix such as `org.example.gate.MAGIC.v1`.
    pub fn from_text(text: &str) -> Self {
        let digest = blake3::hash(text.as_bytes());
        let mut bytes = [0u8; 16];
        bytes.copy_from_slice(&digest.as_bytes()[..16]);
        Self { bytes }
    }

    pub const fn to_bytes(self) -> [u8; 16] {
        self.bytes
    }

    pub const fn as_bytes(&self) -> &[u8; 16] {
        &self.bytes
    }
}

impl From<[u8; 16]> for GateSemanticId {
    fn from(bytes: [u8; 16]) -> Self {
        Self::from_bytes(bytes)
    }
}

impl fmt::Display for GateSemanticId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for byte in self.bytes {
            write!(f, "{byte:02x}")?;
        }
        Ok(())
    }
}

static_assertions::assert_eq_size!(GateSemanticId, [u8; 16]);
static_assertions::assert_impl_all!(GateSemanticId: Copy, Send, Sync);
