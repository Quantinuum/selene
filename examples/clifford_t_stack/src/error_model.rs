use anyhow::{Result, anyhow};
use rand::{Rng, SeedableRng};
use rand_pcg::Pcg64Mcg;
use selene_core::error_model::{
    BatchResult, ErrorModelInterface, interface::ErrorModelInterfaceFactory,
};
use selene_core::gatewire::{DynamicGateSet, GateSetSpec, Qubit};
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

use crate::gates::{CliffordT, X, clifford_t_gateset, require_clifford_t};

#[derive(Debug)]
pub struct CliffordTErrorModel {
    rng: Pcg64Mcg,
    flip_probability: f64,
    injected_x: u64,
}

impl CliffordTErrorModel {
    pub fn new(flip_probability: f64) -> Result<Self> {
        if !(0.0..=1.0).contains(&flip_probability) {
            return Err(anyhow!("flip probability must be between 0 and 1"));
        }
        Ok(Self {
            rng: Pcg64Mcg::seed_from_u64(0),
            flip_probability,
            injected_x: 0,
        })
    }

    pub fn deterministic() -> Self {
        Self::new(1.0).expect("deterministic probability is valid")
    }

    fn send(simulator: &mut dyn SimulatorInterface, op: Operation) -> Result<()> {
        let results = simulator.handle_operations(BatchOperation::error_model(vec![op]))?;
        if results.bool_results.is_empty() && results.u64_results.is_empty() {
            Ok(())
        } else {
            Err(anyhow!("non-measurement operation produced results"))
        }
    }

    pub fn injected_x(&self) -> u64 {
        self.injected_x
    }
}

impl ErrorModelInterface for CliffordTErrorModel {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        self.rng = Pcg64Mcg::seed_from_u64(seed);
        self.injected_x = 0;
        Ok(())
    }

    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        require_clifford_t(gateset)?;
        Ok(clifford_t_gateset())
    }

    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::Gate { gate } => {
                    let injection_target = gate.single_qubit_operand();
                    Self::send(simulator, Operation::from_gate_instance(gate)?)?;
                    if let Some(q0) = injection_target {
                        if self.rng.random::<f64>() < self.flip_probability {
                            let injected = CliffordT::X(X { q0: Qubit(q0) }).to_instance();
                            Self::send(simulator, Operation::from_gate_instance(injected)?)?;
                            self.injected_x += 1;
                        }
                    }
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    let mut measurement =
                        simulator.handle_operations(BatchOperation::error_model(vec![
                            Operation::Measure {
                                qubit_id,
                                result_id: 0,
                            },
                        ]))?;
                    let result = measurement
                        .bool_results
                        .pop()
                        .ok_or_else(|| anyhow!("simulator returned no bool result"))?
                        .value;
                    results.set_bool_result(result_id, result);
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    let mut measurement =
                        simulator.handle_operations(BatchOperation::error_model(vec![
                            Operation::Measure {
                                qubit_id,
                                result_id: 0,
                            },
                        ]))?;
                    let result = measurement
                        .bool_results
                        .pop()
                        .ok_or_else(|| anyhow!("simulator returned no bool result"))?
                        .value;
                    results.set_u64_result(result_id, result.into());
                }
                Operation::Reset { qubit_id } => {
                    Self::send(simulator, Operation::Reset { qubit_id })?;
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
                "injected_x".to_string(),
                MetricValue::U64(self.injected_x),
            ))),
            _ => Ok(None),
        }
    }
}

#[derive(Default)]
pub struct CliffordTErrorModelFactory;

impl ErrorModelInterfaceFactory for CliffordTErrorModelFactory {
    type Interface = CliffordTErrorModel;

    fn init(
        self: std::sync::Arc<Self>,
        _n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let args = error_model_args
            .get(1..)
            .ok_or_else(|| anyhow!("missing plugin argv"))?;
        let flip_probability = match args {
            [] => 1.0,
            [probability] => probability
                .as_ref()
                .parse::<f64>()
                .map_err(|error| anyhow!("invalid flip probability: {error}"))?,
            _ => return Err(anyhow!("expected at most one error model argument")),
        };
        Ok(Box::new(CliffordTErrorModel::new(flip_probability)?))
    }
}

selene_core::export_error_model_plugin!(crate::CliffordTErrorModelFactory);
