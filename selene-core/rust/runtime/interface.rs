use anyhow::{Result, anyhow, bail};
use std::sync::Arc;

use crate::utils::MetricValue;

use crate::operation::BatchOperation;

/// Instances of runtime plugins implement this interface.
///
/// Many instances of a plugin may exist simultaneously. Instances are
/// generically constructed by impls of [RuntimeInterfaceFactory].
///
/// All functions can return an error, which will usually result in aborting the
/// emulation.
///
/// `cdylib` crates can export the runtime plugin C interface via
/// [crate::export_runtime_plugin!]
/// # Concurrency
///
/// All methods use shared receivers. Implementations must remain memory-safe
/// even when calls overlap, including lifecycle and metric calls, and synchronize mutable
/// state; no lock may be held while waiting for a result if it blocks its producer.
/// Separate instances may also be used concurrently.
///
/// One consumer retrieves and executes batches in order and publishes results.
/// The caller must serialize that consumer, including execution outside this API.
/// For correct shot semantics, the host excludes other calls during lifecycle
/// methods (`shot_start`, `shot_end`, `exit`) and throughout metric enumeration.
/// Rust's type system does not enforce this protocol; implementations must not
/// rely on it for memory safety. The loaded-plugin wrapper enforces per-call
/// lifecycle/metric exclusion and serializes retrieval at the C ABI boundary.
/// The host remains responsible for keeping a complete metric enumeration idle.
pub trait RuntimeInterface: Send + Sync {
    /// Signals that the instance of the runtime plugin should cleanup. Plugins
    /// should `Err`` from any functions called on an instance after `exit`.
    fn exit(&self) -> Result<()>;
    /// Called to retrieve the next batch of operations from the runtime.
    ///
    /// An empty batch is interpreted as the plugin having no more operations at
    /// this time. Only one consumer may drain an instance. An empty batch does
    /// not imply that previously dispatched measurement results are available.
    fn get_next_operations(&self) -> Result<Option<BatchOperation>>;

    /// Called to signal that the runtime should prepare to begin a shot
    fn shot_start(&self, shot_id: u64, seed: u64) -> Result<()>;

    /// Called to signal that the current shot has ended. This is an
    /// ideal place to perform validation (if applicable) and cleanup.
    fn shot_end(&self) -> Result<()>;

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

    /// Provide a metric to the output stream.
    ///
    /// Will be called with incrementing `nth_metric` until `None` is returned.
    /// The host excludes all other calls throughout this enumeration (for example,
    /// between shots), not merely during each individual metric call.
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

    /// Request progress towards the result with index `result_id`.
    ///
    /// After this returns successfully, draining `get_next_operations` must expose
    /// the work needed to resolve the result, unless already dispatched or resolved.
    /// Executing that work and publishing its results must make the result getter
    /// return `Some`. This may require multiple batches. Concurrent submissions
    /// must not indefinitely postpone forced work, and a force request overlapping
    /// retrieval must not be lost. Repeated forcing of a live result is permitted.
    /// Waiters must check the result itself, not just whether the queue is empty.
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

    /// Increment the reference count of the result with index `result_id`.
    /// Set the result of the measurement with index `result_id` to `result`.
    /// This is called by the emulator with the result from the simulator after
    /// the corresponding measurement is returned from `get_next_operations`.
    fn set_u64_result(&self, result_id: u64, result: u64) -> Result<()>;

    /// It is invalid to refer to a result index after its reference count has
    /// reached zero.
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

/// Creates independent runtime instances; factories may be shared across threads.
pub trait RuntimeInterfaceFactory: Send + Sync {
    type Interface: RuntimeInterface;
    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>>;
}
