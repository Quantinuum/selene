use super::{
    BatchResult, ErrorModelInterface,
    plugin::{Errno, ErrorModelInstance},
};
use crate::{
    operation::plugin::{
        BatchBuilder, OperationResultHandle, OperationResultInterface,
        RuntimeExtractOperationHandle, RuntimeExtractOperationInterface,
    },
    plugin::{LastErrorFn, write_negotiated_gateset},
    simulator::{Simulator, inline::SimulatorHandle},
    utils::{result_of_errno_to_errno, result_to_errno},
};
use std::{ffi, marker::PhantomData};

/// Owns a Rust error-model implementation and exposes a C-ABI-friendly
/// `(instance pointer, function table)` pair for dependency injection.
pub struct ErrorModelFFIAdapter {
    error_model: Box<dyn ErrorModelInterface>,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ErrorModelHandle<'a> {
    pub instance: ErrorModelInstance,
    pub interface: ErrorModelOperationInterface<'a>,
}

impl ErrorModelFFIAdapter {
    pub fn new(error_model: Box<dyn ErrorModelInterface>) -> Self {
        Self { error_model }
    }

    pub fn ffi_interface(&mut self) -> ErrorModelHandle<'static> {
        ErrorModelHandle {
            instance: &raw mut self.error_model as ErrorModelInstance,
            interface: ErrorModelOperationInterface {
                exit_fn: Self::exit,
                last_error_fn: Self::last_error,
                shot_start_fn: Self::shot_start,
                shot_end_fn: Self::shot_end,
                negotiate_gateset_fn: Self::negotiate_gateset,
                handle_operations_fn: Self::handle_operations,
                get_metrics_fn: Self::get_metrics,
                _marker: PhantomData,
            },
        }
    }

    unsafe fn with_error_model<T>(
        instance: ErrorModelInstance,
        mut go: impl FnMut(&mut dyn ErrorModelInterface) -> T,
    ) -> T {
        assert!(!instance.is_null());
        let error_model = unsafe { &mut *(instance as *mut Box<dyn ErrorModelInterface>) };
        go(error_model.as_mut())
    }

    unsafe extern "C" fn exit(instance: ErrorModelInstance) -> Errno {
        result_to_errno("ErrorModelFFIAdapter: exit failed", unsafe {
            Self::with_error_model(instance, |error_model| error_model.exit())
        })
    }

    unsafe extern "C" fn last_error(
        output: *mut ffi::c_char,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        unsafe { crate::utils::last_error_message(output, output_len, written) }
    }

    unsafe extern "C" fn shot_start(
        instance: ErrorModelInstance,
        shot_id: u64,
        error_model_seed: u64,
    ) -> Errno {
        result_to_errno(
            format!("ErrorModelFFIAdapter: shot_start failed for shot {shot_id}"),
            unsafe {
                Self::with_error_model(instance, |error_model| {
                    error_model.shot_start(shot_id, error_model_seed)
                })
            },
        )
    }

    unsafe extern "C" fn shot_end(instance: ErrorModelInstance) -> Errno {
        result_to_errno("ErrorModelFFIAdapter: shot_end failed", unsafe {
            Self::with_error_model(instance, |error_model| error_model.shot_end())
        })
    }

    unsafe extern "C" fn negotiate_gateset(
        instance: ErrorModelInstance,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        result_to_errno("ErrorModelFFIAdapter: negotiate_gateset failed", unsafe {
            Self::with_error_model(instance, |error_model| {
                write_negotiated_gateset(input, input_len, output, output_len, written, |gateset| {
                    error_model.negotiate_gateset(gateset)
                })
            })
        })
    }

    unsafe extern "C" fn handle_operations(
        instance: ErrorModelInstance,
        batch: RuntimeExtractOperationHandle,
        simulator: SimulatorHandle<'static>,
        result: OperationResultHandle,
    ) -> Errno {
        result_to_errno("ErrorModelFFIAdapter: handle_operations failed", unsafe {
            Self::with_error_model(instance, |error_model| {
                let mut batch_builder = BatchBuilder::default();
                let builder = batch_builder.runtime_get_operation();
                let RuntimeExtractOperationInterface { extract_fn, .. } = batch.interface;
                extract_fn(&raw const batch, builder);

                let mut simulator = Simulator::from_raw_parts(simulator);
                let results =
                    error_model.handle_operations(batch_builder.finish(), &mut simulator)?;
                Self::write_results(results, result);
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe fn write_results(results: BatchResult, result: OperationResultHandle) {
        let OperationResultInterface {
            set_bool_result_fn,
            set_u64_result_fn,
            ..
        } = result.interface;
        for bool_result in results.bool_results {
            unsafe {
                set_bool_result_fn(result.instance, bool_result.result_id, bool_result.value)
            };
        }
        for u64_result in results.u64_results {
            unsafe { set_u64_result_fn(result.instance, u64_result.result_id, u64_result.value) };
        }
    }

    unsafe extern "C" fn get_metrics(
        instance: ErrorModelInstance,
        nth_metric: u8,
        out_tag_str: *mut ffi::c_char,
        out_datatype: *mut u8,
        out_data: *mut u64,
    ) -> Errno {
        result_of_errno_to_errno("ErrorModelFFIAdapter: get_metrics failed", unsafe {
            Self::with_error_model(instance, |error_model| {
                let Some((tag, metric)) = error_model.get_metric(nth_metric)? else {
                    return Ok::<i32, anyhow::Error>(1);
                };
                metric.write_raw(tag, out_tag_str, out_datatype, out_data);
                Ok::<i32, anyhow::Error>(0)
            })
        })
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
#[non_exhaustive]
pub struct ErrorModelOperationInterface<'a> {
    pub exit_fn: unsafe extern "C" fn(ErrorModelInstance) -> Errno,
    pub last_error_fn: LastErrorFn,
    pub shot_start_fn: unsafe extern "C" fn(ErrorModelInstance, u64, u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(ErrorModelInstance) -> Errno,
    pub handle_operations_fn: unsafe extern "C" fn(
        ErrorModelInstance,
        RuntimeExtractOperationHandle,
        SimulatorHandle<'a>,
        OperationResultHandle,
    ) -> Errno,
    pub get_metrics_fn:
        unsafe extern "C" fn(ErrorModelInstance, u8, *mut ffi::c_char, *mut u8, *mut u64) -> Errno,
    pub negotiate_gateset_fn: unsafe extern "C" fn(
        ErrorModelInstance,
        *const u8,
        usize,
        *mut u8,
        usize,
        *mut usize,
    ) -> Errno,
    _marker: PhantomData<&'a ()>,
}
