use anyhow::{Result, bail};
use selene_core::error_model::interface::ErrorModelInterfaceFactory;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::export_error_model_plugin;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;
pub struct IdealErrorModel;

fn singleton_batch(op: Operation) -> BatchOperation {
    BatchOperation::error_model(vec![op])
}

impl ErrorModelInterface for IdealErrorModel {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }
    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        let mut pending = Vec::new();
        for op in operations {
            match op {
                Operation::RXYGate { .. }
                | Operation::RZZGate { .. }
                | Operation::RZGate { .. }
                | Operation::Measure { .. }
                | Operation::TK2Gate { .. }
                | Operation::RPPGate { .. }
                | Operation::Reset { .. } => pending.push(op),
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    if !pending.is_empty() {
                        results.extend(simulator.handle_operations(
                            BatchOperation::error_model(std::mem::take(&mut pending)),
                        )?);
                    }
                    // In this ideal model, there's no leakage, so a leaked measurement
                    // is just a regular measurement projected into the [0, 1] range.
                    let measurement_result =
                        simulator.handle_operations(singleton_batch(Operation::Measure {
                            qubit_id,
                            result_id,
                        }))?;
                    let Some(measurement) = measurement_result.bool_results.into_iter().next()
                    else {
                        bail!("Ideal error model did not receive a measurement result");
                    };
                    results.set_u64_result(result_id, measurement.value.into());
                }
                Operation::Custom { .. } => {
                    // Passively ignore custom operations
                }
                _ => {
                    bail!("Ideal error model received unsupported operation: {:?}", op);
                }
            }
        }
        if !pending.is_empty() {
            results.extend(simulator.handle_operations(BatchOperation::error_model(pending))?);
        }
        Ok(results)
    }

    fn get_metric(&mut self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
}

#[derive(Default)]
pub struct IdealErrorModelFactory;

impl ErrorModelInterfaceFactory for IdealErrorModelFactory {
    type Interface = IdealErrorModel;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let _ = n_qubits;
        if error_model_args.len() > 1 {
            bail!("Invalid number of arguments to ideal error model plugin");
        }
        Ok(Box::new(IdealErrorModel))
    }
}

export_error_model_plugin!(crate::IdealErrorModelFactory);
