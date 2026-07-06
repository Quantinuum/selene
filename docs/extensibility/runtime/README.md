# Runtime Plugins

A runtime plugin is the scheduling layer. It receives user-facing operations,
tracks qubit allocation and measurement futures, and emits batches of operations
for the error model and simulator.

Use a runtime plugin when you want to control any of these:

- Qubit allocation and deallocation.
- Gate lowering or rewriting.
- Operation batching.
- Timing annotations and barriers.
- Lazy measurement execution.
- Custom runtime calls exposed by higher-level interfaces.

The runtime should not simulate quantum state, and it should not inject noise.
It may reorder or lower operations if that is the runtime's purpose, but it must
preserve the semantics it promises to the user-facing interface.

## Mental Model

The interface calls methods such as `qalloc`, `gate`, `measure`, and `reset`.
The runtime records those calls. When Selene needs work to execute, it calls
`get_next_operations`, and the runtime emits a batch.

Measurement is deliberately indirect. The runtime returns a result ID when a
measurement is requested. Later, after the error model and simulator have
processed the batch, Selene calls `set_bool_result` or `set_u64_result` on the
runtime with the value for that result ID.

## Gateset Role

The runtime is the first plugin in the gateset handshake. It receives the gates
the interface may call. It returns the gates it may emit in batches.

This means a runtime can accept a high-level gate and lower it:

```text
interface -> runtime:  RZ, PhasedX, ZZPhase
runtime -> next layer: PhasedX, ZZPhase
```

If a runtime cannot accept one of the interface gates, it should reject the
configuration during negotiation. Do not wait until the first `gate` call.

## Tutorials

- [Writing a runtime in Rust](rust.md)
- [Writing a runtime in C](c.md)

