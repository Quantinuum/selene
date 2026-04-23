use crate::utils::MetricValue;
use anyhow::Result;
use std::sync;

pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;
use crate::runtime::BatchOperation;
use delegate::delegate;
pub use inline::{ErrorModelFFIAdapter, ErrorModelOperationInterface};
pub use interface::{ErrorModelInterface, ErrorModelInterfaceFactory};
pub use version::ErrorModelAPIVersion;

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
}

pub struct ErrorModel(Box<dyn ErrorModelInterface>);

impl ErrorModel {
    pub fn from_boxed(interface: Box<dyn ErrorModelInterface>) -> Self {
        Self(interface)
    }

    pub fn into_boxed(self) -> Box<dyn ErrorModelInterface> {
        self.0
    }

    pub fn new(
        factory: sync::Arc<impl ErrorModelInterfaceFactory + 'static>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Self> {
        Ok(Self(factory.init(n_qubits, error_model_args)?))
    }
}

impl AsRef<dyn ErrorModelInterface> for ErrorModel {
    fn as_ref(&self) -> &(dyn ErrorModelInterface + 'static) {
        self.0.as_ref()
    }
}

impl AsMut<dyn ErrorModelInterface> for ErrorModel {
    fn as_mut(&mut self) -> &mut (dyn ErrorModelInterface + 'static) {
        &mut *self.0
    }
}

impl ErrorModelInterface for ErrorModel {
    delegate! {
        to self.0.as_mut() {
            fn shot_start(&mut self, shot_id: u64, error_model_seed: u64) -> Result<()>;
            fn shot_end(&mut self) -> Result<()>;
            fn handle_operations(&mut self, operations: BatchOperation, simulator: &mut dyn crate::simulator::SimulatorInterface) -> Result<BatchResult>;
            fn exit(&mut self) -> Result<()>;
            fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;
        }
    }
}
