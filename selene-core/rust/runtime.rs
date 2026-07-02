pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::ffi::OsStr;
use std::sync;

pub use crate::operation::{
    BatchOperation, BatchSource, BuiltinGate, ErrorModelBatchSource, Operation, RuntimeBatchSource,
    SimulatorBatchSource,
};
pub use inline::{RuntimeFFIAdapter, RuntimeHandle, RuntimeOperationInterface};
pub use interface::{RuntimeInterface, RuntimeInterfaceFactory};
pub use version::RuntimeAPIVersion;

use crate::utils::{MetricValue, read_raw_metric};
use anyhow::{Result, anyhow};

use crate::gatewire::{DynamicGateSet, OwnedGateInstance};
use crate::operation::plugin::BatchBuilder;
use crate::plugin as plugin_utils;

enum RuntimeBacking {
    Adapter { _adapter: Box<RuntimeFFIAdapter> },
}

/// An instance of a runtime plugin, ready to be used for emulation.
///
/// `Runtime` is the primary runtime representation inside selene-core. It stores
/// the runtime instance pointer alongside the function-table descriptor used to
/// operate on it.
pub struct Runtime {
    handle: RuntimeHandle<'static>,
    backing: RuntimeBacking,
    name: String,
}

impl Runtime {
    pub fn from_boxed(interface: Box<dyn RuntimeInterface>) -> Self {
        Self::from_boxed_named("Unknown", interface)
    }

    pub fn from_boxed_named(name: impl Into<String>, interface: Box<dyn RuntimeInterface>) -> Self {
        let mut adapter = Box::new(RuntimeFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: RuntimeBacking::Adapter { _adapter: adapter },
            name: name.into(),
        }
    }

    pub fn into_boxed(self) -> Box<dyn RuntimeInterface> {
        Box::new(self)
    }

    /// Constructs a new Runtime from a [RuntimeInterfaceFactory].
    pub fn new(
        factory: sync::Arc<impl RuntimeInterfaceFactory + 'static>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let name = factory.name().to_string();
        let interface: Box<dyn RuntimeInterface> = factory.init(n_qubits, start, args)?;
        Ok(Self::from_boxed_named(name, interface))
    }

    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = plugin::RuntimePluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, start, args)
    }

    fn context(&self, message: &'static str) -> String {
        format!("Runtime ({}): {message}", self.name)
    }

    fn label(&self) -> String {
        format!("Runtime ({})", self.name)
    }

    fn check_errno(&self, errno: plugin_utils::Errno, message: &'static str) -> Result<()> {
        plugin_utils::check_plugin_errno_with_context(
            errno,
            self.handle.interface.last_error_fn,
            || anyhow!("{}", self.context(message)),
        )
    }
}

impl AsRef<dyn RuntimeInterface> for Runtime {
    fn as_ref(&self) -> &(dyn RuntimeInterface + 'static) {
        self
    }
}

impl AsMut<dyn RuntimeInterface> for Runtime {
    fn as_mut(&mut self) -> &mut (dyn RuntimeInterface + 'static) {
        self
    }
}

impl RuntimeInterface for Runtime {
    fn exit(&mut self) -> Result<()> {
        let _ = &self.backing;
        self.check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            "exit failed",
        )
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        self.check_errno(
            unsafe { (self.handle.interface.get_next_operations_fn)(self.handle.instance, ops) },
            "get_next_operations failed",
        )?;
        let batch = batch_builder.finish();
        if batch.is_empty() {
            Ok(None)
        } else {
            Ok(Some(batch))
        }
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.shot_start_fn)(self.handle.instance, shot_id, seed) },
            "shot_start failed",
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.shot_end_fn)(self.handle.instance) },
            "shot_end failed",
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        plugin_utils::negotiate_gateset(
            &self.label(),
            self.handle.instance,
            self.handle.interface.negotiate_gateset_fn,
            self.handle.interface.last_error_fn,
            gateset,
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        self.check_errno(
            unsafe {
                (self.handle.interface.custom_call_fn)(
                    self.handle.instance,
                    custom_tag,
                    data.as_ptr().cast(),
                    data.len(),
                    &mut result,
                )
            },
            "custom_call failed",
        )?;
        Ok(result)
    }

    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.simulate_delay_fn)(self.handle.instance, delay_ns) },
            "simulate_delay failed",
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.handle.interface.get_metrics_fn)(
                self.handle.instance,
                nth_metric,
                tag_ptr,
                datatype_ptr,
                data_ptr,
            )
        })
    }

    fn qalloc(&mut self) -> Result<u64> {
        let mut result = 0;
        self.check_errno(
            unsafe { (self.handle.interface.qalloc_fn)(self.handle.instance, &mut result) },
            "qalloc failed",
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.qfree_fn)(self.handle.instance, qubit_id) },
            "qfree failed",
        )
    }

    fn gate(&mut self, gate: &OwnedGateInstance) -> Result<()> {
        let data = gate.serialize();
        self.check_errno(
            unsafe {
                (self.handle.interface.gate_fn)(self.handle.instance, data.as_ptr(), data.len())
            },
            "gate failed",
        )
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        self.check_errno(
            unsafe {
                (self.handle.interface.measure_fn)(self.handle.instance, qubit_id, &mut result)
            },
            "measure failed",
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        self.check_errno(
            unsafe {
                (self.handle.interface.measure_leaked_fn)(
                    self.handle.instance,
                    qubit_id,
                    &mut result,
                )
            },
            "measure_leaked failed",
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.reset_fn)(self.handle.instance, qubit_id) },
            "reset failed",
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.force_result_fn)(self.handle.instance, result_id) },
            "force_result failed",
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = -1;
        self.check_errno(
            unsafe {
                (self.handle.interface.get_bool_result_fn)(
                    self.handle.instance,
                    result_id,
                    &mut result,
                )
            },
            "get_bool_result failed",
        )?;
        match result {
            -1 => Ok(None),
            0 => Ok(Some(false)),
            1 => Ok(Some(true)),
            _ => Err(anyhow!(
                "{}",
                self.context("get_bool_result returned an invalid value")
            )),
        }
    }

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        let mut result = u64::MAX;
        self.check_errno(
            unsafe {
                (self.handle.interface.get_u64_result_fn)(
                    self.handle.instance,
                    result_id,
                    &mut result,
                )
            },
            "get_u64_result failed",
        )?;
        if result == u64::MAX {
            Ok(None)
        } else {
            Ok(Some(result))
        }
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.set_bool_result_fn)(self.handle.instance, result_id, result)
            },
            "set_bool_result failed",
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.set_u64_result_fn)(self.handle.instance, result_id, result)
            },
            "set_u64_result failed",
        )
    }

    fn increment_future_refcount(&mut self, future: u64) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.increment_future_refcount_fn)(self.handle.instance, future)
            },
            "increment_future_refcount failed",
        )
    }

    fn decrement_future_refcount(&mut self, future: u64) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.decrement_future_refcount_fn)(self.handle.instance, future)
            },
            "decrement_future_refcount failed",
        )
    }

    fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        self.check_errno(
            unsafe {
                (self.handle.interface.local_barrier_fn)(
                    self.handle.instance,
                    qubits.as_ptr(),
                    qubits.len() as u64,
                    sleep_ns,
                )
            },
            "local_barrier failed",
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        self.check_errno(
            unsafe { (self.handle.interface.global_barrier_fn)(self.handle.instance, sleep_ns) },
            "global_barrier failed",
        )
    }
}
