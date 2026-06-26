# Writing Gates in Rust

Rust code should use the typed gatewire API whenever possible. You define gate
structs, combine them into a gateset enum, and serialize or decode gate
instances through that gateset.

## Use Builtin Gates

The builtin gates live in `selene_core::gatewire::builtin`:

```rust
use selene_core::define_gateset;
use selene_core::gatewire::builtin::RZ;
use selene_core::gatewire::{Angle, GateSet, Qubit};

define_gateset! {
    enum RzOnly {
        RZ(RZ),
    }
}

let gate = RZ {
    q0: Qubit(0),
    theta: Angle(std::f64::consts::PI),
};

let gateset = GateSet::<RzOnly>::new()?;
let bytes = gateset.serialize_gate(&RzOnly::RZ(gate))?;
```

For a set containing several gate types, define an enum:

```rust
use selene_core::define_gateset;
use selene_core::gatewire::builtin::{PhasedX, RZ, ZZPhase};

define_gateset! {
    pub enum HeliosGates {
        RZ(RZ),
        PhasedX(PhasedX),
        ZZPhase(ZZPhase),
    }
}
```

The enum gives you one type that can serialize outgoing gates and decode
incoming gate instances:

```rust
use selene_core::gatewire::{GateSet, TryDecode};

let gateset = GateSet::<HeliosGates>::new()?;
let decoded = gateset.decode(&wire_bytes)?;
```

## Define a Custom Gate

Use `define_gate!` for custom declarations:

```rust
use selene_core::define_gate;
use selene_core::gatewire::{Angle, Qubit};

define_gate! {
    pub struct VirtualZ [
        id = "com.example.calibration.VirtualZ.v1",
        display = "VirtualZ",
        version = 1,
    ] {
        q0: Qubit,
        theta: Angle,
    }
}
```

The semantic ID should be globally stable. Include a namespace you control and a
version suffix. If the operand order or meaning changes, define `VirtualZ.v2`
instead of reusing `VirtualZ.v1`.

## Negotiate Gates in a Plugin

A Rust runtime or error model receives a `DynamicGateSet` and returns the
`DynamicGateSet` it will emit:

```rust
use anyhow::Result;
use selene_core::gatewire::{DynamicGateSet, GateSetSpec};

fn output_gateset() -> DynamicGateSet {
    DynamicGateSet::from_declarations(HeliosGates::declarations())
        .expect("Helios gate declarations are unique")
}

fn negotiate_gateset(input: &DynamicGateSet) -> Result<DynamicGateSet> {
    for decl in input.declarations() {
        // Reject gates you cannot accept from the previous layer.
        if !output_gateset().contains(decl.semantic_id) {
            anyhow::bail!("unsupported input gate {}", decl.name);
        }
    }

    // Return the gates this plugin may emit downstream.
    Ok(output_gateset())
}
```

Do not rely on display names for compatibility. Use semantic IDs and typed
decoding.

## Decode Incoming Gates

Plugin callbacks receive generic `OwnedGateInstance` values. Decode them with
your gateset enum:

```rust
use selene_core::gatewire::TryDecode;

match HeliosGates::try_from_instance(gate)? {
    Some(HeliosGates::RZ(rz)) => {
        // use rz.q0 and rz.theta
    }
    Some(HeliosGates::PhasedX(px)) => {
        // use px.q0, px.theta, px.phi
    }
    Some(HeliosGates::ZZPhase(zz)) => {
        // use zz.q0, zz.q1, zz.theta
    }
    None => anyhow::bail!("gate was not part of HeliosGates"),
}
```

This keeps the plugin independent of frontend naming and independent of the
serialized wire format.

## Inspect Qubit Operands Generically

Some plugins should not decode by gate identity. Error models often care only
whether a gate touched one qubit, two qubits, or something else. Use
`OwnedGateInstance::qubit_operands()` for that:

```rust
use selene_core::runtime::Operation;

match operation {
    Operation::Gate { gate } => {
        let qubits: Vec<u64> = gate.qubit_operands().map(u64::from).collect();
        match qubits.as_slice() {
            [q0] => {
                // apply a one-qubit policy to q0
            }
            [q0, q1] => {
                // apply a two-qubit policy to q0 and q1
            }
            _ => {
                // pass through, reject, or use a model-specific policy
            }
        }
    }
    _ => {}
}
```

There are also convenience methods:

- `qubit_operand_count()` returns the number of qubit operands.
- `single_qubit_operand()` returns `Some(q)` only when exactly one qubit operand
  is present.
