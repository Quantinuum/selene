use anyhow::{Result, bail};
use selene_core::error_model::interface::ErrorModelInterfaceFactory;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::export_error_model_plugin;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;
pub struct IdealErrorModel;

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
        for op in operations {
            match op {
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => {
                    simulator.rxy(qubit_id, theta, phi)?;
                }
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => {
                    simulator.rzz(qubit_id_1, qubit_id_2, theta)?;
                }
                Operation::RZGate { qubit_id, theta } => {
                    simulator.rz(qubit_id, theta)?;
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    let measurement = simulator.measure(qubit_id)?;
                    results.set_bool_result(result_id, measurement);
                }
                Operation::TK2Gate {
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                } => {
                    simulator.tk2(qubit_id_1, qubit_id_2, alpha, beta, gamma)?;
                }
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => {
                    simulator.rpp(qubit_id_1, qubit_id_2, theta, phi)?;
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    // In this ideal model, there's no leakage.
                    // Just do a normal measurement and stick to the [0,1] range
                    let measurement = simulator.measure(qubit_id)?;
                    results.set_u64_result(result_id, measurement.into());
                }

                Operation::Reset { qubit_id } => {
                    simulator.reset(qubit_id)?;
                }
                Operation::Custom { .. } => {
                    // Passively ignore custom operations
                }
                _ => {
                    bail!("Ideal error model received unsupported operation: {:?}", op);
                }
            }
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
