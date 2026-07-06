use anyhow::{Result, bail};
use selene_core::error_model::BatchResult;
use selene_core::gatewire::{DynamicGateSet, OwnedGateInstance};
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

use crate::gates::{CliffordT, decode_clifford_t, require_clifford_t};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TraceEntry(pub String);

#[derive(Debug)]
pub struct CliffordTTraceSimulator {
    n_qubits: u64,
    classical_state: Vec<bool>,
    trace: Vec<TraceEntry>,
    gates_seen: u64,
    measurements: u64,
}

impl CliffordTTraceSimulator {
    pub fn new(n_qubits: u64) -> Self {
        Self {
            n_qubits,
            classical_state: vec![false; n_qubits as usize],
            trace: Vec::new(),
            gates_seen: 0,
            measurements: 0,
        }
    }

    pub fn trace(&self) -> &[TraceEntry] {
        &self.trace
    }

    pub fn gates_seen(&self) -> u64 {
        self.gates_seen
    }

    pub fn measurements(&self) -> u64 {
        self.measurements
    }

    fn check_qubit(&self, q: u64) -> Result<()> {
        if q >= self.n_qubits {
            bail!("qubit {q} is out of bounds");
        }
        Ok(())
    }

    fn apply_gate(&mut self, gate: OwnedGateInstance) -> Result<()> {
        match decode_clifford_t(&gate)? {
            CliffordT::H(gate) => {
                self.check_qubit(gate.q0.0.into())?;
                self.trace.push(TraceEntry(format!("H q{}", gate.q0.0)));
            }
            CliffordT::S(gate) => {
                self.check_qubit(gate.q0.0.into())?;
                self.trace.push(TraceEntry(format!("S q{}", gate.q0.0)));
            }
            CliffordT::Sdg(gate) => {
                self.check_qubit(gate.q0.0.into())?;
                self.trace.push(TraceEntry(format!("Sdg q{}", gate.q0.0)));
            }
            CliffordT::T(gate) => {
                self.check_qubit(gate.q0.0.into())?;
                self.trace.push(TraceEntry(format!("T q{}", gate.q0.0)));
            }
            CliffordT::Tdg(gate) => {
                self.check_qubit(gate.q0.0.into())?;
                self.trace.push(TraceEntry(format!("Tdg q{}", gate.q0.0)));
            }
            CliffordT::X(gate) => {
                let q = u64::from(gate.q0.0);
                self.check_qubit(q)?;
                self.classical_state[q as usize] = !self.classical_state[q as usize];
                self.trace.push(TraceEntry(format!("X q{}", gate.q0.0)));
            }
            CliffordT::CNOT(gate) => {
                let control = u64::from(gate.control.0);
                let target = u64::from(gate.target.0);
                self.check_qubit(control)?;
                self.check_qubit(target)?;
                if self.classical_state[control as usize] {
                    self.classical_state[target as usize] = !self.classical_state[target as usize];
                }
                self.trace.push(TraceEntry(format!(
                    "CNOT q{} q{}",
                    gate.control.0, gate.target.0
                )));
            }
        }
        self.gates_seen += 1;
        Ok(())
    }
}

impl SimulatorInterface for CliffordTTraceSimulator {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
        self.classical_state.fill(false);
        self.trace.clear();
        self.gates_seen = 0;
        self.measurements = 0;
        Ok(())
    }

    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        require_clifford_t(gateset)?;
        Ok(gateset.clone())
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::Gate { gate } => self.apply_gate(gate)?,
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    self.check_qubit(qubit_id)?;
                    self.measurements += 1;
                    let value = self.classical_state[qubit_id as usize];
                    self.trace
                        .push(TraceEntry(format!("MEASURE q{qubit_id} -> {value}")));
                    results.set_bool_result(result_id, value);
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    self.check_qubit(qubit_id)?;
                    self.measurements += 1;
                    let value = u64::from(self.classical_state[qubit_id as usize]);
                    self.trace
                        .push(TraceEntry(format!("MEASURE_LEAKED q{qubit_id} -> {value}")));
                    results.set_u64_result(result_id, value);
                }
                Operation::Reset { qubit_id } => {
                    self.check_qubit(qubit_id)?;
                    self.classical_state[qubit_id as usize] = false;
                    self.trace.push(TraceEntry(format!("RESET q{qubit_id}")));
                }
                Operation::Postselect {
                    qubit_id,
                    target_value,
                } => self.postselect(qubit_id, target_value)?,
                Operation::Custom { .. } => {}
                _ => {}
            }
        }
        Ok(results)
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        self.check_qubit(qubit)?;
        if self.classical_state[qubit as usize] == target_value {
            Ok(())
        } else {
            bail!("postselection failed for qubit {qubit}");
        }
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "gates_seen".to_string(),
                MetricValue::U64(self.gates_seen),
            ))),
            1 => Ok(Some((
                "measurements".to_string(),
                MetricValue::U64(self.measurements),
            ))),
            _ => Ok(None),
        }
    }
}
