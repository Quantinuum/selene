use crate::utils::{MetricValue, check_errno, read_raw_metric};
use anyhow::{Result, anyhow};
use std::ffi::OsStr;
use std::sync;

pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;
use crate::operation::BatchOperation;
pub use inline::{ErrorModelFFIAdapter, ErrorModelHandle, ErrorModelOperationInterface};
pub use interface::{ErrorModelInterface, ErrorModelInterfaceFactory};
pub use version::ErrorModelAPIVersion;

use self::plugin::BatchResultBuilder;
use crate::operation::plugin::BatchExtractor;
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
}

impl ErrorModel {
    pub fn from_boxed(interface: Box<dyn ErrorModelInterface>) -> Self {
        let mut adapter = Box::new(ErrorModelFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: ErrorModelBacking::Adapter { _adapter: adapter },
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
        let interface: Box<dyn ErrorModelInterface> = factory.init(n_qubits, error_model_args)?;
        Ok(Self::from_boxed(interface))
    }

    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = plugin::ErrorModelPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, error_model_args)
    }

    pub fn handle_operations_with_simulator(
        &mut self,
        operations: BatchOperation,
        simulator: &mut Simulator,
    ) -> Result<BatchResult> {
        let mut operation_extractor = BatchExtractor::from_batch_operation(operations);
        let batch = operation_extractor.runtime_batch_extraction();
        let mut result_builder = BatchResultBuilder::default();
        let result = result_builder.error_model_set_result();
        let simulator = simulator.ffi_parts().into_static();
        check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(
                    self.handle.instance,
                    batch,
                    simulator,
                    result,
                )
            },
            || anyhow!("ErrorModel: handle_operations failed"),
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
        check_errno(
            unsafe {
                (self.handle.interface.shot_start_fn)(
                    self.handle.instance,
                    shot_id,
                    error_model_seed,
                )
            },
            || anyhow!("ErrorModel: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.shot_end_fn)(self.handle.instance) },
            || anyhow!("ErrorModel: shot_end failed"),
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
        let mut result_builder = BatchResultBuilder::default();
        let result = result_builder.error_model_set_result();
        check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(
                    self.handle.instance,
                    batch,
                    simulator,
                    result,
                )
            },
            || anyhow!("ErrorModel: handle_operations failed"),
        )?;
        Ok(result_builder.finish())
    }

    fn exit(&mut self) -> Result<()> {
        let _ = &self.backing;
        check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            || anyhow!("ErrorModel: exit failed"),
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
