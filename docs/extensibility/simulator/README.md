# Simulator Plugins

A simulator plugin owns the quantum state. It receives the final operation
stream after runtime scheduling and error-model mutation, then executes exactly
what it is told.

Use a simulator plugin when you want to connect Selene to a new backend:

- A state-vector simulator.
- A stabilizer simulator.
- A tensor-network simulator.
- A hardware-backed or external engine.
- A specialized backend such as a Clifford-only simulator.

The simulator should not inject errors. It should not silently approximate gates
outside its domain. If it cannot execute a gate, it should reject the gateset
during negotiation. For example, a Clifford-only simulator should reject a
non-Clifford gateset before the first shot starts.

## Mental Model

The simulator receives operations from the error model:

```text
runtime batch -> error model -> simulator operation interface
```

For each shot, the simulator prepares state in `shot_start`, applies gates,
measures qubits, resets qubits, and cleans up in `shot_end`.

Measurements return values immediately to the caller. In the normal pipeline,
the caller is the error model, which maps those values back to runtime result
IDs.

## Gateset Role

The simulator is the final gateset authority. It receives the gateset the error
model may emit and must either accept it unchanged or return an error.

A simulator usually returns the input gateset unchanged after validation. It
should not return a different gateset unless it is also acting as a lowering
layer, which is unusual and should be documented.

## Tutorials

- [Writing a simulator in Rust](rust.md)
- [Writing a simulator in C](c.md)

