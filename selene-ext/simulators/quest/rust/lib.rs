/// Quest simulator plugin for Selene, implemented using the quest_sys crate.
//
// The version of quest_sys used here is only valid up until 0.17, after which
// the crate removed support for almost everything we use. It is likely that we
// will need to roll our own support later on, or move to using the QuEST C API
// directly if we wish to continue using QuEST as a simulator backend.
//
// Definitions of the various gates implemented here can be found in the accompanying
// gate_definitions.py file, which provides the matrices used for each gate, as well
// as giving their real/imaginary parts for simplicity. The outputs are provided
// in the comments within the implementation of each gate within this source file.
use anyhow::{Result, anyhow, bail};
use selene_core::export_simulator_plugin;
use selene_core::simulator::SimulatorInterface;
use selene_core::simulator::interface::SimulatorInterfaceFactory;
use selene_core::utils::MetricValue;
use std::io::Write;

use quest_sys::Qureg;
#[cfg(all(target_os = "windows", target_env = "gnu"))]
use std::ffi::{CStr, c_char};
use std::mem::size_of;
use std::os::raw::{c_int, c_ulong};

#[cfg(test)]
mod tests;

#[cfg(all(target_os = "windows", target_env = "gnu"))]
#[unsafe(no_mangle)]
pub unsafe extern "C" fn invalidQuESTInputError(err_msg: *const c_char, err_func: *const c_char) {
    let err_msg = if err_msg.is_null() {
        "Unknown QuEST error"
    } else {
        // SAFETY: `err_msg` is expected to be a valid null-terminated C string from QuEST.
        CStr::from_ptr(err_msg)
            .to_str()
            .unwrap_or("Invalid UTF-8 in QuEST error message")
    };
    let err_func = if err_func.is_null() {
        "unknown"
    } else {
        // SAFETY: `err_func` is expected to be a valid null-terminated C string from QuEST.
        CStr::from_ptr(err_func)
            .to_str()
            .unwrap_or("Invalid UTF-8 in QuEST function name")
    };
    eprintln!("!!!");
    eprintln!("QuEST Error in function {err_func}: {err_msg}");
    eprintln!("!!!");
    eprintln!("Exiting...");
    std::process::exit(1);
}

pub struct QuestSimulator {
    environment: quest_sys::QuESTEnv,
    qureg: Qureg,
    n_qubits: u64,
    cumulative_postselect_probability: f64,
}

impl QuestSimulator {
    fn seed(&mut self, seed: u64) {
        // seedQuest accepts an array of 'c_ulong's, so we need to split the
        // provided seed accordingly.
        //
        // c_ulong does not have a standard size, so we find out how many c_ulongs we
        // need and populate them with (low endian) bytes from the seed.
        const N_ULONGS: usize = size_of::<u64>().div_ceil(size_of::<c_ulong>());
        let mut seed_bytes = [0_u8; N_ULONGS * size_of::<c_ulong>()];
        seed_bytes[..size_of::<u64>()].copy_from_slice(&seed.to_le_bytes());
        unsafe {
            quest_sys::seedQuEST(
                &mut self.environment,
                seed_bytes.as_mut_ptr() as *mut c_ulong,
                N_ULONGS as i32,
            );
        }
    }
}

impl SimulatorInterface for QuestSimulator {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }

    fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
        unsafe { quest_sys::initClassicalState(self.qureg, 0) };
        self.cumulative_postselect_probability = 1.0;
        self.seed(seed);
        Ok(())
    }

    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }

    fn rz(&mut self, q0: u64, theta: f64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "RZ(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // Use the built-in from QuEST
            unsafe { quest_sys::rotateZ(self.qureg, q0 as c_int, theta) };
            Ok(())
        }
    }

    fn rxy(&mut self, q0: u64, theta: f64, phi: f64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "RXY(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for RXY:

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
            let u = quest_sys::ComplexMatrix2 {
                real: [
                    [cos_theta_2, -sin_phi * sin_theta_2],
                    [sin_phi * sin_theta_2, cos_theta_2],
                ],
                imag: [[0.0, -sin_theta_2 * cos_phi], [-sin_theta_2 * cos_phi, 0.0]],
            };
            unsafe { quest_sys::unitary(self.qureg, q0 as c_int, u) };
            Ok(())
        }
    }

    fn rzz(&mut self, q0: u64, q1: u64, theta: f64) -> Result<()> {
        if q0 >= self.n_qubits || q1 >= self.n_qubits {
            Err(anyhow!(
                "RZZ(q0={q0}, q1={q1}) is out of bounds. q0 and q1 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for RZZ,
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
            let mut targets: [c_int; 2] = [q0 as c_int, q1 as c_int];
            let diag_real: [f64; 4] = [1.0, cos, cos, 1.0];
            let diag_imag: [f64; 4] = [0.0, sin, sin, 0.0];
            unsafe {
                let op = quest_sys::createSubDiagonalOp(2);
                std::ptr::copy_nonoverlapping(diag_real.as_ptr(), op.real, 4);
                std::ptr::copy_nonoverlapping(diag_imag.as_ptr(), op.imag, 4);
                quest_sys::applySubDiagonalOp(self.qureg, targets.as_mut_ptr(), 2, op);
                quest_sys::destroySubDiagonalOp(op);
            }
            Ok(())
        }
    }

    fn tk2(&mut self, q0: u64, q1: u64, alpha: f64, beta: f64, gamma: f64) -> Result<()> {
        if q0 >= self.n_qubits || q1 >= self.n_qubits {
            Err(anyhow!(
                "TK2(q0={q0}, q1={q1}) is out of bounds. q0 and q1 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for TK2:
            //
            // Real part:
            //
            // ⎡   ⎛γ⎞    ⎛α - β⎞                                             ⎛γ⎞    ⎛α - β⎞⎤
            // ⎢cos⎜─⎟⋅cos⎜─────⎟           0                  0          -sin⎜─⎟⋅sin⎜─────⎟⎥
            // ⎢   ⎝2⎠    ⎝  2  ⎠                                             ⎝2⎠    ⎝  2  ⎠⎥
            // ⎢                                                                            ⎥
            // ⎢                       ⎛γ⎞    ⎛α + β⎞     ⎛γ⎞    ⎛α + β⎞                    ⎥
            // ⎢        0           cos⎜─⎟⋅cos⎜─────⎟  sin⎜─⎟⋅sin⎜─────⎟          0         ⎥
            // ⎢                       ⎝2⎠    ⎝  2  ⎠     ⎝2⎠    ⎝  2  ⎠                    ⎥
            // ⎢                                                                            ⎥
            // ⎢                       ⎛γ⎞    ⎛α + β⎞     ⎛γ⎞    ⎛α + β⎞                    ⎥
            // ⎢        0           sin⎜─⎟⋅sin⎜─────⎟  cos⎜─⎟⋅cos⎜─────⎟          0         ⎥
            // ⎢                       ⎝2⎠    ⎝  2  ⎠     ⎝2⎠    ⎝  2  ⎠                    ⎥
            // ⎢                                                                            ⎥
            // ⎢    ⎛γ⎞    ⎛α - β⎞                                           ⎛γ⎞    ⎛α - β⎞ ⎥
            // ⎢-sin⎜─⎟⋅sin⎜─────⎟          0                  0          cos⎜─⎟⋅cos⎜─────⎟ ⎥
            // ⎣    ⎝2⎠    ⎝  2  ⎠                                           ⎝2⎠    ⎝  2  ⎠ ⎦
            //
            // Imaginary part:
            //
            //
            // ⎡    ⎛γ⎞    ⎛α - β⎞                                              ⎛α - β⎞    ⎛γ⎞⎤
            // ⎢-sin⎜─⎟⋅cos⎜─────⎟          0                   0           -sin⎜─────⎟⋅cos⎜─⎟⎥
            // ⎢    ⎝2⎠    ⎝  2  ⎠                                              ⎝  2  ⎠    ⎝2⎠⎥
            // ⎢                                                                              ⎥
            // ⎢                       ⎛γ⎞    ⎛α + β⎞       ⎛α + β⎞    ⎛γ⎞                    ⎥
            // ⎢        0           sin⎜─⎟⋅cos⎜─────⎟   -sin⎜─────⎟⋅cos⎜─⎟          0         ⎥
            // ⎢                       ⎝2⎠    ⎝  2  ⎠       ⎝  2  ⎠    ⎝2⎠                    ⎥
            // ⎢                                                                              ⎥
            // ⎢                        ⎛α + β⎞    ⎛γ⎞     ⎛γ⎞    ⎛α + β⎞                     ⎥
            // ⎢        0           -sin⎜─────⎟⋅cos⎜─⎟  sin⎜─⎟⋅cos⎜─────⎟           0         ⎥
            // ⎢                        ⎝  2  ⎠    ⎝2⎠     ⎝2⎠    ⎝  2  ⎠                     ⎥
            // ⎢                                                                              ⎥
            // ⎢    ⎛α - β⎞    ⎛γ⎞                                              ⎛γ⎞    ⎛α - β⎞⎥
            // ⎢-sin⎜─────⎟⋅cos⎜─⎟          0                   0           -sin⎜─⎟⋅cos⎜─────⎟⎥
            // ⎣    ⎝  2  ⎠    ⎝2⎠                                              ⎝2⎠    ⎝  2  ⎠⎦

            let cos_g_2 = (gamma / 2.0).cos();
            let sin_g_2 = (gamma / 2.0).sin();

            let cos_a_2_minus_b_2 = (alpha / 2.0 - beta / 2.0).cos();
            let sin_a_2_minus_b_2 = (alpha / 2.0 - beta / 2.0).sin();
            let cos_a_2_plus_b_2 = (alpha / 2.0 + beta / 2.0).cos();
            let sin_a_2_plus_b_2 = (alpha / 2.0 + beta / 2.0).sin();

            let u = quest_sys::ComplexMatrix4 {
                real: [
                    [
                        cos_g_2 * cos_a_2_minus_b_2,
                        0.0,
                        0.0,
                        -sin_g_2 * sin_a_2_minus_b_2,
                    ],
                    [
                        0.0,
                        cos_g_2 * cos_a_2_plus_b_2,
                        sin_g_2 * sin_a_2_plus_b_2,
                        0.0,
                    ],
                    [
                        0.0,
                        sin_g_2 * sin_a_2_plus_b_2,
                        cos_g_2 * cos_a_2_plus_b_2,
                        0.0,
                    ],
                    [
                        -sin_g_2 * sin_a_2_minus_b_2,
                        0.0,
                        0.0,
                        cos_g_2 * cos_a_2_minus_b_2,
                    ],
                ],
                imag: [
                    [
                        -sin_g_2 * cos_a_2_minus_b_2,
                        0.0,
                        0.0,
                        -sin_a_2_minus_b_2 * cos_g_2,
                    ],
                    [
                        0.0,
                        sin_g_2 * cos_a_2_plus_b_2,
                        -sin_a_2_plus_b_2 * cos_g_2,
                        0.0,
                    ],
                    [
                        0.0,
                        -sin_a_2_plus_b_2 * cos_g_2,
                        sin_g_2 * cos_a_2_plus_b_2,
                        0.0,
                    ],
                    [
                        -sin_a_2_minus_b_2 * cos_g_2,
                        0.0,
                        0.0,
                        -sin_g_2 * cos_a_2_minus_b_2,
                    ],
                ],
            };
            unsafe { quest_sys::twoQubitUnitary(self.qureg, q0 as c_int, q1 as c_int, u) };
            Ok(())
        }
    }

    fn rpp(&mut self, q0: u64, q1: u64, theta: f64, phi: f64) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "RPP(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            // As provided in the accompanying gate_definitions.py, here is the matrix for RPP:
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
            let u = quest_sys::ComplexMatrix4 {
                real: [
                    [cos_theta_2, 0.0, 0.0, -sin_2phi * sin_theta_2],
                    [0.0, cos_theta_2, 0.0, 0.0],
                    [0.0, 0.0, cos_theta_2, 0.0],
                    [sin_2phi * sin_theta_2, 0.0, 0.0, cos_theta_2],
                ],
                imag: [
                    [0.0, 0.0, 0.0, -sin_theta_2 * cos_2phi],
                    [0.0, 0.0, -sin_theta_2, 0.0],
                    [0.0, -sin_theta_2, 0.0, 0.0],
                    [-sin_theta_2 * cos_2phi, 0.0, 0.0, 0.0],
                ],
            };
            unsafe { quest_sys::twoQubitUnitary(self.qureg, q0 as c_int, q1 as c_int, u) };
            Ok(())
        }
    }

    fn measure(&mut self, q0: u64) -> Result<bool> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "Measure(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            Ok(unsafe { quest_sys::measure(self.qureg, q0 as i32) } > 0)
        }
    }

    fn postselect(&mut self, q0: u64, target_value: bool) -> Result<()> {
        if q0 >= self.n_qubits {
            Err(anyhow!(
                "Postselect(q0={q0}) is out of bounds. q0 must be less than the number of qubits ({}).",
                self.n_qubits
            ))
        } else {
            let target_value = if target_value { 1 } else { 0 };
            unsafe {
                quest_sys::applyProjector(self.qureg, q0 as i32, target_value);
            }
            let postselect_probability = unsafe { quest_sys::calcTotalProb(self.qureg) };
            self.cumulative_postselect_probability *= postselect_probability;
            if postselect_probability < 1e-10 {
                return Err(anyhow!(
                    "Postselection of {target_value} on qubit {q0} is too unlikely to postselect. The probability of this outcome is {postselect_probability:.2e}.",
                ));
            }
            let scale = 1.0 / postselect_probability.sqrt();
            // Rescale the state vector to maintain normalization
            let mat = quest_sys::ComplexMatrix2 {
                real: [[scale, 0.0], [0.0, scale]],
                imag: [[0.0, 0.0], [0.0, 0.0]],
            };
            unsafe {
                quest_sys::applyMatrix2(self.qureg, q0 as i32, mat);
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
            let outcome = unsafe { quest_sys::measure(self.qureg, q0 as i32) };
            if outcome == 1 {
                unsafe { quest_sys::pauliX(self.qureg, q0 as i32) };
            }
            Ok(())
        }
    }
    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        match nth_metric {
            0 => Ok(Some((
                "cumulative_postselect_probability".to_string(),
                MetricValue::F64(self.cumulative_postselect_probability),
            ))),
            _ => Ok(None),
        }
    }
    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        let handle = std::fs::File::create(file)?;
        let mut writer = std::io::BufWriter::new(handle);
        writer.write_all(b"selene-quest")?;
        writer.write_all(self.n_qubits.to_le_bytes().as_slice())?;
        writer.write_all((qubits.len() as u64).to_le_bytes().as_slice())?;
        for &q in qubits {
            writer.write_all(q.to_le_bytes().as_slice())?;
        }
        let reals: *const f64 = self.qureg.stateVec.real;
        let imags: *const f64 = self.qureg.stateVec.imag;
        for i in 0..(1 << self.n_qubits) {
            let real: f64 = unsafe { *reals.add(i as usize) };
            let imag: f64 = unsafe { *imags.add(i as usize) };
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
        let environment = unsafe { quest_sys::createQuESTEnv() };
        let qureg = unsafe { quest_sys::createQureg(n_qubits.try_into().unwrap(), environment) };
        Ok(Box::new(QuestSimulator {
            environment,
            qureg,
            n_qubits,
            cumulative_postselect_probability: 1.0,
        }))
    }
}

export_simulator_plugin!(crate::QuestSimulatorFactory);
