//! Runtime interfaces that drive a quantum peripheral directly.
//!
//! The API 0.3.x interface remains in the parent module. LegacyRuntime adapts
//! it on the calling thread, including its original batch polling behaviour.
use crate::peripheral::{
    PeripheralBorrowCallback, PeripheralBorrowRequest, QuantumPeripheralHandle,
};
use crate::utils::MetricValue;
use anyhow::{Result, anyhow, bail};
use std::sync::Arc;

pub mod helper;
pub mod legacy;
pub mod plugin;
pub use legacy::LegacyRuntime;
pub use plugin::{Runtime, RuntimePluginDescriptorV2};

/// A host operation performed on the runtime's peripheral execution thread.
/// Return zero on success. Never unwind across this C boundary.
pub type ExecutionCallback = unsafe extern "C" fn(*mut std::ffi::c_void) -> i32;

/// Runtime operations may be called concurrently. Implementations synchronise
/// their input state and execute all peripheral operations on one fixed thread.
/// The host excludes operational calls during lifecycle transitions and metrics.
///
/// # Safety
/// Implementations must honour the callback lifetimes, exclusivity and fixed
/// execution-thread guarantees below. Safe Rust helpers rely on these rules
/// when lending scoped callback data to the runtime.
pub unsafe trait RuntimeInterface: Send + Sync {
    /// Older runtimes may clear their metrics in shot_end, so the compatibility
    /// path samples those metrics before calling the old lifecycle function.
    fn is_legacy(&self) -> bool {
        false
    }

    /// Compatibility checkpoint after a user call has been recorded. Peripheral
    /// runtimes need no action here; the legacy wrapper polls its batches inline.
    fn process_pending(&self) -> Result<()> {
        Ok(())
    }

    fn exit(&self) -> Result<()>;

    /// The host has started the peripheral's shot on the execution thread.
    /// Take exclusive access until shot_end returns. If shot_start fails,
    /// return without retaining the handle.
    ///
    /// # Safety
    /// The handle must remain live until shot_end returns. All use must stay
    /// on the execution thread, and no handle or callback may escape the shot.
    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        peripheral: QuantumPeripheralHandle,
    ) -> Result<()>;

    /// Complete submitted work and relinquish the peripheral, even on failure.
    /// This does not end the simulator or error model shot. The host does that
    /// afterwards, on the execution thread.
    fn shot_end(&self) -> Result<()>;

    /// Run a host callback synchronously on the same thread used for peripheral
    /// execution. This is also available between shots for plugin lifecycle calls.
    ///
    /// # Safety
    /// context must remain valid through this call. Invoke callback exactly once
    /// before returning, without retaining either argument. Do not overlap it
    /// with peripheral execution or any other execution-thread callback.
    unsafe fn on_execution_thread(
        &self,
        callback: ExecutionCallback,
        context: *mut std::ffi::c_void,
    ) -> Result<()>;

    /// Temporarily lend the peripheral to the host on its execution thread.
    ///
    /// # Safety
    /// The request and context must remain valid through this call. On success,
    /// invoke callback exactly once, exclusively, and never retain its arguments.
    /// A forced flush completes all work ordered before this borrow. If that
    /// guarantee is unsupported, return an error without invoking the callback.
    unsafe fn borrow_peripheral(
        &self,
        request: &PeripheralBorrowRequest,
        callback: PeripheralBorrowCallback,
        context: *mut std::ffi::c_void,
    ) -> Result<()>;

    fn custom_call(&self, _tag: u64, _data: &[u8]) -> Result<u64> {
        Err(anyhow!(
            "A custom call has been issued to a runtime that does not support custom calls."
        ))
    }

    fn simulate_delay(&self, _delay_ns: u64) -> Result<()> {
        Err(anyhow!(
            "A request to simulate a delay has been issued to a runtime that does not support this feature."
        ))
    }

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;

    fn qalloc(&self) -> Result<u64>;

    fn qfree(&self, qubit_id: u64) -> Result<()>;

    fn rxy_gate(&self, _qubit_id: u64, _theta: f64, _phi: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RXY gate");
    }

    fn rzz_gate(&self, _qubit_id_1: u64, _qubit_id_2: u64, _theta: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RZZ gate");
    }

    fn rz_gate(&self, _qubit_id: u64, _theta: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RZ gate");
    }

    fn rpp_gate(&self, _qubit_id_1: u64, _qubit_id_2: u64, _theta: f64, _phi: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RPP gate");
    }

    fn measure(&self, qubit_id: u64) -> Result<u64>;

    fn measure_leaked(&self, qubit_id: u64) -> Result<u64>;

    fn reset(&self, qubit_id: u64) -> Result<()>;

    /// Make the requested result available before returning. Execution and
    /// publication belong to the runtime; the host will not poll for batches.
    fn force_result(&self, result_id: u64) -> Result<()>;

    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>>;

    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>>;

    fn increment_future_refcount(&self, future: u64) -> Result<()>;

    fn decrement_future_refcount(&self, future: u64) -> Result<()>;

    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()>;

    fn global_barrier(&self, sleep_ns: u64) -> Result<()>;
}

pub trait RuntimeInterfaceFactory: Send + Sync {
    type Interface: RuntimeInterface;
    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>>;
}

/// Keep panics inside Rust when implementing a C callback.
pub fn callback_result(callback: impl FnOnce() -> Result<()>) -> i32 {
    match std::panic::catch_unwind(std::panic::AssertUnwindSafe(callback)) {
        Ok(result) => crate::utils::result_to_errno("Peripheral runtime callback failed", result),
        Err(_) => {
            eprintln!("Peripheral runtime callback panicked");
            -1
        }
    }
}

/// Run a scoped Rust operation on a runtime's execution thread. Captured data
/// must be Send because the runtime may execute the callback on another thread.
pub fn on_execution_thread<T: Send>(
    runtime: &dyn RuntimeInterface,
    operation: impl FnOnce() -> Result<T> + Send,
) -> Result<T> {
    struct Call<F, T> {
        operation: Option<F>,
        result: Option<Result<T>>,
    }
    unsafe extern "C" fn invoke<F: FnOnce() -> Result<T>, T>(
        context: *mut std::ffi::c_void,
    ) -> i32 {
        let call = unsafe { &mut *context.cast::<Call<F, T>>() };
        callback_result(|| {
            let operation = call
                .operation
                .take()
                .ok_or_else(|| anyhow!("Callback invoked more than once"))?;
            call.result = Some(operation());
            if call.result.as_ref().unwrap().is_err() {
                return Err(anyhow!("Host callback failed"));
            }
            Ok(())
        })
    }
    fn run<F: FnOnce() -> Result<T> + Send, T: Send>(
        runtime: &dyn RuntimeInterface,
        operation: F,
    ) -> Result<T> {
        let mut call = Call {
            operation: Some(operation),
            result: None,
        };
        let invoked = unsafe {
            runtime.on_execution_thread(invoke::<F, T>, (&mut call as *mut Call<F, T>).cast())
        };
        match call.result {
            Some(Err(error)) => Err(error),
            Some(Ok(value)) => {
                invoked?;
                Ok(value)
            }
            None => {
                invoked?;
                Err(anyhow!("Runtime did not invoke execution-thread callback"))
            }
        }
    }
    run(runtime, operation)
}

/// Borrow exclusively on the runtime's execution thread. The callback cannot
/// return a reference to the peripheral or move its thread-bound wrapper away.
pub fn borrow_peripheral<T: Send>(
    runtime: &dyn RuntimeInterface,
    request: &PeripheralBorrowRequest,
    operation: impl FnOnce(&mut crate::peripheral::QuantumPeripheral<'_>) -> Result<T> + Send,
) -> Result<T> {
    struct Call<F, T> {
        operation: Option<F>,
        result: Option<Result<T>>,
    }
    unsafe extern "C" fn invoke<
        F: FnOnce(&mut crate::peripheral::QuantumPeripheral<'_>) -> Result<T>,
        T,
    >(
        context: *mut std::ffi::c_void,
        handle: QuantumPeripheralHandle,
    ) -> i32 {
        let call = unsafe { &mut *context.cast::<Call<F, T>>() };
        callback_result(|| {
            let operation = call
                .operation
                .take()
                .ok_or_else(|| anyhow!("Callback invoked more than once"))?;
            let mut peripheral =
                unsafe { crate::peripheral::QuantumPeripheral::from_raw_parts(handle) };
            call.result = Some(operation(&mut peripheral));
            if call.result.as_ref().unwrap().is_err() {
                return Err(anyhow!("Host borrow callback failed"));
            }
            Ok(())
        })
    }
    fn run<
        F: FnOnce(&mut crate::peripheral::QuantumPeripheral<'_>) -> Result<T> + Send,
        T: Send,
    >(
        runtime: &dyn RuntimeInterface,
        request: &PeripheralBorrowRequest,
        operation: F,
    ) -> Result<T> {
        let mut call = Call {
            operation: Some(operation),
            result: None,
        };
        let invoked = unsafe {
            runtime.borrow_peripheral(
                request,
                invoke::<F, T>,
                (&mut call as *mut Call<F, T>).cast(),
            )
        };
        match call.result {
            Some(Err(error)) => Err(error),
            Some(Ok(value)) => {
                invoked?;
                Ok(value)
            }
            None => {
                invoked?;
                Err(anyhow!("Runtime did not invoke peripheral borrow callback"))
            }
        }
    }
    run(runtime, request, operation)
}
