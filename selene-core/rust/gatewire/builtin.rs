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

crate::define_gateset! {
    pub enum HeliosGateSet {
        RZ(RZ),
        PhasedX(PhasedX),
        ZZPhase(ZZPhase),
    }
}

crate::define_gateset! {
    pub enum SolGateSet {
        RZ(RZ),
        PhasedX(PhasedX),
        PhasedXX(PhasedXX),
    }
}

crate::define_gateset! {
    pub enum QuantinuumGateSet {
        RZ(RZ),
        PhasedX(PhasedX),
        ZZPhase(ZZPhase),
        PhasedXX(PhasedXX),
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum HeliosGate {
    RZ {
        qubit_id: u64,
        theta: f64,
    },
    PhasedX {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    ZZPhase {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum SolGate {
    RZ {
        qubit_id: u64,
        theta: f64,
    },
    PhasedX {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    PhasedXX {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum QuantinuumGate {
    RZ {
        qubit_id: u64,
        theta: f64,
    },
    PhasedX {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    ZZPhase {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
    PhasedXX {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
}

impl HeliosGateSet {
    pub fn dynamic() -> DynamicGateSet {
        dynamic_gateset::<Self>("Helios")
    }
}

impl SolGateSet {
    pub fn dynamic() -> DynamicGateSet {
        dynamic_gateset::<Self>("Sol")
    }
}

impl QuantinuumGateSet {
    pub fn dynamic() -> DynamicGateSet {
        HeliosGateSet::dynamic()
            .union(&SolGateSet::dynamic())
            .expect("Quantinuum builtin gate declarations are unique")
    }
}

fn dynamic_gateset<G: GateSetSpec>(name: &str) -> DynamicGateSet {
    DynamicGateSet::from_declarations(G::declarations())
        .unwrap_or_else(|_| panic!("{name} builtin gate declarations are unique"))
}

impl GateView for HeliosGate {
    type GateSet = HeliosGateSet;

    fn from_gate(gate: HeliosGateSet) -> Self {
        match gate {
            HeliosGateSet::RZ(gate) => Self::RZ {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
            },
            HeliosGateSet::PhasedX(gate) => Self::PhasedX {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            },
            HeliosGateSet::ZZPhase(gate) => Self::ZZPhase {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
            },
        }
    }
}

impl GateView for SolGate {
    type GateSet = SolGateSet;

    fn from_gate(gate: SolGateSet) -> Self {
        match gate {
            SolGateSet::RZ(gate) => Self::RZ {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
            },
            SolGateSet::PhasedX(gate) => Self::PhasedX {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            },
            SolGateSet::PhasedXX(gate) => Self::PhasedXX {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            },
        }
    }
}

impl GateView for QuantinuumGate {
    type GateSet = QuantinuumGateSet;

    fn from_gate(gate: QuantinuumGateSet) -> Self {
        match gate {
            QuantinuumGateSet::RZ(gate) => Self::RZ {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
            },
            QuantinuumGateSet::PhasedX(gate) => Self::PhasedX {
                qubit_id: gate.q0.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            },
            QuantinuumGateSet::ZZPhase(gate) => Self::ZZPhase {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
            },
            QuantinuumGateSet::PhasedXX(gate) => Self::PhasedXX {
                qubit_id_1: gate.q0.0.into(),
                qubit_id_2: gate.q1.0.into(),
                theta: gate.theta.0,
                phi: gate.phi.0,
            },
        }
    }
}
