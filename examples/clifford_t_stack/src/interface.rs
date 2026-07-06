use anyhow::Result;
use selene_core::gatewire::{GateSetSpec, Qubit};
use selene_core::runtime::RuntimeInterface;

use crate::gates::{CNOT, CliffordT, H, S, Sdg, T, Tdg, X};

pub struct CliffordTInterface<'a> {
    runtime: &'a mut dyn RuntimeInterface,
}

impl<'a> CliffordTInterface<'a> {
    pub fn new(runtime: &'a mut dyn RuntimeInterface) -> Self {
        Self { runtime }
    }

    fn emit(&mut self, gate: CliffordT) -> Result<()> {
        self.runtime.gate(&gate.to_instance())
    }

    pub fn h(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::H(H { q0: Qubit(q0) }))
    }

    pub fn s(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::S(S { q0: Qubit(q0) }))
    }

    pub fn sdg(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::Sdg(Sdg { q0: Qubit(q0) }))
    }

    pub fn t(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::T(T { q0: Qubit(q0) }))
    }

    pub fn tdg(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::Tdg(Tdg { q0: Qubit(q0) }))
    }

    pub fn x(&mut self, q0: u32) -> Result<()> {
        self.emit(CliffordT::X(X { q0: Qubit(q0) }))
    }

    pub fn cnot(&mut self, control: u32, target: u32) -> Result<()> {
        self.emit(CliffordT::CNOT(CNOT {
            control: Qubit(control),
            target: Qubit(target),
        }))
    }

    pub fn measure(&mut self, q0: u64) -> Result<u64> {
        self.runtime.measure(q0)
    }
}
