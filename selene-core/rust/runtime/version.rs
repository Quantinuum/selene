use anyhow::{Result, anyhow};

#[derive(Debug, Clone, Copy)]
#[repr(C)]
/// A decomposed runtime API version.
///
/// Use this to inspect the version's individual fields. Plugin descriptors
/// store a packed integer: `SELENE_RUNTIME_CURRENT_API_VERSION` for v2, or
/// `SELENE_RUNTIME_V1_API_VERSION` for v1.
pub struct RuntimeAPIVersion {
    /// Reserved for future use, must be 0.
    reserved: u8,
    /// Major version of the API.
    major: u8,
    /// Minor version of the API.
    minor: u8,
    /// Patch version of the API.
    patch: u8,
}
impl From<u64> for RuntimeAPIVersion {
    fn from(value: u64) -> Self {
        Self {
            reserved: ((value >> 24) & 255) as u8,
            major: ((value >> 16) & 255) as u8,
            minor: ((value >> 8) & 255) as u8,
            patch: (value & 255) as u8,
        }
    }
}
impl From<RuntimeAPIVersion> for u64 {
    fn from(value: RuntimeAPIVersion) -> u64 {
        ((value.reserved as u64) << 24)
            | ((value.major as u64) << 16)
            | ((value.minor as u64) << 8)
            | (value.patch as u64)
    }
}

/// cbindgen:ignore
pub const CURRENT_API_VERSION: RuntimeAPIVersion = RuntimeAPIVersion {
    reserved: 0,
    major: 0,
    minor: 4,
    patch: 0,
};

/// API version for concurrent v2 runtime descriptors, packed for the C ABI.
pub const RUNTIME_CURRENT_API_VERSION: u64 = 0x0000_0400;

/// API version for legacy v1 runtime descriptors.
pub const RUNTIME_V1_API_VERSION: u64 = 0x0000_0300;

// CHANGELOG:
// 0.4.0: V2 plugins allow concurrent operational calls on a shared instance.
// 0.0.1: Initial version
// 0.0.2: Introduced MeasureLeaked, changed get_result to get_bool_result and get_u64_result

impl RuntimeAPIVersion {
    pub const fn as_u64(self) -> u64 {
        ((self.reserved as u64) << 24)
            | ((self.major as u64) << 16)
            | ((self.minor as u64) << 8)
            | (self.patch as u64)
    }

    pub fn validate(&self) -> Result<()> {
        self.validate_minor(CURRENT_API_VERSION.minor)
    }

    pub(crate) fn validate_v1(&self) -> Result<()> {
        self.validate_minor(3)
    }

    fn validate_minor(&self, expected_minor: u8) -> Result<()> {
        // Reserved must be 0. We may want to attribute meaning to this one day.
        if self.reserved != 0 {
            return Err(anyhow!(
                "API version reserved field must be 0, got {}",
                self.reserved
            ));
        }
        // If the major version is different, the plugin is almost definitely incompatible.
        if self.major != CURRENT_API_VERSION.major {
            return Err(anyhow!(
                "Runtime API major version must be the same as Selene's Runtime API major version ({}), got {}",
                CURRENT_API_VERSION.major,
                self.major
            ));
        }
        // Each descriptor has its own contract: v1 uses 0.3.x and v2 uses 0.4.x.
        // Reject other minor versions rather than assuming those contracts match.
        if self.minor != expected_minor {
            return Err(anyhow!(
                "Runtime API minor version must match the descriptor contract ({}), got {}",
                expected_minor,
                self.minor
            ));
        }
        // The patch version might be bumped for changes that are optional and additive.
        // For example, if we wish to allow runtimes to have a selene_runtime_foo() function,
        // but it is not mandatory, we express the symbol as optional in plugin.rs, and the
        // behaviour of selene does not change with regards to the other functions (i.e. we do
        // not avoid calling shot_end() because selene_runtime_foo() has taken over that meaning),
        // then we can bump the patch version. Otherwise we should bump the minor version.
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_runtime_without_thread_safety_contract() {
        assert!(RuntimeAPIVersion::from(0x0000_0300).validate().is_err());
        assert!(CURRENT_API_VERSION.validate().is_ok());
        assert!(
            RuntimeAPIVersion::from(RUNTIME_V1_API_VERSION)
                .validate_v1()
                .is_ok()
        );
        assert!(CURRENT_API_VERSION.validate_v1().is_err());
    }

    #[test]
    fn c_api_version_matches_rust_version() {
        assert_eq!(RUNTIME_CURRENT_API_VERSION, CURRENT_API_VERSION.as_u64());
    }
}
