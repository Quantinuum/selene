use super::{SimulatorInterface, plugin::SimulatorInstance};
use crate::{
    gatewire::OwnedGateInstance,
    operation::plugin::{BatchBuilder, OperationResultHandle, RuntimeExtractOperationHandle},
    plugin::{LastErrorFn, write_negotiated_gateset},
    runtime::{BatchOperation, Operation},
    simulator::plugin::Errno,
    utils::{result_of_errno_to_errno, result_to_errno, set_last_error},
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
            last_error_fn: BorrowedSimulatorBridge::last_error,
            shot_start_fn: BorrowedSimulatorBridge::shot_start,
            shot_end_fn: BorrowedSimulatorBridge::shot_end,
            negotiate_gateset_fn: BorrowedSimulatorBridge::negotiate_gateset,
            handle_operations_fn: BorrowedSimulatorBridge::handle_operations,
            gate_fn: BorrowedSimulatorBridge::gate,
            measure_fn: BorrowedSimulatorBridge::measure,
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
    unsafe extern "C" fn last_error(
        output: *mut ffi::c_char,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        unsafe { crate::utils::last_error_message(output, output_len, written) }
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
    unsafe extern "C" fn negotiate_gateset(
        instance: SimulatorInstance,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        result_to_errno(
            "BorrowedSimulatorBridge: negotiate_gateset failed",
            unsafe {
                Self::with_simulator(instance, |simulator| {
                    write_negotiated_gateset(
                        input,
                        input_len,
                        output,
                        output_len,
                        written,
                        |gateset| simulator.negotiate_gateset(gateset),
                    )
                })
            },
        )
    }
    unsafe extern "C" fn handle_operations(
        instance: SimulatorInstance,
        batch: RuntimeExtractOperationHandle,
        result: OperationResultHandle,
    ) -> Errno {
        result_to_errno(
            "BorrowedSimulatorBridge: handle_operations failed",
            unsafe {
                Self::with_simulator(instance, |simulator| {
                    let mut batch_builder = BatchBuilder::default();
                    let operations = batch_builder.runtime_get_operation();
                    (batch.interface.extract_fn)(&raw const batch, operations);
                    let results = simulator.handle_operations(batch_builder.finish())?;
                    for bool_result in results.bool_results {
                        (result.interface.set_bool_result_fn)(
                            result.instance,
                            bool_result.result_id,
                            bool_result.value,
                        );
                    }
                    for u64_result in results.u64_results {
                        (result.interface.set_u64_result_fn)(
                            result.instance,
                            u64_result.result_id,
                            u64_result.value,
                        );
                    }
                    Ok::<(), anyhow::Error>(())
                })
            },
        )
    }
    unsafe extern "C" fn gate(
        instance: SimulatorInstance,
        data: *const u8,
        data_len: usize,
    ) -> Errno {
        result_to_errno("BorrowedSimulatorBridge: gate failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let gate =
                    OwnedGateInstance::deserialize(std::slice::from_raw_parts(data, data_len))?;
                let results = simulator.handle_operations(Self::singleton_batch(
                    Operation::from_gate_instance(gate)?,
                ))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("Gate unexpectedly produced results")
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
                last_error_fn: Self::last_error,
                shot_start_fn: Self::shot_start,
                shot_end_fn: Self::shot_end,
                negotiate_gateset_fn: Self::negotiate_gateset,
                handle_operations_fn: Self::handle_operations,
                gate_fn: Self::gate,
                measure_fn: Self::measure,
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

    unsafe extern "C" fn last_error(
        output: *mut ffi::c_char,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        unsafe { crate::utils::last_error_message(output, output_len, written) }
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

    unsafe extern "C" fn negotiate_gateset(
        instance: SimulatorInstance,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: negotiate_gateset failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                write_negotiated_gateset(input, input_len, output, output_len, written, |gateset| {
                    simulator.negotiate_gateset(gateset)
                })
            })
        })
    }

    unsafe extern "C" fn handle_operations(
        instance: SimulatorInstance,
        batch: RuntimeExtractOperationHandle,
        result: OperationResultHandle,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: handle_operations failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let mut batch_builder = BatchBuilder::default();
                let operations = batch_builder.runtime_get_operation();
                (batch.interface.extract_fn)(&raw const batch, operations);
                let results = simulator.handle_operations(batch_builder.finish())?;
                for bool_result in results.bool_results {
                    (result.interface.set_bool_result_fn)(
                        result.instance,
                        bool_result.result_id,
                        bool_result.value,
                    );
                }
                for u64_result in results.u64_results {
                    (result.interface.set_u64_result_fn)(
                        result.instance,
                        u64_result.result_id,
                        u64_result.value,
                    );
                }
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn gate(
        instance: SimulatorInstance,
        data: *const u8,
        data_len: usize,
    ) -> Errno {
        result_to_errno("SimulatorFFIAdapter: gate failed", unsafe {
            Self::with_simulator(instance, |simulator| {
                let gate =
                    OwnedGateInstance::deserialize(std::slice::from_raw_parts(data, data_len))?;
                let results = simulator.handle_operations(Self::singleton_batch(
                    Operation::from_gate_instance(gate)?,
                ))?;
                if results.bool_results.is_empty() && results.u64_results.is_empty() {
                    Ok(())
                } else {
                    anyhow::bail!("Gate unexpectedly produced results")
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
                set_last_error(format!("{e:#}"));
                -1
            }
        }
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
    pub last_error_fn: LastErrorFn,
    pub shot_start_fn:
        unsafe extern "C" fn(instance: SimulatorInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(instance: SimulatorInstance) -> Errno,
    pub handle_operations_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        batch: RuntimeExtractOperationHandle,
        result: OperationResultHandle,
    ) -> Errno,
    pub measure_fn: unsafe extern "C" fn(instance: SimulatorInstance, qubit: u64) -> Errno,
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
    pub gate_fn:
        unsafe extern "C" fn(instance: SimulatorInstance, data: *const u8, len: usize) -> Errno,
    pub negotiate_gateset_fn: unsafe extern "C" fn(
        instance: SimulatorInstance,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno,
    _marker: PhantomData<&'a ()>,
}

impl SimulatorOperationInterface<'_> {
    pub fn into_static(self) -> SimulatorOperationInterface<'static> {
        SimulatorOperationInterface {
            exit_fn: self.exit_fn,
            last_error_fn: self.last_error_fn,
            shot_start_fn: self.shot_start_fn,
            shot_end_fn: self.shot_end_fn,
            handle_operations_fn: self.handle_operations_fn,
            measure_fn: self.measure_fn,
            reset_fn: self.reset_fn,
            get_metric_fn: self.get_metric_fn,
            dump_state_fn: self.dump_state_fn,
            gate_fn: self.gate_fn,
            negotiate_gateset_fn: self.negotiate_gateset_fn,
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
