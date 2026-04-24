pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::collections::HashSet;
use std::ffi::OsStr;
use std::{iter, sync};

pub use inline::{RuntimeFFIAdapter, RuntimeOperationInterface};
pub use interface::{RuntimeInterface, RuntimeInterfaceFactory};
pub use version::RuntimeAPIVersion;

use crate::utils::{MetricValue, check_errno, read_raw_metric};
use anyhow::{Result, anyhow};

use self::plugin::{
    BatchBuilder, RuntimeGetOperationInstance, RuntimeGetOperationInterface, RuntimeInstance,
};

/// We assume that operations of the same type can be done in parallel.
/// The level of parallelism is decided by the runtime - i.e. it can
/// choose to provide just one element at a time, or up to some limit N,
/// or even an unbounded number.
///
/// [BatchOperation]s are provided to the error model, as it may
/// find this information pertinent. However, there is no requirement
/// that simulation of the operations itself is done in parallel; in fact,
/// the interface is currently limited to individual operations, but this
/// may change in future if it is found to be beneficial for performance.
#[derive(Debug, Clone, PartialEq)]
#[non_exhaustive]
pub enum Operation {
    Measure {
        qubit_id: u64,
        result_id: u64,
    },
    Reset {
        qubit_id: u64,
    },
    RXYGate {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    RZGate {
        qubit_id: u64,
        theta: f64,
    },
    RZZGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
    Custom {
        custom_tag: usize,
        data: Box<[u8]>,
    },
    MeasureLeaked {
        qubit_id: u64,
        result_id: u64,
    },
    RPPGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
    TK2Gate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    },
}

impl Operation {
    pub fn get_qubit_ids(&self) -> HashSet<u64> {
        match self {
            Operation::Measure { qubit_id, .. }
            | Operation::Reset { qubit_id }
            | Operation::RXYGate { qubit_id, .. }
            | Operation::RZGate { qubit_id, .. }
            | Operation::MeasureLeaked { qubit_id, .. } => {
                let mut set = HashSet::new();
                set.insert(*qubit_id);
                set
            }
            Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                ..
            }
            | Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                ..
            }
            | Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                ..
            } => {
                let mut set = HashSet::new();
                set.insert(*qubit_id_1);
                set.insert(*qubit_id_2);
                set
            }
            Operation::Custom { .. } => HashSet::new(),
        }
    }
}

#[derive(Default, Clone, Debug)]
pub struct BatchOperation {
    ops: Vec<Operation>,
    start: crate::time::Instant,
    duration: crate::time::Duration,
}

impl BatchOperation {
    pub fn len(&self) -> usize {
        self.ops.len()
    }

    pub fn is_empty(&self) -> bool {
        self.ops.is_empty()
    }

    pub fn iter_ops(&self) -> impl iter::DoubleEndedIterator<Item = &Operation> + '_ {
        self.ops.iter()
    }

    pub fn start(&self) -> crate::time::Instant {
        self.start
    }

    pub fn end(&self) -> crate::time::Instant {
        self.start + self.duration
    }

    pub fn duration(&self) -> crate::time::Duration {
        self.duration
    }

    pub fn new(
        ops: Vec<Operation>,
        start: crate::time::Instant,
        duration: crate::time::Duration,
    ) -> Self {
        Self {
            ops,
            start,
            duration,
        }
    }

    pub fn get_qubit_ids(&self) -> HashSet<u64> {
        self.ops.iter().fold(HashSet::new(), |mut acc, op| {
            for qubit_id in op.get_qubit_ids() {
                acc.insert(qubit_id);
            }
            acc
        })
    }

    pub fn add_operation(&mut self, op: Operation) {
        self.ops.push(op);
    }
}

impl IntoIterator for BatchOperation {
    type Item = Operation;
    type IntoIter = <Vec<Operation> as IntoIterator>::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        self.ops.into_iter()
    }
}

enum RuntimeBacking {
    Adapter { _adapter: Box<RuntimeFFIAdapter> },
}

/// An instance of a runtime plugin, ready to be used for emulation.
///
/// `Runtime` is the primary runtime representation inside selene-core. It stores
/// the runtime instance pointer alongside the function-table descriptor used to
/// operate on it.
pub struct Runtime {
    instance: RuntimeInstance,
    interface: RuntimeOperationInterface<'static>,
    backing: RuntimeBacking,
}

impl Runtime {
    pub fn from_boxed(interface: Box<dyn RuntimeInterface>) -> Self {
        let mut adapter = Box::new(RuntimeFFIAdapter::new(interface));
        let (instance, interface) = adapter.ffi_interface();
        Self {
            instance,
            interface,
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
        check_errno(unsafe { (self.interface.exit_fn)(self.instance) }, || {
            anyhow!("Runtime: exit failed")
        })
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let (ops_instance, ops_interface): (
            RuntimeGetOperationInstance,
            RuntimeGetOperationInterface<'_>,
        ) = batch_builder.runtime_get_operation();
        check_errno(
            unsafe {
                (self.interface.get_next_operations_fn)(self.instance, ops_instance, &ops_interface)
            },
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
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("Runtime: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("Runtime: shot_end failed"),
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe {
                (self.interface.custom_call_fn)(
                    self.instance,
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
            unsafe { (self.interface.simulate_delay_fn)(self.instance, delay_ns) },
            || anyhow!("Runtime: simulate_delay failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.interface.get_metrics_fn)(
                self.instance,
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
            unsafe { (self.interface.qalloc_fn)(self.instance, &mut result) },
            || anyhow!("Runtime: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.qfree_fn)(self.instance, qubit_id) },
            || anyhow!("Runtime: qfree failed"),
        )
    }

    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rxy_gate_fn)(self.instance, qubit_id, theta, phi) },
            || anyhow!("Runtime: rxy_gate failed"),
        )
    }

    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rzz_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta) },
            || anyhow!("Runtime: rzz_gate failed"),
        )
    }

    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rz_gate_fn)(self.instance, qubit_id, theta) },
            || anyhow!("Runtime: rz_gate failed"),
        )
    }

    fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.interface.rpp_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta, phi)
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
                (self.interface.tk2_gate_fn)(
                    self.instance,
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
            unsafe { (self.interface.measure_fn)(self.instance, qubit_id, &mut result) },
            || anyhow!("Runtime: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        check_errno(
            unsafe { (self.interface.measure_leaked_fn)(self.instance, qubit_id, &mut result) },
            || anyhow!("Runtime: measure_leaked failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit_id) },
            || anyhow!("Runtime: reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.force_result_fn)(self.instance, result_id) },
            || anyhow!("Runtime: force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = -1;
        check_errno(
            unsafe { (self.interface.get_bool_result_fn)(self.instance, result_id, &mut result) },
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
            unsafe { (self.interface.get_u64_result_fn)(self.instance, result_id, &mut result) },
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
            unsafe { (self.interface.set_bool_result_fn)(self.instance, result_id, result) },
            || anyhow!("Runtime: set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.set_u64_result_fn)(self.instance, result_id, result) },
            || anyhow!("Runtime: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.increment_future_refcount_fn)(self.instance, future) },
            || anyhow!("Runtime: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.decrement_future_refcount_fn)(self.instance, future) },
            || anyhow!("Runtime: decrement_future_refcount failed"),
        )
    }

    fn local_barrier(&mut self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe {
                (self.interface.local_barrier_fn)(
                    self.instance,
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
            unsafe { (self.interface.global_barrier_fn)(self.instance, sleep_ns) },
            || anyhow!("Runtime: global_barrier failed"),
        )
    }
}
