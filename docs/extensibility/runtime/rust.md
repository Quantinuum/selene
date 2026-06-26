# Writing a Runtime Plugin in Rust

Rust runtimes should implement `RuntimeInterface` and
`RuntimeInterfaceFactory`, then export the plugin with
`selene_core::export_runtime_plugin!`. The macro handles the C descriptor,
opaque instance pointer, ABI version, gateset serialization, and error
translation.

## 1. Create a `cdylib` Crate

Your plugin crate should build a shared library:

```toml
[lib]
crate-type = ["cdylib"]

[dependencies]
anyhow = "1"
selene-core = { path = "../../path/to/selene-core/rust" }
```

In a workspace, use the same `selene-core` revision that will load the plugin.

## 2. Define the Gate Vocabulary

Use typed gatewire gates. This example accepts the Helios-style builtin set:

```rust
use selene_core::define_gateset;
use selene_core::gatewire::builtin::{PhasedX, RZ, ZZPhase};

define_gateset! {
    enum RuntimeGates {
        RZ(RZ),
        PhasedX(PhasedX),
        ZZPhase(ZZPhase),
    }
}
```

If the runtime lowers gates, define a second gateset for output. The input
gateset is what the interface may send. The output gateset is what the runtime
may emit downstream.

## 3. Store Runtime State

The runtime instance owns the state for one configured run:

```rust
use selene_core::runtime::{BatchOperation, Operation, RuntimeInterface};
use selene_core::utils::MetricValue;
use selene_core::gatewire::{DynamicGateSet, GateSetSpec, OwnedGateInstance};
use anyhow::{Result, bail};
use std::collections::{HashMap, VecDeque};

struct MyRuntime {
    n_qubits: u64,
    batch_start: selene_core::time::Instant,
    allocated: Vec<bool>,
    queue: VecDeque<Operation>,
    next_result: u64,
    bool_results: HashMap<u64, bool>,
}
```

Keep per-shot or per-run state in the struct. Avoid global mutable state unless
it is intentionally shared and synchronized.

## 4. Negotiate Gates

Validate the interface gates and return the runtime output gates:

```rust
impl MyRuntime {
    fn output_gateset() -> DynamicGateSet {
        DynamicGateSet::from_declarations(RuntimeGates::declarations())
            .expect("runtime gate declarations are unique")
    }
}

impl RuntimeInterface for MyRuntime {
    fn negotiate_gateset(&mut self, input: &DynamicGateSet) -> Result<DynamicGateSet> {
        let accepted = Self::output_gateset();
        for decl in input.declarations() {
            if !accepted.contains(decl.semantic_id) {
                bail!("runtime does not accept gate {}", decl.name);
            }
        }
        Ok(accepted)
    }

    /* other methods shown below */
}
```

If you omit `negotiate_gateset`, Selene assumes identity negotiation. Public
runtimes should implement it explicitly so unsupported gates fail at
configuration time.

## 5. Accept Generic Gates

The runtime receives gates as `OwnedGateInstance`. Decode them through the
gateset you negotiated:

```rust
fn gate(&mut self, gate: &OwnedGateInstance) -> Result<()> {
    let Some(gate) = RuntimeGates::try_from_instance(gate)? else {
        bail!("runtime received a gate outside its negotiated gateset");
    };

    let instance = gate.to_instance();
    self.queue.push_back(Operation::from_gate_instance(instance)?);
    Ok(())
}
```

This is the only gate entry point. Do not add separate runtime methods for each
builtin gate.

## 6. Manage Qubits and Measurements

The interface asks the runtime to allocate qubits:

```rust
fn qalloc(&mut self) -> Result<u64> {
    if let Some((index, slot)) = self
        .allocated
        .iter_mut()
        .enumerate()
        .find(|(_, allocated)| !**allocated)
    {
        *slot = true;
        Ok(index as u64)
    } else {
        Ok(u64::MAX)
    }
}

fn qfree(&mut self, qubit: u64) -> Result<()> {
    let Some(slot) = self.allocated.get_mut(qubit as usize) else {
        bail!("invalid qubit {qubit}");
    };
    if !*slot {
        bail!("qubit {qubit} is not allocated");
    }
    *slot = false;
    Ok(())
}
```

Measurements return result IDs:

```rust
fn measure(&mut self, qubit: u64) -> Result<u64> {
    let result_id = self.next_result;
    self.next_result += 1;
    self.queue.push_back(Operation::Measure { qubit_id: qubit, result_id });
    Ok(result_id)
}

fn set_bool_result(&mut self, result_id: u64, value: bool) -> Result<()> {
    self.bool_results.insert(result_id, value);
    Ok(())
}

fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
    Ok(self.bool_results.get(&result_id).copied())
}
```

A production runtime should also implement result reference counting with
`increment_future_refcount` and `decrement_future_refcount`.

## 7. Emit Batches

`get_next_operations` returns `None` when the runtime has no work ready. When it
does have work, return a `BatchOperation`:

```rust
fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
    if self.queue.is_empty() {
        return Ok(None);
    }

    let ops: Vec<_> = self.queue.drain(..).collect();
    let duration = selene_core::time::Duration::from(0);
    Ok(Some(BatchOperation::runtime(ops, self.batch_start, duration)))
}
```

Use the runtime batch source to attach timing information. If your runtime does
not model time, a zero duration is fine.

## 8. Complete the Trait

A minimal runtime also implements lifecycle, reset, barriers, result forcing,
leakage measurement if supported, metrics, and exit. Unsupported optional
features should return a clear error. Methods that are part of the core runtime
contract should be real implementations, not silent no-ops.

Metrics are dynamic:

```rust
fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
    match nth_metric {
        0 => Ok(Some(("queued_operations".into(), MetricValue::U64(self.queue.len() as u64)))),
        1 => Ok(Some(("allocated_qubits".into(), MetricValue::U64(
            self.allocated.iter().filter(|allocated| **allocated).count() as u64,
        )))),
        _ => Ok(None),
    }
}
```

Prefer metrics that describe runtime behavior rather than hardcoding specific
gate names.

## 9. Export the Plugin

Implement a factory and export it:

```rust
use std::sync::Arc;
use selene_core::runtime::{RuntimeInterfaceFactory};

struct MyRuntimeFactory;

impl RuntimeInterfaceFactory for MyRuntimeFactory {
    type Interface = MyRuntime;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        _start: selene_core::time::Instant,
        _args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::new(MyRuntime {
            n_qubits,
            batch_start: _start,
            allocated: vec![false; n_qubits as usize],
            queue: VecDeque::new(),
            next_result: 0,
            bool_results: HashMap::new(),
        }))
    }
}

selene_core::export_runtime_plugin!(MyRuntimeFactory);
```

Build the crate, then configure Selene to load the resulting shared library as a
runtime plugin.
