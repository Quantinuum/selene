# Gates and Gatesets

Gates are Selene's shared vocabulary. They are not tied to a Python method name,
a Rust enum variant, or a simulator's private instruction set. A gate is defined
by a stable semantic ID and a typed operand list, and a gateset is the set of
gate declarations a layer promises it can send or receive.

Read the language-specific tutorials when you need to construct or consume
gates:

- [Writing gates in Rust](rust.md)
- [Writing gates in C](c.md)

## Builtin Gates

Selene ships four builtin gate declarations:

- `RZ(q0, theta)`
- `PhasedX(q0, theta, phi)`
- `ZZPhase(q0, q1, theta)`
- `PhasedXX(q0, q1, theta, phi)`

The builtin names are the names used by the plugin API. Older names such as
`rz`, `rxy`, `rzz`, and `rpp` belong at compatibility boundaries such as QIS
parsers, not inside plugin implementations.

## Custom Gates

Use a custom gate when a runtime, error model, and simulator need to agree on an
operation that is not covered by the builtins. The declaration should be stable:
choose a semantic ID that includes your namespace and a version number, then
only change the meaning by introducing a new version.

For example:

```text
com.example.calibration.VirtualZ.v1(q0: qubit, theta: f64)
```

Once a gate is declared, instances of that gate can travel through the same
runtime, error model, and simulator path as builtin gates.

## Gatesets in the Pipeline

The interface creates the initial gateset. Each plugin then negotiates:

```text
interface gateset -> runtime output -> error model output -> simulator input
```

The output gateset can differ from the input gateset. This is intentional. It
lets a layer accept a user-facing vocabulary while emitting a lower-level one.

## What to Read Next

If you are writing a plugin in Rust, start with [Writing gates in Rust](rust.md)
and then the Rust guide for your plugin type.

If you are writing a plugin in C, start with [Writing gates in C](c.md). The C
plugin tutorials assume you are comfortable with serialized gatewire bytes and
the `gw_*` functions.

