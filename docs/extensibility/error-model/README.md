# Error Model Plugins

An error model plugin sits between the runtime and simulator. It receives
batches of operations from the runtime, applies a stochastic model, calls the
simulator, and reports measurement results back to Selene.

Selene's error-model API is operation-level. Noise is represented by injecting
gates, resets, measurements, delays, or other operation mutations. It does not
expose a density-matrix channel API to error models.

Use an error model plugin when you want to model behavior such as:

- Depolarizing, dephasing, or biased Pauli errors.
- Leakage modeled by extra operations or altered measurement results.
- Measurement assignment errors.
- Time-dependent or qubit-dependent stochastic effects.
- Hardware-inspired noise tied to runtime batch timing.

## Mental Model

An error model handles a runtime batch like this:

```text
runtime batch
  -> inspect each operation
  -> maybe inject extra operations
  -> call simulator
  -> collect simulator measurement values
  -> return result IDs and values to Selene
```

The error model does not own the quantum state. It owns its random process and
any model state, then drives the simulator through the simulator operation
interface.

## Gateset Role

The error model receives the gateset the runtime may emit and returns the gateset
the error model may emit to the simulator.

If the error model only forwards operations unchanged, it can return the input
gateset. If it injects extra gates, the returned gateset must include them. For
example, a model that accepts `RZ` and `PhasedX` from the runtime but injects
`ZZPhase` must return a gateset containing `ZZPhase`.

Many error models should inspect gate arity rather than gate names. In Rust,
`OwnedGateInstance::qubit_operands()` gives the qubits touched by any gate
instance, builtin or custom. In C, use
`gw_decoded_gate_qubit_operand_count` and `gw_decoded_gate_qubit_operand_at`
after decoding a gate with `gw_gate_deserialize`.

## Tutorials

- [Writing an error model in Rust](rust.md)
- [Writing an error model in C](c.md)
