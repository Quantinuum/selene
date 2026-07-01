# Writing a Simulator Plugin in Rust

Rust simulators implement `SimulatorInterface` and
`SimulatorInterfaceFactory`, then export the plugin with
`selene_core::export_simulator_plugin!`.

The simulator owns quantum state. The examples here use placeholder state
methods such as `apply_rz`; replace them with your backend's real operations.

## 1. Create a `cdylib` Crate

```toml
[lib]
crate-type = ["cdylib"]

[dependencies]
anyhow = "1"
selene-core = { path = "../../path/to/selene-core/rust" }
```

## 2. Define Supported Gates

If your simulator supports the standard native gates, define a gateset enum:

```rust
use selene_core::define_gateset;
use selene_core::gatewire::builtin::{PhasedX, PhasedXX, RZ, ZZPhase};

define_gateset! {
    enum SimulatorGates {
        RZ(RZ),
        PhasedX(PhasedX),
        ZZPhase(ZZPhase),
        PhasedXX(PhasedXX),
    }
}
```

A restricted simulator can define a smaller set. A Clifford-only simulator, for
example, should reject non-Clifford declarations in `negotiate_gateset`.

## 3. Store Simulator State

```rust
use anyhow::{Result, bail};
use selene_core::error_model::BatchResult;
use selene_core::gatewire::{DynamicGateSet, GateSetSpec};
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use selene_core::utils::MetricValue;

struct MySimulator {
    n_qubits: u64,
    measurements: u64,
    // backend state goes here
}
```

Initialize state in the factory and reset per-shot state in `shot_start`.

## 4. Negotiate Gates

The simulator validates the final gateset:

```rust
impl MySimulator {
    fn supported_gateset() -> DynamicGateSet {
        DynamicGateSet::from_declarations(SimulatorGates::declarations())
            .expect("simulator gate declarations are unique")
    }
}

impl SimulatorInterface for MySimulator {
    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        let supported = Self::supported_gateset();
        for decl in gateset.declarations() {
            if !supported.contains(decl.semantic_id) {
                bail!("simulator does not support gate {}", decl.name);
            }
        }
        Ok(gateset.clone())
    }

    /* other methods shown below */
}
```

Rejecting here gives users a configuration error before any shot is run.

## 5. Execute Operations

`handle_operations` receives a batch and returns measurement results:

```rust
fn handle_operations(&mut self, operations: BatchOperation) -> Result<BatchResult> {
    let mut results = BatchResult::default();

    for op in operations {
        match op {
            Operation::Gate { gate } => {
                let Some(gate) = SimulatorGates::try_from_instance(&gate)? else {
                    bail!("simulator received an unnegotiated gate");
                };
                self.apply_gate(gate)?;
            }
            Operation::Measure { qubit_id, result_id } => {
                let value = self.measure_qubit(qubit_id)?;
                results.set_bool_result(result_id, value);
                self.measurements += 1;
            }
            Operation::MeasureLeaked { qubit_id, result_id } => {
                let value = self.measure_leaked_qubit(qubit_id)?;
                results.set_u64_result(result_id, value);
                self.measurements += 1;
            }
            Operation::Reset { qubit_id } => {
                self.reset_qubit(qubit_id)?;
            }
            Operation::Custom { custom_tag, .. } => {
                bail!("simulator does not support custom operation {custom_tag}");
            }
        }
    }

    Ok(results)
}
```

Decode gates by semantic ID, not by display string:

```rust
impl MySimulator {
    fn apply_gate(&mut self, gate: SimulatorGates) -> Result<()> {
        match gate {
            SimulatorGates::RZ(g) => self.apply_rz(g.q0.0.into(), g.theta.0),
            SimulatorGates::PhasedX(g) => self.apply_phased_x(g.q0.0.into(), g.theta.0, g.phi.0),
            SimulatorGates::ZZPhase(g) => self.apply_zz_phase(g.q0.0.into(), g.q1.0.into(), g.theta.0),
            SimulatorGates::PhasedXX(g) => {
                self.apply_phased_xx(g.q0.0.into(), g.q1.0.into(), g.theta.0, g.phi.0)
            }
        }
    }
}
```

## 6. Implement Lifecycle and Optional Features

`shot_start` should reset state for a shot and seed any simulator RNG. `shot_end`
should validate and release per-shot resources. `exit` should make the instance
unusable.

Postselection is represented as an operation in `handle_operations`. State
dumping remains optional; if unsupported, return a clear error. Metrics are
dynamic:

```rust
fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
    match nth_metric {
        0 => Ok(Some(("measurements".into(), MetricValue::U64(self.measurements)))),
        _ => Ok(None),
    }
}
```

## 7. Export the Plugin

```rust
use std::sync::Arc;
use selene_core::simulator::SimulatorInterfaceFactory;

struct MySimulatorFactory;

impl SimulatorInterfaceFactory for MySimulatorFactory {
    type Interface = MySimulator;

    fn name(&self) -> &str {
        "MySimulator"
    }

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        _args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::new(MySimulator {
            n_qubits,
            measurements: 0,
        }))
    }
}

selene_core::export_simulator_plugin!(MySimulatorFactory);
```

After building the shared library, configure Selene to load it as a simulator.
