use anyhow::{Result, anyhow};
use clap::Parser;
use rand::{Rng, SeedableRng};
use rand_pcg::Pcg64Mcg;
use selene_core::error_model::interface::ErrorModelInterfaceFactory;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::export_error_model_plugin;
use selene_core::runtime::{BatchOperation, BuiltinGate, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

#[derive(Parser, Debug)]
struct Params {
    #[arg(long, default_value = "0.01")]
    flip_probability: f64,
    #[arg(long, default_value = "0.01")]
    angle_mutation: f64,
    #[arg(long, default_value = "0.01")]
    leak_probability: f64,
}

#[derive(Default, Debug)]
struct Stats {
    flips_induced: u64,
    leaks_induced: u64,
    total_angle_error: f64,
}

pub struct ExampleErrorModel {
    rng: Pcg64Mcg,
    error_params: Params,
    stats: Stats,
    leakage_map: Vec<bool>,
}

impl ExampleErrorModel {
    fn mutate_angle(&mut self, angle: f64) -> f64 {
        let offset = self
            .rng
            .random_range(-self.error_params.angle_mutation..self.error_params.angle_mutation);
        self.stats.total_angle_error += offset.abs();
        angle + offset
    }

    fn should_flip(&mut self) -> bool {
        self.rng.random_bool(self.error_params.flip_probability)
    }

    fn should_leak(&mut self) -> bool {
        self.rng.random_bool(self.error_params.leak_probability)
    }

    fn flip_qubit(&mut self, simulator: &mut dyn SimulatorInterface, qubit_id: u64) -> Result<()> {
        self.apply_simulator_void(
            simulator,
            Operation::phased_x(qubit_id, std::f64::consts::PI, 0.0)?,
        )?;
        self.stats.flips_induced += 1;
        Ok(())
    }

    fn apply_simulator_void(
        &mut self,
        simulator: &mut dyn SimulatorInterface,
        operation: Operation,
    ) -> Result<()> {
        let results = simulator.handle_operations(BatchOperation::error_model(vec![operation]))?;
        if results.bool_results.is_empty() && results.u64_results.is_empty() {
            Ok(())
        } else {
            Err(anyhow!(
                "ExampleErrorModel: simulator unexpectedly produced results for a non-measurement operation"
            ))
        }
    }

    fn measure_simulator(
        &mut self,
        simulator: &mut dyn SimulatorInterface,
        qubit_id: u64,
    ) -> Result<bool> {
        let results = simulator.handle_operations(BatchOperation::error_model(vec![
            Operation::Measure {
                qubit_id,
                result_id: 0,
            },
        ]))?;
        if results.u64_results.is_empty() && results.bool_results.len() == 1 {
            Ok(results.bool_results[0].value)
        } else {
            Err(anyhow!(
                "ExampleErrorModel: simulator returned an unexpected measurement result shape"
            ))
        }
    }

    fn handle_gate(
        &mut self,
        operation: Operation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<()> {
        match operation.as_builtin_gate()? {
            Some(BuiltinGate::PhasedX {
                qubit_id,
                theta,
                phi,
            }) => {
                let theta = self.mutate_angle(theta);
                let phi = self.mutate_angle(phi);
                self.apply_simulator_void(simulator, Operation::phased_x(qubit_id, theta, phi)?)?;
                if self.should_flip() {
                    self.flip_qubit(simulator, qubit_id)?;
                }
                if self.should_leak() {
                    self.stats.leaks_induced += 1;
                    self.leakage_map[qubit_id as usize] = true;
                }
            }
            Some(BuiltinGate::ZZPhase {
                qubit_id_1,
                qubit_id_2,
                theta,
            }) => {
                let theta = self.mutate_angle(theta);
                let mut leaked_1 = self.leakage_map[qubit_id_1 as usize];
                let mut leaked_2 = self.leakage_map[qubit_id_2 as usize];
                match (leaked_1, leaked_2) {
                    (false, true) => {
                        self.leakage_map[qubit_id_1 as usize] = true;
                        leaked_1 = true;
                    }
                    (true, false) => {
                        self.leakage_map[qubit_id_2 as usize] = true;
                        leaked_2 = true;
                    }
                    (false, false) => {
                        if self.should_leak() {
                            self.stats.leaks_induced += 2;
                            self.leakage_map[qubit_id_1 as usize] = true;
                            self.leakage_map[qubit_id_2 as usize] = true;
                            leaked_1 = true;
                            leaked_2 = true;
                        }
                    }
                    _ => {}
                }
                if !leaked_1 && !leaked_2 {
                    self.apply_simulator_void(
                        simulator,
                        Operation::zz_phase(qubit_id_1, qubit_id_2, theta)?,
                    )?;
                    if self.should_flip() {
                        self.flip_qubit(simulator, qubit_id_1)?;
                        self.flip_qubit(simulator, qubit_id_2)?;
                    }
                }
            }
            Some(BuiltinGate::RZ { qubit_id, theta }) => {
                let theta = self.mutate_angle(theta);
                self.apply_simulator_void(simulator, Operation::rz(qubit_id, theta)?)?;
                if self.should_flip() {
                    self.flip_qubit(simulator, qubit_id)?;
                }
                if self.should_leak() {
                    self.stats.leaks_induced += 1;
                    self.leakage_map[qubit_id as usize] = true;
                }
            }
            Some(BuiltinGate::PhasedXX { .. }) | None => {
                self.apply_simulator_void(simulator, operation)?;
            }
        }
        Ok(())
    }
}

impl ErrorModelInterface for ExampleErrorModel {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        self.rng = Pcg64Mcg::seed_from_u64(seed);
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
        for operation in operations {
            match operation {
                Operation::Gate { .. } => self.handle_gate(operation, simulator)?,
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    let measurement = if self.leakage_map[qubit_id as usize] {
                        self.rng.random_bool(0.9)
                    } else {
                        let true_measurement = self.measure_simulator(simulator, qubit_id)?;
                        if self.should_flip() {
                            self.stats.flips_induced += 1;
                            !true_measurement
                        } else {
                            true_measurement
                        }
                    };
                    results.set_bool_result(result_id, measurement);
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    let measurement = if self.leakage_map[qubit_id as usize] {
                        2
                    } else {
                        let true_measurement = self.measure_simulator(simulator, qubit_id)?;
                        if self.should_flip() {
                            self.stats.flips_induced += 1;
                            (!true_measurement) as u64
                        } else {
                            true_measurement as u64
                        }
                    };
                    results.set_u64_result(result_id, measurement);
                }
                Operation::Reset { qubit_id } => {
                    self.leakage_map[qubit_id as usize] = false;
                    self.apply_simulator_void(simulator, Operation::Reset { qubit_id })?;
                    if self.should_flip() {
                        self.flip_qubit(simulator, qubit_id)?;
                    }
                }
                Operation::Custom { .. } => {}
                _ => {}
            }
        }
        Ok(results)
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "flips_induced".to_string(),
                MetricValue::U64(self.stats.flips_induced),
            ))),
            1 => Ok(Some((
                "total_angle_error".to_string(),
                MetricValue::F64(self.stats.total_angle_error),
            ))),
            2 => Ok(Some((
                "leaks_induced".to_string(),
                MetricValue::U64(self.stats.leaks_induced),
            ))),
            3 => Ok(None),
            _ => Err(anyhow!(
                "Selene requested an out of bounds metric: {}",
                nth_metric
            )),
        }
    }
}

#[derive(Default)]
pub struct ExampleErrorModelFactory;

impl ErrorModelInterfaceFactory for ExampleErrorModelFactory {
    type Interface = ExampleErrorModel;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        match Params::try_parse_from(error_model_args.iter().map(|s| s.as_ref())) {
            Err(e) => Err(anyhow!(
                "Error parsing arguments to the example error model plugin: {}",
                e
            )),
            Ok(params) => Ok(Box::new(ExampleErrorModel {
                rng: Pcg64Mcg::seed_from_u64(0),
                error_params: params,
                stats: Stats::default(),
                leakage_map: vec![false; n_qubits as usize],
            })),
        }
    }
}

export_error_model_plugin!(crate::ExampleErrorModelFactory);
