pub mod conformance_testing;
pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::ffi::{CString, OsStr};
use std::sync::Arc;

pub use inline::{SimulatorFFIAdapter, SimulatorHandle, SimulatorOperationInterface};
pub use interface::{SimulatorInterface, SimulatorInterfaceFactory};
pub use version::SimulatorAPIVersion;

use crate::utils::{MetricValue, check_errno, read_raw_metric};
use anyhow::{Result, anyhow};

use crate::error_model::BatchResult;
use crate::runtime::{BatchOperation, Operation};

enum SimulatorBacking {
    Adapter { _adapter: Box<SimulatorFFIAdapter> },
    Borrowed,
}

/// An instance of a simulator plugin, ready to be used for emulation.
///
/// `Simulator` is the primary runtime representation of a simulator inside
/// selene-core. It stores the simulator instance pointer alongside the
/// function-table descriptor used to operate on it.
pub struct Simulator {
    handle: SimulatorHandle<'static>,
    backing: SimulatorBacking,
}

impl Simulator {
    pub fn from_boxed(interface: Box<dyn SimulatorInterface>) -> Self {
        let mut adapter = Box::new(SimulatorFFIAdapter::new(interface));
        Self {
            handle: adapter.ffi_interface(),
            backing: SimulatorBacking::Adapter { _adapter: adapter },
        }
    }

    pub fn into_boxed(self) -> Box<dyn SimulatorInterface> {
        Box::new(self)
    }

    /// Constructs a new Simulator from a [SimulatorInterfaceFactory].
    pub fn new(
        factory: Arc<impl SimulatorInterfaceFactory + 'static>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let interface: Box<dyn SimulatorInterface> = factory.init(n_qubits, args)?;
        Ok(Self::from_boxed(interface))
    }

    pub fn load_from_file(
        plugin_path: &impl AsRef<OsStr>,
        n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Self> {
        let plugin = plugin::SimulatorPluginInterface::new_from_file(plugin_path)?;
        Self::new(plugin, n_qubits, args)
    }

    pub(crate) fn from_raw_parts(handle: SimulatorHandle<'_>) -> Self {
        Self {
            handle: handle.into_static(),
            backing: SimulatorBacking::Borrowed,
        }
    }

    pub(crate) fn ffi_parts(&mut self) -> SimulatorHandle<'static> {
        self.handle
    }
}

impl AsRef<dyn SimulatorInterface> for Simulator {
    fn as_ref(&self) -> &(dyn SimulatorInterface + 'static) {
        self
    }
}

impl AsMut<dyn SimulatorInterface> for Simulator {
    fn as_mut(&mut self) -> &mut (dyn SimulatorInterface + 'static) {
        self
    }
}

impl SimulatorInterface for Simulator {
    fn exit(&mut self) -> Result<()> {
        let _ = &self.backing;
        check_errno(
            unsafe { (self.handle.interface.exit_fn)(self.handle.instance) },
            || anyhow!("Simulator: exit failed"),
        )
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.shot_start_fn)(self.handle.instance, shot_id, seed) },
            || anyhow!("Simulator: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.handle.interface.shot_end_fn)(self.handle.instance) },
            || anyhow!("Simulator: shot_end failed"),
        )
    }

    fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
        let mut results = BatchResult::default();
        for operation in operations {
            match operation {
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => {
                    check_errno(
                        unsafe {
                            (self.handle.interface.rxy_fn)(
                                self.handle.instance,
                                qubit_id,
                                theta,
                                phi,
                            )
                        },
                        || anyhow!("Simulator: rxy failed"),
                    )?;
                }
                Operation::RZGate { qubit_id, theta } => {
                    check_errno(
                        unsafe {
                            (self.handle.interface.rz_fn)(self.handle.instance, qubit_id, theta)
                        },
                        || anyhow!("Simulator: rz failed"),
                    )?;
                }
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => {
                    check_errno(
                        unsafe {
                            (self.handle.interface.rzz_fn)(
                                self.handle.instance,
                                qubit_id_1,
                                qubit_id_2,
                                theta,
                            )
                        },
                        || anyhow!("Simulator: rzz failed"),
                    )?;
                }
                Operation::TK2Gate {
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                } => {
                    check_errno(
                        unsafe {
                            (self.handle.interface.tk2_fn)(
                                self.handle.instance,
                                qubit_id_1,
                                qubit_id_2,
                                alpha,
                                beta,
                                gamma,
                            )
                        },
                        || anyhow!("Simulator: tk2 failed"),
                    )?;
                }
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => {
                    check_errno(
                        unsafe {
                            (self.handle.interface.rpp_fn)(
                                self.handle.instance,
                                qubit_id_1,
                                qubit_id_2,
                                theta,
                                phi,
                            )
                        },
                        || anyhow!("Simulator: rpp failed"),
                    )?;
                }
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => match unsafe {
                    (self.handle.interface.measure_fn)(self.handle.instance, qubit_id)
                } {
                    0 => results.set_bool_result(result_id, false),
                    1 => results.set_bool_result(result_id, true),
                    _ => return Err(anyhow!("Simulator: measure failed")),
                },
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => match unsafe {
                    (self.handle.interface.measure_fn)(self.handle.instance, qubit_id)
                } {
                    0 => results.set_u64_result(result_id, 0),
                    1 => results.set_u64_result(result_id, 1),
                    _ => return Err(anyhow!("Simulator: measure leaked failed")),
                },
                Operation::Reset { qubit_id } => {
                    check_errno(
                        unsafe { (self.handle.interface.reset_fn)(self.handle.instance, qubit_id) },
                        || anyhow!("Simulator: reset failed"),
                    )?;
                }
                Operation::Custom { .. } => {
                    return Err(anyhow!("Simulator: custom operations are not supported"));
                }
            }
        }
        Ok(results)
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        check_errno(
            unsafe {
                (self.handle.interface.postselect_fn)(self.handle.instance, qubit, target_value)
            },
            || anyhow!("Simulator: postselect failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.handle.interface.get_metric_fn)(
                self.handle.instance,
                nth_metric,
                tag_ptr,
                datatype_ptr,
                data_ptr,
            )
        })
    }

    fn dump_state(&mut self, file: &std::path::Path, qubits: &[u64]) -> Result<()> {
        let filename = file
            .to_str()
            .ok_or_else(|| anyhow!("Simulator: dump_state failed due to invalid UTF-8 path"))?;
        let filename = CString::new(filename).map_err(|_| {
            anyhow!("Simulator: dump_state failed due to embedded null byte in path")
        })?;
        check_errno(
            unsafe {
                (self.handle.interface.dump_state_fn)(
                    self.handle.instance,
                    filename.as_ptr(),
                    qubits.as_ptr(),
                    qubits.len() as u64,
                )
            },
            || anyhow!("Simulator: dump_state failed"),
        )
    }
}
