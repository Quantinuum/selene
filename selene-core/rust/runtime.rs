//! The current runtime API and its supported versions.
//!
//! New runtimes implement this interface. API 0.3 plugins are loaded through
//! their original contract and adapted before the host uses them.

pub mod adapters;
pub mod plugin;
pub mod v0_3;
pub mod v0_4;

pub use crate::operation::{
    BatchOperation, BatchSource, ErrorModelBatchSource, Operation, RuntimeBatchSource,
    SimulatorBatchSource,
};
pub use plugin::Runtime;
pub use v0_4::{
    ExecutionCallback, RuntimeInstruction, RuntimeInstructionResult, RuntimeInterface,
    RuntimeInterfaceFactory, RuntimePluginDescriptorV2, borrow_endpoint, callback_result, helper,
    instruction, on_execution_thread, output, version,
};

pub use v0_4::export_runtime_plugin;
