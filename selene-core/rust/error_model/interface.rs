use anyhow::Result;
use std::sync::Arc;

use crate::error_model::BatchResult;
use crate::runtime::BatchOperation;
use crate::simulator::SimulatorInterface;
use crate::utils::MetricValue;

/// Instances of error model plugins implement this interface.
///
/// Many instances of a plugin may exist simultaneously. Instance are
/// generically constructed by impls of [ErrorModelInterfaceFactory].
///
/// All functions can return an error, which will usually result in aborting the
/// emulation.
///
/// `cdylib` crates can export the error model plugin C interface via
/// [crate::export_error_model_plugin!]
pub trait ErrorModelInterface {
    /// Signals that the instance of the error model plugin should cleanup. Plugins
    /// should `Err`` from any functions called on an instance after `exit`. They can
    /// also return an error from `exit` itself if an expected condition is not met.
    fn exit(&mut self) -> Result<()>;
    /// Called to signal that the error model should proceed to the next shot. It should
    /// reset all state that has an impact on the next shot, such as caches. A new random
    /// seed is provided, and the error model should reseed its RNG based on this. It should
    /// also invoke shot_start on its underlying simulator with the provided new_simulator_seed.
    ///
    /// It is important that reseeding is performed. This way, a single shot can be
    /// deterministically repeated by reseeding the error model with the same seed,
    /// regardless of whether or not it is the first or Nth in a sequence of shots.
    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()>;
    /// Called to signal that the current shot has ended
    fn shot_end(&mut self) -> Result<()>;
    /// Provide the error model with a batch of quantum operations from the runtime.
    /// The error model should perform any required measurements and return them in the
    /// BatchResult upon success.
    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult>;
    /// Request metrics from the error model.
    ///
    /// Error models may wish to provide metrics such as:
    /// - the number or rate of pauli errors introduced.
    /// - the number of times an instruction is ignored
    /// - the number of leaked qubits
    ///
    /// It can implement this function and return metrics in the form of a string label and a
    /// MetricValue, which can take on the form of a u64, i64, f64 or boolean. This function
    /// is invoked until it returns None, or until nth_metric exceeds 255 - this allows for
    /// dynamic metrics to be provided by the error model, with a different number of metrics
    /// depending on runtime information such as number of qubits.
    ///
    /// Metrics may be requested at the end of a shot or mid-shot, depending on the configuration
    /// of selene provided by the user.
    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;
}

pub trait ErrorModelInterfaceFactory {
    type Interface: ErrorModelInterface;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>>;
}
