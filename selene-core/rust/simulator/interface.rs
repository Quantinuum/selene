use anyhow::{Result, bail};
use std::sync::Arc;

use crate::error_model::BatchResult;
use crate::gatewire::{DynamicGateSet, builtin};
use crate::runtime::BatchOperation;
use crate::utils::MetricValue;

pub trait SimulatorInterface {
    // Signals that the instance of the simulator should cleanup. Plugins
    // should `Err` from any functions called on an instance after `exit`.
    fn exit(&mut self) -> Result<()>;

    // Called to signal that the simulator should prepare to begin a shot
    // with the given random seed.
    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()>;

    // Called to signal that the simulator should prepare to end the current
    // shot.
    fn shot_end(&mut self) -> Result<()>;

    // Validate the gates this simulator may receive.
    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        let supported = builtin::all();
        if let Some(decl) = gateset.first_unsupported_by(&supported) {
            bail!("The chosen simulator does not support gate {}", decl.name);
        }
        Ok(gateset.clone())
    }

    // Perform a batch of runtime operations on the simulator and return the
    // results of any measurements in the batch.
    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult>;

    // Perform a post-selection on the given qubit.
    // If the post-selection isn't deemed possible, return an error.
    // This is optional functionality, and the default is to raise an
    // error.
    fn postselect(&mut self, _qubit: u64, _target_value: bool) -> Result<()> {
        bail!("Post-selection is not supported on the chosen simulator.");
    }

    // Provide a metric to the output stream.
    // Will be called with incrementing `nth_metric` until `None` is returned.
    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;

    // Dump the internal state of the simulator to the given file, in a manner
    // parsable by the python component of the simulator. The qubits provided
    // by the user may be used to specify an ordering, but the approach used
    // is implementor defined.
    fn dump_state(&mut self, _file: &std::path::Path, _qubits: &[u64]) -> Result<()> {
        Err(anyhow::anyhow!(
            "Dumping state is not supported on the chosen simulator."
        ))
    }
}

pub trait SimulatorInterfaceFactory {
    type Interface: SimulatorInterface;
    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>>;
}
