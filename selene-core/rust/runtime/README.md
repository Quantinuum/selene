# Runtimes and quantum peripherals

A runtime is the classical controller of a hybrid quantum program. It accepts
operations from the program and decides how to schedule them. A quantum
peripheral is what the runtime drives: it accepts batches of quantum operations
and returns measurement results.

In libselene, a peripheral combines an error model with a simulator. Depending on
the configuration, we wrap their calls with event hooks to record traces,
measurements and metrics. The runtime does not need to know about those layers.
It sees a stateful object with a C function table, in the same way that an error
model sees the simulator passed to it.

## Owning execution

Peripheral runtimes export `SeleneRuntimePluginDescriptorV2` from
`selene/pipeline_runtime.h`. The descriptor uses API 0.4.x. A plugin can export
`selene_runtime_plugin_descriptor_v2` or return the descriptor from
`selene_runtime_get_plugin_descriptor_v2()`.

The runtime's incoming interface is thread safe, so several program threads can
submit instructions to the same instance. Its outgoing interface has a different
contract: one fixed execution thread performs every peripheral call, in order.
A runtime can use the calling thread or choose a separate thread. Libselene does
not add a queue or wait for an acknowledgement after each submitted gate.

Libselene owns the simulator and error-model lifecycle:

1. It uses `on_execution_thread_fn` to load the plugins and create their wrappers
   on the runtime's execution thread.
2. On that thread, it starts their shots, then gives the peripheral handle to the
   runtime's `shot_start_fn`.
3. The runtime exclusively drives the peripheral during the shot. Libselene can
   temporarily borrow it through the callback interface described below.
4. The runtime's `shot_end_fn` finishes submitted work and releases the handle.
   This release must also happen if execution fails.
5. Libselene collects plugin metrics and ends their shots on the execution
   thread. It can reuse the plugins for another shot. When the instance ends,
   it also cleans up and drops them on that thread, before exiting the runtime.

The execution-thread callback remains available between shots so that lifecycle
operations do not accidentally move a plugin to another thread. Serial access
alone is not sufficient for a plugin that uses thread-local implementation
state. The runtime invokes these callbacks, but their contents and lifecycle
policy belong to libselene.

A failed `shot_start_fn` must return without retaining the peripheral. A runtime
must not call a peripheral or retain any callback after handing it back. The
host must stop and join its submitting program threads before lifecycle calls;
queued work inside the runtime is completed by the runtime itself.

## Executing batches

`SeleneQuantumPeripheral` contains an opaque instance pointer and an operation
table. `handle_operations_fn` accepts a batch extractor and a result sink. The
runtime supplies result identifiers in its measurement operations, and the
peripheral writes values with those identifiers into the sink before returning.
Neither side may retain the batch or result callbacks after the call.

The runtime decides when to execute. It might submit each batch immediately, or
queue and optimise instructions until a measurement value is required. A queued
submission acknowledges acceptance rather than completed execution; an execution
failure must be reported by a subsequent synchronising operation or shot end. After
`force_result_fn` succeeds, the requested result must be available: the host does
not poll `get_next_operations()` for a peripheral runtime.

The operation and result interfaces make no reference to an error model or a
particular simulator. A C implementation can provide a peripheral directly;
`selene-core/examples/runtime/c/peripheral.c` demonstrates a complete C host and
peripheral driving the threaded runtime plugin.

## Borrowing the peripheral

State inspection needs access to the same state that the runtime is driving.
The host calls:

```c
SelenePeripheralBorrowRequest request = {
    .struct_size = sizeof(request),
    .force_flush = true,
};
runtime->borrow_peripheral_fn(instance, &request, inspect, context);
```

The request describes the access requirements. The callback's `context` is
separate and opaque to the runtime. The public libselene utility entry point,
`selene_borrow_peripheral`, has the same request/callback/context arrangement.

Both forms run the callback exclusively on the peripheral's execution thread
and wait for it to return. The callback must not retain the handle, re-enter the
same runtime, or unwind across the C boundary. If a callback fails, the runtime
still releases the borrow and can continue its own cleanup.

With `force_flush = false`, the runtime finishes any peripheral call already in
progress but may leave scheduled instructions pending. With `force_flush = true`,
it compiles and executes all work ordered before the borrow and publishes its
results before invoking the callback. A runtime that cannot meet the requested
boundary returns an error without invoking the callback.

The boundary applies to the whole peripheral. An inspection of some qubits can
depend on operations involving other qubits, so the request does not select a
subset to flush. Concurrent submissions have a defined order relative to the
borrow; later submissions need not finish before it. The request carries its
size so future versions can add more access requirements.

Libselene uses a forced borrow when a user program asks for a state dump. This
means that an X gate followed by a state dump observes the gate even if the
runtime normally postpones execution until measurement.

## Existing runtimes

API 0.3.x and `SeleneRuntimePluginDescriptorV1` are unchanged. The loader chooses
v2 when it is advertised and otherwise wraps v1 in `pipeline::LegacyRuntime`.
An invalid advertised v2 is an error rather than a reason to try v1.

The wrapper preserves the original calling-thread path. After recording a user
call, libselene polls `get_next_operations()`, executes the returned batches and
publishes their results, just as the original emulator did. It also preserves
metric collection before legacy shot end, because an older runtime may reset its
counters there. No worker or per-call channel is introduced. An old runtime does
not gain concurrent-entry support: calls on a legacy instance must stay on its
initialising thread.

The simulator and error-model plugin interfaces are unchanged in both paths.

## Rust implementations

The original runtime traits remain in `selene_core::runtime`. New implementations
use `selene_core::runtime::pipeline::{RuntimeInterface, RuntimeInterfaceFactory}`
and `export_pipeline_runtime_plugin!`. Their methods take `&self`, and the
implementation synchronises its scheduling state.

The new runtime trait is unsafe to implement because scoped host callbacks rely
on its lifetime, exclusivity and execution-thread guarantees. The
`pipeline::on_execution_thread` and `pipeline::borrow_peripheral` helpers accept
scoped Rust closures, return their results and keep panics inside Rust. Captures
and return values must be `Send`; the peripheral itself need not be. The
`QuantumPeripheral` wrapper cannot be moved or shared between threads.

`QuantumPeripheralFFIAdapter` exposes a Rust `QuantumPeripheralInterface` through
the same C function table used by native plugins. This keeps the Rust and C
interfaces on the same ownership path rather than providing two execution
implementations.

On Linux, the C example can also be built and run directly from the repository
root after building the workspace:

```sh
cc -std=c17 -Wall -Wextra -Werror -I selene-core/c/include \
    selene-core/examples/runtime/c/peripheral.c -ldl -pthread -o /tmp/peripheral
/tmp/peripheral target/release/libselene_threaded_runtime.so \
    target/release/libselene_simple_runtime.so
```
