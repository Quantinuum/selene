use super::{
    RuntimeInterface,
    plugin::{Errno, RuntimeInstance},
};
use crate::{
    gatewire::OwnedGateInstance,
    operation::plugin::{RuntimeGetOperationHandle, RuntimeGetOperationInterface},
    plugin::{LastErrorFn, write_negotiated_gateset},
    runtime::Operation,
    utils::{result_of_errno_to_errno, result_to_errno},
};
use std::{ffi, marker::PhantomData};

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimeHandle<'a> {
    pub instance: RuntimeInstance,
    pub interface: RuntimeOperationInterface<'a>,
}

/// Owns a Rust runtime implementation and exposes a C-ABI-friendly
/// `(instance pointer, function table)` pair for dependency injection.
pub struct RuntimeFFIAdapter {
    runtime: Box<dyn RuntimeInterface>,
}

impl RuntimeFFIAdapter {
    pub fn new(runtime: Box<dyn RuntimeInterface>) -> Self {
        Self { runtime }
    }

    pub fn ffi_interface(&mut self) -> RuntimeHandle<'static> {
        RuntimeHandle {
            instance: &raw mut self.runtime as RuntimeInstance,
            interface: RuntimeOperationInterface {
                exit_fn: Self::exit,
                last_error_fn: Self::last_error,
                get_next_operations_fn: Self::get_next_operations,
                shot_start_fn: Self::shot_start,
                shot_end_fn: Self::shot_end,
                get_metrics_fn: Self::get_metric,
                qalloc_fn: Self::qalloc,
                qfree_fn: Self::qfree,
                local_barrier_fn: Self::local_barrier,
                global_barrier_fn: Self::global_barrier,
                gate_fn: Self::gate,
                negotiate_gateset_fn: Self::negotiate_gateset,
                measure_fn: Self::measure,
                measure_leaked_fn: Self::measure_leaked,
                reset_fn: Self::reset,
                force_result_fn: Self::force_result,
                get_bool_result_fn: Self::get_bool_result,
                get_u64_result_fn: Self::get_u64_result,
                set_bool_result_fn: Self::set_bool_result,
                set_u64_result_fn: Self::set_u64_result,
                increment_future_refcount_fn: Self::increment_future_refcount,
                decrement_future_refcount_fn: Self::decrement_future_refcount,
                custom_call_fn: Self::custom_call,
                simulate_delay_fn: Self::simulate_delay,
                _marker: PhantomData,
            },
        }
    }

    unsafe fn with_runtime<T>(
        instance: RuntimeInstance,
        mut go: impl FnMut(&mut dyn RuntimeInterface) -> T,
    ) -> T {
        assert!(!instance.is_null());
        let runtime = unsafe { &mut *(instance as *mut Box<dyn RuntimeInterface>) };
        go(runtime.as_mut())
    }

    unsafe extern "C" fn exit(instance: RuntimeInstance) -> Errno {
        result_to_errno("RuntimeFFIAdapter: exit failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.exit())
        })
    }

    unsafe extern "C" fn last_error(
        output: *mut ffi::c_char,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        unsafe { crate::utils::last_error_message(output, output_len, written) }
    }

    unsafe extern "C" fn get_next_operations(
        instance: RuntimeInstance,
        ops: RuntimeGetOperationHandle,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: get_next_operations failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                let Some(batch) = runtime.get_next_operations()? else {
                    return Ok::<(), anyhow::Error>(());
                };
                let RuntimeGetOperationInterface {
                    measure_fn,
                    measure_leaked_fn,
                    postselect_fn,
                    reset_fn,
                    custom_fn,
                    set_batch_time_fn,
                    gate_fn,
                    ..
                } = ops.interface;
                if let Some(timing) = batch.runtime_source() {
                    set_batch_time_fn(
                        ops.instance,
                        timing.start().into(),
                        timing.duration().into(),
                    );
                }
                for operation in batch.iter_ops() {
                    match operation {
                        Operation::Measure {
                            qubit_id,
                            result_id,
                        } => measure_fn(ops.instance, *qubit_id, *result_id),
                        Operation::MeasureLeaked {
                            qubit_id,
                            result_id,
                        } => measure_leaked_fn(ops.instance, *qubit_id, *result_id),
                        Operation::Postselect {
                            qubit_id,
                            target_value,
                        } => postselect_fn(ops.instance, *qubit_id, *target_value),
                        Operation::Reset { qubit_id } => reset_fn(ops.instance, *qubit_id),
                        Operation::Gate { gate } => {
                            let data = gate.serialize();
                            gate_fn(ops.instance, data.as_ptr(), data.len())
                        }
                        Operation::Custom { custom_tag, data } => custom_fn(
                            ops.instance,
                            *custom_tag,
                            data.as_ptr() as *const ffi::c_void,
                            data.len(),
                        ),
                    }
                }
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn shot_start(instance: RuntimeInstance, shot_id: u64, seed: u64) -> Errno {
        result_to_errno(
            format!("RuntimeFFIAdapter: shot_start failed for shot {shot_id}"),
            unsafe { Self::with_runtime(instance, |runtime| runtime.shot_start(shot_id, seed)) },
        )
    }

    unsafe extern "C" fn shot_end(instance: RuntimeInstance) -> Errno {
        result_to_errno("RuntimeFFIAdapter: shot_end failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.shot_end())
        })
    }

    unsafe extern "C" fn negotiate_gateset(
        instance: RuntimeInstance,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: negotiate_gateset failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                write_negotiated_gateset(input, input_len, output, output_len, written, |gateset| {
                    runtime.negotiate_gateset(gateset)
                })
            })
        })
    }

    unsafe extern "C" fn get_metric(
        instance: RuntimeInstance,
        nth_metric: u8,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) -> Errno {
        result_of_errno_to_errno("RuntimeFFIAdapter: get_metric failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                let Some((tag, metric)) = runtime.get_metric(nth_metric)? else {
                    return Ok::<i32, anyhow::Error>(1);
                };
                metric.write_raw(tag, tag_ptr, datatype_ptr, data_ptr);
                Ok::<i32, anyhow::Error>(0)
            })
        })
    }

    unsafe extern "C" fn qalloc(instance: RuntimeInstance, qaddress_out: *mut u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: qalloc failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *qaddress_out = runtime.qalloc()?;
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn qfree(instance: RuntimeInstance, qaddress: u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: qfree failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.qfree(qaddress))
        })
    }

    unsafe extern "C" fn local_barrier(
        instance: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno {
        let qubits = unsafe { std::slice::from_raw_parts(qubits, qubits_len as usize) };
        result_to_errno("RuntimeFFIAdapter: local_barrier failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.local_barrier(qubits, sleep_ns))
        })
    }

    unsafe extern "C" fn global_barrier(instance: RuntimeInstance, sleep_ns: u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: global_barrier failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.global_barrier(sleep_ns))
        })
    }

    unsafe extern "C" fn gate(
        instance: RuntimeInstance,
        data: *const u8,
        data_len: usize,
    ) -> Errno {
        result_to_errno(
            "RuntimeFFIAdapter: gate failed",
            (|| unsafe {
                let gate =
                    OwnedGateInstance::deserialize(std::slice::from_raw_parts(data, data_len))?;
                Self::with_runtime(instance, |runtime| runtime.gate(&gate))
            })(),
        )
    }

    unsafe extern "C" fn measure(
        instance: RuntimeInstance,
        qubit: u64,
        result_id_out: *mut u64,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: measure failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *result_id_out = runtime.measure(qubit)?;
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn measure_leaked(
        instance: RuntimeInstance,
        qubit: u64,
        result_id_out: *mut u64,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: measure_leaked failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *result_id_out = runtime.measure_leaked(qubit)?;
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn reset(instance: RuntimeInstance, qubit: u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: reset failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.reset(qubit))
        })
    }

    unsafe extern "C" fn force_result(instance: RuntimeInstance, result_id: u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: force_result failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.force_result(result_id))
        })
    }

    unsafe extern "C" fn get_bool_result(
        instance: RuntimeInstance,
        id: u64,
        result_out: *mut i8,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: get_bool_result failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *result_out = runtime.get_bool_result(id)?.map_or(-1, |r| r as i8);
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn get_u64_result(
        instance: RuntimeInstance,
        id: u64,
        result_out: *mut u64,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: get_u64_result failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *result_out = runtime.get_u64_result(id)?.unwrap_or(u64::MAX);
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn set_bool_result(
        instance: RuntimeInstance,
        result_id: u64,
        result: bool,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: set_bool_result failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                runtime.set_bool_result(result_id, result)
            })
        })
    }

    unsafe extern "C" fn set_u64_result(
        instance: RuntimeInstance,
        result_id: u64,
        result: u64,
    ) -> Errno {
        result_to_errno("RuntimeFFIAdapter: set_u64_result failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                runtime.set_u64_result(result_id, result)
            })
        })
    }

    unsafe extern "C" fn increment_future_refcount(
        instance: RuntimeInstance,
        result_id: u64,
    ) -> Errno {
        result_to_errno(
            "RuntimeFFIAdapter: increment_future_refcount failed",
            unsafe {
                Self::with_runtime(instance, |runtime| {
                    runtime.increment_future_refcount(result_id)
                })
            },
        )
    }

    unsafe extern "C" fn decrement_future_refcount(
        instance: RuntimeInstance,
        result_id: u64,
    ) -> Errno {
        result_to_errno(
            "RuntimeFFIAdapter: decrement_future_refcount failed",
            unsafe {
                Self::with_runtime(instance, |runtime| {
                    runtime.decrement_future_refcount(result_id)
                })
            },
        )
    }

    unsafe extern "C" fn custom_call(
        instance: RuntimeInstance,
        tag: u64,
        data: *const ffi::c_void,
        data_len: usize,
        result_out: *mut u64,
    ) -> Errno {
        let data = unsafe { std::slice::from_raw_parts(data as *const u8, data_len) };
        result_to_errno("RuntimeFFIAdapter: custom_call failed", unsafe {
            Self::with_runtime(instance, |runtime| {
                *result_out = runtime.custom_call(tag, data)?;
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe extern "C" fn simulate_delay(instance: RuntimeInstance, delay_ns: u64) -> Errno {
        result_to_errno("RuntimeFFIAdapter: simulate_delay failed", unsafe {
            Self::with_runtime(instance, |runtime| runtime.simulate_delay(delay_ns))
        })
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
#[non_exhaustive]
pub struct RuntimeOperationInterface<'a> {
    pub exit_fn: unsafe extern "C" fn(RuntimeInstance) -> Errno,
    pub last_error_fn: LastErrorFn,
    pub get_next_operations_fn:
        unsafe extern "C" fn(RuntimeInstance, RuntimeGetOperationHandle) -> Errno,
    pub shot_start_fn: unsafe extern "C" fn(RuntimeInstance, u64, u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(RuntimeInstance) -> Errno,
    pub get_metrics_fn:
        unsafe extern "C" fn(RuntimeInstance, u8, *mut ffi::c_char, *mut u8, *mut u64) -> Errno,
    pub qalloc_fn: unsafe extern "C" fn(RuntimeInstance, *mut u64) -> Errno,
    pub qfree_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub local_barrier_fn: unsafe extern "C" fn(RuntimeInstance, *const u64, u64, u64) -> Errno,
    pub global_barrier_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub measure_fn: unsafe extern "C" fn(RuntimeInstance, u64, *mut u64) -> Errno,
    pub measure_leaked_fn: unsafe extern "C" fn(RuntimeInstance, u64, *mut u64) -> Errno,
    pub reset_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub force_result_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub get_bool_result_fn: unsafe extern "C" fn(RuntimeInstance, u64, *mut i8) -> Errno,
    pub get_u64_result_fn: unsafe extern "C" fn(RuntimeInstance, u64, *mut u64) -> Errno,
    pub set_bool_result_fn: unsafe extern "C" fn(RuntimeInstance, u64, bool) -> Errno,
    pub set_u64_result_fn: unsafe extern "C" fn(RuntimeInstance, u64, u64) -> Errno,
    pub increment_future_refcount_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub decrement_future_refcount_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub custom_call_fn:
        unsafe extern "C" fn(RuntimeInstance, u64, *const ffi::c_void, usize, *mut u64) -> Errno,
    pub simulate_delay_fn: unsafe extern "C" fn(RuntimeInstance, u64) -> Errno,
    pub gate_fn: unsafe extern "C" fn(RuntimeInstance, *const u8, usize) -> Errno,
    pub negotiate_gateset_fn: unsafe extern "C" fn(
        RuntimeInstance,
        *const u8,
        usize,
        *mut u8,
        usize,
        *mut usize,
    ) -> Errno,
    _marker: PhantomData<&'a ()>,
}
