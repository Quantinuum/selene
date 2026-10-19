//! Export a Rust peripheral runtime through the same C ABI used by native plugins.
use super::{ExecutionCallback, RuntimeInterface, RuntimeInterfaceFactory};
use crate::{
    peripheral::{PeripheralBorrowCallback, PeripheralBorrowRequest, QuantumPeripheralHandle},
    runtime::plugin::{Errno, RuntimeInstance},
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
    pub unsafe extern "C" fn exit(instance: RuntimeInstance) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                let runtime = unsafe { Box::from_raw(instance.cast::<F::Interface>()) };
                runtime.exit()
            })
        })
    }
    pub unsafe extern "C" fn shot_start(
        instance: RuntimeInstance,
        shot_id: u64,
        seed: u64,
        peripheral: QuantumPeripheralHandle,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno(
                format!("RuntimeFFIAdapter: shot_start failed for shot {shot_id}"),
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.shot_start(shot_id, seed, peripheral)
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
    pub unsafe extern "C" fn qalloc(instance: RuntimeInstance, qaddress_out: *mut u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: qalloc failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *qaddress_out = runtime.qalloc()?;
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn qfree(instance: RuntimeInstance, qaddress: u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: qfree failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.qfree(qaddress))
            })
        })
    }
    pub unsafe extern "C" fn local_barrier(
        instance: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno {
        catch_errno(|| {
            let qubits = if qubits_len == 0 {
                &[]
            } else {
                unsafe { std::slice::from_raw_parts(qubits, qubits_len as usize) }
            };
            result_to_errno("RuntimeFFIAdapter: local_barrier failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.local_barrier(qubits, sleep_ns))
            })
        })
    }
    pub unsafe extern "C" fn global_barrier(instance: RuntimeInstance, sleep_ns: u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: global_barrier failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.global_barrier(sleep_ns))
            })
        })
    }
    pub unsafe extern "C" fn rxy_gate(
        instance: RuntimeInstance,
        qubit: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: rxy_gate failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.rxy_gate(qubit, theta, phi))
            })
        })
    }
    pub unsafe extern "C" fn rzz_gate(
        instance: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: rzz_gate failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.rzz_gate(qubit0, qubit1, theta))
            })
        })
    }
    pub unsafe extern "C" fn rz_gate(instance: RuntimeInstance, qubit: u64, theta: f64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: rz_gate failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.rz_gate(qubit, theta))
            })
        })
    }
    pub unsafe extern "C" fn rpp_gate(
        instance: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: rpp_gate failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    runtime.rpp_gate(qubit0, qubit1, theta, phi)
                })
            })
        })
    }
    pub unsafe extern "C" fn measure(
        instance: RuntimeInstance,
        qubit: u64,
        result_id_out: *mut u64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: measure failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *result_id_out = runtime.measure(qubit)?;
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn measure_leaked(
        instance: RuntimeInstance,
        qubit: u64,
        result_id_out: *mut u64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: measure_leaked failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *result_id_out = runtime.measure_leaked(qubit)?;
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn reset(instance: RuntimeInstance, qubit: u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: reset failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.reset(qubit))
            })
        })
    }
    pub unsafe extern "C" fn force_result(instance: RuntimeInstance, result_id: u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: force_result failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.force_result(result_id))
            })
        })
    }
    pub unsafe extern "C" fn get_bool_result(
        instance: RuntimeInstance,
        id: u64,
        result_out: *mut i8,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: get_bool_result failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *result_out = runtime.get_bool_result(id)?.map_or(-1, |r| r as i8);
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn get_u64_result(
        instance: RuntimeInstance,
        id: u64,
        result_out: *mut u64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: get_u64_result failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *result_out = runtime.get_u64_result(id)?.unwrap_or(u64::MAX);
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn increment_future_refcount(
        instance: RuntimeInstance,
        result_id: u64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno(
                "RuntimeFFIAdapter: increment_future_refcount failed",
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.increment_future_refcount(result_id)
                    })
                },
            )
        })
    }
    pub unsafe extern "C" fn decrement_future_refcount(
        instance: RuntimeInstance,
        result_id: u64,
    ) -> Errno {
        catch_errno(|| {
            result_to_errno(
                "RuntimeFFIAdapter: decrement_future_refcount failed",
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.decrement_future_refcount(result_id)
                    })
                },
            )
        })
    }
    pub unsafe extern "C" fn custom_call(
        instance: RuntimeInstance,
        tag: u64,
        data: *const ffi::c_void,
        data_len: usize,
        result_out: *mut u64,
    ) -> Errno {
        catch_errno(|| {
            let data = if data_len == 0 {
                &[]
            } else {
                unsafe { std::slice::from_raw_parts(data as *const u8, data_len) }
            };
            result_to_errno("RuntimeFFIAdapter: custom_call failed", unsafe {
                Self::with_runtime(instance, |runtime| {
                    *result_out = runtime.custom_call(tag, data)?;
                    Ok::<(), anyhow::Error>(())
                })
            })
        })
    }
    pub unsafe extern "C" fn simulate_delay(instance: RuntimeInstance, delay_ns: u64) -> Errno {
        catch_errno(|| {
            result_to_errno("RuntimeFFIAdapter: simulate_delay failed", unsafe {
                Self::with_runtime(instance, |runtime| runtime.simulate_delay(delay_ns))
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
    pub unsafe extern "C" fn borrow_peripheral(
        instance: RuntimeInstance,
        request: *const PeripheralBorrowRequest,
        callback: PeripheralBorrowCallback,
        context: *mut ffi::c_void,
    ) -> Errno {
        catch_errno(|| {
            super::callback_result(|| {
                anyhow::ensure!(!request.is_null(), "Peripheral borrow request is null");
                // Read the size before the rest of the request so older, shorter
                // structures can be rejected without reading past their allocation.
                anyhow::ensure!(
                    unsafe { (*request).struct_size }
                        >= size_of::<PeripheralBorrowRequest>() as u64,
                    "Undersized peripheral borrow request"
                );
                unsafe {
                    Self::with_runtime(instance, |runtime| {
                        runtime.borrow_peripheral(&*request, callback, context)
                    })
                }
            })
        })
    }
}

#[macro_export]
macro_rules! export_pipeline_runtime_plugin {
    ($factory:ty) => {
        #[unsafe(no_mangle)]
        pub static selene_runtime_plugin_descriptor_v2: $crate::runtime::pipeline::RuntimePluginDescriptorV2 = $crate::runtime::pipeline::RuntimePluginDescriptorV2 {
            struct_size: core::mem::size_of::<$crate::runtime::pipeline::RuntimePluginDescriptorV2>() as u64,
            api_version: $crate::runtime::pipeline::plugin::RUNTIME_V2_API_VERSION,
            init_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::init),
            exit_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::exit),
            shot_start_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::shot_start),
            shot_end_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::shot_end),
            get_metrics_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::get_metric),
            qalloc_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::qalloc),
            qfree_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::qfree),
            local_barrier_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::local_barrier),
            global_barrier_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::global_barrier),
            rxy_gate_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::rxy_gate),
            rzz_gate_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::rzz_gate),
            rz_gate_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::rz_gate),
            rpp_gate_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::rpp_gate),
            measure_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::measure),
            measure_leaked_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::measure_leaked),
            reset_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::reset),
            force_result_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::force_result),
            get_bool_result_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::get_bool_result),
            get_u64_result_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::get_u64_result),
            increment_future_refcount_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::increment_future_refcount),
            decrement_future_refcount_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::decrement_future_refcount),
            custom_call_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::custom_call),
            simulate_delay_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::simulate_delay),
            on_execution_thread_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::on_execution_thread),
            borrow_peripheral_fn: Some($crate::runtime::pipeline::helper::Helper::<$factory>::borrow_peripheral),
        };
    };
}
