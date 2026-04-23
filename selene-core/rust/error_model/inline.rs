use super::{
    BatchResult, ErrorModelInterface,
    plugin::{
        Errno, ErrorModelInstance, ErrorModelSetResultInstance, ErrorModelSetResultInterface,
    },
};
use crate::{
    runtime::plugin::{
        BatchBuilder, RuntimeExtractOperationInstance, RuntimeExtractOperationInterface,
    },
    simulator::{
        SimulatorInterface, inline::SimulatorOperationInterface, plugin::SimulatorInstance,
    },
    utils::{result_of_errno_to_errno, result_to_errno},
};
use std::{ffi, marker::PhantomData};

/// Owns a Rust error-model implementation and exposes a C-ABI-friendly
/// `(instance pointer, function table)` pair for dependency injection.
pub struct ErrorModelFFIAdapter {
    error_model: Box<dyn ErrorModelInterface>,
}

impl ErrorModelFFIAdapter {
    pub fn new(error_model: Box<dyn ErrorModelInterface>) -> Self {
        Self { error_model }
    }

    pub fn ffi_interface(&mut self) -> (ErrorModelInstance, ErrorModelOperationInterface<'_>) {
        (
            &raw mut self.error_model as ErrorModelInstance,
            ErrorModelOperationInterface {
                exit_fn: Self::exit,
                shot_start_fn: Self::shot_start,
                shot_end_fn: Self::shot_end,
                handle_operations_fn: Self::handle_operations,
                get_metrics_fn: Self::get_metrics,
                _marker: PhantomData,
            },
        )
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

    unsafe extern "C" fn handle_operations(
        instance: ErrorModelInstance,
        batch_instance: RuntimeExtractOperationInstance,
        batch_interface: *const RuntimeExtractOperationInterface,
        simulator_instance: SimulatorInstance,
        simulator_interface: *const SimulatorOperationInterface,
        result_instance: ErrorModelSetResultInstance,
        result_interface: *const ErrorModelSetResultInterface,
    ) -> Errno {
        result_to_errno("ErrorModelFFIAdapter: handle_operations failed", unsafe {
            Self::with_error_model(instance, |error_model| {
                let mut batch_builder = BatchBuilder::default();
                let (builder_instance, builder_interface) = batch_builder.runtime_get_operation();
                let RuntimeExtractOperationInterface { extract_fn, .. } = &*batch_interface;
                extract_fn(batch_instance, builder_instance, builder_interface);

                let mut simulator = FfiSimulator {
                    instance: simulator_instance,
                    interface: simulator_interface,
                };
                let results =
                    error_model.handle_operations(batch_builder.finish(), &mut simulator)?;
                Self::write_results(results, result_instance, result_interface);
                Ok::<(), anyhow::Error>(())
            })
        })
    }

    unsafe fn write_results(
        results: BatchResult,
        result_instance: ErrorModelSetResultInstance,
        result_interface: *const ErrorModelSetResultInterface,
    ) {
        let ErrorModelSetResultInterface {
            set_bool_result_fn,
            set_u64_result_fn,
            ..
        } = unsafe { &*result_interface };
        for bool_result in results.bool_results {
            unsafe {
                set_bool_result_fn(result_instance, bool_result.result_id, bool_result.value)
            };
        }
        for u64_result in results.u64_results {
            unsafe { set_u64_result_fn(result_instance, u64_result.result_id, u64_result.value) };
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

struct FfiSimulator<'a> {
    instance: SimulatorInstance,
    interface: *const SimulatorOperationInterface<'a>,
}
impl SimulatorInterface for FfiSimulator<'_> {
    fn exit(&mut self) -> anyhow::Result<()> {
        Ok(())
    }
    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> anyhow::Result<()> {
        Ok(())
    }
    fn shot_end(&mut self) -> anyhow::Result<()> {
        Ok(())
    }
    fn measure(&mut self, _qubit: u64) -> anyhow::Result<bool> {
        let iface = unsafe { &*self.interface };
        match unsafe { (iface.measure_fn)(self.instance, _qubit) } {
            0 => Ok(false),
            1 => Ok(true),
            _ => anyhow::bail!("Simulator interface measure failed"),
        }
    }
    fn reset(&mut self, _qubit: u64) -> anyhow::Result<()> {
        let iface = unsafe { &*self.interface };
        match unsafe { (iface.reset_fn)(self.instance, _qubit) } {
            0 => Ok(()),
            _ => anyhow::bail!("Simulator interface reset failed"),
        }
    }
    fn get_metric(
        &mut self,
        _nth_metric: u8,
    ) -> anyhow::Result<Option<(String, crate::utils::MetricValue)>> {
        crate::utils::read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| {
            let iface = unsafe { &*self.interface };
            unsafe {
                (iface.get_metric_fn)(self.instance, _nth_metric, tag_ptr, datatype_ptr, data_ptr)
            }
        })
    }
}

#[repr(C)]
#[non_exhaustive]
pub struct ErrorModelOperationInterface<'a> {
    pub exit_fn: unsafe extern "C" fn(ErrorModelInstance) -> Errno,
    pub shot_start_fn: unsafe extern "C" fn(ErrorModelInstance, u64, u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(ErrorModelInstance) -> Errno,
    pub handle_operations_fn: unsafe extern "C" fn(
        ErrorModelInstance,
        RuntimeExtractOperationInstance,
        *const RuntimeExtractOperationInterface,
        SimulatorInstance,
        *const SimulatorOperationInterface<'a>,
        ErrorModelSetResultInstance,
        *const ErrorModelSetResultInterface,
    ) -> Errno,
    pub get_metrics_fn:
        unsafe extern "C" fn(ErrorModelInstance, u8, *mut ffi::c_char, *mut u8, *mut u64) -> Errno,
    _marker: PhantomData<&'a ()>,
}
