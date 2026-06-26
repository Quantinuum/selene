//! A complete custom-gateset Selene example.
//!
//! This crate is intentionally small but real: it defines a Clifford+T gateset,
//! implements plugins that negotiate that gateset, and exports plugin
//! descriptors for the three native plugin types. The companion Python package
//! demonstrates the full `selene_sim.build(...).run_shots(...)` workflow.

pub mod error_model;
pub mod gates;
pub mod interface;
pub mod runtime;
pub mod simulator;

pub use error_model::{CliffordTErrorModel, CliffordTErrorModelFactory};
pub use gates::{CNOT, CliffordT, H, S, Sdg, T, Tdg, X};
pub use gates::{clifford_t_gateset, decode_clifford_t, gateset_names, require_clifford_t};
pub use interface::CliffordTInterface;
pub use runtime::{CliffordTRuntime, CliffordTRuntimeFactory};
pub use simulator::{CliffordTTraceSimulator, TraceEntry};

#[cfg(test)]
mod tests;
