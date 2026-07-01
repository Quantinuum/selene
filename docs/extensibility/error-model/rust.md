# Writing an Error Model Plugin in Rust

Rust error models implement `ErrorModelInterface` and
`ErrorModelInterfaceFactory`, then export the plugin with
`selene_core::export_error_model_plugin!`.

The example below shows the structure of an operation-level stochastic model. It
forwards runtime operations to the simulator and injects an extra gate with some
probability.

## 1. Create a `cdylib` Crate

```toml
[lib]
crate-type = ["cdylib"]

[dependencies]
anyhow = "1"
rand = "0.8"
rand_chacha = "0.3"
selene-core = { path = "../../path/to/selene-core/rust" }
```

## 2. Define Injected Gates

The incoming gateset is what the runtime may emit. Many error models should not
care which named gate caused the noise; they only need to know which qubits the
gate touched. In that case, forward incoming gates unchanged and add only the
extra gates the model may inject.

This example injects Pauli-like rotations, so it needs builtin `RZ` and
`PhasedX` downstream:

```rust
use selene_core::define_gateset;
use selene_core::gatewire::builtin::{PhasedX, RZ};

define_gateset! {
    enum InjectedGates {
        RZ(RZ),
        PhasedX(PhasedX),
    }
}
```

## 3. Store Model State

```rust
use anyhow::{Result, bail};
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha8Rng;
use selene_core::error_model::{BatchResult, ErrorModelInterface};
use selene_core::gatewire::{Angle, DynamicGateSet, GateDecl, GateSetSpec, GateSpec, Qubit};
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

struct MyErrorModel {
    probability: f64,
    rng: ChaCha8Rng,
    injected_errors: u64,
}
```

Reseed the RNG in `shot_start`. That makes each shot reproducible from Selene's
shot seed.

## 4. Negotiate Gates

Return a gateset containing all forwarded input gates plus every gate the model
may inject. If a required builtin semantic ID is already present, check that the
declaration is the builtin declaration you expect:

```rust
impl MyErrorModel {
    fn ensure_output_gate(declarations: &mut Vec<GateDecl>, required: GateDecl) -> Result<()> {
        match declarations
            .iter()
            .find(|decl| decl.semantic_id == required.semantic_id)
        {
            Some(existing) if *existing == required => Ok(()),
            Some(existing) => bail!(
                "required builtin gate {} conflicts with incoming gate {}",
                required.name,
                existing.name,
            ),
            None => {
                declarations.push(required);
                Ok(())
            }
        }
    }
}

impl ErrorModelInterface for MyErrorModel {
    fn negotiate_gateset(&mut self, input: &DynamicGateSet) -> Result<DynamicGateSet> {
        let mut declarations: Vec<_> = input.declarations().cloned().collect();
        Self::ensure_output_gate(&mut declarations, RZ::declaration())?;
        Self::ensure_output_gate(&mut declarations, PhasedX::declaration())?;
        DynamicGateSet::from_declarations(declarations).map_err(Into::into)
    }

    /* other methods shown below */
}
```

If your model forwards every gate unchanged and injects nothing, return
`input.clone()`. If your model only supports a particular semantic vocabulary,
reject unsupported declarations here instead.

## 5. Handle Operations

The error model receives a `BatchOperation` and a mutable simulator interface.
It can call the simulator directly:

```rust
fn handle_operations(
    &mut self,
    operations: BatchOperation,
    simulator: &mut dyn SimulatorInterface,
) -> Result<BatchResult> {
    let mut results = BatchResult::default();

    for op in operations {
        match op {
            Operation::Gate { gate } => {
                let qubits: Vec<u64> = gate.qubit_operands().map(u64::from).collect();
                simulator.handle_operations(BatchOperation::simulator(vec![
                    Operation::from_gate_instance(gate)?,
                ]))?;

                if qubits.len() == 1 && self.rng.random::<f64>() < self.probability {
                    let injected = selene_core::gatewire::builtin::PhasedX {
                        q0: Qubit(qubits[0].try_into()?),
                        theta: Angle(std::f64::consts::PI),
                        phi: Angle(0.0),
                    }
                    .to_instance();

                    simulator.handle_operations(BatchOperation::simulator(vec![
                        Operation::Gate { gate: injected },
                    ]))?;
                    self.injected_errors += 1;
                }
            }
            Operation::Measure { qubit_id, result_id } => {
                let mut batch = simulator.handle_operations(BatchOperation::simulator(vec![
                    Operation::Measure { qubit_id, result_id },
                ]))?;
                results.extend(batch);
            }
            Operation::MeasureLeaked { qubit_id, result_id } => {
                let mut batch = simulator.handle_operations(BatchOperation::simulator(vec![
                    Operation::MeasureLeaked { qubit_id, result_id },
                ]))?;
                results.extend(batch);
            }
            Operation::Reset { qubit_id } => {
                simulator.handle_operations(BatchOperation::simulator(vec![
                    Operation::Reset { qubit_id },
                ]))?;
            }
            Operation::Custom { custom_tag, .. } => {
                bail!("error model does not support custom operation {custom_tag}");
            }
        }
    }

    Ok(results)
}
```

`OwnedGateInstance::qubit_operands()` is the useful generic hook here. It lets a
model such as depolarizing noise apply a one-qubit channel to any one-qubit gate
and a two-qubit channel to any two-qubit gate without knowing the gate's display
name or semantic ID.

## 6. Lifecycle and Metrics

```rust
fn shot_start(&mut self, _shot_id: u64, seed: u64) -> Result<()> {
    self.rng = ChaCha8Rng::seed_from_u64(seed);
    self.injected_errors = 0;
    Ok(())
}

fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
    match nth_metric {
        0 => Ok(Some(("injected_errors".into(), MetricValue::U64(self.injected_errors)))),
        _ => Ok(None),
    }
}
```

Metrics should describe model behavior. Prefer names such as `injected_errors`,
`measurement_flips`, or `leakage_events` over names tied to one gate unless the
metric is truly gate-specific.

## 7. Export the Plugin

```rust
use std::sync::Arc;
use selene_core::error_model::ErrorModelInterfaceFactory;

struct MyErrorModelFactory;

impl ErrorModelInterfaceFactory for MyErrorModelFactory {
    type Interface = MyErrorModel;

    fn name(&self) -> &str {
        "MyErrorModel"
    }

    fn init(
        self: Arc<Self>,
        _n_qubits: u64,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        // Rust plugin factories receive argv-style arguments. args[0] is a
        // synthetic program name so parsers such as clap can consume the same
        // slice directly. Skip it when parsing manually.
        let probability = args
            .get(1)
            .map(|arg| arg.as_ref().parse())
            .transpose()?
            .unwrap_or(0.0);

        Ok(Box::new(MyErrorModel {
            probability,
            rng: ChaCha8Rng::seed_from_u64(0),
            injected_errors: 0,
        }))
    }
}

selene_core::export_error_model_plugin!(MyErrorModelFactory);
```

Build the crate and configure Selene to load the resulting shared library as an
error model.
