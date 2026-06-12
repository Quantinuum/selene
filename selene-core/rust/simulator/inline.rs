use super::{SimulatorInterface, plugin::SimulatorInstance};
use crate::{
    runtime::{BatchOperation, Operation},
    simulator::plugin::Errno,
    utils::{result_of_errno_to_errno, result_to_errno},
};
use std::{ffi, marker::PhantomData};

/// Owns a Rust simulator implementation and exposes a C-ABI-friendly
/// `(instance pointer, function table)` pair for dependency injection.
pub struct SimulatorFFIAdapter {
    simulator: Box<dyn SimulatorInterface>,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SimulatorHandle<'a> {
    pub instance: SimulatorInstance,
    pub interface: SimulatorOperationInterface<'a>,
}

pub fn borrowed_simulator_interface(
    simulator: &mut &mut dyn SimulatorInterface,
) -> SimulatorHandle<'static> {
    SimulatorHandle {
        instance: simulator as *mut &mut dyn SimulatorInterface as SimulatorInstance,
        interface: SimulatorOperationInterface {
            exit_fn: BorrowedSimulatorBridge::exit,
            shot_start_fn: BorrowedSimulatorBridge::shot_start,
            shot_end_fn: BorrowedSimulatorBridge::shot_end,
            rxy_fn: BorrowedSimulatorBridge::rxy,
            rz_fn: BorrowedSimulatorBridge::rz,
            rzz_fn: BorrowedSimulatorBridge::rzz,
            rpp_fn: BorrowedSimulatorBridge::rpp,
            measure_fn: BorrowedSimulatorBridge::measure,
            postselect_fn: BorrowedSimulatorBridge::postselect,
            reset_fn: BorrowedSimulatorBridge::reset,
            get_metric_fn: BorrowedSimulatorBridge::get_metric,
            dump_state_fn: BorrowedSimulatorBridge::dump_state,
            _marker: PhantomData,
        },
    }
}

struct BorrowedSimulatorBridge;
impl BorrowedSimulatorBridge {
    fn singleton_batch(op: Operation) -> BatchOperation {
        BatchOperation::simulator(vec![op])
    }

    unsafe fn with_simulator<T>(
        instance: SimulatorInstance,
        mut go: impl FnMut(&mut dyn SimulatorInterface) -> T,
    ) -> T {
        let simulator_ref = unsafe { &mut *(instance as *mut &mut dyn SimulatorInterface) };
        go(*simulator_ref)
    }

    unsafe extern "C" fn exit(instance: SimulatorInstance) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: exit failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.exit())
        })
    }
    unsafe extern "C" fn shot_start(instance: SimulatorInstance, shot_id: u64, seed: u64) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: shot_start failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.shot_start(shot_id, seed))
        })
    }
    unsafe extern "C" fn shot_end(instance: SimulatorInstance) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: shot_end failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.shot_end())
        })
    }
    unsafe extern "C" fn rxy(
        instance: SimulatorInstance,
        qubit: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: rxy failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RXYGate {
                        qubit_id: qubit,
                        theta,
                        phi,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RXY unexpectedly produced results")
                }
            })
        })
    }
    unsafe extern "C" fn rz(instance: SimulatorInstance, qubit: u64, theta: f64) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: rz failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RZGate {
                        qubit_id: qubit,
                        theta,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RZ unexpectedly produced results")
                }
            })
        })
    }
    unsafe extern "C" fn rzz(instance: SimulatorInstance, q1: u64, q2: u64, theta: f64) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: rzz failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RZZGate {
                        qubit_id_1: q1,
                        qubit_id_2: q2,
                        theta,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RZZ unexpectedly produced results")
                }
            })
        })
    }
    unsafe extern "C" fn rpp(
        instance: SimulatorInstance,
        q1: u64,
        q2: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: rpp failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RPPGate {
                        qubit_id_1: q1,
                        qubit_id_2: q2,
                        theta,
                        phi,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RPP unexpectedly produced results")
                }
            })
        })
    }
    unsafe extern "C" fn measure(instance: SimulatorInstance, qubit: u64) -> Errno {
        match unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::Measure {
                        qubit_id: qubit,
                        result_id: 0,
                    }))?;
                if results.u64_results.is_empty() && results.bool_results.len() == 1 {
                    Ok(results.bool_results[0].value)
                } else {
                    anyhow::bail!("Measure expected exactly one bool result")
                }
            })
        } {
            Ok(false) => 0,
            Ok(true) => 1,
            Err(_) => -1,
        }
    }
    unsafe extern "C" fn postselect(
        instance: SimulatorInstance,
        qubit: u64,
        target: bool,
    ) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: postselect failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.postselect(qubit, target))
        })
    }
    unsafe extern "C" fn reset(instance: SimulatorInstance, qubit: u64) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: reset failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::Reset {
                        qubit_id: qubit,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("Reset unexpectedly produced results")
                }
            })
        })
    }
    unsafe extern "C" fn get_metric(
        instance: SimulatorInstance,
        nth_metric: u8,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) -> Errno {
        result_of_errno_to_errno("BorrowedSimulatorBridge: get_metric failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let Some((tag, metric)) = simulator.get_metric(nth_metric)? else {
                    return Ok::<i32, anyhow::Error>(1);
                };
                metric.write_raw(tag, tag_ptr, datatype_ptr, data_ptr);
                Ok::<i32, anyhow::Error>(0)
            })
        })
    }
    unsafe extern "C" fn dump_state(
        instance: SimulatorInstance,
        file: *const ffi::c_char,
        qubits: *const u64,
        n_qubits: u64,
    ) -> Errno {
        let path = unsafe { std::path::PathBuf::from(ffi::CStr::from_ptr(file).to_str().unwrap()) };
        result_to_errno("BorrowedSimulatorBridge: dump_state failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                simulator.dump_state(&path, std::slice::from_raw_parts(qubits, n_qubits as usize))
            })
        })
    }
}

impl SimulatorFFIAdapter {
    fn singleton_batch(op: Operation) -> BatchOperation {
        BatchOperation::simulator(vec![op])
    }

    pub fn new(simulator: Box<dyn SimulatorInterface>) -> Self {
        Self { simulator }
    }

    pub fn ffi_interface(&mut self) -> SimulatorHandle<'static> {
        SimulatorHandle {
            instance: &raw mut self.simulator as SimulatorInstance,
            interface: SimulatorOperationInterface {
                exit_fn: Self::exit,
                shot_start_fn: Self::shot_start,
                shot_end_fn: Self::shot_end,
                rxy_fn: Self::rxy,
                rz_fn: Self::rz,
                rzz_fn: Self::rzz,
                rpp_fn: Self::rpp,
                measure_fn: Self::measure,
                postselect_fn: Self::postselect,
                reset_fn: Self::reset,
                get_metric_fn: Self::get_metric,
                dump_state_fn: Self::dump_state,
                _marker: PhantomData,
            },
        }
    }

    unsafe fn with_simulator<T>(
        instance: SimulatorInstance,
        mut go: impl FnMut(&mut dyn SimulatorInterface) -> T,
    ) -> T {
        assert!(!instance.is_null());
        let simulator = unsafe { &mut *(instance as *mut Box<dyn SimulatorInterface>) };
        go(simulator.as_mut())
    }

    unsafe extern "C" fn exit(instance: SimulatorInstance) -> Errno {
        result_to_errno("SimulatorFFIAdapter: exit failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.exit())
        })
    }

    unsafe extern "C" fn shot_start(instance: SimulatorInstance, shot_id: u64, seed: u64) -> Errno {
        result_to_errno(
            format!("SimulatorFFIAdapter: failed to start shot {shot_id}"),
            unsafe {
                Self::with_simulator(instance, |simulator| simulator.shot_start(shot_id, seed))
            },
        )
    }

    unsafe extern "C" fn shot_end(instance: SimulatorInstance) -> Errno {
        result_to_errno("SimulatorFFIAdapter: shot_end failed", unsafe {
            Self::with_simulator(instance, |simulator| simulator.shot_end())
        })
    }

    unsafe extern "C" fn rxy(
        instance: SimulatorInstance,
        qubit: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: rxy failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RXYGate {
                        qubit_id: qubit,
                        theta,
                        phi,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RXY unexpectedly produced results")
                }
            })
        })
    }

    unsafe extern "C" fn rz(instance: SimulatorInstance, qubit: u64, theta: f64) -> Errno {
        result_to_errno("SimulatorFFIAdapter: rz failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RZGate {
                        qubit_id: qubit,
                        theta,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RZ unexpectedly produced results")
                }
            })
        })
    }

    unsafe extern "C" fn rzz(
        instance: SimulatorInstance,
        qubit1: u64,
        qubit2: u64,
        theta: f64,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: rzz failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RZZGate {
                        qubit_id_1: qubit1,
                        qubit_id_2: qubit2,
                        theta,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RZZ unexpectedly produced results")
                }
            })
        })
    }

    unsafe extern "C" fn rpp(
        instance: SimulatorInstance,
        qubit1: u64,
        qubit2: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: rpp failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::RPPGate {
                        qubit_id_1: qubit1,
                        qubit_id_2: qubit2,
                        theta,
                        phi,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("RPP unexpectedly produced results")
                }
            })
        })
    }

    unsafe extern "C" fn measure(instance: SimulatorInstance, qubit: u64) -> Errno {
        let result = unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::Measure {
                        qubit_id: qubit,
                        result_id: 0,
                    }))?;
                if results.u64_results.is_empty() && results.bool_results.len() == 1 {
                    Ok(results.bool_results[0].value)
                } else {
                    anyhow::bail!("Measure expected exactly one bool result")
                }
            })
        };
        match result {
            Ok(false) => 0,
            Ok(true) => 1,
            Err(e) => {
                eprintln!("SimulatorFFIAdapter: measure failed: {e:#}");
                -1
            }
        }
    }

    unsafe extern "C" fn postselect(
        instance: SimulatorInstance,
        qubit: u64,
        target_value: bool,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: postselect failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                simulator.postselect(qubit, target_value)
            })
        })
    }

    unsafe extern "C" fn reset(instance: SimulatorInstance, qubit: u64) -> Errno {
        result_to_errno("SimulatorFFIAdapter: reset failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let results =
                    simulator.handle_operations(Self::singleton_batch(Operation::Reset {
                        qubit_id: qubit,
                    }))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("Reset unexpectedly produced results")
                }
            })
        })
    }

    unsafe extern "C" fn get_metric(
        instance: SimulatorInstance,
        nth_metric: u8,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) -> Errno {
        result_of_errno_to_errno("SimulatorFFIAdapter: get_metric failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let Some((tag, metric)) = simulator.get_metric(nth_metric)? else {
                    return anyhow::Ok(1);
                };
                metric.write_raw(tag, tag_ptr, datatype_ptr, data_ptr);
                Ok(0)
            })
        })
    }

    unsafe extern "C" fn dump_state(
        instance: SimulatorInstance,
        file: *const ffi::c_char,
        qubits: *const u64,
        n_qubits: u64,
    ) -> Errno {
        let path = unsafe { std::path::PathBuf::from(ffi::CStr::from_ptr(file).to_str().unwrap()) };
        result_to_errno(
            format!("SimulatorFFIAdapter: dump_state failed for {path:?}"),
            unsafe {
                Self::with_simulator(instance, |simulator| {
                    simulator
                        .dump_state(&path, std::slice::from_raw_parts(qubits, n_qubits as usize))
                })
            },
        )
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
#[non_exhaustive]
pub struct SimulatorOperationInterface<'a> {
    pub exit_fn: unsafe extern "C" fn(instance: SimulatorInstance) -> Errno,
    pub shot_start_fn:
        unsafe extern "C" fn(instance: SimulatorInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(instance: SimulatorInstance) -> Errno,
    pub rxy_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        qubit: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    pub rz_fn: unsafe extern "C" fn(instance: SimulatorInstance, qubit: u64, theta: f64) -> Errno,
    pub rzz_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        qubit1: u64,
        qubit2: u64,
        theta: f64,
    ) -> Errno,
    pub rpp_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        qubit1: u64,
        qubit2: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    pub measure_fn: unsafe extern "C" fn(instance: SimulatorInstance, qubit: u64) -> Errno,
    pub postselect_fn:
        unsafe extern "C" fn(instance: SimulatorInstance, qubit: u64, target_value: bool) -> Errno,
    pub reset_fn: unsafe extern "C" fn(instance: SimulatorInstance, qubit: u64) -> Errno,
    pub get_metric_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        nth_metric: u8,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) -> Errno,
    pub dump_state_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        file: *const ffi::c_char,
        qubits: *const u64,
        n_qubits: u64,
    ) -> Errno,
    _marker: PhantomData<&'a ()>,
}

impl SimulatorOperationInterface<'_> {
    pub fn into_static(self) -> SimulatorOperationInterface<'static> {
        SimulatorOperationInterface {
            exit_fn: self.exit_fn,
            shot_start_fn: self.shot_start_fn,
            shot_end_fn: self.shot_end_fn,
            rxy_fn: self.rxy_fn,
            rz_fn: self.rz_fn,
            rzz_fn: self.rzz_fn,
            rpp_fn: self.rpp_fn,
            measure_fn: self.measure_fn,
            postselect_fn: self.postselect_fn,
            reset_fn: self.reset_fn,
            get_metric_fn: self.get_metric_fn,
            dump_state_fn: self.dump_state_fn,
            _marker: PhantomData,
        }
    }
}

impl SimulatorHandle<'_> {
    pub fn into_static(self) -> SimulatorHandle<'static> {
        SimulatorHandle {
            instance: self.instance,
            interface: self.interface.into_static(),
        }
    }
}
