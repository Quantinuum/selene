use anyhow::{Result, anyhow, bail};
use selene_core::gatewire::{DynamicGateSet, GateSetSpec, OwnedGateInstance, Qubit};
use selene_core::{define_gate, define_gateset};

define_gate! {
    pub struct H [
        id = "example.clifford_t.H.v1",
        display = "H",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct S [
        id = "example.clifford_t.S.v1",
        display = "S",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct Sdg [
        id = "example.clifford_t.Sdg.v1",
        display = "Sdg",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct T [
        id = "example.clifford_t.T.v1",
        display = "T",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct Tdg [
        id = "example.clifford_t.Tdg.v1",
        display = "Tdg",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct X [
        id = "example.clifford_t.X.v1",
        display = "X",
        version = 1,
    ] { q0: Qubit }
}

define_gate! {
    pub struct CNOT [
        id = "example.clifford_t.CNOT.v1",
        display = "CNOT",
        version = 1,
    ] {
        control: Qubit,
        target: Qubit,
    }
}

define_gateset! {
    pub enum CliffordT {
        H(H),
        S(S),
        Sdg(Sdg),
        T(T),
        Tdg(Tdg),
        X(X),
        CNOT(CNOT),
    }
}

pub fn clifford_t_gateset() -> DynamicGateSet {
    DynamicGateSet::from_declarations(CliffordT::declarations())
        .expect("Clifford+T declarations are unique")
}

pub fn gateset_names(gateset: &DynamicGateSet) -> Vec<String> {
    gateset
        .declarations()
        .map(|decl| decl.name.clone())
        .collect()
}

pub fn require_clifford_t(input: &DynamicGateSet) -> Result<()> {
    let supported = clifford_t_gateset();
    if let Some(decl) = input.first_unsupported_by(&supported) {
        bail!("unsupported Clifford+T input gate {}", decl.name);
    }
    Ok(())
}

pub fn decode_clifford_t(gate: &OwnedGateInstance) -> Result<CliffordT> {
    CliffordT::try_from_instance(gate)?
        .ok_or_else(|| anyhow!("gate is not in the Clifford+T gateset"))
}

pub fn gate_qubits(gate: &OwnedGateInstance) -> impl Iterator<Item = u64> + '_ {
    gate.qubit_operands().map(u64::from)
}
