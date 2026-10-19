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
        pipeline::{
            ExecutionCallback, RuntimeInstruction, RuntimeInstructionResult, RuntimeInterface,
            RuntimeInterfaceFactory, output::OutputSinkHandle,
        },
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
    output: Option<OutputSinkHandle>,
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
    fn handle_instruction(
        &mut self,
        instruction: RuntimeInstruction,
    ) -> Result<RuntimeInstructionResult> {
        use RuntimeInstruction as I;
        use RuntimeInstructionResult as R;
        if let I::Exit { request } = instruction {
            // Even if earlier work failed, attempt the original diagnostic.
            // This worker performs all execution itself, so returning this reply
            // also guarantees that no background peripheral access remains.
            let flushed = self.scheduler.global_barrier(0).and_then(|_| self.drain());
            let printed = unsafe {
                self.output
                    .ok_or_else(|| anyhow!("No output sink"))?
                    .print(0, &request.records())
            };
            let output_flushed = unsafe { self.output.unwrap().flush() };
            flushed.and(printed).and(output_flushed)?;
            return Ok(R::None);
        }
        if let Some(error) = &self.failure {
            return Err(anyhow!("{error}"));
        }
        self.submitted += 1;
        match instruction {
            I::QAlloc => Ok(R::Qubit(self.scheduler.qalloc()?)),
            I::QFree { qubit_id } => {
                self.scheduler.qfree(qubit_id)?;
                Ok(R::None)
            }
            I::RXYGate {
                qubit_id,
                theta,
                phi,
            } => {
                self.scheduler.rxy_gate(qubit_id, theta, phi)?;
                Ok(R::None)
            }
            I::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            } => {
                self.scheduler.rzz_gate(qubit_id_1, qubit_id_2, theta)?;
                Ok(R::None)
            }
            I::RZGate { qubit_id, theta } => {
                self.scheduler.rz_gate(qubit_id, theta)?;
                Ok(R::None)
            }
            I::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            } => {
                self.scheduler
                    .rpp_gate(qubit_id_1, qubit_id_2, theta, phi)?;
                Ok(R::None)
            }
            I::Measure { qubit_id } => Ok(R::Future(self.scheduler.measure(qubit_id)?)),
            I::MeasureLeaked { qubit_id } => {
                Ok(R::Future(self.scheduler.measure_leaked(qubit_id)?))
            }
            I::Reset { qubit_id } => {
                self.scheduler.reset(qubit_id)?;
                Ok(R::None)
            }
            I::ForceResult { result_id } => {
                self.scheduler.force_result(result_id)?;
                self.drain()?;
                Ok(R::None)
            }
            I::GetBoolResult { result_id } => {
                Ok(R::Bool(self.scheduler.get_bool_result(result_id)?))
            }
            I::GetU64Result { result_id } => Ok(R::U64(self.scheduler.get_u64_result(result_id)?)),
            I::IncrementFutureRefcount { future } => {
                self.scheduler.increment_future_refcount(future)?;
                Ok(R::None)
            }
            I::DecrementFutureRefcount { future } => {
                self.scheduler.decrement_future_refcount(future)?;
                Ok(R::None)
            }
            I::LocalBarrier { qubits, sleep_ns } => {
                self.scheduler.local_barrier(&qubits, sleep_ns)?;
                Ok(R::None)
            }
            I::GlobalBarrier { sleep_ns } => {
                self.scheduler.global_barrier(sleep_ns)?;
                Ok(R::None)
            }
            I::CustomCall { tag, data } => {
                Ok(R::U64(Some(self.scheduler.custom_call(tag, &data)?)))
            }
            I::SimulateDelay { delay_ns } => {
                self.scheduler.simulate_delay(delay_ns)?;
                Ok(R::None)
            }
            I::Print { request } => {
                unsafe {
                    self.output
                        .ok_or_else(|| anyhow!("No output sink"))?
                        .print(0, &[request])?;
                }
                Ok(R::None)
            }
            I::Exit { .. } => unreachable!(),
        }
    }
}

struct Queue {
    sender: Option<mpsc::Sender<Request>>,
    program_open: bool,
}

pub struct ThreadedRuntime {
    requests: Mutex<Queue>,
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
                    output: None,
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
            requests: Mutex::new(Queue {
                sender: Some(requests),
                program_open: false,
            }),
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
            .sender
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
}
impl Drop for ThreadedRuntime {
    fn drop(&mut self) {
        let _ = self.destroy();
    }
}
unsafe impl RuntimeInterface for ThreadedRuntime {
    fn destroy(&self) -> Result<()> {
        self.requests
            .lock()
            .map_err(|_| anyhow!("Runtime queue lock poisoned"))?
            .sender
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
        output: OutputSinkHandle,
    ) -> Result<()> {
        // Transport only the address and function pointers. The pointed-to
        // plugins were created on this worker and are never used by the caller.
        let address = peripheral.instance as usize;
        let interface = peripheral.interface;
        self.call(move |state| {
            anyhow::ensure!(state.peripheral.is_none(), "Runtime shot already active");
            state.scheduler.shot_start(shot_id, seed)?;
            state.failure = None;
            state.output = Some(output);
            state.submitted = 0;
            state.peripheral = Some(QuantumPeripheralHandle {
                instance: address as *mut ffi::c_void,
                interface,
            });
            Ok(())
        })?;
        self.requests
            .lock()
            .map_err(|_| anyhow!("Runtime queue lock poisoned"))?
            .program_open = true;
        Ok(())
    }
    fn shot_end(&self) -> Result<()> {
        self.requests
            .lock()
            .map_err(|_| anyhow!("Runtime queue lock poisoned"))?
            .program_open = false;
        self.call(|state| {
            let drained = state.drain();
            let ended = state.scheduler.shot_end();
            state.peripheral = None;
            state.output = None;
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
    fn handle_instruction(
        &self,
        instruction: RuntimeInstruction,
    ) -> Result<RuntimeInstructionResult> {
        use RuntimeInstruction as I;
        let is_exit = matches!(&instruction, I::Exit { .. });
        let synchronous = matches!(
            &instruction,
            I::QAlloc
                | I::Measure { .. }
                | I::MeasureLeaked { .. }
                | I::ForceResult { .. }
                | I::GetBoolResult { .. }
                | I::GetU64Result { .. }
                | I::CustomCall { .. }
                | I::Exit { .. }
        );
        let (reply, result) = mpsc::sync_channel(1);
        {
            // Exit closes submissions under the same lock that orders requests.
            // Nothing accepted afterwards can land behind it on the worker.
            let mut queue = self
                .requests
                .lock()
                .map_err(|_| anyhow!("Runtime queue lock poisoned"))?;
            anyhow::ensure!(queue.program_open, "Program is not accepting instructions");
            if is_exit {
                queue.program_open = false;
            }
            queue
                .sender
                .as_ref()
                .ok_or_else(|| anyhow!("Runtime has exited"))?
                .send(Box::new(move |state| {
                    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                        state.handle_instruction(instruction)
                    }))
                    .unwrap_or_else(|_| Err(anyhow!("Runtime instruction panicked")));
                    if let Err(error) = &outcome {
                        state.failure = Some(format!("{error:#}"));
                    }
                    if synchronous {
                        let _ = reply.send(outcome);
                    }
                }))
                .map_err(|_| anyhow!("Runtime execution thread has stopped"))?;
        }
        if synchronous {
            result
                .recv()
                .map_err(|_| anyhow!("Runtime stopped before replying"))?
        } else {
            Ok(RuntimeInstructionResult::None)
        }
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
