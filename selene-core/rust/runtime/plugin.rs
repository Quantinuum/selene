//! Select a supported plugin API and present the current runtime interface.
use super::{RuntimeInterface, adapters::LegacyRuntime, v0_3};
use anyhow::{Context as _, Result};
use std::{ffi::OsStr, sync::Arc};

pub use super::v0_4::plugin::Runtime;

impl Runtime {
    /// Prefer API 0.4 when advertised. An invalid advertised descriptor is an
    /// error, rather than a reason to retry using an older contract.
    pub fn load_from_file(
        path: &impl AsRef<OsStr>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<dyn RuntimeInterface>> {
        let library = Arc::new(
            unsafe { libloading::Library::new(path.as_ref()) }.with_context(|| {
                format!(
                    "Failed to load runtime plugin: {}",
                    path.as_ref().to_string_lossy()
                )
            })?,
        );
        match Self::load_from_library(library, n_qubits, start, args)? {
            Some(runtime) => Ok(Box::new(runtime)),
            None => Ok(Box::new(LegacyRuntime::new(v0_3::Runtime::load_from_file(
                path, n_qubits, start, args,
            )?))),
        }
    }
}
