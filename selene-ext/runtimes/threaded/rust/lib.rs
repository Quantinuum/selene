//! A runtime that accepts concurrent callers and drives its peripheral on a
//! dedicated thread. Gates are queued without waiting for an acknowledgement;
//! measurements, forced borrows and shot end establish execution boundaries.
use anyhow::{Result, anyhow};
use selene_core::{
    peripheral::{
        PeripheralBorrowCallback, PeripheralBorrowRequest, QuantumPeripheral,
        QuantumPeripheralHandle, QuantumPeripheralInterface,
    },
    runtime::{
        Runtime as Scheduler, RuntimeInterface as SchedulerInterface,
        pipeline::{ExecutionCallback, RuntimeInterface, RuntimeInterfaceFactory},
    },
    utils::MetricValue,
};
use std::{
    ffi,
    sync::{Arc, Mutex, mpsc},
    thread::{self, JoinHandle},
};

type Request = Box<dyn FnOnce(&mut State) + Send>;
struct State {
    scheduler: Scheduler,
    peripheral: Option<QuantumPeripheralHandle>,
    failure: Option<String>,
    submitted: u64,
}
impl State {
    fn drain(&mut self) -> Result<()> {
        if let Some(error) = &self.failure {
            return Err(anyhow!("{error}"));
        }
        let result = self.execute();
        if let Err(error) = &result {
            self.failure = Some(format!("{error:#}"));
        }
        result
    }
    fn execute(&mut self) -> Result<()> {
        let handle = self
            .peripheral
            .ok_or_else(|| anyhow!("No quantum peripheral attached"))?;
        let mut peripheral = unsafe { QuantumPeripheral::from_raw_parts(handle) };
        while let Some(batch) = self.scheduler.get_next_operations()? {
            let results = peripheral.handle_operations(batch)?;
            for result in results.bool_results {
                self.scheduler
                    .set_bool_result(result.result_id, result.value)?;
            }
            for result in results.u64_results {
                self.scheduler
                    .set_u64_result(result.result_id, result.value)?;
            }
        }
        Ok(())
    }
}

pub struct ThreadedRuntime {
    requests: Mutex<Option<mpsc::Sender<Request>>>,
    thread: Mutex<Option<JoinHandle<()>>>,
}
impl ThreadedRuntime {
    pub fn new(
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let mut args: Vec<String> = args.iter().map(|arg| arg.as_ref().to_owned()).collect();
        let scheduler_index = args
            .iter()
            .position(|arg| arg.starts_with("--scheduler="))
            .ok_or_else(|| {
                anyhow!("Threaded runtime requires --scheduler=<legacy runtime library>")
            })?;
        let scheduler = args
            .remove(scheduler_index)
            .trim_start_matches("--scheduler=")
            .to_owned();
        // The exported helper has supplied argv[0]. The legacy loader supplies
        // its own, so only pass the actual scheduler arguments across that ABI.
        let scheduler_args = args.into_iter().skip(1).collect::<Vec<_>>();
        Self::with_scheduler(move || {
            Scheduler::load_from_file(&scheduler, n_qubits, start, &scheduler_args)
        })
    }

    /// Construct the scheduler on the execution thread as well. The scheduler
    /// and peripheral can both use plugins with thread-local implementation state.
    pub fn with_scheduler(
        initialise: impl FnOnce() -> Result<Scheduler> + Send + 'static,
    ) -> Result<Self> {
        let (requests, receiver) = mpsc::channel::<Request>();
        let (ready, initialised) = mpsc::sync_channel(1);
        let thread = thread::Builder::new()
            .name("selene-threaded-runtime".into())
            .spawn(move || {
                let scheduler = match initialise() {
                    Ok(scheduler) => scheduler,
                    Err(error) => {
                        let _ = ready.send(Err(error));
                        return;
                    }
                };
                let mut state = State {
                    scheduler,
                    peripheral: None,
                    failure: None,
                    submitted: 0,
                };
                if ready.send(Ok(())).is_err() {
                    return;
                }
                for request in receiver {
                    request(&mut state);
                }
                let _ = state.scheduler.exit();
            })?;
        let runtime = Self {
            requests: Mutex::new(Some(requests)),
            thread: Mutex::new(Some(thread)),
        };
        initialised
            .recv()
            .map_err(|_| anyhow!("Runtime stopped during initialisation"))??;
        Ok(runtime)
    }
    fn enqueue(&self, request: Request) -> Result<()> {
        self.requests
            .lock()
            .map_err(|_| anyhow!("Runtime queue lock poisoned"))?
            .as_ref()
            .ok_or_else(|| anyhow!("Runtime has exited"))?
            .send(request)
            .map_err(|_| anyhow!("Runtime execution thread has stopped"))
    }
    fn call<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&mut State) -> Result<T> + Send + 'static,
    ) -> Result<T> {
        let (reply, result) = mpsc::sync_channel(1);
        self.enqueue(Box::new(move |state| {
            let result =
                std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| operation(state)))
                    .unwrap_or_else(|_| Err(anyhow!("Runtime execution thread callback panicked")));
            let _ = reply.send(result);
        }))?;
        result
            .recv()
            .map_err(|_| anyhow!("Runtime stopped before replying"))?
    }
    fn submit(
        &self,
        operation: impl FnOnce(&mut Scheduler) -> Result<()> + Send + 'static,
    ) -> Result<()> {
        self.enqueue(Box::new(move |state| {
            if state.failure.is_some() {
                return;
            }
            state.submitted += 1;
            if let Err(error) = operation(&mut state.scheduler) {
                state.failure = Some(format!("{error:#}"));
            }
        }))
    }
}
impl Drop for ThreadedRuntime {
    fn drop(&mut self) {
        let _ = self.exit();
    }
}
unsafe impl RuntimeInterface for ThreadedRuntime {
    fn exit(&self) -> Result<()> {
        self.requests
            .lock()
            .map_err(|_| anyhow!("Runtime queue lock poisoned"))?
            .take();
        if let Some(thread) = self
            .thread
            .lock()
            .map_err(|_| anyhow!("Runtime thread lock poisoned"))?
            .take()
        {
            thread
                .join()
                .map_err(|_| anyhow!("Runtime execution thread panicked"))?;
        }
        Ok(())
    }
    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        peripheral: QuantumPeripheralHandle,
    ) -> Result<()> {
        // Transport only the address and function pointers. The pointed-to
        // plugins were created on this worker and are never used by the caller.
        let address = peripheral.instance as usize;
        let interface = peripheral.interface;
        self.call(move |state| {
            anyhow::ensure!(state.peripheral.is_none(), "Runtime shot already active");
            state.scheduler.shot_start(shot_id, seed)?;
            state.failure = None;
            state.submitted = 0;
            state.peripheral = Some(QuantumPeripheralHandle {
                instance: address as *mut ffi::c_void,
                interface,
            });
            Ok(())
        })
    }
    fn shot_end(&self) -> Result<()> {
        self.call(|state| {
            let drained = state.drain();
            let ended = state.scheduler.shot_end();
            state.peripheral = None;
            drained.and(ended)
        })
    }
    unsafe fn on_execution_thread(
        &self,
        callback: ExecutionCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        let context = context as usize;
        self.call(move |_| {
            selene_core::utils::check_errno(
                unsafe { callback(context as *mut ffi::c_void) },
                || anyhow!("Host execution-thread callback failed"),
            )
        })
    }
    unsafe fn borrow_peripheral(
        &self,
        request: &PeripheralBorrowRequest,
        callback: PeripheralBorrowCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        anyhow::ensure!(
            request.struct_size >= size_of::<PeripheralBorrowRequest>() as u64,
            "Undersized peripheral borrow request"
        );
        let force_flush = request.force_flush;
        let context = context as usize;
        // Enqueueing under the sender lock establishes the borrow's position
        // relative to concurrent submissions. Later work stays behind it until
        // the callback has returned, even if new callers continue submitting.
        self.call(move |state| {
            if force_flush {
                state.scheduler.global_barrier(0)?;
                state.drain()?;
            }
            let peripheral = state
                .peripheral
                .ok_or_else(|| anyhow!("No quantum peripheral to borrow"))?;
            selene_core::utils::check_errno(
                unsafe { callback(context as *mut ffi::c_void, peripheral) },
                || anyhow!("Host peripheral borrow failed"),
            )
        })
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        self.call(move |state| {
            state.scheduler.force_result(result_id)?;
            state.drain()
        })
    }
    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        self.call(move |state| {
            Ok(match nth_metric {
                0 => Some((
                    "submitted_operations".into(),
                    MetricValue::U64(state.submitted),
                )),
                _ => None,
            })
        })
    }
    fn qalloc(&self) -> Result<u64> {
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.qalloc()
        })
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.qfree(qubit_id))
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        self.submit(move |scheduler| scheduler.rxy_gate(qubit_id, theta, phi))
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        self.submit(move |scheduler| scheduler.rzz_gate(qubit_id_1, qubit_id_2, theta))
    }
    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        self.submit(move |scheduler| scheduler.rpp_gate(qubit_id_1, qubit_id_2, theta, phi))
    }
    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        self.submit(move |scheduler| scheduler.rz_gate(qubit_id, theta))
    }
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.measure(qubit_id)
        })
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.measure_leaked(qubit_id)
        })
    }
    fn reset(&self, qubit_id: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.reset(qubit_id))
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.get_bool_result(result_id)
        })
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.get_u64_result(result_id)
        })
    }
    fn increment_future_refcount(&self, future: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.increment_future_refcount(future))
    }
    fn decrement_future_refcount(&self, future: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.decrement_future_refcount(future))
    }
    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        let qubits = qubits.to_vec();
        self.submit(move |scheduler| scheduler.local_barrier(&qubits, sleep_ns))
    }
    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.global_barrier(sleep_ns))
    }
    fn custom_call(&self, tag: u64, data: &[u8]) -> Result<u64> {
        let data = data.to_vec();
        self.call(move |state| {
            if let Some(error) = &state.failure {
                return Err(anyhow!("{error}"));
            }
            state.scheduler.custom_call(tag, &data)
        })
    }
    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        self.submit(move |scheduler| scheduler.simulate_delay(delay_ns))
    }
}

#[derive(Default)]
pub struct ThreadedRuntimeFactory;
impl RuntimeInterfaceFactory for ThreadedRuntimeFactory {
    type Interface = ThreadedRuntime;
    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::new(ThreadedRuntime::new(n_qubits, start, args)?))
    }
}
selene_core::export_pipeline_runtime_plugin!(ThreadedRuntimeFactory);
