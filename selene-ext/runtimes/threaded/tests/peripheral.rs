use anyhow::{Result, anyhow};
use selene_core::{
    error_model::BatchResult,
    peripheral::{
        PeripheralBorrowRequest, QuantumPeripheralFFIAdapter, QuantumPeripheralInterface,
    },
    runtime::{
        BatchOperation, Operation,
        pipeline::{self, RuntimeInterface},
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
            selene_core::runtime::Runtime::new(
                Arc::new(selene_simple_runtime::SimpleRuntimeFactory),
                8,
                0.into(),
                &args,
            )
        })
        .unwrap();
        let calls = Arc::new(Mutex::new(Vec::new()));
        let fail = Arc::new(AtomicBool::new(false));
        let recorded = calls.clone();
        let failing = fail.clone();
        let address = pipeline::on_execution_thread(&runtime, move || {
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
        }
    }
    fn start(&self, shot: u64) {
        let address = self.address;
        // This callback starts the host's shot on the execution thread, before
        // the runtime receives its peripheral. No Send bound is needed on the
        // actual peripheral: its Rc and state stay on that thread throughout.
        let (instance, interface) = pipeline::on_execution_thread(&self.runtime, move || {
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
        unsafe { self.runtime.shot_start(shot, 123, handle) }.unwrap();
    }
    fn end(&self) -> Result<()> {
        let ended = self.runtime.shot_end();
        let address = self.address;
        pipeline::on_execution_thread(&self.runtime, move || {
            unsafe { &*(address as *mut Adapter) }.inner.record("end");
            Ok(())
        })?;
        ended
    }
}
impl Drop for Fixture {
    fn drop(&mut self) {
        let address = self.address;
        pipeline::on_execution_thread(&self.runtime, move || {
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
    let q = fixture.runtime.qalloc().unwrap();
    fixture.runtime.reset(q).unwrap();
    fixture
        .runtime
        .rxy_gate(q, std::f64::consts::PI, 0.0)
        .unwrap();

    // The runtime has accepted both instructions, but its scheduler hasn't
    // sent them to the peripheral yet. A borrow without a flush must leave
    // that work pending, while still excluding simultaneous peripheral calls.
    pipeline::borrow_peripheral(
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
    pipeline::borrow_peripheral(
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
    let result = fixture.runtime.measure(q).unwrap();
    fixture.runtime.force_result(result).unwrap();
    assert_eq!(fixture.runtime.get_bool_result(result).unwrap(), Some(true));
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
                let q = runtime.qalloc().unwrap();
                runtime.reset(q).unwrap();
                runtime.rxy_gate(q, std::f64::consts::PI, 0.0).unwrap();
                let result = runtime.measure(q).unwrap();
                runtime.force_result(result).unwrap();
                assert_eq!(runtime.get_bool_result(result).unwrap(), Some(true));
                runtime.qfree(q).unwrap();
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
        pipeline::borrow_peripheral(&fixture.runtime, &Default::default(), |_| {
            Err(anyhow!("Inspection failed"))
        });
    assert!(failed.is_err());
    let panicked: Result<()> =
        pipeline::borrow_peripheral(&fixture.runtime, &Default::default(), |_| {
            panic!("Inspection panicked")
        });
    assert!(panicked.is_err());
    pipeline::borrow_peripheral(&fixture.runtime, &Default::default(), |_| Ok(())).unwrap();
    let q = fixture.runtime.qalloc().unwrap();
    fixture.fail.store(true, Ordering::Relaxed);
    fixture.runtime.reset(q).unwrap();
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
    let q = fixture.runtime.qalloc().unwrap();
    let (entered, waiting) = std::sync::mpsc::channel();
    let (resume, released) = std::sync::mpsc::channel();
    let calls = fixture.calls.clone();
    thread::scope(|scope| {
        let runtime = &fixture.runtime;
        let borrowed = scope.spawn(move || {
            pipeline::borrow_peripheral(runtime, &Default::default(), move |_| {
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
        fixture.runtime.reset(q).unwrap();
        fixture
            .runtime
            .rxy_gate(q, std::f64::consts::PI, 0.0)
            .unwrap();
        resume.send(()).unwrap();
        assert_eq!(borrowed.join().unwrap(), 812);
    });
    let result = fixture.runtime.measure(q).unwrap();
    fixture.runtime.force_result(result).unwrap();
    assert_eq!(fixture.runtime.get_bool_result(result).unwrap(), Some(true));
    fixture.end().unwrap();
}

#[test]
fn legacy_wrapper_keeps_polling_and_execution_on_the_calling_thread() {
    use selene_core::runtime::{Runtime, pipeline::LegacyRuntime};
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
    unsafe { runtime.shot_start(0, 123, adapter.ffi_interface()) }.unwrap();
    let q = runtime.qalloc().unwrap();
    runtime.reset(q).unwrap();
    assert!(calls.lock().unwrap().is_empty());
    // Libselene records the user call before this checkpoint. We should only
    // see the simulator operation now, in the same order as the old emulator.
    runtime.process_pending().unwrap();
    assert_eq!(calls.lock().unwrap().len(), 1);
    thread::scope(|scope| {
        assert!(scope.spawn(|| runtime.qalloc()).join().unwrap().is_err());
    });
    runtime.shot_end().unwrap();
    runtime.exit().unwrap();
    assert!(runtime.qalloc().is_err());
    assert!(
        calls
            .lock()
            .unwrap()
            .iter()
            .all(|(id, _)| *id == thread::current().id())
    );
}
