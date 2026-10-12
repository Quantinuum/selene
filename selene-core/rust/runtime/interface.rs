use anyhow::{Result, anyhow, bail};
use std::sync::Arc;

use crate::utils::MetricValue;

use crate::operation::BatchOperation;

/// Implement this trait to decide how a user program's quantum operations are
/// grouped and scheduled for execution. Selene submits operations here, then
/// collects batches to run on the simulator.
///
/// Create instances through [`RuntimeInterfaceFactory`]. If your plugin is a
/// `cdylib`, use [`crate::export_runtime_plugin!`] to expose it to Selene.
/// Any method can return an error, which usually aborts the emulation.
///
/// # Sharing a runtime between threads
///
/// Several user threads can call the same runtime at once. Every method takes
/// `&self`, so your implementation needs to protect its mutable state. This also
/// applies to state shared between separate instances of your plugin.
///
/// The host collects batches, executes them in order, and writes back their
/// results. We call the thread doing this the consumer. There must be only one
/// consumer per instance, including for the execution done outside this trait. Don't wait for a result while holding a lock that
/// the consumer needs to produce it.
///
/// One consumer retrieves and executes batches in order and publishes results.
/// The caller must serialize that consumer, including execution outside this API.
/// The host serializes `shot_start`, `shot_end`, `exit`, and metric collection.
/// It excludes operational calls during start, exit, and metric enumeration.
/// During `shot_end`, existing workers may finish operational calls, and the
/// consumer may retrieve work and publish results needed for their completion.
/// The host must stop unrelated submissions before ending the shot and retain
/// the instance and its library until all worker calls have returned.
/// Rust's type system does not enforce this protocol; implementations must not
/// rely on it for memory safety. The loaded-plugin wrapper serializes lifecycle
/// and metric calls, allows operations during end, and serializes retrieval at
/// the C ABI boundary. The host keeps a complete metric enumeration idle.
pub trait RuntimeInterface: Send + Sync {
    /// Clean up this runtime instance. Return an error from subsequent calls
    /// to the instance.
    fn exit(&self) -> Result<()>;
    /// Collect the next batch of operations that are ready to execute.
    ///
    /// Return `None` when there's no work ready right now. Only one consumer may
    /// collect and execute batches. It may still be executing a batch collected
    /// earlier, so having no more batches doesn't mean all results are ready.
    fn get_next_operations(&self) -> Result<Option<BatchOperation>>;

    /// Prepare to begin a shot with the given ID and random seed.
    fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()>;

    /// Called to signal that the current shot has ended. This is an
    /// ideal place to perform validation (if applicable) and cleanup.
    ///
    /// Implementations that own workers must drain ordinary work and join those
    /// workers before returning. Cancellation is requested separately through
    /// [`Self::cancel`], which wakes pending work before the joins. Existing workers and the consumer
    /// may call operational methods during this join. Do not hold a lock that
    /// prevents those calls from completing.
    fn shot_end(&self) -> Result<()>;

    /// Compatibility notification for older callers. New callers use
    /// [`Self::shot_end`] for graceful managed completion and cleanup.
    /// The default is a no-op; retain it for already published v2 consumers.
    fn program_complete(&self) -> Result<()> {
        Ok(())
    }

    /// Wake blocked shot operations after cancellation without joining workers.
    /// This may overlap shot_end and must not acquire its lifecycle lock. Runtimes
    /// with no pending asynchronous work need no additional wake action.
    fn cancel(&self) -> Result<()> {
        Ok(())
    }

    /// Whether worker entry can rely on concurrent cancellation and draining.
    /// Legacy adapters and older loaded v2 plugins do not supply this contract.
    fn supports_worker_cancellation(&self) -> bool {
        true
    }

    // If a runtime has special behaviour that a user may wish to invoke
    // from within a utility, this function serves as a generic interface
    // to that. For example, if the runtime supports some behaviour invokable
    // via frobnicate_qubits(qubit_a, qubit_b), and this doesn't make sense to
    // expose as a behaviour within standard guppy/hugr/etc, then a developer
    // may create extensions to guppy/hugr/etc that define frobinate_qubits
    // for a user to invoke as a symbol. A utility can then be created that
    // defines frobnicate_qubits as a symbol, invoking selene's exposed
    // runtime_call_direct function with a unique tag and some data, which
    // will then be passed to this function. After this function has been invoked,
    // get_next_operations will be called by selene in case the result of the
    // call is a sequence of operations.
    fn custom_call(&self, _tag: u64, _data: &[u8]) -> Result<u64> {
        Err(anyhow!(
            "A custom call has been issued to a runtime that does not support custom calls."
        ))
    }

    /// Simulate a delay by notifying the runtime of a period of inactivity.
    fn simulate_delay(&self, _delay_ns: u64) -> Result<()> {
        Err(anyhow!(
            "A request to simulate a delay has been issued to a runtime that does not support this feature."
        ))
    }

    /// Return the requested metric, or `None` when there are no more metrics.
    ///
    /// The host calls this with increasing indices. It must pause all other
    /// calls until collection finishes, including between individual calls to
    /// this method. Between shots is a good time to collect metrics.
    fn get_metric(&self, nth_metric: u8) -> Result<Option<(String, MetricValue)>>;

    /// Attempt to allocate a free qubit. If no qubits are available,
    /// then [u64::MAX] should be returned.
    fn qalloc(&self) -> Result<u64>;

    /// Free a qubit. An error should be returned if the qubit is not allocated.
    fn qfree(&self, qubit_id: u64) -> Result<()>;

    /// Schedule an RXY gate to allocated qubit `qubit_id` with the given angles.
    fn rxy_gate(&self, _qubit_id: u64, _theta: f64, _phi: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RXY gate");
    }

    /// Schedule an RZZ gate between allocated qubits `qubit_id_1` and `qubit_id_2` with the given angle.
    fn rzz_gate(&self, _qubit_id_1: u64, _qubit_id_2: u64, _theta: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RZZ gate");
    }

    /// Schedule an RZ gate to allocated qubit `qubit_id` with the given angle.
    fn rz_gate(&self, _qubit_id: u64, _theta: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RZ gate");
    }

    /// Schedule an RPP gate between allocated qubits `qubit_id_1` and `qubit_id_2` with the given angles.
    fn rpp_gate(&self, _qubit_id_1: u64, _qubit_id_2: u64, _theta: f64, _phi: f64) -> Result<()> {
        bail!("RuntimeInterface: The chosen runtime does not support the RPP gate");
    }

    /// Schedule a measurement of allocated qubit `qubit_id`. The plugin should return a
    /// new result index. That result index must have a reference count of 1.
    fn measure(&self, qubit_id: u64) -> Result<u64>;

    /// Schedule a leakage-detection and measurement of allocated qubit `qubit_id`.
    /// The plugin should return a new result index. That result index must have a
    /// reference count of 1.
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64>;

    /// Schedule a reset of allocated qubit `qubit_id`.
    fn reset(&self, qubit_id: u64) -> Result<()>;

    /// Make the work needed for `result_id` available to the consumer.
    ///
    /// After this succeeds, calls to [`Self::get_next_operations`] must let the
    /// consumer reach that work. It may take several batches. New submissions
    /// must not keep pushing the requested work back indefinitely, and a request
    /// that overlaps batch retrieval must still take effect.
    ///
    /// The consumer executes the work and writes back the result. Once it has
    /// done so, the result getter must return `Some`. The work might already be
    /// with the consumer, or the value might already be ready, when this method
    /// is called. Repeated requests for a live result are allowed.
    ///
    /// If you're waiting for the value, check the result getter. An empty queue
    /// doesn't tell you whether the consumer has finished executing its work.
    fn force_result(&self, result_id: u64) -> Result<()>;

    /// Get the result of the measurement with index `result_id`. The plugin should
    /// return `None` if the result is not yet available.
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>>;

    /// Get the result of the measurement with index `result_id`. The plugin should
    /// return `None` if the result is not yet available.
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>>;

    /// Set the result of the measurement with index `result_id` to `result`.
    /// This is called by the emulator with the result from the simulator after
    /// the corresponding measurement is returned from `get_next_operations`.
    fn set_bool_result(&self, result_id: u64, result: bool) -> Result<()>;

    /// Set the result of the measurement with index `result_id` to `result`.
    /// This is called by the emulator with the result from the simulator after
    /// the corresponding measurement is returned from `get_next_operations`.
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()>;

    /// Keep an additional reference to this result.
    ///
    /// The result must still have a live reference. Once its reference count
    /// reaches zero, you can no longer use its index, even to retain it again.
    fn increment_future_refcount(&self, future: u64) -> Result<()>;

    /// Decrement the reference count of the result with index `result_id`.
    /// It is invalid to refer to a result index after its reference count has
    /// reached zero.
    fn decrement_future_refcount(&self, future: u64) -> Result<()>;

    /// Flush all operations involving the given qubits
    /// with a sleep time associated with those qubits afterwards
    /// (set to 0 for vanilla barrier).
    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()>;

    /// Flush all operations involving all allocated qubits
    /// with a sleep time associated afterwards
    /// (set to 0 for vanilla barrier).
    fn global_barrier(&self, sleep_ns: u64) -> Result<()>;
}

/// Creates independent runtime instances.
///
/// A factory can be shared between threads, so protect any state it shares
/// between calls to `init`.
pub trait RuntimeInterfaceFactory: Send + Sync {
    type Interface: RuntimeInterface;
    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>>;
}
