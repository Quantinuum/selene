pub mod conformance_testing;
pub mod helper;
pub mod inline;
pub mod interface;
pub mod plugin;
pub mod version;

use std::ffi::{CString, OsStr};
use std::sync::Arc;

pub use inline::{SimulatorFFIAdapter, SimulatorOperationInterface};
pub use interface::{SimulatorInterface, SimulatorInterfaceFactory};
pub use version::SimulatorAPIVersion;

use crate::utils::{MetricValue, check_errno, read_raw_metric};
use anyhow::{Result, anyhow};

use self::plugin::SimulatorInstance;

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
    instance: SimulatorInstance,
    interface: SimulatorOperationInterface<'static>,
    backing: SimulatorBacking,
}

impl Simulator {
    pub fn from_boxed(interface: Box<dyn SimulatorInterface>) -> Self {
        let mut adapter = Box::new(SimulatorFFIAdapter::new(interface));
        let (instance, interface) = adapter.ffi_interface();
        Self {
            instance,
            interface,
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

    pub(crate) fn from_raw_parts(
        instance: SimulatorInstance,
        interface: SimulatorOperationInterface<'_>,
    ) -> Self {
        Self {
            instance,
            interface: interface.into_static(),
            backing: SimulatorBacking::Borrowed,
        }
    }

    pub(crate) fn ffi_parts(
        &mut self,
    ) -> (
        SimulatorInstance,
        *const SimulatorOperationInterface<'static>,
    ) {
        (self.instance, &self.interface as *const _)
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
        check_errno(unsafe { (self.interface.exit_fn)(self.instance) }, || {
            anyhow!("Simulator: exit failed")
        })
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("Simulator: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("Simulator: shot_end failed"),
        )
    }

    fn rz(&mut self, qubit: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rz_fn)(self.instance, qubit, theta) },
            || anyhow!("Simulator: rz failed"),
        )
    }

    fn rxy(&mut self, qubit: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rxy_fn)(self.instance, qubit, theta, phi) },
            || anyhow!("Simulator: rxy failed"),
        )
    }

    fn rzz(&mut self, qubit1: u64, qubit2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rzz_fn)(self.instance, qubit1, qubit2, theta) },
            || anyhow!("Simulator: rzz failed"),
        )
    }

    fn tk2(&mut self, qubit1: u64, qubit2: u64, alpha: f64, beta: f64, gamma: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.tk2_fn)(self.instance, qubit1, qubit2, alpha, beta, gamma) },
            || anyhow!("Simulator: tk2 failed"),
        )
    }

    fn rpp(&mut self, qubit1: u64, qubit2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rpp_fn)(self.instance, qubit1, qubit2, theta, phi) },
            || anyhow!("Simulator: rpp failed"),
        )
    }

    fn measure(&mut self, qubit: u64) -> Result<bool> {
        match unsafe { (self.interface.measure_fn)(self.instance, qubit) } {
            0 => Ok(false),
            1 => Ok(true),
            _ => Err(anyhow!("Simulator: measure failed")),
        }
    }

    fn postselect(&mut self, qubit: u64, target_value: bool) -> Result<()> {
        check_errno(
            unsafe { (self.interface.postselect_fn)(self.instance, qubit, target_value) },
            || anyhow!("Simulator: postselect failed"),
        )
    }

    fn reset(&mut self, qubit: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit) },
            || anyhow!("Simulator: reset failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        read_raw_metric(|tag_ptr, datatype_ptr, data_ptr| unsafe {
            (self.interface.get_metric_fn)(
                self.instance,
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
                (self.interface.dump_state_fn)(
                    self.instance,
                    filename.as_ptr(),
                    qubits.as_ptr(),
                    qubits.len() as u64,
                )
            },
            || anyhow!("Simulator: dump_state failed"),
        )
    }
}
