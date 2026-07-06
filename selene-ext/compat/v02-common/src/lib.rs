use std::ffi::{OsStr, c_void};

use anyhow::{Result, anyhow, bail};
use libloading::Library;
use selene_core::{
    gatewire::{DynamicGateSet, OwnedGateInstance, builtin},
    runtime::Operation,
};

pub type Errno = i32;
pub type Instance = *mut c_void;

pub const V02_SIMULATOR_API_VERSION: u64 = 0x0000_0100;
pub const V02_RUNTIME_API_VERSION: u64 = 0x0000_0201;
pub const V02_ERROR_MODEL_API_VERSION: u64 = 0x0000_0200;

pub fn legacy_gateset() -> DynamicGateSet {
    builtin::HeliosGateSet::dynamic()
}

pub fn negotiate_legacy_gateset(kind: &str, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
    let legacy = legacy_gateset();
    if let Some(decl) = gateset.first_unsupported_by(&legacy) {
        bail!(
            "{kind} 0.2 compatibility adapter only supports gate {}",
            decl.name
        );
    }
    Ok(legacy)
}

#[derive(Clone, Copy, Debug)]
pub enum LegacyGate {
    Rz {
        qubit: u64,
        theta: f64,
    },
    Rxy {
        qubit: u64,
        theta: f64,
        phi: f64,
    },
    Rzz {
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    },
}

impl LegacyGate {
    pub fn from_gate_instance(gate: &OwnedGateInstance) -> Result<Self> {
        match Operation::gate_as_view::<builtin::HeliosGate>(gate)? {
            Some(builtin::HeliosGate::RZ { qubit_id, theta }) => Ok(Self::Rz {
                qubit: qubit_id,
                theta,
            }),
            Some(builtin::HeliosGate::PhasedX {
                qubit_id,
                theta,
                phi,
            }) => Ok(Self::Rxy {
                qubit: qubit_id,
                theta,
                phi,
            }),
            Some(builtin::HeliosGate::ZZPhase {
                qubit_id_1,
                qubit_id_2,
                theta,
            }) => Ok(Self::Rzz {
                qubit0: qubit_id_1,
                qubit1: qubit_id_2,
                theta,
            }),
            None => bail!("0.2 compatibility adapter cannot translate this gate"),
        }
    }
}

pub fn load_library(kind: &str, path: &OsStr) -> Result<Library> {
    unsafe { Library::new(path) }.map_err(|error| {
        anyhow!(
            "failed to load {kind} 0.2 plugin '{}': {error}",
            path.to_string_lossy()
        )
    })
}

pub unsafe fn required_symbol<T: Copy>(lib: &Library, symbol: &'static [u8]) -> Result<T> {
    Ok(*unsafe { lib.get::<T>(symbol) }.map_err(|error| {
        anyhow!(
            "0.2 compatibility adapter could not load symbol {}: {error}",
            String::from_utf8_lossy(symbol)
        )
    })?)
}

pub unsafe fn optional_symbol<T: Copy>(lib: &Library, symbol: &'static [u8]) -> Option<T> {
    unsafe { lib.get::<T>(symbol) }.ok().map(|symbol| *symbol)
}

pub unsafe fn validate_api_version(
    lib: &Library,
    symbol: &'static [u8],
    expected_major_minor: u64,
    kind: &str,
) -> Result<()> {
    let get_version: unsafe extern "C" fn() -> u64 = unsafe { required_symbol(lib, symbol) }?;
    let version = unsafe { get_version() };
    if (version & 0x00ff_ff00) != (expected_major_minor & 0x00ff_ff00) {
        bail!(
            "{kind} 0.2 compatibility adapter expected API version major/minor {:#08x}, got {:#08x}",
            expected_major_minor,
            version
        );
    }
    Ok(())
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct LegacyRuntimeGetOperationInterface {
    pub rzz_fn: unsafe extern "C" fn(Instance, u64, u64, f64),
    pub rxy_fn: unsafe extern "C" fn(Instance, u64, f64, f64),
    pub rz_fn: unsafe extern "C" fn(Instance, u64, f64),
    pub measure_fn: unsafe extern "C" fn(Instance, u64, u64),
    pub measure_leaked_fn: unsafe extern "C" fn(Instance, u64, u64),
    pub reset_fn: unsafe extern "C" fn(Instance, u64),
    pub custom_fn: unsafe extern "C" fn(Instance, usize, *const c_void, usize),
    pub set_batch_time_fn: unsafe extern "C" fn(Instance, u64, u64),
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct LegacyRuntimeExtractOperationInterface {
    pub extract_fn: unsafe extern "C" fn(Instance, Instance, LegacyRuntimeGetOperationInterface),
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct LegacyOperationResultInterface {
    pub set_bool_result_fn: unsafe extern "C" fn(Instance, u64, bool),
    pub set_u64_result_fn: unsafe extern "C" fn(Instance, u64, u64),
}

#[cfg(test)]
mod tests {
    use super::*;
    use selene_core::gatewire::{Angle, GateSpec, Qubit};

    #[test]
    fn legacy_gateset_accepts_only_0_2_gate_family() {
        let legacy = legacy_gateset();
        assert!(negotiate_legacy_gateset("test", &legacy).is_ok());

        let with_phased_xx = DynamicGateSet::from_declarations([
            builtin::RZ::declaration(),
            builtin::PhasedXX::declaration(),
        ])
        .unwrap();
        let error = negotiate_legacy_gateset("test", &with_phased_xx).unwrap_err();
        assert!(error.to_string().contains("only supports gate PhasedXX"));
    }

    #[test]
    fn translates_current_builtin_gates_to_legacy_calls() {
        let rz = builtin::RZ {
            q0: Qubit(1),
            theta: Angle(0.5),
        }
        .to_instance();
        assert!(matches!(
            LegacyGate::from_gate_instance(&rz).unwrap(),
            LegacyGate::Rz {
                qubit: 1,
                theta: 0.5
            }
        ));

        let phased_x = builtin::PhasedX {
            q0: Qubit(2),
            theta: Angle(0.25),
            phi: Angle(0.75),
        }
        .to_instance();
        assert!(matches!(
            LegacyGate::from_gate_instance(&phased_x).unwrap(),
            LegacyGate::Rxy {
                qubit: 2,
                theta: 0.25,
                phi: 0.75
            }
        ));

        let zz = builtin::ZZPhase {
            q0: Qubit(3),
            q1: Qubit(4),
            theta: Angle(0.125),
        }
        .to_instance();
        assert!(matches!(
            LegacyGate::from_gate_instance(&zz).unwrap(),
            LegacyGate::Rzz {
                qubit0: 3,
                qubit1: 4,
                theta: 0.125
            }
        ));
    }
}
