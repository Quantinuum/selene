use anyhow::{Result, anyhow};
use selene_core::{
    error_model::BatchResult,
    peripheral::{
        PeripheralBorrowRequest, QuantumPeripheralFFIAdapter, QuantumPeripheralInterface,
    },
    runtime::{
        self, BatchOperation, Operation, RuntimeInstruction, RuntimeInstructionResult,
        RuntimeInterface,
    },
};
use selene_threaded_runtime::ThreadedRuntime;
use std::{
    path::Path,
    rc::Rc,
    sync::{
        Arc, Mutex,
        atomic::{AtomicBool, Ordering},
    },
    thread::{self, ThreadId},
};

type Adapter = QuantumPeripheralFFIAdapter<ThreadBoundPeripheral>;

struct ThreadBoundPeripheral {
    owner: Rc<ThreadId>,
    calls: Arc<Mutex<Vec<(ThreadId, &'static str)>>>,
    fail: Arc<AtomicBool>,
    values: Vec<bool>,
}
impl ThreadBoundPeripheral {
    fn record(&self, operation: &'static str) {
        let thread = thread::current().id();
        assert_eq!(*self.owner, thread);
        self.calls.lock().unwrap().push((thread, operation));
    }
}
impl QuantumPeripheralInterface for ThreadBoundPeripheral {
    fn handle_operations(&mut self, batch: BatchOperation) -> Result<BatchResult> {
        self.record("execute");
        anyhow::ensure!(
            !self.fail.load(Ordering::Relaxed),
            "Peripheral execution failed"
        );
        let mut results = BatchResult::default();
        for operation in batch {
            match operation {
                Operation::Reset { qubit_id } => self.values[qubit_id as usize] = false,
                Operation::RXYGate { qubit_id, .. } => self.values[qubit_id as usize] ^= true,
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => results.set_bool_result(result_id, self.values[qubit_id as usize]),
                Operation::MeasureLeaked { result_id, .. } => {
                    results.set_bool_result(result_id, false)
                }
                _ => {}
            }
        }
        Ok(results)
    }
    fn dump_state(&mut self, file: &Path, _qubits: &[u64]) -> Result<()> {
        self.record("inspect");
        std::fs::write(file, if self.values[0] { "one" } else { "zero" })?;
        Ok(())
    }
}
impl Drop for ThreadBoundPeripheral {
    fn drop(&mut self) {
        self.record("drop");
    }
}

struct Fixture {
    runtime: ThreadedRuntime,
    address: usize,
    calls: Arc<Mutex<Vec<(ThreadId, &'static str)>>>,
    fail: Arc<AtomicBool>,
    output: Box<OutputLog>,
}
impl Fixture {
    fn new() -> Self {
        let args = [
            "threaded",
            "--duration-ns-rxy=0",
            "--duration-ns-rzz=0",
            "--duration-ns-rz=0",
            "--duration-ns-rpp=0",
            "--duration-ns-measure=0",
            "--duration-ns-reset=0",
            "--duration-ns-measure-leaked=0",
        ];
        let runtime = ThreadedRuntime::with_scheduler(move || {
            selene_core::runtime::v0_3::Runtime::new(
                Arc::new(selene_simple_runtime::SimpleRuntimeFactory),
                8,
                0.into(),
                &args,
            )
        })
        .unwrap();
        Self::with_runtime(runtime)
    }
    fn with_runtime(runtime: ThreadedRuntime) -> Self {
        let calls = Arc::new(Mutex::new(Vec::new()));
        let fail = Arc::new(AtomicBool::new(false));
        let recorded = calls.clone();
        let failing = fail.clone();
        let address = runtime::on_execution_thread(&runtime, move || {
            let peripheral = ThreadBoundPeripheral {
                owner: Rc::new(thread::current().id()),
                calls: recorded,
                fail: failing,
                values: vec![false; 8],
            };
            peripheral.record("create");
            Ok(Box::into_raw(Box::new(Adapter::new(peripheral))) as usize)
        })
        .unwrap();
        Self {
            runtime,
            address,
            calls,
            fail,
            output: Box::default(),
        }
    }
    fn start(&self, shot: u64) {
        let address = self.address;
        // This callback starts the host's shot on the execution thread, before
        // the runtime receives its peripheral. No Send bound is needed on the
        // actual peripheral: its Rc and state stay on that thread throughout.
        let (instance, interface) = runtime::on_execution_thread(&self.runtime, move || {
            let adapter = unsafe { &mut *(address as *mut Adapter) };
            adapter.inner.record("start");
            let handle = adapter.ffi_interface();
            Ok((handle.instance as usize, handle.interface))
        })
        .unwrap();
        let handle = selene_core::peripheral::QuantumPeripheralHandle {
            instance: instance as *mut _,
            interface,
        };
        unsafe {
            self.runtime
                .shot_start(shot, 123, handle, self.output.handle())
        }
        .unwrap();
    }
    fn end(&self) -> Result<()> {
        let ended = self.runtime.shot_end();
        let address = self.address;
        runtime::on_execution_thread(&self.runtime, move || {
            unsafe { &*(address as *mut Adapter) }.inner.record("end");
            Ok(())
        })?;
        ended
    }
}
impl Drop for Fixture {
    fn drop(&mut self) {
        let address = self.address;
        runtime::on_execution_thread(&self.runtime, move || {
            drop(unsafe { Box::from_raw(address as *mut Adapter) });
            Ok(())
        })
        .unwrap();
    }
}

#[test]
fn execution_and_scoped_borrows_stay_on_the_peripheral_thread() {
    let fixture = Fixture::new();
    let caller = thread::current().id();
    let records = fixture.calls.clone();
    fixture.start(0);
    let q = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::QAlloc)
        .and_then(RuntimeInstructionResult::into_qubit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Reset { qubit_id: q })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::RXYGate {
            qubit_id: q,
            theta: std::f64::consts::PI,
            phi: 0.0,
        })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();

    // The runtime has accepted both instructions, but its scheduler hasn't
    // sent them to the peripheral yet. A borrow without a flush must leave
    // that work pending, while still excluding simultaneous peripheral calls.
    runtime::borrow_peripheral(
        &fixture.runtime,
        &PeripheralBorrowRequest::default(),
        |_| {
            assert!(
                !records
                    .lock()
                    .unwrap()
                    .iter()
                    .any(|(_, operation)| *operation == "execute")
            );
            assert_ne!(thread::current().id(), caller);
            Ok(())
        },
    )
    .unwrap();

    let path = std::env::temp_dir().join(format!("selene-peripheral-{}.state", std::process::id()));
    runtime::borrow_peripheral(
        &fixture.runtime,
        &PeripheralBorrowRequest {
            force_flush: true,
            ..Default::default()
        },
        |peripheral| peripheral.dump_state(&path, &[q]),
    )
    .unwrap();
    assert_eq!(std::fs::read_to_string(&path).unwrap(), "one");
    std::fs::remove_file(path).unwrap();
    let result = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Measure { qubit_id: q })
        .and_then(RuntimeInstructionResult::into_future)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::ForceResult { result_id: result })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    assert_eq!(
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::GetBoolResult { result_id: result })
            .and_then(RuntimeInstructionResult::into_bool)
            .unwrap(),
        Some(true)
    );
    fixture.end().unwrap();
    fixture.start(1);
    fixture.end().unwrap();
    drop(fixture);

    let records = records.lock().unwrap();
    let owner = records[0].0;
    assert_ne!(owner, caller);
    assert!(records.iter().all(|(thread, _)| *thread == owner));
    assert_eq!(records.last().unwrap().1, "drop");
    assert_eq!(records.iter().filter(|(_, call)| *call == "end").count(), 2);
}

#[test]
fn concurrent_submitters_can_wait_for_their_own_measurements() {
    let fixture = Fixture::new();
    fixture.start(0);
    thread::scope(|scope| {
        for _ in 0..8 {
            let runtime = &fixture.runtime;
            scope.spawn(move || {
                let q = runtime
                    .handle_instruction(RuntimeInstruction::QAlloc)
                    .and_then(RuntimeInstructionResult::into_qubit)
                    .unwrap();
                runtime
                    .handle_instruction(RuntimeInstruction::Reset { qubit_id: q })
                    .and_then(RuntimeInstructionResult::into_unit)
                    .unwrap();
                runtime
                    .handle_instruction(RuntimeInstruction::RXYGate {
                        qubit_id: q,
                        theta: std::f64::consts::PI,
                        phi: 0.0,
                    })
                    .and_then(RuntimeInstructionResult::into_unit)
                    .unwrap();
                let result = runtime
                    .handle_instruction(RuntimeInstruction::Measure { qubit_id: q })
                    .and_then(RuntimeInstructionResult::into_future)
                    .unwrap();
                runtime
                    .handle_instruction(RuntimeInstruction::ForceResult { result_id: result })
                    .and_then(RuntimeInstructionResult::into_unit)
                    .unwrap();
                assert_eq!(
                    runtime
                        .handle_instruction(RuntimeInstruction::GetBoolResult { result_id: result })
                        .and_then(RuntimeInstructionResult::into_bool)
                        .unwrap(),
                    Some(true)
                );
                runtime
                    .handle_instruction(RuntimeInstruction::QFree { qubit_id: q })
                    .and_then(RuntimeInstructionResult::into_unit)
                    .unwrap();
            });
        }
    });
    fixture.end().unwrap();
}

#[test]
fn failed_borrows_release_access_and_failed_shots_return_the_peripheral() {
    let fixture = Fixture::new();
    fixture.start(0);
    let failed: Result<()> =
        runtime::borrow_peripheral(&fixture.runtime, &Default::default(), |_| {
            Err(anyhow!("Inspection failed"))
        });
    assert!(failed.is_err());
    let panicked: Result<()> =
        runtime::borrow_peripheral(&fixture.runtime, &Default::default(), |_| {
            panic!("Inspection panicked")
        });
    assert!(panicked.is_err());
    runtime::borrow_peripheral(&fixture.runtime, &Default::default(), |_| Ok(())).unwrap();
    let q = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::QAlloc)
        .and_then(RuntimeInstructionResult::into_qubit)
        .unwrap();
    fixture.fail.store(true, Ordering::Relaxed);
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Reset { qubit_id: q })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    assert!(fixture.end().is_err());
    // Even though execution failed, shot_end has released the handle and the
    // host can end this shot, then start another one with the same peripheral.
    fixture.fail.store(false, Ordering::Relaxed);
    fixture.start(1);
    fixture.end().unwrap();
}

#[test]
fn a_borrow_excludes_execution_while_new_submissions_can_queue() {
    let fixture = Fixture::new();
    fixture.start(0);
    let q = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::QAlloc)
        .and_then(RuntimeInstructionResult::into_qubit)
        .unwrap();
    let (entered, waiting) = std::sync::mpsc::channel();
    let (resume, released) = std::sync::mpsc::channel();
    let calls = fixture.calls.clone();
    thread::scope(|scope| {
        let runtime = &fixture.runtime;
        let borrowed = scope.spawn(move || {
            runtime::borrow_peripheral(runtime, &Default::default(), move |_| {
                entered.send(()).unwrap();
                released
                    .recv_timeout(std::time::Duration::from_secs(5))
                    .unwrap();
                assert!(
                    !calls
                        .lock()
                        .unwrap()
                        .iter()
                        .any(|(_, call)| *call == "execute")
                );
                Ok(812)
            })
            .unwrap()
        });
        waiting
            .recv_timeout(std::time::Duration::from_secs(5))
            .unwrap();
        // These submissions must be accepted without waiting for the borrow's
        // callback. They must not execute while it still has exclusive access.
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::Reset { qubit_id: q })
            .and_then(RuntimeInstructionResult::into_unit)
            .unwrap();
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::RXYGate {
                qubit_id: q,
                theta: std::f64::consts::PI,
                phi: 0.0,
            })
            .and_then(RuntimeInstructionResult::into_unit)
            .unwrap();
        resume.send(()).unwrap();
        assert_eq!(borrowed.join().unwrap(), 812);
    });
    let result = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Measure { qubit_id: q })
        .and_then(RuntimeInstructionResult::into_future)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::ForceResult { result_id: result })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    assert_eq!(
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::GetBoolResult { result_id: result })
            .and_then(RuntimeInstructionResult::into_bool)
            .unwrap(),
        Some(true)
    );
    fixture.end().unwrap();
}

#[test]
fn legacy_wrapper_keeps_polling_and_execution_on_the_calling_thread() {
    use selene_core::runtime::{adapters::LegacyRuntime, v0_3::Runtime};
    let args = [
        "simple",
        "--duration-ns-rxy=0",
        "--duration-ns-rzz=0",
        "--duration-ns-rz=0",
        "--duration-ns-rpp=0",
        "--duration-ns-measure=0",
        "--duration-ns-reset=0",
        "--duration-ns-measure-leaked=0",
    ];
    let runtime = LegacyRuntime::new(
        Runtime::new(
            Arc::new(selene_simple_runtime::SimpleRuntimeFactory),
            1,
            0.into(),
            &args,
        )
        .unwrap(),
    );
    let calls = Arc::new(Mutex::new(Vec::new()));
    let mut adapter = Adapter::new(ThreadBoundPeripheral {
        owner: Rc::new(thread::current().id()),
        calls: calls.clone(),
        fail: Arc::new(AtomicBool::new(false)),
        values: vec![false],
    });
    unsafe { runtime.shot_start(0, 123, adapter.ffi_interface(), discard_output()) }.unwrap();
    let q = runtime
        .handle_instruction(RuntimeInstruction::QAlloc)
        .and_then(RuntimeInstructionResult::into_qubit)
        .unwrap();
    runtime
        .handle_instruction(RuntimeInstruction::Reset { qubit_id: q })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    assert!(calls.lock().unwrap().is_empty());
    // Libselene records the user call before this checkpoint. We should only
    // see the simulator operation now, in the same order as the old emulator.
    runtime.process_pending().unwrap();
    assert_eq!(calls.lock().unwrap().len(), 1);
    thread::scope(|scope| {
        assert!(
            scope
                .spawn(|| runtime
                    .handle_instruction(RuntimeInstruction::QAlloc)
                    .and_then(RuntimeInstructionResult::into_qubit))
                .join()
                .unwrap()
                .is_err()
        );
    });
    runtime.shot_end().unwrap();
    runtime.destroy().unwrap();
    assert!(
        runtime
            .handle_instruction(RuntimeInstruction::QAlloc)
            .and_then(RuntimeInstructionResult::into_qubit)
            .is_err()
    );
    assert!(
        calls
            .lock()
            .unwrap()
            .iter()
            .all(|(id, _)| *id == thread::current().id())
    );
}

unsafe extern "C" fn flush_output(_: *mut std::ffi::c_void) -> i32 {
    0
}

fn discard_output() -> runtime::output::OutputSinkHandle {
    unsafe extern "C" fn write(
        _: *mut std::ffi::c_void,
        _: u64,
        _: *const runtime::output::PrintRequestRaw,
        _: u64,
    ) -> i32 {
        0
    }
    runtime::output::OutputSinkHandle {
        context: std::ptr::null_mut(),
        write_fn: Some(write),
        flush_fn: Some(flush_output),
    }
}

#[derive(Default)]
struct OutputLog {
    records: Mutex<Vec<(ThreadId, Vec<runtime::output::PrintRequest>)>>,
    pause_exit: Option<(Arc<std::sync::Barrier>, Arc<std::sync::Barrier>)>,
    fail: AtomicBool,
    fail_flush: AtomicBool,
    flushes: std::sync::atomic::AtomicUsize,
}
impl OutputLog {
    fn handle(&self) -> runtime::output::OutputSinkHandle {
        unsafe extern "C" fn write(
            context: *mut std::ffi::c_void,
            _: u64,
            records: *const runtime::output::PrintRequestRaw,
            length: u64,
        ) -> i32 {
            runtime::callback_result(|| {
                let log = unsafe { &*context.cast::<OutputLog>() };
                let records = unsafe { std::slice::from_raw_parts(records, length as usize) }
                    .iter()
                    .map(|raw| unsafe { runtime::output::PrintRequest::from_raw(raw) })
                    .collect::<Result<Vec<_>>>()?;
                if records[0].tag.starts_with("EXIT:")
                    && let Some((entered, release)) = &log.pause_exit
                {
                    entered.wait();
                    release.wait();
                }
                log.records
                    .lock()
                    .unwrap()
                    .push((thread::current().id(), records));
                anyhow::ensure!(!log.fail.load(Ordering::Relaxed), "Printer failed");
                Ok(())
            })
        }
        unsafe extern "C" fn flush(context: *mut std::ffi::c_void) -> i32 {
            runtime::callback_result(|| {
                let log = unsafe { &*context.cast::<OutputLog>() };
                log.flushes.fetch_add(1, Ordering::Relaxed);
                anyhow::ensure!(
                    !log.fail_flush.load(Ordering::Relaxed),
                    "Output flush failed"
                );
                Ok(())
            })
        }
        runtime::output::OutputSinkHandle {
            context: (self as *const Self).cast_mut().cast(),
            write_fn: Some(write),
            flush_fn: Some(flush),
        }
    }
}

#[test]
fn exit_finishes_quantum_work_and_output_before_returning() {
    use runtime::output::{ExitRequest, PrintRequest};
    let fixture = Fixture::new();
    fixture.start(0);
    let qubit = fixture
        .runtime
        .handle_instruction(RuntimeInstruction::QAlloc)
        .and_then(RuntimeInstructionResult::into_qubit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Reset { qubit_id: qubit })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::RXYGate {
            qubit_id: qubit,
            theta: std::f64::consts::PI,
            phi: 0.0,
        })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Print {
            request: PrintRequest::new("USER:array", &[42u64, 64][..]),
        })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();
    fixture
        .runtime
        .handle_instruction(RuntimeInstruction::Exit {
            request: ExitRequest {
                error_code: 1001,
                message: "stopped".into(),
                backtrace: vec![PrintRequest::new("DEBUG:BACKTRACE:program", 123u64)],
            },
        })
        .and_then(RuntimeInstructionResult::into_unit)
        .unwrap();

    // Exit must execute the pending gates even though we never requested a
    // measurement. It must also write the preceding print and the complete
    // diagnostic before returning to C, where the program can jump away.
    assert!(
        fixture
            .calls
            .lock()
            .unwrap()
            .iter()
            .any(|(_, op)| *op == "execute")
    );
    let records = fixture.output.records.lock().unwrap();
    assert_eq!(records.len(), 2);
    assert_eq!(
        records[0].1,
        vec![PrintRequest::new("USER:array", &[42u64, 64][..])]
    );
    assert_eq!(
        records[1].1[0],
        PrintRequest::new("EXIT:INT:stopped", 1001u64)
    );
    assert_eq!(
        records[1].1[1],
        PrintRequest::new("DEBUG:BACKTRACE:program", 123u64)
    );
    assert!(
        records
            .iter()
            .all(|(owner, _)| *owner != thread::current().id())
    );
    drop(records);
    assert_eq!(fixture.output.flushes.load(Ordering::Relaxed), 1);
    assert!(
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::Reset { qubit_id: qubit })
            .and_then(RuntimeInstructionResult::into_unit)
            .is_err()
    );
    fixture.end().unwrap();
    fixture.start(1);
    assert!(
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::QAlloc)
            .and_then(RuntimeInstructionResult::into_qubit)
            .is_ok()
    );
    fixture.end().unwrap();
}

#[test]
fn exit_closes_concurrent_submissions_before_waiting_for_output() {
    let mut fixture = Fixture::new();
    let entered = Arc::new(std::sync::Barrier::new(2));
    let release = Arc::new(std::sync::Barrier::new(2));
    fixture.output.pause_exit = Some((entered.clone(), release.clone()));
    fixture.start(0);
    thread::scope(|scope| {
        let runtime = &fixture.runtime;
        let exiting = scope.spawn(move || {
            runtime
                .handle_instruction(RuntimeInstruction::Exit {
                    request: runtime::output::ExitRequest {
                        error_code: 0,
                        message: "done".into(),
                        backtrace: Vec::new(),
                    },
                })
                .and_then(RuntimeInstructionResult::into_unit)
        });
        entered.wait();
        // The printer is still running on the execution thread. New calls
        // must fail immediately, rather than queue behind this exit or wait
        // for the printer to finish.
        let (reply, result) = std::sync::mpsc::channel();
        let submitting = scope.spawn(move || {
            let allocation_rejected = runtime
                .handle_instruction(RuntimeInstruction::QAlloc)
                .and_then(RuntimeInstructionResult::into_qubit)
                .is_err();
            let print_rejected = runtime
                .handle_instruction(RuntimeInstruction::Print {
                    request: runtime::output::PrintRequest::new("late", 1u64),
                })
                .and_then(RuntimeInstructionResult::into_unit)
                .is_err();
            reply.send((allocation_rejected, print_rejected)).unwrap();
        });
        let rejected = result.recv_timeout(std::time::Duration::from_secs(2));
        release.wait();
        submitting.join().unwrap();
        assert_eq!(rejected.unwrap(), (true, true));
        exiting.join().unwrap().unwrap();
    });
    fixture.end().unwrap();
}

#[test]
fn a_failed_exit_still_allows_shot_end_and_the_next_shot() {
    for failure in 0..3 {
        let fixture = Fixture::new();
        fixture.start(0);
        let qubit = fixture
            .runtime
            .handle_instruction(RuntimeInstruction::QAlloc)
            .and_then(RuntimeInstructionResult::into_qubit)
            .unwrap();
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::Reset { qubit_id: qubit })
            .and_then(RuntimeInstructionResult::into_unit)
            .unwrap();
        fixture.fail.store(failure == 0, Ordering::Relaxed);
        fixture.output.fail.store(failure == 1, Ordering::Relaxed);
        fixture
            .output
            .fail_flush
            .store(failure == 2, Ordering::Relaxed);
        assert!(
            fixture
                .runtime
                .handle_instruction(RuntimeInstruction::Exit {
                    request: runtime::output::ExitRequest {
                        error_code: 1001,
                        message: "original failure".into(),
                        backtrace: Vec::new(),
                    }
                })
                .and_then(RuntimeInstructionResult::into_unit)
                .is_err()
        );
        // A failed quantum flush mustn't suppress the original panic. A failed
        // printer mustn't leave the runtime waiting for another acknowledgement.
        assert_eq!(fixture.output.records.lock().unwrap().len(), 1);
        assert!(fixture.end().is_err());
        fixture.fail.store(false, Ordering::Relaxed);
        fixture.output.fail.store(false, Ordering::Relaxed);
        fixture.output.fail_flush.store(false, Ordering::Relaxed);
        fixture.start(1);
        let qubit = fixture
            .runtime
            .handle_instruction(RuntimeInstruction::QAlloc)
            .and_then(RuntimeInstructionResult::into_qubit)
            .unwrap();
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::Reset { qubit_id: qubit })
            .and_then(RuntimeInstructionResult::into_unit)
            .unwrap();
        fixture.end().unwrap();
    }
}

struct CustomCallScheduler(selene_core::runtime::v0_3::Runtime);
impl selene_core::runtime::v0_3::RuntimeInterface for CustomCallScheduler {
    fn custom_call(&mut self, _tag: u64, _data: &[u8]) -> Result<u64> {
        self.0.rxy_gate(0, std::f64::consts::PI, 0.0)?;
        self.0.measure(0)
    }
    fn exit(&mut self) -> Result<()> {
        self.0.exit()
    }
    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        self.0.get_next_operations()
    }
    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        self.0.shot_start(shot_id, seed)
    }
    fn shot_end(&mut self) -> Result<()> {
        self.0.shot_end()
    }
    fn get_metric(
        &mut self,
        nth_metric: u8,
    ) -> Result<Option<(String, selene_core::utils::MetricValue)>> {
        self.0.get_metric(nth_metric)
    }
    fn qalloc(&mut self) -> Result<u64> {
        self.0.qalloc()
    }
    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        self.0.qfree(qubit_id)
    }
    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        self.0.measure(qubit_id)
    }
    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        self.0.measure_leaked(qubit_id)
    }
    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        self.0.reset(qubit_id)
    }
    fn force_result(&mut self, result_id: u64) -> Result<()> {
        self.0.force_result(result_id)
    }
    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        self.0.get_bool_result(result_id)
    }
    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        self.0.get_u64_result(result_id)
    }
    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        self.0.set_bool_result(result_id, result)
    }
    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        self.0.set_u64_result(result_id, result)
    }
    fn increment_future_refcount(&mut self, future: u64) -> Result<()> {
        self.0.increment_future_refcount(future)
    }
    fn decrement_future_refcount(&mut self, future: u64) -> Result<()> {
        self.0.decrement_future_refcount(future)
    }
    fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        self.0.local_barrier(qubits, sleep_ns)
    }
    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        self.0.global_barrier(sleep_ns)
    }
}

#[test]
fn custom_calls_execute_their_batches_before_returning() {
    for fail in [false, true] {
        let runtime = ThreadedRuntime::with_scheduler(|| {
            let scheduler = selene_core::runtime::v0_3::Runtime::new(
                Arc::new(selene_simple_runtime::SimpleRuntimeFactory),
                1,
                0.into(),
                &[
                    "custom-call-test",
                    "--duration-ns-rxy=0",
                    "--duration-ns-rzz=0",
                    "--duration-ns-rz=0",
                    "--duration-ns-rpp=0",
                    "--duration-ns-measure=0",
                    "--duration-ns-reset=0",
                    "--duration-ns-measure-leaked=0",
                ],
            )?;
            Ok(selene_core::runtime::v0_3::Runtime::from_boxed(Box::new(
                CustomCallScheduler(scheduler),
            )))
        })
        .unwrap();
        let fixture = Fixture::with_runtime(runtime);
        fixture.start(0);
        fixture
            .runtime
            .handle_instruction(RuntimeInstruction::QAlloc)
            .unwrap();
        fixture.fail.store(fail, Ordering::Relaxed);

        // Our custom call queues an X and a measurement in separate batches.
        // We should be able to read that measurement as soon as the call returns,
        // without forcing the result or borrowing the peripheral to flush it.
        let result = fixture
            .runtime
            .handle_instruction(RuntimeInstruction::CustomCall {
                tag: 0,
                data: vec![],
            });
        if fail {
            // If execution fails, the caller must hear about it during the
            // custom call, rather than finding out at the end of the shot.
            assert!(result.is_err());
            assert!(fixture.end().is_err());
        } else {
            let result_id = result.unwrap().into_u64().unwrap().unwrap();
            assert_eq!(
                fixture
                    .runtime
                    .handle_instruction(RuntimeInstruction::GetBoolResult { result_id })
                    .and_then(RuntimeInstructionResult::into_bool)
                    .unwrap(),
                Some(true),
            );
            assert_eq!(
                fixture
                    .calls
                    .lock()
                    .unwrap()
                    .iter()
                    .filter(|(_, call)| *call == "execute")
                    .count(),
                2
            );
            fixture.end().unwrap();
        }
    }
}
