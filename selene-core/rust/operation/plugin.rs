use super::{BatchOperation, Operation, RuntimeBatchSource};
use core::slice;
use std::ffi;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimeGetOperationHandle {
    pub instance: RuntimeGetOperationInstance,
    pub interface: RuntimeGetOperationInterface,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimeExtractOperationHandle {
    pub instance: RuntimeExtractOperationInstance,
    pub interface: RuntimeExtractOperationInterface,
}

/// A helper type used by plugin tooling to populate operation batches through
/// the runtime batch callback ABI.
#[derive(Default)]
pub struct BatchBuilder {
    ops: Vec<Operation>,
    source: RuntimeBatchSource,
}

impl BatchBuilder {
    fn push(interface: RuntimeGetOperationInstance, op: Operation) {
        Self::with_interface(interface, move |this| this.ops.push(op))
    }

    fn with_interface<T>(
        interface: RuntimeGetOperationInstance,
        go: impl FnOnce(&mut Self) -> T,
    ) -> T {
        let this = interface as *mut Self;
        let this = unsafe { &mut *this };
        go(this)
    }

    unsafe extern "C" fn rzz(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    ) {
        Self::push(
            interface,
            Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            },
        )
    }

    unsafe extern "C" fn rz(interface: RuntimeGetOperationInstance, qubit_id: u64, theta: f64) {
        Self::push(interface, Operation::RZGate { qubit_id, theta })
    }

    unsafe extern "C" fn rxy(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        theta: f64,
        phi: f64,
    ) {
        Self::push(
            interface,
            Operation::RXYGate {
                qubit_id,
                theta,
                phi,
            },
        )
    }

    unsafe extern "C" fn rpp(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    ) {
        Self::push(
            interface,
            Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            },
        )
    }

    unsafe extern "C" fn tk2(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) {
        Self::push(
            interface,
            Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                alpha,
                beta,
                gamma,
            },
        )
    }

    unsafe extern "C" fn measure(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        result_id: u64,
    ) {
        Self::push(
            interface,
            Operation::Measure {
                qubit_id,
                result_id,
            },
        )
    }

    unsafe extern "C" fn measure_leaked(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        result_id: u64,
    ) {
        Self::push(
            interface,
            Operation::MeasureLeaked {
                qubit_id,
                result_id,
            },
        )
    }

    unsafe extern "C" fn reset(interface: RuntimeGetOperationInstance, qubit_id: u64) {
        Self::push(interface, Operation::Reset { qubit_id })
    }

    unsafe extern "C" fn custom(
        interface: RuntimeGetOperationInstance,
        custom_tag: usize,
        data: *const ffi::c_void,
        len: usize,
    ) {
        let data = unsafe { slice::from_raw_parts(data as *mut u8, len) }
            .to_vec()
            .into_boxed_slice();
        Self::push(interface, Operation::Custom { custom_tag, data })
    }

    unsafe extern "C" fn set_batch_time(
        interface: RuntimeGetOperationInstance,
        start: u64,
        duration: u64,
    ) {
        Self::with_interface(interface, |this| {
            this.source = RuntimeBatchSource::new(start.into(), duration.into());
        })
    }

    pub fn runtime_get_operation(&mut self) -> RuntimeGetOperationHandle {
        RuntimeGetOperationHandle {
            instance: self as *mut Self as RuntimeGetOperationInstance,
            interface: RuntimeGetOperationInterface {
                measure_fn: Self::measure,
                measure_leaked_fn: Self::measure_leaked,
                reset_fn: Self::reset,
                custom_fn: Self::custom,
                set_batch_time_fn: Self::set_batch_time,
                rzz_fn: Self::rzz,
                rxy_fn: Self::rxy,
                rz_fn: Self::rz,
                rpp_fn: Self::rpp,
                tk2_fn: Self::tk2,
            },
        }
    }

    pub fn finish(self) -> BatchOperation {
        BatchOperation::runtime_with_source(self.ops, self.source)
    }
}

/// An instance is provided to `selene_runtime_get_next_operations`, which must
/// pass that back to any function it calls in its provided
/// [RuntimeGetOperationInterface].
pub type RuntimeGetOperationInstance = *mut ffi::c_void;

#[repr(C)]
#[derive(Clone, Copy)]
#[non_exhaustive]
pub struct RuntimeGetOperationInterface {
    pub measure_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub measure_leaked_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub reset_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64),
    pub custom_fn:
        unsafe extern "C" fn(RuntimeGetOperationInstance, usize, *const ffi::c_void, usize),
    pub set_batch_time_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub rzz_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64),
    pub rxy_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, f64, f64),
    pub rz_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, f64),
    pub rpp_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64, f64),
    pub tk2_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64, f64, f64),
}

#[derive(Default)]
pub struct BatchExtractor(BatchOperation);

impl BatchExtractor {
    pub fn from_batch_operation(batch: BatchOperation) -> Self {
        Self(batch)
    }

    pub unsafe extern "C" fn extract(
        input: RuntimeExtractOperationHandle,
        output: RuntimeGetOperationHandle,
    ) {
        let batch_ptr = input.instance as *const BatchOperation;
        let batch: &BatchOperation = unsafe { &*batch_ptr };
        let RuntimeGetOperationInterface {
            measure_fn,
            measure_leaked_fn,
            reset_fn,
            custom_fn,
            set_batch_time_fn,
            rzz_fn,
            rxy_fn,
            rz_fn,
            rpp_fn,
            tk2_fn,
            ..
        } = output.interface;
        if let Some(timing) = batch.runtime_source() {
            unsafe {
                set_batch_time_fn(
                    output.instance,
                    timing.start().into(),
                    timing.duration().into(),
                )
            };
        }
        for operation in batch.iter_ops() {
            match operation {
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => unsafe { measure_fn(output.instance, *qubit_id, *result_id) },
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => unsafe { measure_leaked_fn(output.instance, *qubit_id, *result_id) },
                Operation::Reset { qubit_id } => unsafe { reset_fn(output.instance, *qubit_id) },
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => unsafe { rxy_fn(output.instance, *qubit_id, *theta, *phi) },
                Operation::RZGate { qubit_id, theta } => unsafe {
                    rz_fn(output.instance, *qubit_id, *theta)
                },
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => unsafe { rzz_fn(output.instance, *qubit_id_1, *qubit_id_2, *theta) },
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => unsafe { rpp_fn(output.instance, *qubit_id_1, *qubit_id_2, *theta, *phi) },
                Operation::TK2Gate {
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                } => unsafe {
                    tk2_fn(
                        output.instance,
                        *qubit_id_1,
                        *qubit_id_2,
                        *alpha,
                        *beta,
                        *gamma,
                    )
                },
                Operation::Custom { custom_tag, data } => {
                    let (ptr, len) = (data.as_ptr() as *const ffi::c_void, data.len());
                    unsafe { custom_fn(output.instance, *custom_tag, ptr, len) }
                }
            }
        }
    }

    pub fn runtime_batch_extraction(&mut self) -> RuntimeExtractOperationHandle {
        RuntimeExtractOperationHandle {
            instance: &raw mut self.0 as RuntimeExtractOperationInstance,
            interface: RuntimeExtractOperationInterface {
                extract_fn: Self::extract,
            },
        }
    }
}

pub type RuntimeExtractOperationInstance = *mut ffi::c_void;

#[repr(C)]
#[derive(Clone, Copy)]
#[non_exhaustive]
pub struct RuntimeExtractOperationInterface {
    pub extract_fn: unsafe extern "C" fn(RuntimeExtractOperationHandle, RuntimeGetOperationHandle),
}
