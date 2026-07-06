# Simulator Design

Selene accepts simulators as plugins. A simulator owns the quantum state, while
Selene owns the pipeline that feeds operations into it.

The simulator API has two layers:

- `SimulatorInterface` in [interface.rs](interface.rs) is the idiomatic Rust
  trait implemented by Rust simulators.
- The descriptor and function-table ABI in [plugin.rs](plugin.rs) and
  [inline.rs](inline.rs) is the C-compatible shape used by dynamically loaded
  plugins and in-process adapters.

## Rust Trait Shape

A Rust simulator implements:

- lifecycle callbacks: `shot_start`, `shot_end`, and `exit`;
- `negotiate_gateset`, which validates the final gateset the simulator may
  receive;
- `handle_operations`, which applies a batch and returns measurement results;
- optional state dumping and dynamic metrics.

`handle_operations` is the first-class operation entry point. Gates,
measurements, resets, postselection, timing, and custom operations all travel in
the same batch representation. This keeps the simulator ABI aligned with the
runtime and error-model APIs and avoids a split between direct per-operation
callbacks and batched execution.

## Gate Compatibility

The default `negotiate_gateset` implementation accepts the builtin
`QuantinuumGateSet`. Simulators with a smaller domain should override this
method and reject unsupported gates before any shot starts. For example, a
Clifford-only simulator should fail negotiation for a gateset containing a
non-Clifford gate rather than attempting to approximate it later.

Simulators decode generic gate instances by semantic ID through gatewire. They
should not branch on frontend names such as historical `rxy` or `rzz`.

## C ABI Shape

The C-compatible descriptor begins with `PluginDescriptorHeaderV1`, including
the mandatory plugin name and last-error callbacks. The simulator descriptor
then provides lifecycle callbacks, `handle_operations_fn`,
`negotiate_gateset_fn`, metrics, and optional state dumping.

The helper macro `export_simulator_plugin!(FactoryType)` in [helper.rs](helper.rs)
turns a Rust `SimulatorInterfaceFactory` implementation into that descriptor and
captures Rust callback errors for `last_error_fn`.

For user-facing simulator plugin tutorials, see
[the extensibility simulator docs](../../../docs/extensibility/simulator/README.md).
