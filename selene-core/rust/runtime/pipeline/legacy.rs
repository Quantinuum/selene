//! Compatibility with API 0.3.x. Calls and batch execution stay on the thread
//! that initialised the legacy runtime; no worker or per-call channel is added.
use super::{ExecutionCallback, RuntimeInterface};
use crate::{
    peripheral::{
        PeripheralBorrowCallback, PeripheralBorrowRequest, QuantumPeripheral,
        QuantumPeripheralHandle, QuantumPeripheralInterface,
    },
    runtime::{Runtime, RuntimeInterface as LegacyInterface},
    utils::MetricValue,
};
use anyhow::{Result, anyhow};
use std::{
    ffi,
    sync::Mutex,
    thread::{self, ThreadId},
};

struct State {
    runtime: Runtime,
    peripheral: Option<QuantumPeripheralHandle>,
    exited: bool,
}
impl State {
    fn drain(&mut self) -> Result<()> {
        let handle = self
            .peripheral
            .ok_or_else(|| anyhow!("No peripheral attached to legacy runtime"))?;
        let mut peripheral = unsafe { QuantumPeripheral::from_raw_parts(handle) };
        while let Some(batch) = self.runtime.get_next_operations()? {
            let results = peripheral.handle_operations(batch)?;
            for result in results.bool_results {
                self.runtime
                    .set_bool_result(result.result_id, result.value)?;
            }
            for result in results.u64_results {
                self.runtime
                    .set_u64_result(result.result_id, result.value)?;
            }
        }
        Ok(())
    }
}

pub struct LegacyRuntime {
    owner: ThreadId,
    state: Mutex<Option<State>>,
}

// Every entry checks the original thread before touching State. If a Rust
// caller drops this adapter on a different thread, we leak its thread-bound
// state rather than running plugin destructors on a thread they cannot use.
unsafe impl Send for LegacyRuntime {}
unsafe impl Sync for LegacyRuntime {}
impl LegacyRuntime {
    pub fn new(runtime: Runtime) -> Self {
        Self {
            owner: thread::current().id(),
            state: Mutex::new(Some(State {
                runtime,
                peripheral: None,
                exited: false,
            })),
        }
    }
    fn with<T>(&self, go: impl FnOnce(&mut State) -> Result<T>) -> Result<T> {
        anyhow::ensure!(
            self.owner == thread::current().id(),
            "Legacy runtimes must be called on their initialising thread"
        );
        let mut state = self
            .state
            .try_lock()
            .map_err(|_| anyhow!("Legacy runtime is already in use or its lock is poisoned"))?;
        let state = state
            .as_mut()
            .ok_or_else(|| anyhow!("Legacy runtime has exited"))?;
        anyhow::ensure!(!state.exited, "Legacy runtime has exited");
        go(state)
    }
}
impl Drop for LegacyRuntime {
    fn drop(&mut self) {
        if self.owner != thread::current().id() {
            let state = self
                .state
                .get_mut()
                .unwrap_or_else(|error| error.into_inner());
            std::mem::forget(state.take());
        } else if let Ok(Some(state)) = self.state.get_mut()
            && !state.exited
        {
            let _ = state.runtime.exit();
        }
    }
}
unsafe impl RuntimeInterface for LegacyRuntime {
    fn is_legacy(&self) -> bool {
        true
    }

    fn process_pending(&self) -> Result<()> {
        self.with(|state| state.drain())
    }

    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        peripheral: QuantumPeripheralHandle,
    ) -> Result<()> {
        self.with(|state| {
            anyhow::ensure!(
                state.peripheral.is_none(),
                "Legacy runtime shot already active"
            );
            state.peripheral = Some(peripheral);
            let result = state
                .runtime
                .shot_start(shot_id, seed)
                .and_then(|_| state.drain());
            if result.is_err() {
                state.peripheral = None;
            }
            result
        })
    }
    fn shot_end(&self) -> Result<()> {
        self.with(|state| {
            let ended = state.runtime.shot_end();
            let drained = state.drain();
            state.peripheral = None;
            ended.and(drained)
        })
    }
    unsafe fn on_execution_thread(
        &self,
        callback: ExecutionCallback,
        context: *mut ffi::c_void,
    ) -> Result<()> {
        anyhow::ensure!(
            self.owner == thread::current().id(),
            "Legacy runtime execution thread differs"
        );
        self.with(|_| {
            crate::utils::check_errno(unsafe { callback(context) }, || {
                anyhow!("Host lifecycle callback failed")
            })
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
        self.with(|state| {
            if request.force_flush {
                state.runtime.global_barrier(0)?;
                state.drain()?;
            }
            let handle = state
                .peripheral
                .ok_or_else(|| anyhow!("No peripheral to borrow"))?;
            crate::utils::check_errno(unsafe { callback(context, handle) }, || {
                anyhow!("Host inspection failed")
            })
        })
    }
    fn exit(&self) -> Result<()> {
        self.with(|state| {
            state.exited = true;
            state.runtime.exit()
        })
    }
    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        self.with(|state| state.runtime.get_metric(nth_metric))
    }
    fn qalloc(&self) -> Result<u64> {
        self.with(|state| state.runtime.qalloc())
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        self.with(|state| state.runtime.qfree(qubit_id))
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        self.with(|state| state.runtime.rxy_gate(qubit_id, theta, phi))
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        self.with(|state| state.runtime.rzz_gate(qubit_id_1, qubit_id_2, theta))
    }
    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        self.with(|state| state.runtime.rpp_gate(qubit_id_1, qubit_id_2, theta, phi))
    }
    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        self.with(|state| state.runtime.rz_gate(qubit_id, theta))
    }
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        self.with(|state| state.runtime.measure(qubit_id))
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        self.with(|state| state.runtime.measure_leaked(qubit_id))
    }
    fn reset(&self, qubit_id: u64) -> Result<()> {
        self.with(|state| state.runtime.reset(qubit_id))
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        self.with(|state| state.runtime.force_result(result_id))
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        self.with(|state| state.runtime.get_bool_result(result_id))
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        self.with(|state| state.runtime.get_u64_result(result_id))
    }
    fn increment_future_refcount(&self, future: u64) -> Result<()> {
        self.with(|state| state.runtime.increment_future_refcount(future))
    }
    fn decrement_future_refcount(&self, future: u64) -> Result<()> {
        self.with(|state| state.runtime.decrement_future_refcount(future))
    }
    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        self.with(|state| state.runtime.local_barrier(qubits, sleep_ns))
    }
    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        self.with(|state| state.runtime.global_barrier(sleep_ns))
    }
    fn custom_call(&self, tag: u64, data: &[u8]) -> Result<u64> {
        self.with(|state| state.runtime.custom_call(tag, data))
    }
    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        self.with(|state| state.runtime.simulate_delay(delay_ns))
    }
}
