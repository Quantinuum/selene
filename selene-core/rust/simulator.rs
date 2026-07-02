pub mod conformance_testing;
pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::ffi::{CString, OsStr};
use std::sync::Arc;

pub use inline::{SimulatorFFIAdapter, SimulatorHandle, SimulatorOperationInterface};
pub use interface::{SimulatorInterface, SimulatorInterfaceFactory};
pub use version::SimulatorAPIVersion;

use crate::utils::{MetricValue, read_raw_metric};
use anyhow::{Result, anyhow};

use crate::error_model::BatchResult;
use crate::gatewire::DynamicGateSet;
use crate::operation::plugin::{BatchExtractor, OperationResultBuilder};
use crate::plugin as plugin_utils;
use crate::runtime::BatchOperation;

enum SimulatorBacking {
    Adapter { _adapter: Box<SimulatorFFIAdapter> },
    Borrowed,
}

/// An instance of a simulator plugin, ready to be used for emulation.
///
/// `Simulator` is the primary runtime representation of a simulator inside
/// selene-core. It stores the simulator instance pointer alongside the
/// function-table descriptor used to operate on it.
pub struct Simulator {
    handle: SimulatorHandle<'static>,
    backing: SimulatorBacking,
    name: String,
}

impl Simulator {
    pub fn from_boxed(interface: Box<dyn SimulatorInterface>) -> Self {
        Self::from_boxed_named("Unknown", interface)
    }

    pub fn from_boxed_named(
        name: impl Into<String>,
        interface: Box<dyn SimulatorInterface>,
    ) -> Self {
        let mut adapter = Box::new(SimulatorFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: SimulatorBacking::Adapter { _adapter: adapter },
            name: name.into(),
        }
    }

    pub fn into_boxed(self) -> Box<dyn SimulatorInterface> {
        Box::new(self)
    }

    /// Constructs a new Simulator from a [SimulatorInterfaceFactory].
    pub fn new(
        factory: Arc<impl SimulatorInterfaceFactory + 'static>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let name = factory.name().to_string();
        let interface: Box<dyn SimulatorInterface> = factory.init(n_qubits, args)?;
        Ok(Self::from_boxed_named(name, interface))
    }

    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = plugin::SimulatorPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, args)
    }

    pub(crate) fn from_raw_parts(handle: SimulatorHandle<'_>) -> Self {
        Self {
            handle: handle.into_static(),
            backing: SimulatorBacking::Borrowed,
            name: "Borrowed".to_string(),
        }
    }

    pub(crate) fn ffi_parts(&mut self) -> SimulatorHandle<'static> {
        self.handle
    }

    fn context(&self, message: &'static str) -> String {
        format!("Simulator ({}): {message}", self.name)
    }

    fn label(&self) -> String {
        format!("Simulator ({})", self.name)
    }

    fn check_errno(&self, errno: plugin_utils::Errno, message: &'static str) -> Result<()> {
        plugin_utils::check_plugin_errno_with_context(
            errno,
            self.handle.interface.last_error_fn,
            || anyhow!("{}", self.context(message)),
        )
    }
}

impl AsRef<dyn SimulatorInterface> for Simulator {
    fn as_ref(&self) -> &(dyn SimulatorInterface + 'static) {
        self
    }
}

impl AsMut<dyn SimulatorInterface> for Simulator {
    fn as_mut(&mut self) -> &mut (dyn SimulatorInterface + 'static) {
        self
    }
}

impl SimulatorInterface for Simulator {
    fn exit(&mut self) -> Result<()> {
        let _ = &self.backing;
        self.check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            "exit failed",
        )
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.shot_start_fn)(self.handle.instance, shot_id, seed) },
            "shot_start failed",
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.shot_end_fn)(self.handle.instance) },
            "shot_end failed",
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        plugin_utils::negotiate_gateset(
            &self.label(),
            self.handle.instance,
            self.handle.interface.negotiate_gateset_fn,
            self.handle.interface.last_error_fn,
            gateset,
        )
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut batch_extractor = BatchExtractor::from_batch_operation(operations);
        let batch = batch_extractor.runtime_batch_extraction();
        let mut result_builder = OperationResultBuilder::default();
        let result = result_builder.operation_result();
        self.check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(self.handle.instance, batch, result)
            },
            "handle_operations failed",
        )?;
        Ok(result_builder.finish())
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        let results = self.handle_operations(BatchOperation::simulator(vec![
            crate::runtime::Operation::Postselect {
                qubit_id: qubit,
                target_value,
            },
        ]))?;
        if results.bool_results.is_empty() && results.u64_results.is_empty() {
            Ok(())
        } else {
            Err(anyhow!(
                "{}",
                self.context("postselect unexpectedly produced results")
            ))
        }
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.handle.interface.get_metric_fn)(
                self.handle.instance,
                nth_metric,
                tag_ptr,
                datatype_ptr,
                data_ptr,
            )
        })
    }

    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        let filename = file.to_str().ok_or_else(|| {
            anyhow!(
                "{}",
                self.context("dump_state failed due to invalid UTF-8 path")
            )
        })?;
        let filename = CString::new(filename).map_err(|_| {
            anyhow!(
                "{}",
                self.context("dump_state failed due to embedded null byte in path")
            )
        })?;
        self.check_errno(
            unsafe {
                (self.handle.interface.dump_state_fn)(
                    self.handle.instance,
                    filename.as_ptr(),
                    qubits.as_ptr(),
                    qubits.len() as u64,
                )
            },
            "dump_state failed",
        )
    }
}
