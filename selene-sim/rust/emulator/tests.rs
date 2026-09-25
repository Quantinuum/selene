use super::*;
use crate::{ffi_interface::*, selene_instance::SeleneInstance};
use consumer::State;
use parking_lot::{Condvar, Mutex};
use selene_core::{
    encoder::{InternalBuffer, OutputStream, OutputWriter},
    error_model::{ErrorModel, ErrorModelInterface},
    runtime::Operation as RuntimeOp,
    simulator::Simulator,
    utils::MetricValue,
};
use std::{
    collections::{BTreeMap, VecDeque},
    rc::Rc,
    sync::{
        Barrier,
        atomic::{AtomicBool, AtomicU64, Ordering},
    },
    thread::{self, ThreadId},
    time::Duration,
};

#[derive(Default)]
struct RuntimeState {
    queue: VecDeque<BatchOperation>,
    results: BTreeMap<u64, u64>,
    consumer: Option<ThreadId>,
    released: bool,
    waiting: bool,
}

#[derive(Default)]
struct TestRuntime {
    state: Mutex<RuntimeState>,
    ready: Condvar,
    next: AtomicU64,
    fail: AtomicBool,
}

impl RuntimeInterface for TestRuntime {
    fn exit(&self) -> Result<()> {
        Ok(())
    }
    fn shot_start(&self, _: u64, _: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&self) -> Result<()> {
        Ok(())
    }
    fn get_metric(&self, _: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        anyhow::ensure!(!self.fail.load(Ordering::Relaxed), "consumer failure");
        let mut state = self.state.lock();
        let current = thread::current().id();
        assert_eq!(*state.consumer.get_or_insert(current), current);
        Ok(state.queue.pop_front())
    }
    fn qalloc(&self) -> Result<u64> {
        Ok(self.next.fetch_add(1, Ordering::Relaxed))
    }
    fn qfree(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn rz_gate(&self, q: u64, theta: f64) -> Result<()> {
        self.state
            .lock()
            .queue
            .push_back(BatchOperation::simulator(vec![RuntimeOp::RZGate {
                qubit_id: q,
                theta,
            }]));
        Ok(())
    }
    fn measure(&self, q: u64) -> Result<u64> {
        let id = self.next.fetch_add(1, Ordering::Relaxed);
        self.state
            .lock()
            .queue
            .push_back(BatchOperation::simulator(vec![RuntimeOp::Measure {
                qubit_id: q,
                result_id: id,
            }]));
        Ok(id)
    }
    fn measure_leaked(&self, q: u64) -> Result<u64> {
        self.measure(q)
    }
    fn reset(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn force_result(&self, _: u64) -> Result<()> {
        // Measurements are ready to collect as soon as they are queued.
        // The consumer will execute them when the caller asks it to process work.
        Ok(())
    }
    fn get_bool_result(&self, id: u64) -> Result<Option<bool>> {
        Ok(self.get_u64_result(id)?.map(|v| v != 0))
    }
    fn get_u64_result(&self, id: u64) -> Result<Option<u64>> {
        Ok(self.state.lock().results.get(&id).copied())
    }
    fn set_bool_result(&self, id: u64, value: bool) -> Result<()> {
        self.set_u64_result(id, value.into())
    }
    fn set_u64_result(&self, id: u64, value: u64) -> Result<()> {
        self.state.lock().results.insert(id, value);
        self.ready.notify_all();
        Ok(())
    }
    fn increment_future_refcount(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn decrement_future_refcount(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn local_barrier(&self, _: &[u64], _: u64) -> Result<()> {
        Ok(())
    }
    fn global_barrier(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn custom_call(&self, tag: u64, _: &[u8]) -> Result<u64> {
        match tag {
            0 => {
                let mut state = self.state.lock();
                state.waiting = true;
                self.ready.notify_all();
                self.ready
                    .wait_while_for(&mut state, |s| !s.released, Duration::from_secs(5));
                anyhow::ensure!(state.released, "another QIS caller could not make progress");
                Ok(42)
            }
            1 => {
                let mut state = self.state.lock();
                self.ready
                    .wait_while_for(&mut state, |s| !s.waiting, Duration::from_secs(5));
                anyhow::ensure!(state.waiting, "waiting QIS caller could not enter runtime");
                state.released = true;
                self.ready.notify_all();
                Ok(0)
            }
            3 => {
                self.fail.store(true, Ordering::Relaxed);
                Ok(0)
            }
            // Queue the measurement before the caller asks the consumer to run it.
            _ => self.measure(0),
        }
    }
}

struct ThreadAffineSimulator {
    owner: Rc<ThreadId>,
    dropped: Arc<AtomicBool>,
}
impl ThreadAffineSimulator {
    fn check(&self) {
        assert_eq!(*self.owner, thread::current().id());
    }
}
impl Drop for ThreadAffineSimulator {
    fn drop(&mut self) {
        self.check();
        self.dropped.store(true, Ordering::Relaxed);
    }
}
impl SimulatorInterface for ThreadAffineSimulator {
    fn exit(&mut self) -> Result<()> {
        self.check();
        Ok(())
    }
    fn shot_start(&mut self, _: u64, _: u64) -> Result<()> {
        self.check();
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        self.check();
        Ok(())
    }
    fn get_metric(&mut self, _: u8) -> Result<Option<(String, MetricValue)>> {
        self.check();
        Ok(None)
    }
    fn handle_operations(&mut self, batch: BatchOperation) -> Result<BatchResult> {
        self.check();
        let mut results = BatchResult::default();
        for op in batch {
            if let RuntimeOp::Measure { result_id, .. } = op {
                results.set_bool_result(result_id, true);
            }
        }
        Ok(results)
    }
}
struct Passthrough;
impl ErrorModelInterface for Passthrough {
    fn exit(&mut self) -> Result<()> {
        Ok(())
    }
    fn shot_start(&mut self, _: u64, _: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        Ok(())
    }
    fn get_metric(&mut self, _: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn handle_operations(
        &mut self,
        batch: BatchOperation,
        simulator: &mut dyn SimulatorInterface,
    ) -> Result<BatchResult> {
        simulator.handle_operations(batch)
    }
}

fn instance() -> (SeleneInstance, Arc<AtomicBool>) {
    let runtime = Arc::new(Runtime::from_boxed(Box::<TestRuntime>::default()));
    let hooks = SharedEventHook::default();
    let dropped = Arc::new(AtomicBool::new(false));
    let consumer = {
        let runtime = runtime.clone();
        let hooks = hooks.clone();
        let dropped = dropped.clone();
        Consumer::spawn(move || {
            Ok(State {
                runtime,
                simulator: Simulator::from_boxed(Box::new(ThreadAffineSimulator {
                    owner: Rc::new(thread::current().id()),
                    dropped,
                })),
                error_model: ErrorModel::from_boxed(Box::new(Passthrough)),
                hooks,
                failure: None,
            })
        })
        .unwrap()
    };
    let config: Configuration = serde_yml::from_str(
        r#"
n_qubits: 16
output_stream: internal
artifact_dir: /tmp
simulator: {name: test, file: unused, args: []}
error_model: {name: test, file: unused, args: []}
runtime: {name: test, file: unused, args: []}
event_hooks: {}
shots: {count: 1, offset: 0, increment: 1}
seed_mode: default
"#,
    )
    .unwrap();
    (
        SeleneInstance {
            config,
            emulator: Emulator {
                runtime,
                consumer,
                event_hooks: hooks,
            },
            out_encoder: Mutex::new(OutputStream::new(OutputWriter::Internal(
                InternalBuffer::default(),
            ))),
            time_cursor: AtomicU64::new(0),
            shot_number: 0,
            prng: Mutex::new(None),
            state_dump_lock: Mutex::new(()),
        },
        dropped,
    )
}

fn pointer(instance: &SeleneInstance) -> *mut SeleneInstance {
    std::ptr::from_ref(instance).cast_mut()
}

#[test]
fn concurrent_qis_and_output_use_one_consumer() {
    fn assert_send_sync<T: Send + Sync>() {}
    assert_send_sync::<SeleneInstance>();
    let (mut instance, dropped) = instance();
    instance.shot_start(0).unwrap();
    instance.random_seed(123);
    let start = Barrier::new(8);
    thread::scope(|scope| {
        for _ in 0..8 {
            let instance = &instance;
            let start = &start;
            scope.spawn(move || unsafe {
                let ptr = pointer(instance);
                start.wait();
                let q = selene_qalloc(ptr);
                assert_eq!(q.error_code, 0);
                for _ in 0..32 {
                    assert_eq!(selene_rz(ptr, q.value, 0.5).error_code, 0);
                    let result = selene_qubit_lazy_measure(ptr, q.value);
                    assert_eq!(result.error_code, 0);
                    assert_eq!(
                        selene_refcount_increment(ptr, result.reference).error_code,
                        0
                    );
                    let measured = selene_future_read_bool(ptr, result.reference);
                    assert_eq!(measured.error_code, 0);
                    assert!(measured.value);
                    assert_eq!(selene_future_read_u64(ptr, result.reference).value, 1);
                    assert_eq!(
                        selene_refcount_decrement(ptr, result.reference).error_code,
                        0
                    );
                    assert_eq!(
                        selene_refcount_decrement(ptr, result.reference).error_code,
                        0
                    );
                    assert_eq!(selene_random_u32(ptr).error_code, 0);
                    let tag = WrappedString {
                        data: c"value".as_ptr(),
                        length: 5,
                        owned: false,
                    };
                    assert_eq!(selene_print_u64(ptr, tag, q.value).error_code, 0);
                }
                assert_eq!(selene_qfree(ptr, q.value).error_code, 0);
            });
        }
    });
    instance.shot_end().unwrap();
    // Thread scheduling can change the order of the values. Check the record
    // count and each record's framing without assuming an order for the payloads.
    let mut encoder = instance.out_encoder.lock();
    let actual = encoder.try_read(usize::MAX).unwrap().to_vec();
    drop(encoder);
    let mut frames = Vec::new();
    for (tag, value) in [("SELENE:SHOT_START", 0), ("SELENE:SHOT_END", 0)] {
        let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        crate::selene_instance::print::print_directly_to_stream(&mut encoder, 0, tag, value as u64)
            .unwrap();
        frames.push(encoder.try_read(usize::MAX).unwrap().to_vec());
    }
    assert!(actual.starts_with(&frames[0]));
    assert!(actual.ends_with(&frames[1]));
    let body = &actual[frames[0].len()..actual.len() - frames[1].len()];
    let mut template = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
    crate::selene_instance::print::print_directly_to_stream(&mut template, 0, "value", 0u64)
        .unwrap();
    let frame = template.try_read(usize::MAX).unwrap().to_vec();
    assert_eq!(body.len(), 8 * 32 * frame.len());
    for record in body.chunks_exact(frame.len()) {
        // The u64 payload is followed by the four-byte message terminator.
        assert_eq!(&record[..record.len() - 12], &frame[..frame.len() - 12]);
        assert_eq!(&record[record.len() - 4..], &[0; 4]);
    }
    drop(instance);
    assert!(
        dropped.load(Ordering::Relaxed),
        "consumer must be joined before destruction returns"
    );
}

#[test]
fn blocking_runtime_calls_allow_consumer_and_other_callers_to_progress() {
    let (mut instance, _) = instance();
    instance.shot_start(0).unwrap();
    thread::scope(|scope| {
        let instance = &instance;
        let blocked = scope.spawn(move || unsafe {
            selene_custom_runtime_call(pointer(instance), 0, b"".as_ptr(), 0)
        });
        let released = unsafe { selene_custom_runtime_call(pointer(instance), 1, b"".as_ptr(), 0) };
        assert_eq!(released.error_code, 0);
        let result = blocked.join().unwrap();
        assert_eq!(result.error_code, 0);
        assert_eq!(result.value, 42);
    });
    let result = unsafe { selene_custom_runtime_call(pointer(&instance), 2, b"".as_ptr(), 0) };
    assert_eq!(result.error_code, 0);
    let measured = unsafe { selene_future_read_bool(pointer(&instance), result.value) };
    assert_eq!(measured.error_code, 0);
    assert!(measured.value);
    instance.shot_end().unwrap();
}

#[test]
fn consumer_failure_is_reported_and_shutdown_still_joins() {
    let (mut instance, dropped) = instance();
    instance.shot_start(0).unwrap();
    let error = instance.custom_runtime_call(3, &[]).unwrap_err();
    assert!(format!("{error:#}").contains("get_next_operations"));
    assert!(instance.emulator.poke().is_err());
    assert!(instance.shot_end().is_err());
    drop(instance);
    assert!(dropped.load(Ordering::Relaxed));
}

#[test]
fn consumer_survives_multiple_shots_and_null_qis_handles_fail() {
    let (mut instance, _) = instance();
    for shot in 0..3 {
        instance.shot_start(shot).unwrap();
        let q = instance.qalloc().unwrap();
        assert!(instance.qubit_measure(q).unwrap());
        instance.qfree(q).unwrap();
        instance.shot_end().unwrap();
    }
    unsafe {
        assert_eq!(selene_qalloc(std::ptr::null_mut()).error_code, 100000);
        assert_eq!(selene_rz(std::ptr::null_mut(), 0, 0.0).error_code, 100000);
        assert_eq!(
            selene_future_read_bool(std::ptr::null_mut(), 0).error_code,
            100000
        );
        assert_eq!(selene_random_u32(std::ptr::null_mut()).error_code, 100000);
        assert_eq!(selene_random_f64(std::ptr::null_mut()).error_code, 100000);
        assert_eq!(
            selene_qubit_lazy_measure(std::ptr::null_mut(), 0).error_code,
            100000
        );
    }
}
