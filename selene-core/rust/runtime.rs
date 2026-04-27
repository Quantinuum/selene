pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::ffi::OsStr;
use std::sync;

pub use crate::operation::{
    BatchOperation, BatchSource, ErrorModelBatchSource, Operation, RuntimeBatchSource,
    SimulatorBatchSource,
};
pub use inline::{RuntimeFFIAdapter, RuntimeHandle, RuntimeOperationInterface};
pub use interface::{RuntimeInterface, RuntimeInterfaceFactory};
pub use version::RuntimeAPIVersion;

use crate::utils::{MetricValue, check_errno, read_raw_metric};
use anyhow::{Result, anyhow};

use crate::operation::plugin::BatchBuilder;

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
}

impl Runtime {
    pub fn from_boxed(interface: Box<dyn RuntimeInterface>) -> Self {
        let mut adapter = Box::new(RuntimeFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: RuntimeBacking::Adapter { _adapter: adapter },
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
        let interface: Box<dyn RuntimeInterface> = factory.init(n_qubits, start, args)?;
        Ok(Self::from_boxed(interface))
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
        check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            || anyhow!("Runtime: exit failed"),
        )
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let ops = batch_builder.runtime_get_operation();
        check_errno(
            unsafe { (self.handle.interface.get_next_operations_fn)(self.handle.instance, ops) },
            || anyhow!("Runtime: get_next_operations failed"),
        )?;
        let batch = batch_builder.finish();
        if batch.is_empty() {
            Ok(None)
        } else {
            Ok(Some(batch))
        }
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.shot_start_fn)(self.handle.instance, shot_id, seed) },
            || anyhow!("Runtime: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.shot_end_fn)(self.handle.instance) },
            || anyhow!("Runtime: shot_end failed"),
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe {
                (self.handle.interface.custom_call_fn)(
                    self.handle.instance,
                    custom_tag,
                    data.as_ptr().cast(),
                    data.len(),
                    &mut result,
                )
            },
            || anyhow!("Runtime: custom_call failed"),
        )?;
        Ok(result)
    }

    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.simulate_delay_fn)(self.handle.instance, delay_ns) },
            || anyhow!("Runtime: simulate_delay failed"),
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
        check_errno(
            unsafe { (self.handle.interface.qalloc_fn)(self.handle.instance, &mut result) },
            || anyhow!("Runtime: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.qfree_fn)(self.handle.instance, qubit_id) },
            || anyhow!("Runtime: qfree failed"),
        )
    }

    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.rxy_gate_fn)(self.handle.instance, qubit_id, theta, phi)
            },
            || anyhow!("Runtime: rxy_gate failed"),
        )
    }

    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.rzz_gate_fn)(
                    self.handle.instance,
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                )
            },
            || anyhow!("Runtime: rzz_gate failed"),
        )
    }

    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.rz_gate_fn)(self.handle.instance, qubit_id, theta) },
            || anyhow!("Runtime: rz_gate failed"),
        )
    }

    fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.rpp_gate_fn)(
                    self.handle.instance,
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                )
            },
            || anyhow!("Runtime: rpp_gate failed"),
        )
    }

    fn tk2_gate(
        &mut self,
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.tk2_gate_fn)(
                    self.handle.instance,
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                )
            },
            || anyhow!("Runtime: tk2_gate failed"),
        )
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe {
                (self.handle.interface.measure_fn)(self.handle.instance, qubit_id, &mut result)
            },
            || anyhow!("Runtime: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe {
                (self.handle.interface.measure_leaked_fn)(
                    self.handle.instance,
                    qubit_id,
                    &mut result,
                )
            },
            || anyhow!("Runtime: measure_leaked failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.reset_fn)(self.handle.instance, qubit_id) },
            || anyhow!("Runtime: reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.force_result_fn)(self.handle.instance, result_id) },
            || anyhow!("Runtime: force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = -1;
        check_errno(
            unsafe {
                (self.handle.interface.get_bool_result_fn)(
                    self.handle.instance,
                    result_id,
                    &mut result,
                )
            },
            || anyhow!("Runtime: get_bool_result failed"),
        )?;
        match result {
            -1 => Ok(None),
            0 => Ok(Some(false)),
            1 => Ok(Some(true)),
            _ => Err(anyhow!(
                "Runtime: get_bool_result returned an invalid value"
            )),
        }
    }

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        let mut result = u64::MAX;
        check_errno(
            unsafe {
                (self.handle.interface.get_u64_result_fn)(
                    self.handle.instance,
                    result_id,
                    &mut result,
                )
            },
            || anyhow!("Runtime: get_u64_result failed"),
        )?;
        if result == u64::MAX {
            Ok(None)
        } else {
            Ok(Some(result))
        }
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.set_bool_result_fn)(self.handle.instance, result_id, result)
            },
            || anyhow!("Runtime: set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.set_u64_result_fn)(self.handle.instance, result_id, result)
            },
            || anyhow!("Runtime: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.increment_future_refcount_fn)(self.handle.instance, future)
            },
            || anyhow!("Runtime: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.decrement_future_refcount_fn)(self.handle.instance, future)
            },
            || anyhow!("Runtime: decrement_future_refcount failed"),
        )
    }

    fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.local_barrier_fn)(
                    self.handle.instance,
                    qubits.as_ptr(),
                    qubits.len() as u64,
                    sleep_ns,
                )
            },
            || anyhow!("Runtime: local_barrier failed"),
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.global_barrier_fn)(self.handle.instance, sleep_ns) },
            || anyhow!("Runtime: global_barrier failed"),
        )
    }
}
