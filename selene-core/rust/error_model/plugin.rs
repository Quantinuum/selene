//! Load a supported error-model plugin using its versioned contract.
use super::{ErrorModel, v0_3};
use anyhow::Result;
use std::ffi::OsStr;

pub use v0_3::plugin::*;

impl ErrorModel {
    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = v0_3::plugin::ErrorModelPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, error_model_args)
    }
}
