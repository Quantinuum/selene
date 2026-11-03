//! Export a Rust endpoint runtime through the same C ABI used by native plugins.
use super::{
    ExecutionCallback, RuntimeInstruction, RuntimeInterface, RuntimeInterfaceFactory,
    instruction::{RuntimeInstructionRaw, RuntimeInstructionResultRaw},
    output::OutputSinkHandle,
};
use crate::{
    endpoint::{EndpointBorrowCallback, EndpointBorrowRequest, QuantumEndpointHandle},
    runtime::v0_4::plugin::{Errno, RuntimeInstance},
    utils::{convert_cargs_to_strings, result_of_errno_to_errno, result_to_errno},
};
use std::{ffi, sync::Arc};

fn catch_errno(callback: impl FnOnce() -> i32) -> i32 {
    std::panic::catch_unwind(std::panic::AssertUnwindSafe(callback)).unwrap_or_else(|_| {
        eprintln!("Runtime plugin callback panicked");
        -1
    })
}

pub struct Helper<F>(std::marker::PhantomData<F>);
impl<F: Default> Default for Helper<F> {
    fn default() -> Self {
        Self(std::marker::PhantomData)
    }
}
impl<F: RuntimeInterfaceFactory + Default> Helper<F> {
    unsafe fn with_runtime<T>(instance: RuntimeInstance, go: impl FnOnce(&F::Interface) -> T) -> T {
        go(unsafe { &*instance.cast::<F::Interface>() })
    }
    pub unsafe extern "C" fn init(
        out: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                anyhow::ensure!(!out.is_null(), "Runtime output pointer is null");
                let mut args = vec!["runtime".to_owned()];
                args.extend(unsafe { convert_cargs_to_strings(argc, argv) });
                let runtime = Arc::new(F::default()).init(n_qubits, start.into(), &args)?;
                unsafe { *out = Box::into_raw(runtime).cast() };
                Ok(())
            })
        })
    }
    pub unsafe extern "C" fn destroy(instance: RuntimeInstance) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                let runtime = unsafe { Box::from_raw(instance.cast::<F::Interface>()) };
                runtime.destroy()
            })
        })
    }
    pub unsafe extern "C" fn shot_start(
        instance: RuntimeInstance,
        shot_id: u64,
        seed: u64,
        endpoint: QuantumEndpointHandle,
        output: OutputSinkHandle,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno(
                format!("RuntimeFFIAdapter: shot_start failed for shot {shot_id}"),
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.shot_start(shot_id, seed, endpoint, output)
                    })
                },
            )
        })
    }
    pub unsafe extern "C" fn shot_end(instance: RuntimeInstance) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: shot_end failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.shot_end())
            })
        })
    }
    pub unsafe extern "C" fn get_metric(
        instance: RuntimeInstance,
        nth_metric: u8,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) -> Errno {
        catch_errno(|| {
            result_of_errno_to_errno("RuntimeFFIAdapter: get_metric failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    let Some((tag, metric)) = runtime.get_metric(nth_metric)? else {
                        return Ok::<i32, anyhow::Error>(1);
                    };
                    anyhow::ensure!(
                        tag.len() <= 255 && !tag.contains('\0'),
                        "Invalid runtime metric tag"
                    );
                    *data_ptr = 0;
                    metric.write_raw(tag, tag_ptr, datatype_ptr, data_ptr);
                    Ok::<i32, anyhow::Error>(0)
                })
            })
        })
    }
    pub unsafe extern "C" fn handle_instruction(
        instance: RuntimeInstance,
        instruction: *const RuntimeInstructionRaw,
        result: *mut RuntimeInstructionResultRaw,
    ) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                anyhow::ensure!(!result.is_null(), "Null instruction result pointer");
                let instruction = unsafe { RuntimeInstruction::from_raw(instruction)? };
                let value = unsafe {
                    Self::with_runtime(instance, |runtime| runtime.handle_instruction(instruction))
                }?;
                unsafe {
                    *result = value.as_raw();
                }
                Ok(())
            })
        })
    }
    pub unsafe extern "C" fn on_execution_thread(
        instance: RuntimeInstance,
        callback: ExecutionCallback,
        context: *mut ffi::c_void,
    ) -> Errno {
        catch_errno(|| {
            super::callback_result(|| unsafe {
                Self::with_runtime(instance, |runtime| {
                    runtime.on_execution_thread(callback, context)
                })
            })
        })
    }
    pub unsafe extern "C" fn borrow_endpoint(
        instance: RuntimeInstance,
        request: *const EndpointBorrowRequest,
        callback: EndpointBorrowCallback,
        context: *mut ffi::c_void,
    ) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                anyhow::ensure!(!request.is_null(), "Endpoint borrow request is null");
                // Read the size before the rest of the request so older, shorter
                // structures can be rejected without reading past their allocation.
                anyhow::ensure!(
                    unsafe { (*request).struct_size } >= size_of::<EndpointBorrowRequest>() as u64,
                    "Undersized endpoint borrow request"
                );
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.borrow_endpoint(&*request, callback, context)
                    })
                }
            })
        })
    }
}

#[macro_export]
macro_rules! export_runtime_plugin_v0_4 {
    ($factory:ty) => {
        #[unsafe(no_mangle)]
        pub static selene_runtime_plugin_descriptor_v2:
            $crate::runtime::v0_4::RuntimePluginDescriptorV2 =
            $crate::runtime::v0_4::RuntimePluginDescriptorV2 {
                struct_size: core::mem::size_of::<$crate::runtime::v0_4::RuntimePluginDescriptorV2>(
                ) as u64,
                api_version: $crate::runtime::v0_4::version::RUNTIME_V0_4_API_VERSION,
                init_fn: Some($crate::runtime::v0_4::helper::Helper::<$factory>::init),
                destroy_fn: Some($crate::runtime::v0_4::helper::Helper::<$factory>::destroy),
                shot_start_fn: Some($crate::runtime::v0_4::helper::Helper::<$factory>::shot_start),
                shot_end_fn: Some($crate::runtime::v0_4::helper::Helper::<$factory>::shot_end),
                get_metrics_fn: Some($crate::runtime::v0_4::helper::Helper::<$factory>::get_metric),
                handle_instruction_fn: Some(
                    $crate::runtime::v0_4::helper::Helper::<$factory>::handle_instruction,
                ),
                on_execution_thread_fn: Some(
                    $crate::runtime::v0_4::helper::Helper::<$factory>::on_execution_thread,
                ),
                borrow_endpoint_fn: Some(
                    $crate::runtime::v0_4::helper::Helper::<$factory>::borrow_endpoint,
                ),
            };
    };
}
