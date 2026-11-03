//! Load a supported simulator plugin using its versioned contract.
use super::{Simulator, v0_1};
use anyhow::Result;
use std::ffi::OsStr;

pub use v0_1::plugin::*;

impl Simulator {
    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = v0_1::plugin::SimulatorPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, args)
    }
}
