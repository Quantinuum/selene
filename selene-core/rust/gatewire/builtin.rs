use crate::gatewire::*;

// Note: if a gate is updated, provide the version with
// pub struct GateName [ version = N ] { ... }

crate::define_builtin_gates! {
    // We use the same names as TKET for the gates for consistency
    pub struct RZ { q0: Qubit, theta: Angle }
    pub struct PhasedX { q0: Qubit, theta: Angle, phi: Angle }
    pub struct ZZPhase { q0: Qubit, q1: Qubit, theta: Angle }
    pub struct PhasedXX { q0: Qubit, q1: Qubit, theta: Angle, phi: Angle}
}

pub fn all() -> DynamicGateSet {
    DynamicGateSet::from_declarations(vec![
        RZ::declaration(),
        PhasedX::declaration(),
        ZZPhase::declaration(),
        PhasedXX::declaration(),
    ])
    .expect("builtin gate declarations are unique")
}
