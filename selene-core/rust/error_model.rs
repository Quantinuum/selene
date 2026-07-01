use crate::utils::{MetricValue, read_raw_metric};
use anyhow::{Result, anyhow};
use std::ffi::OsStr;
use std::sync;

use crate::gatewire::DynamicGateSet;
pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;
use crate::operation::BatchOperation;
use crate::plugin as plugin_utils;
pub use inline::{ErrorModelFFIAdapter, ErrorModelHandle, ErrorModelOperationInterface};
pub use interface::{ErrorModelInterface, ErrorModelInterfaceFactory};
pub use version::ErrorModelAPIVersion;

use crate::operation::plugin::{BatchExtractor, OperationResultBuilder};
use crate::simulator::{Simulator, SimulatorInterface, inline::borrowed_simulator_interface};

#[derive(Default)]
pub struct BoolResult {
    pub result_id: u64,
    pub value: bool,
}
#[derive(Default)]
pub struct U64Result {
    pub result_id: u64,
    pub value: u64,
}

#[derive(Default)]
pub struct BatchResult {
    pub bool_results: Vec<BoolResult>,
    pub u64_results: Vec<U64Result>,
}
impl BatchResult {
    pub fn set_bool_result(&mut self, result_id: u64, value: bool) {
        self.bool_results.push(BoolResult { result_id, value });
    }
    pub fn set_u64_result(&mut self, result_id: u64, value: u64) {
        self.u64_results.push(U64Result { result_id, value });
    }
    pub fn extend(&mut self, other: BatchResult) {
        self.bool_results.extend(other.bool_results);
        self.u64_results.extend(other.u64_results);
    }
}

enum ErrorModelBacking {
    Adapter { _adapter: Box<ErrorModelFFIAdapter> },
}

pub struct ErrorModel {
    handle: ErrorModelHandle<'static>,
    backing: ErrorModelBacking,
    name: String,
}

impl ErrorModel {
    pub fn from_boxed(interface: Box<dyn ErrorModelInterface>) -> Self {
        Self::from_boxed_named("Unknown", interface)
    }

    pub fn from_boxed_named(
        name: impl Into<String>,
        interface: Box<dyn ErrorModelInterface>,
    ) -> Self {
        let mut adapter = Box::new(ErrorModelFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: ErrorModelBacking::Adapter { _adapter: adapter },
            name: name.into(),
        }
    }

    pub fn into_boxed(self) -> Box<dyn ErrorModelInterface> {
        Box::new(self)
    }

    pub fn new(
        factory: sync::Arc<impl ErrorModelInterfaceFactory + 'static>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let name = factory.name().to_string();
        let interface: Box<dyn ErrorModelInterface> = factory.init(n_qubits, error_model_args)?;
        Ok(Self::from_boxed_named(name, interface))
    }

    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = plugin::ErrorModelPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, error_model_args)
    }

    fn context(&self, message: &'static str) -> String {
        format!("Error Model ({}): {message}", self.name)
    }

    fn label(&self) -> String {
        format!("Error Model ({})", self.name)
    }

    fn check_errno(&self, errno: plugin_utils::Errno, message: &'static str) -> Result<()> {
        plugin_utils::check_plugin_errno_with_context(
            errno,
            Some(self.handle.interface.last_error_fn),
            || anyhow!("{}", self.context(message)),
        )
    }

    pub fn handle_operations_with_simulator(
        &mut self,
        operations: BatchOperation,
        simulator: &mut Simulator,
    ) -> Result<BatchResult> {
        let mut operation_extractor = BatchExtractor::from_batch_operation(operations);
        let batch = operation_extractor.runtime_batch_extraction();
        let mut result_builder = OperationResultBuilder::default();
        let result = result_builder.operation_result();
        let simulator = simulator.ffi_parts().into_static();
        self.check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(
                    self.handle.instance,
                    batch,
                    simulator,
                    result,
                )
            },
            "handle_operations failed",
        )?;
        Ok(result_builder.finish())
    }
}

impl AsRef<dyn ErrorModelInterface> for ErrorModel {
    fn as_ref(&self) -> &(dyn ErrorModelInterface + 'static) {
        self
    }
}

impl AsMut<dyn ErrorModelInterface> for ErrorModel {
    fn as_mut(&mut self) -> &mut (dyn ErrorModelInterface + 'static) {
        self
    }
}

impl ErrorModelInterface for ErrorModel {
    fn shot_start(&mut self, shot_id: u64, error_model_seed: u64) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.shot_start_fn)(
                    self.handle.instance,
                    shot_id,
                    error_model_seed,
                )
            },
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
            Some(self.handle.interface.last_error_fn),
            gateset,
        )
    }

    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult> {
        let mut simulator_ref: &mut dyn SimulatorInterface = simulator;
        let simulator = borrowed_simulator_interface(&mut simulator_ref).into_static();
        let mut operation_extractor = BatchExtractor::from_batch_operation(operations);
        let batch = operation_extractor.runtime_batch_extraction();
        let mut result_builder = OperationResultBuilder::default();
        let result = result_builder.operation_result();
        self.check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(
                    self.handle.instance,
                    batch,
                    simulator,
                    result,
                )
            },
            "handle_operations failed",
        )?;
        Ok(result_builder.finish())
    }

    fn exit(&mut self) -> Result<()> {
        let _ = &self.backing;
        self.check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            "exit failed",
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.handle.interface.get_metrics_fn)(
                self.handle.instance,
                nth_metric,
                tag_ptr,
                datatype_ptr,
                data_ptr,
            )
        })
    }
}
