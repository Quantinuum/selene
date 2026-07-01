use anyhow::{Result, anyhow, bail};
use clap::Parser;
use rand::{Rng, SeedableRng};
use rand_pcg::Pcg64Mcg;
use selene_core::error_model::interface::ErrorModelInterfaceFactory;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::export_error_model_plugin;
use selene_core::gatewire::{DynamicGateSet, builtin};
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

#[derive(Parser, Debug)]
struct Params {
    /// The probability of a single-qubit gate error
    #[arg(long)]
    p_1q: f64,
    /// The probability of a two-qubit gate error
    #[arg(long)]
    p_2q: f64,
    /// The probability of a measurement error
    #[arg(long)]
    p_meas: f64,
    /// The probability of an initialization error
    #[arg(long)]
    p_init: f64,
}
#[derive(Default)]
struct Stats {
    gate_count_1q: u64,
    err_count_1q_x: u64,
    err_count_1q_y: u64,
    err_count_1q_z: u64,

    gate_count_2q: u64,
    err_count_2q_ix: u64,
    err_count_2q_iy: u64,
    err_count_2q_iz: u64,
    err_count_2q_xi: u64,
    err_count_2q_xx: u64,
    err_count_2q_xy: u64,
    err_count_2q_xz: u64,
    err_count_2q_yi: u64,
    err_count_2q_yx: u64,
    err_count_2q_yy: u64,
    err_count_2q_yz: u64,
    err_count_2q_zi: u64,
    err_count_2q_zx: u64,
    err_count_2q_zy: u64,
    err_count_2q_zz: u64,
    measure_count: u64,
    measure_errors: u64,
    init_count: u64,
    init_errors: u64,
}
pub enum ErrorType {
    I,
    X,
    Y,
    Z,
}

selene_core::define_gateset! {
    enum DepolarizingCorrectionGateSet {
        RZ(builtin::RZ),
        PhasedX(builtin::PhasedX),
    }
}

impl DepolarizingCorrectionGateSet {
    fn dynamic() -> DynamicGateSet {
        DynamicGateSet::from_declarations(
            <Self as selene_core::gatewire::GateSetSpec>::declarations(),
        )
        .expect("depolarizing correction gate declarations are unique")
    }
}

pub struct DepolarizingErrorModel {
    n_qubits: u64,
    rng: Pcg64Mcg,
    error_params: Params,
    stats: Stats,
}

impl DepolarizingErrorModel {
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

    fn error_operation(&self, qubit: u64, error: ErrorType) -> Option<Operation> {
        match error {
            ErrorType::I => None,
            ErrorType::X => Some(Operation::phased_x(qubit, std::f64::consts::PI, 0.0).ok()?),
            ErrorType::Y => Some(
                Operation::phased_x(qubit, std::f64::consts::PI, std::f64::consts::PI / 2.0)
                    .ok()?,
            ),
            ErrorType::Z => Some(Operation::rz(qubit, std::f64::consts::PI).ok()?),
        }
    }
    fn maybe_apply_1q_error(&mut self, q0: u64) -> Result<Option<Operation>> {
        // validate arg
        if q0 >= self.n_qubits {
            bail!(
                "Error: q0 must be less than the number of qubits ({}).",
                self.n_qubits
            );
        }
        // generate error to apply
        let random_float = self.rng.random::<f64>();
        let error = if random_float > self.error_params.p_1q {
            ErrorType::I
        } else {
            let selection = (random_float * 3.0 / self.error_params.p_1q) as u64;
            match selection {
                0 => ErrorType::X,
                1 => ErrorType::Y,
                _ => ErrorType::Z,
            }
        };
        // update statistics
        self.stats.gate_count_1q += 1;
        match error {
            ErrorType::I => (),
            ErrorType::X => self.stats.err_count_1q_x += 1,
            ErrorType::Y => self.stats.err_count_1q_y += 1,
            ErrorType::Z => self.stats.err_count_1q_z += 1,
        }
        Ok(self.error_operation(q0, error))
    }
    fn maybe_apply_2q_error(&mut self, q0: u64, q1: u64) -> Result<Vec<Operation>> {
        // validate arg
        if q0 >= self.n_qubits || q1 >= self.n_qubits {
            bail!(
                "Error: q0 and q1 must be less than the number of qubits ({}).",
                self.n_qubits
            );
        }
        // generate error to apply
        let random_float = self.rng.random::<f64>();
        let (error0, error1) = if random_float > self.error_params.p_2q {
            (ErrorType::I, ErrorType::I)
        } else {
            let selection = (random_float * 15.0 / self.error_params.p_2q) as u64;
            match selection {
                0 => (ErrorType::I, ErrorType::X),
                1 => (ErrorType::I, ErrorType::Y),
                2 => (ErrorType::I, ErrorType::Z),
                3 => (ErrorType::X, ErrorType::I),
                4 => (ErrorType::X, ErrorType::X),
                5 => (ErrorType::X, ErrorType::Y),
                6 => (ErrorType::X, ErrorType::Z),
                7 => (ErrorType::Y, ErrorType::I),
                8 => (ErrorType::Y, ErrorType::X),
                9 => (ErrorType::Y, ErrorType::Y),
                10 => (ErrorType::Y, ErrorType::Z),
                11 => (ErrorType::Z, ErrorType::I),
                12 => (ErrorType::Z, ErrorType::X),
                13 => (ErrorType::Z, ErrorType::Y),
                _ => (ErrorType::Z, ErrorType::Z),
            }
        };
        // update statistics
        self.stats.gate_count_2q += 1;
        match (&error0, &error1) {
            (ErrorType::I, ErrorType::I) => (),
            (ErrorType::I, ErrorType::X) => self.stats.err_count_2q_ix += 1,
            (ErrorType::I, ErrorType::Y) => self.stats.err_count_2q_iy += 1,
            (ErrorType::I, ErrorType::Z) => self.stats.err_count_2q_iz += 1,
            (ErrorType::X, ErrorType::I) => self.stats.err_count_2q_xi += 1,
            (ErrorType::X, ErrorType::X) => self.stats.err_count_2q_xx += 1,
            (ErrorType::X, ErrorType::Y) => self.stats.err_count_2q_xy += 1,
            (ErrorType::X, ErrorType::Z) => self.stats.err_count_2q_xz += 1,
            (ErrorType::Y, ErrorType::I) => self.stats.err_count_2q_yi += 1,
            (ErrorType::Y, ErrorType::X) => self.stats.err_count_2q_yx += 1,
            (ErrorType::Y, ErrorType::Y) => self.stats.err_count_2q_yy += 1,
            (ErrorType::Y, ErrorType::Z) => self.stats.err_count_2q_yz += 1,
            (ErrorType::Z, ErrorType::I) => self.stats.err_count_2q_zi += 1,
            (ErrorType::Z, ErrorType::X) => self.stats.err_count_2q_zx += 1,
            (ErrorType::Z, ErrorType::Y) => self.stats.err_count_2q_zy += 1,
            (ErrorType::Z, ErrorType::Z) => self.stats.err_count_2q_zz += 1,
        }
        let mut operations = Vec::new();
        if let Some(op) = self.error_operation(q0, error0) {
            operations.push(op);
        }
        if let Some(op) = self.error_operation(q1, error1) {
            operations.push(op);
        }
        Ok(operations)
    }
    fn maybe_flip_measurement(&mut self, _qubit: u64, result: bool) -> bool {
        let val = self.rng.random::<f64>();
        let flip = val < self.error_params.p_meas;
        self.stats.measure_count += 1;
        if flip {
            self.stats.measure_errors += 1;
            !result
        } else {
            result
        }
    }
    fn maybe_flip_on_init(&mut self, qubit: u64) -> Result<Option<Operation>> {
        self.stats.init_count += 1;
        let val = self.rng.random::<f64>();
        if val < self.error_params.p_init {
            self.stats.init_errors += 1;
            return Ok(self.error_operation(qubit, ErrorType::X));
        }
        Ok(None)
    }
}

impl ErrorModelInterface for DepolarizingErrorModel {
    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        self.rng = Pcg64Mcg::seed_from_u64(seed);
        self.stats = Stats::default();
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        gateset
            .union(&DepolarizingCorrectionGateSet::dynamic())
            .map_err(Into::into)
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
                Operation::Gate { gate } => {
                    let qubits: Vec<u64> = gate.qubit_operands().map(u64::from).collect();
                    match qubits.as_slice() {
                        [q0] => {
                            if let Some(error) = self.maybe_apply_1q_error(*q0)? {
                                pending.push(error);
                            }
                        }
                        [q0, q1] => {
                            pending.extend(self.maybe_apply_2q_error(*q0, *q1)?);
                        }
                        _ => {}
                    }
                    pending.push(Operation::from_gate_instance(gate)?);
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    self.flush_pending(&mut pending, simulator, &mut results)?;
                    let measurement_result =
                        simulator.handle_operations(Self::singleton_batch(Operation::Measure {
                            qubit_id,
                            result_id,
                        }))?;
                    let Some(measurement) = measurement_result.bool_results.into_iter().next()
                    else {
                        bail!("Depolarizing error model did not receive a measurement result");
                    };
                    let modified_measurement =
                        self.maybe_flip_measurement(qubit_id, measurement.value);
                    results.set_bool_result(result_id, modified_measurement);
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    self.flush_pending(&mut pending, simulator, &mut results)?;
                    // We aren't modelling leakage so this is the same as a normal measurement,
                    // except we set the u64 future as 0 or 1 (leakage would include higher values)
                    let measurement_result =
                        simulator.handle_operations(Self::singleton_batch(Operation::Measure {
                            qubit_id,
                            result_id,
                        }))?;
                    let Some(measurement) = measurement_result.bool_results.into_iter().next()
                    else {
                        bail!(
                            "Depolarizing error model did not receive a leaked measurement result"
                        );
                    };
                    let modified_measurement =
                        self.maybe_flip_measurement(qubit_id, measurement.value);
                    results.set_u64_result(result_id, if modified_measurement { 1 } else { 0 });
                }
                Operation::Reset { qubit_id } => {
                    pending.push(Operation::Reset { qubit_id });
                    if let Some(error) = self.maybe_flip_on_init(qubit_id)? {
                        pending.push(error);
                    }
                }
                Operation::Postselect {
                    qubit_id,
                    target_value,
                } => {
                    pending.push(Operation::Postselect {
                        qubit_id,
                        target_value,
                    });
                    self.flush_pending(&mut pending, simulator, &mut results)?;
                }
                Operation::Custom { .. } => {
                    // Passively ignore custom operations
                }
                _ => {
                    bail!("DepolarizingErrorModel: Unsupported operation {:?}", op);
                }
            }
        }
        self.flush_pending(&mut pending, simulator, &mut results)?;
        Ok(results)
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "gates_1q".to_string(),
                MetricValue::U64(self.stats.gate_count_1q),
            ))),
            1 => Ok(Some((
                "errors_1q_x".to_string(),
                MetricValue::U64(self.stats.err_count_1q_x),
            ))),
            2 => Ok(Some((
                "errors_1q_y".to_string(),
                MetricValue::U64(self.stats.err_count_1q_y),
            ))),
            3 => Ok(Some((
                "errors_1q_z".to_string(),
                MetricValue::U64(self.stats.err_count_1q_z),
            ))),
            4 => Ok(Some((
                "gates_2q".to_string(),
                MetricValue::U64(self.stats.gate_count_2q),
            ))),
            5 => Ok(Some((
                "errors_2q_ix".to_string(),
                MetricValue::U64(self.stats.err_count_2q_ix),
            ))),
            6 => Ok(Some((
                "errors_2q_iy".to_string(),
                MetricValue::U64(self.stats.err_count_2q_iy),
            ))),
            7 => Ok(Some((
                "errors_2q_iz".to_string(),
                MetricValue::U64(self.stats.err_count_2q_iz),
            ))),
            8 => Ok(Some((
                "errors_2q_xi".to_string(),
                MetricValue::U64(self.stats.err_count_2q_xi),
            ))),
            9 => Ok(Some((
                "errors_2q_xx".to_string(),
                MetricValue::U64(self.stats.err_count_2q_xx),
            ))),
            10 => Ok(Some((
                "errors_2q_xy".to_string(),
                MetricValue::U64(self.stats.err_count_2q_xy),
            ))),
            11 => Ok(Some((
                "errors_2q_xz".to_string(),
                MetricValue::U64(self.stats.err_count_2q_xz),
            ))),
            12 => Ok(Some((
                "errors_2q_yi".to_string(),
                MetricValue::U64(self.stats.err_count_2q_yi),
            ))),
            13 => Ok(Some((
                "errors_2q_yx".to_string(),
                MetricValue::U64(self.stats.err_count_2q_yx),
            ))),
            14 => Ok(Some((
                "errors_2q_yy".to_string(),
                MetricValue::U64(self.stats.err_count_2q_yy),
            ))),
            15 => Ok(Some((
                "errors_2q_yz".to_string(),
                MetricValue::U64(self.stats.err_count_2q_yz),
            ))),
            16 => Ok(Some((
                "errors_2q_zi".to_string(),
                MetricValue::U64(self.stats.err_count_2q_zi),
            ))),
            17 => Ok(Some((
                "errors_2q_zx".to_string(),
                MetricValue::U64(self.stats.err_count_2q_zx),
            ))),
            18 => Ok(Some((
                "errors_2q_zy".to_string(),
                MetricValue::U64(self.stats.err_count_2q_zy),
            ))),
            19 => Ok(Some((
                "errors_2q_zz".to_string(),
                MetricValue::U64(self.stats.err_count_2q_zz),
            ))),
            20 => Ok(Some((
                "measurements".to_string(),
                MetricValue::U64(self.stats.measure_count),
            ))),
            21 => Ok(Some((
                "measurement_errors".to_string(),
                MetricValue::U64(self.stats.measure_errors),
            ))),
            22 => Ok(Some((
                "inits".to_string(),
                MetricValue::U64(self.stats.init_count),
            ))),
            23 => Ok(Some((
                "init_errors".to_string(),
                MetricValue::U64(self.stats.init_errors),
            ))),
            _ => Ok(None),
        }
    }
}

#[derive(Default)]
pub struct DepolarizingErrorModelFactory;

impl ErrorModelInterfaceFactory for DepolarizingErrorModelFactory {
    type Interface = DepolarizingErrorModel;

    fn name(&self) -> &str {
        "Depolarizing"
    }

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
            Ok(params) => Ok(Box::new(DepolarizingErrorModel {
                n_qubits,
                rng: Pcg64Mcg::seed_from_u64(0),
                error_params: params,
                stats: Stats::default(),
            })),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use selene_core::gatewire::{
        GateDecl, GateSemanticId, GateValue, OperandKind, OperandSpec, OwnedGateInstance,
    };

    struct RecordingSimulator {
        operations: Vec<Operation>,
    }

    impl SimulatorInterface for RecordingSimulator {
        fn exit(&mut self) -> Result<()> {
            Ok(())
        }

        fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
            Ok(())
        }

        fn shot_end(&mut self) -> Result<()> {
            Ok(())
        }

        fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
            self.operations.extend(operations);
            Ok(BatchResult::default())
        }

        fn get_metric(&mut self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
            Ok(None)
        }
    }

    fn custom_1q_decl() -> GateDecl {
        GateDecl::new(
            GateSemanticId::from_text("test.custom.OneQ.v1"),
            "OneQ",
            [OperandSpec::new("q0", OperandKind::Qubit)],
            1,
        )
    }

    fn model_with_probabilities(p_1q: f64, p_2q: f64) -> DepolarizingErrorModel {
        DepolarizingErrorModel {
            n_qubits: 4,
            rng: Pcg64Mcg::seed_from_u64(0),
            error_params: Params {
                p_1q,
                p_2q,
                p_meas: 0.0,
                p_init: 0.0,
            },
            stats: Stats::default(),
        }
    }

    #[test]
    fn negotiation_accepts_custom_gates_and_adds_injection_gates() {
        let custom = custom_1q_decl();
        let custom_id = custom.semantic_id;
        let gateset = DynamicGateSet::from_declarations([custom]).unwrap();
        let mut model = model_with_probabilities(0.0, 0.0);

        let negotiated = model.negotiate_gateset(&gateset).unwrap();

        assert!(negotiated.contains(custom_id));
        assert!(negotiated.contains(builtin::RZ::semantic_id()));
        assert!(negotiated.contains(builtin::PhasedX::semantic_id()));
    }

    #[test]
    fn one_qubit_custom_gate_is_noised_by_arity_without_gate_names() {
        let custom = custom_1q_decl();
        let gate = OwnedGateInstance::new(custom.semantic_id, [GateValue::Qubit(2)]);
        let mut model = model_with_probabilities(1.0, 0.0);
        let mut simulator = RecordingSimulator {
            operations: Vec::new(),
        };

        model
            .handle_operations(
                BatchOperation::runtime(
                    vec![Operation::from_gate_instance(gate.clone()).unwrap()],
                    selene_core::time::Instant::from(0),
                    selene_core::time::Duration::from(1),
                ),
                &mut simulator,
            )
            .unwrap();

        assert_eq!(simulator.operations.len(), 2);
        assert!(matches!(
            simulator.operations[0],
            Operation::Gate { ref gate } if gate.single_qubit_operand() == Some(2)
        ));
        assert_eq!(
            simulator.operations[1],
            Operation::from_gate_instance(gate).unwrap()
        );
        assert_eq!(model.stats.gate_count_1q, 1);
    }
}

export_error_model_plugin!(crate::DepolarizingErrorModelFactory);
