/// QuEST simulator plugin for Selene.
//
// Definitions of the various gates implemented here can be found in the accompanying
// gate_definitions.py file, which provides the matrices used for each gate, as well
// as giving their real/imaginary parts for simplicity. The outputs are provided
// in the comments within the implementation of each gate within this source file.
mod bindings;
mod legacy_rng;
mod wrapper;

use anyhow::{Result, anyhow, bail};
use legacy_rng::LegacyQuestRng;
use selene_core::error_model::BatchResult;
use selene_core::export_simulator_plugin;
use selene_core::gatewire::builtin;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::simulator::interface::SimulatorInterfaceFactory;
use selene_core::utils::MetricValue;
use std::io::Write;
use wrapper::QuestBackend;

#[cfg(test)]
mod tests;

pub struct QuestSimulator {
    backend: QuestBackend,
    rng: LegacyQuestRng,
    n_qubits: u64,
    cumulative_postselect_probability: f64,
}

impl SimulatorInterface for QuestSimulator {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        self.backend.init_zero_state()?;
        self.cumulative_postselect_probability = 1.0;
        self.rng = LegacyQuestRng::seed_from_u64(seed);
        Ok(())
    }

    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::Gate { .. } => {
                    match operation.as_gate_view::<builtin::QuantinuumGate>()? {
                        Some(builtin::QuantinuumGate::PhasedX {
                            qubit_id,
                            theta,
                            phi,
                        }) => self.phased_x(qubit_id, theta, phi)?,
                        Some(builtin::QuantinuumGate::ZZPhase {
                            qubit_id_1,
                            qubit_id_2,
                            theta,
                        }) => self.zz_phase(qubit_id_1, qubit_id_2, theta)?,
                        Some(builtin::QuantinuumGate::RZ { qubit_id, theta }) => {
                            self.rz(qubit_id, theta)?
                        }
                        Some(builtin::QuantinuumGate::PhasedXX {
                            qubit_id_1,
                            qubit_id_2,
                            theta,
                            phi,
                        }) => self.phased_xx(qubit_id_1, qubit_id_2, theta, phi)?,
                        None => {}
                    }
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => results.set_bool_result(result_id, self.measure(qubit_id)?),
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => results.set_u64_result(result_id, self.measure(qubit_id)? as u64),
                Operation::Reset { qubit_id } => self.reset(qubit_id)?,
                Operation::Postselect {
                    qubit_id,
                    target_value,
                } => self.do_postselect(qubit_id, target_value)?,
                Operation::Custom { .. } => {}
                _ => {}
            }
        }
        Ok(results)
    }
    fn postselect(&mut self, q0: u64, target_value: bool) -> Result<()> {
        self.do_postselect(q0, target_value)
    }
    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        self.do_get_metric(nth_metric)
    }
    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        self.do_dump_state(file, qubits)
    }
}

impl QuestSimulator {
    fn rz(&mut self, q0: u64, theta: f64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "RZ(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // Use the built-in from QuEST
            self.backend.rotate_z(q0 as u32, theta)
        }
    }

    fn phased_x(&mut self, q0: u64, theta: f64, phi: f64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "PhasedX(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for PhasedX:

            // Real part:
            //
            // ⎡      ⎛θ⎞                 ⎛θ⎞⎤
            // ⎢   cos⎜─⎟      -sin(φ)⋅sin⎜─⎟⎥
            // ⎢      ⎝2⎠                 ⎝2⎠⎥
            // ⎢                             ⎥
            // ⎢          ⎛θ⎞         ⎛θ⎞    ⎥
            // ⎢sin(φ)⋅sin⎜─⎟      cos⎜─⎟    ⎥
            // ⎣          ⎝2⎠         ⎝2⎠    ⎦
            //
            // Imaginary part:
            //
            // ⎡                    ⎛θ⎞       ⎤
            // ⎢      0         -sin⎜─⎟⋅cos(φ)⎥
            // ⎢                    ⎝2⎠       ⎥
            // ⎢                              ⎥
            // ⎢    ⎛θ⎞                       ⎥
            // ⎢-sin⎜─⎟⋅cos(φ)        0       ⎥
            // ⎣    ⎝2⎠                       ⎦
            //
            let cos_theta_2 = (theta / 2.0).cos();
            let sin_theta_2 = (theta / 2.0).sin();
            let cos_phi = phi.cos();
            let sin_phi = phi.sin();
            let real = [
                cos_theta_2,
                -sin_phi * sin_theta_2,
                sin_phi * sin_theta_2,
                cos_theta_2,
            ];
            let imag = [0.0, -sin_theta_2 * cos_phi, -sin_theta_2 * cos_phi, 0.0];
            self.backend.matrix1(q0 as u32, &real, &imag)
        }
    }

    fn zz_phase(&mut self, q0: u64, q1: u64, theta: f64) -> Result<()> {
        if q0 >= self.n_qubits || q1 >= self.n_qubits {
            Err(anyhow!(
                "ZZPhase(q0={q0}, q1={q1}) is out of bounds. q0 and q1 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for ZZPhase,
            // after scaling out a global phase of exp(i*theta/2) for consistency with prior versions:
            //
            // Real part:
            //
            // ⎡1    0       0     0⎤
            // ⎢                    ⎥
            // ⎢0  cos(θ)    0     0⎥
            // ⎢                    ⎥
            // ⎢0    0     cos(θ)  0⎥
            // ⎢                    ⎥
            // ⎣0    0       0     1⎦
            //
            // Imaginary part:
            //
            // ⎡0    0       0     0⎤
            // ⎢                    ⎥
            // ⎢0  sin(θ)    0     0⎥
            // ⎢                    ⎥
            // ⎢0    0     sin(θ)  0⎥
            // ⎢                    ⎥
            // ⎣0    0       0     0⎦
            //
            // We implement this using a sub-diagonal operator in QuEST.
            let cos = theta.cos();
            let sin = theta.sin();
            let diag_real: [f64; 4] = [1.0, cos, cos, 1.0];
            let diag_imag: [f64; 4] = [0.0, sin, sin, 0.0];
            self.backend
                .diag_matrix2(q0 as u32, q1 as u32, &diag_real, &diag_imag)
        }
    }

    fn phased_xx(&mut self, q0: u64, q1: u64, theta: f64, phi: f64) -> Result<()> {
        if q0 >= self.n_qubits || q1 >= self.n_qubits {
            Err(anyhow!(
                "PhasedXX(q0={q0}, q1={q1}) is out of bounds. q0 and q1 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for PhasedXX:
            //
            // Real part:
            //
            // ⎡       ⎛θ⎞                                    ⎛θ⎞⎤
            // ⎢    cos⎜─⎟         0       0     -sin(2⋅φ)⋅sin⎜─⎟⎥
            // ⎢       ⎝2⎠                                    ⎝2⎠⎥
            // ⎢                                                 ⎥
            // ⎢                    ⎛θ⎞                          ⎥
            // ⎢       0         cos⎜─⎟    0            0        ⎥
            // ⎢                    ⎝2⎠                          ⎥
            // ⎢                                                 ⎥
            // ⎢                            ⎛θ⎞                  ⎥
            // ⎢       0           0     cos⎜─⎟         0        ⎥
            // ⎢                            ⎝2⎠                  ⎥
            // ⎢                                                 ⎥
            // ⎢            ⎛θ⎞                          ⎛θ⎞     ⎥
            // ⎢sin(2⋅φ)⋅sin⎜─⎟    0       0          cos⎜─⎟     ⎥
            // ⎣            ⎝2⎠                          ⎝2⎠     ⎦
            //
            // Imaginary part:
            //
            // ⎡                                        ⎛θ⎞         ⎤
            // ⎢       0             0        0     -sin⎜─⎟⋅cos(2⋅φ)⎥
            // ⎢                                        ⎝2⎠         ⎥
            // ⎢                                                    ⎥
            // ⎢                               ⎛θ⎞                  ⎥
            // ⎢       0             0     -sin⎜─⎟         0        ⎥
            // ⎢                               ⎝2⎠                  ⎥
            // ⎢                                                    ⎥
            // ⎢                      ⎛θ⎞                           ⎥
            // ⎢       0          -sin⎜─⎟     0            0        ⎥
            // ⎢                      ⎝2⎠                           ⎥
            // ⎢                                                    ⎥
            // ⎢    ⎛θ⎞                                             ⎥
            // ⎢-sin⎜─⎟⋅cos(2⋅φ)     0        0            0        ⎥
            // ⎣    ⎝2⎠                                             ⎦
            let cos_theta_2 = (theta / 2.0).cos();
            let sin_theta_2 = (theta / 2.0).sin();
            let cos_2phi = (2.0 * phi).cos();
            let sin_2phi = (2.0 * phi).sin();
            let real = [
                cos_theta_2,
                0.0,
                0.0,
                -sin_2phi * sin_theta_2,
                0.0,
                cos_theta_2,
                0.0,
                0.0,
                0.0,
                0.0,
                cos_theta_2,
                0.0,
                sin_2phi * sin_theta_2,
                0.0,
                0.0,
                cos_theta_2,
            ];
            let imag = [
                0.0,
                0.0,
                0.0,
                -sin_theta_2 * cos_2phi,
                0.0,
                0.0,
                -sin_theta_2,
                0.0,
                0.0,
                -sin_theta_2,
                0.0,
                0.0,
                -sin_theta_2 * cos_2phi,
                0.0,
                0.0,
                0.0,
            ];
            self.backend.matrix2(q0 as u32, q1 as u32, &real, &imag)
        }
    }

    fn measure(&mut self, q0: u64) -> Result<bool> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "Measure(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            const REAL_EPS: f64 = 1e-13;
            let probability_zero = self.backend.prob_of_outcome(q0 as u32, false)?;
            let outcome = if probability_zero < REAL_EPS {
                true
            } else if 1.0 - probability_zero < REAL_EPS {
                false
            } else {
                self.rng.genrand_real1() > probability_zero
            };
            self.backend.collapse_to_outcome(q0 as u32, outcome)?;
            Ok(outcome)
        }
    }

    fn do_postselect(&mut self, q0: u64, target_value: bool) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "Postselect(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            let postselect_probability =
                self.backend.collapse_to_outcome(q0 as u32, target_value)?;
            self.cumulative_postselect_probability *= postselect_probability;
            if postselect_probability < 1e-10 {
                return Err(anyhow!(
                    "Postselection of {target_value} on qubit {q0} is too unlikely to postselect. The probability of this outcome is {postselect_probability:.2e}.",
                ));
            }
            Ok(())
        }
    }

    fn reset(&mut self, q0: u64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "Reset(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            let outcome = self.measure(q0)?;
            if outcome {
                self.backend.pauli_x(q0 as u32)?;
            }
            Ok(())
        }
    }
    fn do_get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "cumulative_postselect_probability".to_string(),
                MetricValue::F64(self.cumulative_postselect_probability),
            ))),
            _ => Ok(None),
        }
    }
    fn do_dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        let handle = std::fs::File::create(file)?;
        let mut writer = std::io::BufWriter::new(handle);
        writer.write_all(b"selene-quest")?;
        writer.write_all(self.n_qubits.to_le_bytes().as_slice())?;
        writer.write_all((qubits.len() as u64).to_le_bytes().as_slice())?;
        for &q in qubits {
            writer.write_all(q.to_le_bytes().as_slice())?;
        }
        for i in 0..(1 << self.n_qubits) {
            let (real, imag) = self.backend.amp(i)?;
            writer.write_all(real.to_le_bytes().as_slice())?;
            writer.write_all(imag.to_le_bytes().as_slice())?;
        }
        Ok(())
    }
}

#[derive(Default)]
pub struct QuestSimulatorFactory;

fn check_memory(n_qubits: u64) -> Result<()> {
    if n_qubits == 0 {
        bail!("Number of qubits must be greater than 0");
    } else if n_qubits > 60 {
        bail!(
            "It is impossible to describe more than 60 qubits in a statevector on a computer with a 64-bit address space."
        );
    }
    // check against the maximum size of a 64-bit address space
    let bytes_required = bytesize::ByteSize::b(16 * (1 << n_qubits));
    let mut system = sysinfo::System::new();
    system.refresh_memory();
    let reported_available = system.available_memory();
    if reported_available == 0 {
        eprintln!("-----------------------------------");
        eprintln!("Unable to determine available memory due to system limitations.");
        eprintln!("QuEST is going to try to allocate {bytes_required} of memory to");
        eprintln!("store the statevector, and this will be multiplied by the number");
        eprintln!("of processes if running in multiprocessing mode.");
        eprintln!();
        eprintln!("If this fails, verify that your system has sufficient memory.");
        eprintln!("-----------------------------------");
    } else {
        let bytes_available = bytesize::ByteSize::b(reported_available);
        if bytes_required > bytes_available {
            bail!(
                "Insufficient memory available ({bytes_available}) to allocate a state vector of {n_qubits} qubits ({bytes_required}).",
            );
        }
    }
    Ok(())
}

impl SimulatorInterfaceFactory for QuestSimulatorFactory {
    type Interface = QuestSimulator;

    fn name(&self) -> &str {
        "Quest"
    }

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let args: Vec<String> = args.iter().map(|s| s.as_ref().to_string()).collect();
        if args.len() > 1 {
            bail!(
                "Expected no arguments for the quest plugin, got {} arguments: {:?}",
                args.len() - 1,
                args.iter().skip(1)
            );
        }
        check_memory(n_qubits)?;
        let backend = QuestBackend::new(n_qubits.try_into().unwrap())?;
        Ok(Box::new(QuestSimulator {
            backend,
            rng: LegacyQuestRng::seed_from_u64(0),
            n_qubits,
            cumulative_postselect_probability: 1.0,
        }))
    }
}

export_simulator_plugin!(crate::QuestSimulatorFactory);
