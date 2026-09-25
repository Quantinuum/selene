use super::*;
use std::{
    cell::Cell,
    sync::mpsc,
    thread::{self, JoinHandle},
};

type Request = Box<dyn FnOnce(&LegacyState) + Send>;

/// Lets callers on several threads use a plugin that expects just one.
///
/// We send each call to the plugin's thread and wait for its reply. This proxy
/// is Send + Sync, but the plugin instance itself never leaves that thread.
pub(super) struct LegacyRuntime {
    requests: Option<mpsc::Sender<Request>>,
    thread: Option<JoinHandle<()>>,
    // Thread-local plugin state may run destructors as the thread exits.
    // Keep the library loaded until join confirms those have finished.
    _interface: Arc<RuntimePluginInterface>,
}

impl LegacyRuntime {
    pub(super) fn new(
        interface: Arc<RuntimePluginInterface>,
        descriptor: RuntimePluginDescriptorV1,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let args: Vec<String> = args.iter().map(|arg| arg.as_ref().to_owned()).collect();
        let (requests, receiver) = mpsc::channel::<Request>();
        let (ready, initialized) = mpsc::sync_channel(1);
        let worker_interface = interface.clone();
        let thread = thread::Builder::new()
            .name("selene-runtime-v1".into())
            .spawn(move || {
                let mut instance = std::ptr::null_mut();
                let init = with_strings_to_cargs(&args, |argc, argv| {
                    check_errno(
                        unsafe {
                            (descriptor.init_fn)(&mut instance, n_qubits, start.into(), argc, argv)
                        },
                        || anyhow!("Legacy runtime initialization failed"),
                    )
                });
                if let Err(error) = init {
                    let _ = ready.send(Err(error));
                    return;
                }
                let state = LegacyState {
                    _interface: worker_interface,
                    descriptor,
                    instance,
                    exited: Cell::new(false),
                };
                if ready.send(Ok(())).is_err() {
                    return;
                }
                for request in receiver {
                    request(&state);
                }
                // State and its library ownership are dropped on this same thread.
            })?;
        let runtime = Self {
            requests: Some(requests),
            thread: Some(thread),
            _interface: interface,
        };
        initialized
            .recv()
            .map_err(|_| anyhow!("Legacy runtime stopped during initialization"))??;
        Ok(runtime)
    }

    fn call<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&LegacyState) -> Result<T> + Send + 'static,
    ) -> Result<T> {
        let (reply, result) = mpsc::sync_channel(1);
        self.requests
            .as_ref()
            .unwrap()
            .send(Box::new(move |state| {
                let value = if state.exited.get() {
                    Err(anyhow!("Legacy runtime has exited"))
                } else {
                    operation(state)
                };
                let _ = reply.send(value);
            }))
            .map_err(|_| anyhow!("Legacy runtime has stopped"))?;
        result
            .recv()
            .map_err(|_| anyhow!("Legacy runtime stopped before replying"))?
    }
}

impl Drop for LegacyRuntime {
    fn drop(&mut self) {
        self.requests.take();
        if let Some(thread) = self.thread.take() {
            let _ = thread.join();
        }
    }
}

impl RuntimeInterface for LegacyRuntime {
    fn exit(&self) -> Result<()> {
        self.call(move |state| state.exit())
    }
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        self.call(move |state| state.get_next_operations())
    }
    fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()> {
        self.call(move |state| state.shot_start(shot_id, seed))
    }
    fn shot_end(&self) -> Result<()> {
        self.call(move |state| state.shot_end())
    }
    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        self.call(move |state| state.get_metric(nth_metric))
    }
    fn qalloc(&self) -> Result<u64> {
        self.call(move |state| state.qalloc())
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        self.call(move |state| state.qfree(qubit_id))
    }
    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        self.call(move |state| state.global_barrier(sleep_ns))
    }
    fn local_barrier(&self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let qubit_ids = qubit_ids.to_vec();
        self.call(move |state| state.local_barrier(&qubit_ids, sleep_ns))
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        self.call(move |state| state.rxy_gate(qubit_id, theta, phi))
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        self.call(move |state| state.rzz_gate(qubit_id_1, qubit_id_2, theta))
    }
    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        self.call(move |state| state.rz_gate(qubit_id, theta))
    }
    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        self.call(move |state| state.rpp_gate(qubit_id_1, qubit_id_2, theta, phi))
    }
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        self.call(move |state| state.measure(qubit_id))
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        self.call(move |state| state.measure_leaked(qubit_id))
    }
    fn reset(&self, qubit_id: u64) -> Result<()> {
        self.call(move |state| state.reset(qubit_id))
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        self.call(move |state| state.force_result(result_id))
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        self.call(move |state| state.get_bool_result(result_id))
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        self.call(move |state| state.get_u64_result(result_id))
    }
    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        self.call(move |state| state.set_bool_result(result_id, result))
    }
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        self.call(move |state| state.set_u64_result(result_id, result))
    }
    fn increment_future_refcount(&self, future_ref: u64) -> Result<()> {
        self.call(move |state| state.increment_future_refcount(future_ref))
    }
    fn decrement_future_refcount(&self, future_ref: u64) -> Result<()> {
        self.call(move |state| state.decrement_future_refcount(future_ref))
    }
    fn custom_call(&self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let data = data.to_vec();
        self.call(move |state| state.custom_call(custom_tag, &data))
    }
    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        self.call(move |state| state.simulate_delay(delay_ns))
    }
}

struct LegacyState {
    _interface: Arc<RuntimePluginInterface>,
    descriptor: RuntimePluginDescriptorV1,
    instance: RuntimeInstance,
    exited: Cell<bool>,
}

impl Drop for LegacyState {
    fn drop(&mut self) {
        if !self.exited.get() {
            let _ = self.exit();
        }
    }
}

impl LegacyState {
    fn exit(&self) -> Result<()> {
        self.exited.set(true);
        let Some(exit_fn) = self.descriptor.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("RuntimePlugin: exit failed")
        })
    }

    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        check_errno(
            unsafe { (self.descriptor.get_next_operations_fn)(self.instance, ops) },
            || anyhow!("RuntimePlugin: get_next_operations failed"),
        )?;
        Ok(Some(batch_builder.finish()).filter(|b| !b.is_empty()))
    }

    fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("RuntimePlugin: shot_start failed"),
        )
    }

    fn shot_end(&self) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.shot_end_fn)(self.instance) },
            || anyhow!("RuntimePlugin: shot_end failed"),
        )
    }

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(get_metrics_fn) = self.descriptor.get_metrics_fn else {
            return Ok(None);
        };
        read_raw_metric(|tag, data_type, data| unsafe {
            get_metrics_fn(self.instance, nth_metric, tag, data_type, data)
        })
    }

    fn qalloc(&self) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.descriptor.qalloc_fn)(self.instance, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.qfree_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: qfree failed"),
        )
    }

    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.global_barrier_fn)(self.instance, sleep_ns) },
            || anyhow!("RuntimePlugin: global barrier failed"),
        )
    }

    fn local_barrier(&self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let qubit_ids_len = qubit_ids.len() as u64;
        let qubit_ids_ptr = qubit_ids.as_ptr();
        check_errno(
            unsafe {
                (self.descriptor.local_barrier_fn)(
                    self.instance,
                    qubit_ids_ptr,
                    qubit_ids_len,
                    sleep_ns,
                )
            },
            || anyhow!("RuntimePlugin: local barrier failed"),
        )
    }

    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.rxy_gate_fn)(self.instance, qubit_id, theta, phi) },
            || anyhow!("RuntimePlugin: rxy_gate failed"),
        )
    }

    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.rzz_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta) },
            || anyhow!("RuntimePlugin: rzz_gate failed"),
        )
    }

    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.rz_gate_fn)(self.instance, qubit_id, theta) },
            || anyhow!("RuntimePlugin: rz_gate failed"),
        )
    }

    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.descriptor.rpp_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta, phi)
            },
            || anyhow!("RuntimePlugin: rpp_gate failed"),
        )
    }

    fn measure(&self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.descriptor.measure_fn)(self.instance, qubit_id, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.measure_leaked_fn)(self.instance, qubit_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn reset(&self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.reset_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: reset failed"),
        )
    }

    fn force_result(&self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.force_result_fn)(self.instance, result_id) },
            || anyhow!("RuntimePlugin: force_result failed"),
        )
    }

    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        let mut result = 0i8;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.get_bool_result_fn)(self.instance, result_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: get_bool_result failed"),
        )?;
        // The C interface uses 0 and 1 for ready values. Anything else means
        // the measurement is not ready yet.
        Ok(match result {
            0 => Some(false),
            1 => Some(true),
            _ => None,
        })
    }

    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        let mut result = 0u64;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.descriptor.get_u64_result_fn)(
                    self.instance,
                    result_id,
                    result_ref as *mut u64,
                )
            },
            || anyhow!("RuntimePlugin: get_u64_result failed"),
        )?;
        // The C interface reserves u64::MAX for a result that is not ready yet.
        Ok(match result {
            u64::MAX => None,
            n => Some(n),
        })
    }

    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.set_bool_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_bool_result failed"),
        )
    }

    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.set_u64_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.increment_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.descriptor.decrement_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: decrement_future_refcount failed"),
        )
    }

    fn custom_call(&self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        if let Some(custom_call_fn) = self.descriptor.custom_call_fn {
            check_errno(
                unsafe {
                    custom_call_fn(
                        self.instance,
                        custom_tag,
                        data.as_ptr() as *const ffi::c_void,
                        data.len(),
                        result_ref as *mut _,
                    )
                },
                || anyhow!("RuntimePlugin: custom_call failed"),
            )?;
            Ok(result)
        } else {
            Err(anyhow!(
                "RuntimePlugin: custom_call not supported by plugin"
            ))
        }
    }

    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        if let Some(simulate_delay_fn) = self.descriptor.simulate_delay_fn {
            check_errno(
                unsafe { simulate_delay_fn(self.instance, delay_ns) },
                || anyhow!("RuntimePlugin: simulate_delay failed"),
            )
        } else {
            Err(anyhow!(
                "RuntimePlugin: simulate_delay not supported by plugin"
            ))
        }
    }
}
