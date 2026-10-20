//! Runtime API 0.4: instruction objects and exclusive endpoint execution.
use crate::endpoint::{EndpointBorrowCallback, EndpointBorrowRequest, QuantumEndpointHandle};
use crate::utils::MetricValue;
use anyhow::{Result, anyhow};
use std::sync::Arc;

pub mod helper;
pub mod instruction;
pub mod output;
pub mod version;
pub use instruction::{RuntimeInstruction, RuntimeInstructionResult};
pub mod plugin;
pub use plugin::{Runtime, RuntimePluginDescriptorV2};

/// A host operation performed on the runtime's endpoint execution thread.
/// Return zero on success. Never unwind across this C boundary.
pub type ExecutionCallback = unsafe extern "C" fn(*mut std::ffi::c_void) -> i32;

/// Runtime operations may be called concurrently. Implementations synchronise
/// their input state and execute all endpoint operations on one fixed thread.
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

    /// Compatibility checkpoint after a user call has been recorded. Endpoint
    /// runtimes need no action here; the legacy wrapper polls its batches inline.
    fn process_pending(&self) -> Result<()> {
        Ok(())
    }

    fn destroy(&self) -> Result<()>;

    /// The host has started the endpoint's shot on the execution thread.
    /// Take exclusive access until shot_end returns. If shot_start fails,
    /// return without retaining the handle.
    ///
    /// # Safety
    /// Both handles must remain live until shot_end returns. Endpoint use
    /// must stay on the execution thread. The output sink must be thread safe.
    /// Neither handle nor any callback may escape the shot.
    unsafe fn shot_start(
        &self,
        shot_id: u64,
        seed: u64,
        endpoint: QuantumEndpointHandle,
        output: output::OutputSinkHandle,
    ) -> Result<()>;

    /// End program access and relinquish both shot handles, even on failure.
    /// The program can no longer observe quantum outcomes, so queued quantum
    /// operations and unread measurements may be discarded rather than simulated.
    /// Complete pending output and wait for all endpoint calls and callbacks to
    /// return before releasing the handles. Do not retain access after returning.
    /// This does not end the simulator or error model shot. The host does that
    /// afterwards, on the execution thread.
    fn shot_end(&self) -> Result<()>;

    /// Run a host callback synchronously on the same thread used for endpoint
    /// execution. This is also available between shots for plugin lifecycle calls.
    ///
    /// # Safety
    /// context must remain valid through this call. Invoke callback exactly once
    /// before returning, without retaining either argument. Do not overlap it
    /// with endpoint execution or any other execution-thread callback.
    unsafe fn on_execution_thread(
        &self,
        callback: ExecutionCallback,
        context: *mut std::ffi::c_void,
    ) -> Result<()>;

    /// Temporarily lend the endpoint to the host on its execution thread.
    ///
    /// # Safety
    /// The request and context must remain valid through this call. On success,
    /// invoke callback exactly once, exclusively, and never retain its arguments.
    /// A forced flush completes all work ordered before this borrow. If that
    /// guarantee is unsupported, return an error without invoking the callback.
    unsafe fn borrow_endpoint(
        &self,
        request: &EndpointBorrowRequest,
        callback: EndpointBorrowCallback,
        context: *mut std::ffi::c_void,
    ) -> Result<()>;

    /// Accept an owned program instruction. Calls from one thread keep their
    /// order. Concurrent calls establish an order before accepting the work.
    /// Gates and prints may return once queued. Queries return their requested
    /// values, and ForceResult completes execution before returning.
    ///
    /// Exit closes the shot to program instructions, flushes all earlier work
    /// and output, and emits the diagnostic before returning. Even on failure,
    /// no background work may still access the endpoint when Exit returns.
    /// Keep the handles until shot_end, which must remain safe to call. Return
    /// normally: the C program interface performs its jump after this call.
    fn handle_instruction(
        &self,
        instruction: RuntimeInstruction,
    ) -> Result<RuntimeInstructionResult>;

    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;
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
        Ok(result) => crate::utils::result_to_errno("Endpoint runtime callback failed", result),
        Err(_) => {
            eprintln!("Endpoint runtime callback panicked");
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
/// return a reference to the endpoint or move its thread-bound wrapper away.
pub fn borrow_endpoint<T: Send>(
    runtime: &dyn RuntimeInterface,
    request: &EndpointBorrowRequest,
    operation: impl FnOnce(&mut crate::endpoint::QuantumEndpoint<'_>) -> Result<T> + Send,
) -> Result<T> {
    struct Call<F, T> {
        operation: Option<F>,
        result: Option<Result<T>>,
    }
    unsafe extern "C" fn invoke<
        F: FnOnce(&mut crate::endpoint::QuantumEndpoint<'_>) -> Result<T>,
        T,
    >(
        context: *mut std::ffi::c_void,
        handle: QuantumEndpointHandle,
    ) -> i32 {
        let call = unsafe { &mut *context.cast::<Call<F, T>>() };
        callback_result(|| {
            let operation = call
                .operation
                .take()
                .ok_or_else(|| anyhow!("Callback invoked more than once"))?;
            let mut endpoint = unsafe { crate::endpoint::QuantumEndpoint::from_raw_parts(handle) };
            call.result = Some(operation(&mut endpoint));
            if call.result.as_ref().unwrap().is_err() {
                return Err(anyhow!("Host borrow callback failed"));
            }
            Ok(())
        })
    }
    fn run<F: FnOnce(&mut crate::endpoint::QuantumEndpoint<'_>) -> Result<T> + Send, T: Send>(
        runtime: &dyn RuntimeInterface,
        request: &EndpointBorrowRequest,
        operation: F,
    ) -> Result<T> {
        let mut call = Call {
            operation: Some(operation),
            result: None,
        };
        let invoked = unsafe {
            runtime.borrow_endpoint(
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
                Err(anyhow!("Runtime did not invoke endpoint borrow callback"))
            }
        }
    }
    run(runtime, request, operation)
}

pub use crate::export_runtime_plugin_v0_4 as export_runtime_plugin;
