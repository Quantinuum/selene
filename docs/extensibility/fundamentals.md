# Plugin Fundamentals

This page is the shared background for runtime, error model, and simulator
plugins. If you understand the flow here, the individual plugin tutorials become
much smaller: they are all implementations of the same contract at different
points in the pipeline.

## Why Selene Uses Plugins

Selene deliberately separates four concerns:

- The interface describes the user's program.
- The runtime controls scheduling, allocation, batching, and result futures.
- The error model mutates the operation stream to represent stochastic noise.
- The simulator executes the final operation stream.

Those concerns are different enough that they should be developed and tested
independently. A runtime might care about batching gates into hardware-timed
windows. An error model might care about random seeds and injected operations. A
simulator might care about state-vector, stabilizer, tensor-network, or external
engine details. The plugin API keeps those decisions out of the core loop while
still giving Selene enough information to validate compatibility before a shot
starts.

## The Runtime Pipeline

A configured Selene run has this shape:

```text
user/interface
  -> runtime
  -> error model
  -> simulator
```

At configuration time, gates flow through the same path as a negotiation:

```text
interface gateset
  -> runtime accepts and returns runtime output gateset
  -> error model accepts and returns error-model output gateset
  -> simulator accepts or rejects
```

At shot time, operations flow through the pipeline:

1. Selene calls `shot_start(shot_id, seed)` on each plugin instance.
2. The user-facing interface calls runtime operations such as `qalloc`, `gate`,
   `measure`, `reset`, and barriers.
3. The runtime buffers or lowers those requests.
4. Selene repeatedly asks the runtime for the next batch of operations.
5. The error model receives each batch, may inject or mutate operations, calls
   the simulator, and records measurement results.
6. Selene returns measurement results to the runtime by result ID.
7. The user-facing interface reads results from the runtime.
8. Selene calls `shot_end()`, gathers metrics, and either starts another shot
   or calls `exit()`.

The runtime is the only plugin that talks directly to the user-facing interface.
The simulator is the only plugin that actually owns the quantum state. The error
model sits between them.

## Shared Library Model

Native plugins are loaded from a shared library. The library exposes a descriptor
for one plugin type:

- Runtime libraries expose `SeleneRuntimePluginDescriptorV1`.
- Error model libraries expose `SeleneErrorModelPluginDescriptorV1`.
- Simulator libraries expose `SeleneSimulatorPluginDescriptorV1`.

Selene finds that descriptor either as a public symbol named
`selene_<kind>_plugin_descriptor_v1` or through a getter function named
`selene_<kind>_get_plugin_descriptor_v1`.

Every descriptor begins with the same `PluginDescriptorHeaderV1`:

- `struct_size`, so Selene can detect a descriptor compiled against a different
  struct layout.
- `api_version`, so Selene can reject an incompatible ABI version.
- `last_error_fn`, so callback failures can carry a useful plugin-provided
  message.
- `get_name_fn`, so errors can say which plugin failed.

The rest of the descriptor contains:

- Function pointers for the plugin lifecycle and operation callbacks.

Rust plugins usually do not write the descriptor by hand. They implement a
Selene trait and use an export macro. C plugins write the descriptor directly.

## Descriptor Compatibility

Descriptor validation is intentionally boring:

- `struct_size` must match the descriptor type Selene expects.
- The API version reserved byte must be zero.
- The major and minor API versions must match Selene's current API.
- Required callbacks must be present. `last_error_fn`, `get_name_fn`, and
  `negotiate_gateset_fn` are mandatory for every runtime, error-model, and
  simulator plugin.
- Optional callbacks may be null only where the header for that plugin type
  documents them as optional. Missing optional functionality should fail when
  the feature is used, not while the plugin is loaded.

For C plugins, use the version macro from the header for the plugin type you are
implementing:

```c
#include <selene/runtime.h>

const SeleneRuntimePluginDescriptorV1 selene_runtime_plugin_descriptor_v1 = {
    .header = {
        .struct_size = sizeof(SeleneRuntimePluginDescriptorV1),
        .api_version = SELENE_RUNTIME_CURRENT_API_VERSION,
        .last_error_fn = my_runtime_last_error,
        .get_name_fn = my_runtime_get_name,
    },
    /* callbacks */
};
```

For Rust plugins, use the export macro. It fills in the shared descriptor header
for you from the factory's `name()` method and the plugin type's current API
version.

## Instances and Ownership

The descriptor describes the plugin library. An instance is the state for one
configured Selene component. Selene can create more than one instance from the
same library, so do not store per-run state in global variables unless it is
protected and intentionally shared.

The C ABI represents instances as opaque pointers. The plugin allocates its
state during `init`, writes the pointer to the out-parameter, receives it back in
every callback, and frees it during `exit`.

The Rust helpers map that pattern onto boxed trait objects. Your plugin owns a
normal Rust struct; the export macro handles the opaque pointer conversion.

## Reporting Errors

Callbacks return `0` on success and a nonzero errno on failure. C and C++
plugins should not print callback failures to stderr. Instead, store a short
thread-local error message and expose it through the descriptor's
`last_error_fn` callback. Selene calls `last_error_fn` after a failing callback
and includes that message in the host-side error.

`last_error_fn` uses the same two-call buffer shape as gateset negotiation:

1. Selene calls it with `output == NULL` and `output_len == 0`.
   The plugin writes the number of bytes in the UTF-8 message to `written`.
2. Selene allocates a buffer and calls again. The plugin writes the message
   bytes into `output` and writes the byte count to `written`.

Rust plugins exported with Selene's helper macros get this behavior
automatically: any error returned from a callback is captured and reported
through `last_error_fn`.

## Header Ownership

The C headers are split by layer:

- `selene-core` owns plugin ABI headers such as `selene/runtime.h`,
  `selene/error_model.h`, `selene/simulator.h`, `selene/plugin.h`, and
  `selene/gatewire.h`.
- `selene-sim` owns the frontend C API in `selene/selene.h`, including
  `selene_load_config`, `selene_register_gateset`, `selene_gate`, result stream
  operations, and utility callback registration.

Third-party plugin packages should build against the headers provided by
`selene-core`. Frontends and QIS shims that call into a running Selene instance
also include `selene/selene.h` from `selene-sim`. If a C file uses gatewire
types or `gw_*` helpers, include `selene/gatewire.h` explicitly; do not rely on
`selene/selene.h` to pull it in.

## Gatewire and Gatesets

Gatewire is the gate transport layer. It solves two problems:

- A plugin should not need to know which Python method, QIS instruction, or
  frontend produced a gate.
- Selene should validate gate compatibility before operations are emitted.

A gate declaration contains:

- A semantic ID, such as `gatewire.builtin.RZ.v1`.
- A display name, such as `RZ`.
- A version.
- An ordered list of typed operands.

A gate instance contains the same semantic ID and concrete operand values. The
wire format is stable bytes. Rust code normally works with typed gate structs or
`OwnedGateInstance`; C code works with serialized bytes and the `gw_*` functions
from `selene/gatewire.h`.

The builtin gates are:

- `RZ(q0, theta)`
- `PhasedX(q0, theta, phi)`
- `ZZPhase(q0, q1, theta)`
- `PhasedXX(q0, q1, theta, phi)`

The old operation names are not part of the plugin API. If a QIS frontend has an
old or external name for a gate, it should translate that name into a gatewire
gate before calling Selene.

## Gateset Negotiation

Every plugin type must provide `negotiate_gateset_fn`.

The input is the gateset the previous layer may send. The output is the gateset
this plugin may send to the next layer. A plugin can:

- Return the input unchanged.
- Reject the input with an error.
- Accept the input but return a different output gateset after lowering.

For example, a runtime may accept `RZ` because users are allowed to write it, but
emit only `PhasedX` and `ZZPhase` after lowering. The simulator should validate
the gateset it actually receives from the error model, not the gateset the user
originally requested.

In Rust, prefer `DynamicGateSet::is_subset_of`,
`DynamicGateSet::is_superset_of`, or `DynamicGateSet::first_unsupported_by`
instead of open-coding declaration loops in every plugin. In C, use the
`GwGateSet` helpers from `selene/gatewire.h`.

The C ABI uses a two-call buffer protocol for gateset negotiation:

1. Selene calls the callback with `output == NULL` and `output_len == 0`.
   The plugin writes the required byte count to `written`.
2. Selene allocates a buffer and calls again. The plugin writes serialized
   gateset bytes into `output` and writes the byte count to `written`.

`negotiate_gateset_fn` is mandatory. A plugin that accepts and emits the same
gateset should still implement the callback explicitly by validating the input
and returning it unchanged. This keeps the supported gates visible in the plugin
contract instead of relying on an implicit fallback.

## Operations and Batches

The runtime does not call the simulator directly. It returns batches through a
callback interface. A batch can contain gates, measurements, resets, custom
operations, and timing information.

The error model receives the batch through an extractor interface, not as a raw
array. This keeps the C ABI stable while allowing Selene's internal batch
representation to change. The error model then calls the simulator operation
interface to apply gates, measurements, resets, or postselection.

Rust plugins normally see `BatchOperation` and `BatchResult` values. C plugins
see callback handles.

## Measurement Results

Runtimes assign result IDs when a measurement is scheduled. A result ID is a
future, not the measurement value. The runtime returns the ID to the interface,
and Selene later calls `set_bool_result` or `set_u64_result` when the simulator
result is available.

Runtimes must maintain reference counts for result IDs. Once a result's
reference count reaches zero, it is invalid to refer to it again.

Error models report measurement results back through an
`OperationResultHandle`. Simulators return measurement outcomes to the error
model immediately.

Postselection is part of the operation stream. A simulator should handle it
through its batch operation entry point and return a clear simulator error when
the requested postselection is impossible.

## Randomness and Reproducibility

`shot_start` receives a seed. Any plugin that uses randomness should derive all
per-shot randomness from that seed. A shot should be repeatable when rerun with
the same configuration and seed, regardless of how many shots came before it.

This matters most for error models, but it also applies to runtimes or
simulators that use randomized choices internally.

## Metrics

Each plugin can expose dynamic metrics. Selene calls `get_metric(0)`, then
`get_metric(1)`, and so on until the plugin reports that there are no more
metrics.

Metric names should describe the plugin's own behavior rather than hardcoding a
particular gate vocabulary. For example, prefer `injected_errors` or
`unsupported_gate_rejections` over names tied to a single builtin gate unless the
metric is genuinely gate-specific.

## Error Handling

Rust plugins return `anyhow::Result`. C plugins return `SeleneErrno`, where
zero means success and nonzero means failure. A failure normally aborts the
current emulation run and propagates to the user.

For gatewire functions, check `GwStatus`. A nonzero status means the gate or
gateset was invalid, the buffer was too small, or a pointer argument was wrong.

## Threading and Reentrancy

Plugin callbacks should not assume they are globally unique. Selene may create
multiple instances, and independent instances should not share mutable state by
accident. Keep instance state behind the instance pointer or Rust struct. If you
use process-global state, protect it explicitly and document why it is shared.
