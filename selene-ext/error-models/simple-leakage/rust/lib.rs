use anyhow::{Result, anyhow, bail};
use clap::Parser;
use rand::{Rng, SeedableRng};
use rand_pcg::Pcg64Mcg;
use selene_core::error_model::interface::ErrorModelInterfaceFactory;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::export_error_model_plugin;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

#[derive(Parser, Debug)]
struct Params {
    /// The probability of leakage on each operation
    #[arg(long)]
    p_leak: f64,
    /// The probability that a leaked qubit will measure as 1.
    #[arg(long)]
    leak_measurement_bias: f64,
}
#[derive(Default)]
struct Stats {
    spontaneous_leaks: u64,
    interaction_leaks: u64,
}

pub struct SimpleLeakageErrorModel {
    n_qubits: u64,
    rng: Pcg64Mcg,
    leak_register: Vec<bool>,
    error_params: Params,
    stats: Stats,
}

impl SimpleLeakageErrorModel {
    fn singleton_batch(op: Operation) -> BatchOperation {
        BatchOperation::error_model(vec![op])
    }

    fn flush_pending(
        &mut self,
        pending: &mut Vec<Operation>,
        simulator: &mut dyn SimulatorInterface,
        results: &mut BatchResult,
    ) -> Result<()> {
        if pending.is_empty() {
            return Ok(());
        }
        results.extend(
            simulator.handle_operations(BatchOperation::error_model(std::mem::take(pending)))?,
        );
        Ok(())
    }

    fn is_leaked(&self, qubit: u64) -> Result<bool> {
        if qubit >= self.n_qubits {
            bail!(
                "Qubit ID {} is out of bounds for this error model with {} qubits",
                qubit,
                self.n_qubits
            );
        }
        Ok(self.leak_register[qubit as usize])
    }
    fn leak(&mut self, qubit: u64) -> Result<()> {
        if !self.is_leaked(qubit)? {
            self.leak_register[qubit as usize] = true;
        }
        Ok(())
    }
    fn maybe_leak(&mut self, qubit: u64) -> Result<()> {
        if self.is_leaked(qubit)? {
            // If the qubit is already in a leaked state, we don't do anything
            return Ok(());
        }
        if self.rng.random::<f64>() < self.error_params.p_leak {
            self.leak(qubit)?;
            self.stats.spontaneous_leaks += 1;
        }
        Ok(())
    }
    fn spread_leakage(&mut self, qubit_1: u64, qubit_2: u64) -> Result<()> {
        if self.is_leaked(qubit_1)? ^ self.is_leaked(qubit_2)? {
            self.leak(qubit_1)?;
            self.leak(qubit_2)?;
            self.stats.interaction_leaks += 1;
        }
        Ok(())
    }
}

impl ErrorModelInterface for SimpleLeakageErrorModel {
    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        self.rng = Pcg64Mcg::seed_from_u64(seed);
        self.leak_register = vec![false; self.n_qubits as usize];
        self.stats = Stats::default();
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn exit(&mut self) -> Result<()> {
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
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => {
                    self.maybe_leak(qubit_id)?;
                    pending.push(Operation::RXYGate {
                        qubit_id,
                        theta,
                        phi,
                    });
                }
                Operation::RZGate { qubit_id, theta } => {
                    self.maybe_leak(qubit_id)?;
                    pending.push(Operation::RZGate { qubit_id, theta });
                }
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => {
                    self.maybe_leak(qubit_id_1)?;
                    self.maybe_leak(qubit_id_2)?;
                    self.spread_leakage(qubit_id_1, qubit_id_2)?;
                    pending.push(Operation::RZZGate {
                        qubit_id_1,
                        qubit_id_2,
                        theta,
                    });
                }
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => {
                    self.maybe_leak(qubit_id_1)?;
                    self.maybe_leak(qubit_id_2)?;
                    self.spread_leakage(qubit_id_1, qubit_id_2)?;
                    pending.push(Operation::RPPGate {
                        qubit_id_1,
                        qubit_id_2,
                        theta,
                        phi,
                    });
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    self.flush_pending(&mut pending, simulator, &mut results)?;
                    let measurement = if self.leak_register[qubit_id as usize] {
                        self.rng
                            .random_bool(self.error_params.leak_measurement_bias)
                    } else {
                        let measurement_result = simulator.handle_operations(
                            Self::singleton_batch(Operation::Measure {
                                qubit_id,
                                result_id,
                            }),
                        )?;
                        let Some(measurement) = measurement_result.bool_results.into_iter().next()
                        else {
                            bail!(
                                "Simple leakage error model did not receive a measurement result"
                            );
                        };
                        measurement.value
                    };
                    results.set_bool_result(result_id, measurement);
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    self.flush_pending(&mut pending, simulator, &mut results)?;
                    let measurement = if self.leak_register[qubit_id as usize] {
                        2
                    } else {
                        let measurement_result = simulator.handle_operations(
                            Self::singleton_batch(Operation::Measure {
                                qubit_id,
                                result_id,
                            }),
                        )?;
                        let Some(measurement) = measurement_result.bool_results.into_iter().next()
                        else {
                            bail!(
                                "Simple leakage error model did not receive a leaked measurement result"
                            );
                        };
                        measurement.value as u64
                    };
                    results.set_u64_result(result_id, measurement);
                }
                Operation::Reset { qubit_id } => {
                    self.leak_register[qubit_id as usize] = false;
                    pending.push(Operation::Reset { qubit_id });
                }
                Operation::Custom { .. } => {
                    // Passively ignore custom operations
                }
                _ => {
                    bail!("SimpleLeakageErrorModel: Unsupported operation {:?}", op);
                }
            }
        }
        self.flush_pending(&mut pending, simulator, &mut results)?;
        Ok(results)
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "spontaneous_leaks".to_string(),
                MetricValue::U64(self.stats.spontaneous_leaks),
            ))),
            1 => Ok(Some((
                "interaction_leaks".to_string(),
                MetricValue::U64(self.stats.interaction_leaks),
            ))),
            _ => Ok(None),
        }
    }
}

#[derive(Default)]
pub struct SimpleLeakageErrorModelFactory;

impl ErrorModelInterfaceFactory for SimpleLeakageErrorModelFactory {
    type Interface = SimpleLeakageErrorModel;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        match Params::try_parse_from(error_model_args.iter().map(|s| s.as_ref())) {
            Err(e) => Err(anyhow!(
                "Error parsing arguments to depolarizing error model plugin: {}",
                e
            )),
            Ok(params) => {
                let leak_register = vec![false; n_qubits as usize];
                Ok(Box::new(SimpleLeakageErrorModel {
                    n_qubits,
                    rng: Pcg64Mcg::seed_from_u64(0),
                    leak_register,
                    error_params: params,
                    stats: Stats::default(),
                }))
            }
        }
    }
}

export_error_model_plugin!(crate::SimpleLeakageErrorModelFactory);
