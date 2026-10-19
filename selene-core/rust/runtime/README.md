# Runtimes and quantum peripherals

A runtime is the classical controller of a hybrid quantum program. It accepts
instruction objects from the program and decides how to schedule them. A quantum
peripheral is what the runtime drives: it accepts batches of quantum operations
and returns measurement results.

In libselene, a peripheral combines an error model with a simulator. Depending on
the configuration, we wrap their calls with event hooks to record traces,
measurements and metrics. The runtime does not need to know about those layers.
It sees a stateful object with a C function table, in the same way that an error
model sees the simulator passed to it.

The [plugin API versioning](../README.md) describes the versioned Rust modules
and C headers shared by runtimes, simulators and error models.

## Program instructions

The program-facing API and the peripheral-facing API describe different stages
of execution. A `RuntimeInstruction` asks the runtime to allocate a qubit, apply
a gate, measure, print a value or exit. The runtime schedules that work and sends
batches of `Operation` objects to the peripheral.

An API 0.4 runtime implements one `handle_instruction` method. In C, its descriptor
has a `handle_instruction_fn` taking a `SeleneRuntimeInstruction` and a result
pointer. The instruction contains its size, an integer tag and a union of typed
payloads. For example:

```c
SeleneRuntimeInstruction instruction = {
    .struct_size = sizeof(instruction),
    .tag = SeleneRuntimeInstructionTag_RXYGate,
    .payload.rxy_gate = { .qubit_id = qubit, .theta = theta, .phi = phi },
};
SeleneRuntimeInstructionResult result;
runtime->handle_instruction_fn(instance, &instruction, &result);
```

`QAlloc` returns a qubit address; measurements return a future. Result queries
return a value and whether it is available. Other instructions return no value.
The header documents each result kind. No u64 value is reserved to represent an
unavailable result in this interface.

C request buffers are borrowed until the handler returns. If the runtime queues
an instruction, it must copy all its inputs first, including nested print arrays
and backtrace entries. The Rust instruction enum owns its buffers. Its C adapters
perform those copies, so Rust implementations can put the instruction itself on
a queue. Unknown C tags and undersized requests are rejected before reading their
payloads.

Calls made sequentially by one thread keep their order. Concurrent calls acquire
an order when the runtime accepts them. A gate or print may return once accepted;
queries that need a value wait for their reply. `ForceResult` makes its result
available before returning. Lifecycle, metric enumeration and peripheral borrowing
remain separate functions because they manage access to the runtime and its shot.

## Printing and exiting

Libselene keeps the output encoder and lends the runtime a `SeleneOutputSink`
alongside the peripheral at shot start. The runtime orders `Print` instructions
and calls the sink on its execution thread. The sink writes complete records and
can write a diagnostic and its backtrace together without another writer
interleaving records. Program requests contain no timestamps; the runtime supplies
the output timestamp when calling the sink.

Printing a value does not force pending quantum work to execute. It writes the
value supplied by the program. Inspecting simulator state has different
requirements and uses the forced borrow described below. Reading libselene's
internal output buffer waits for earlier queued prints, without forcing quantum
execution.

QIS panic and exit both become an `Exit` instruction. Their code ranges carry the
distinction. Exit is synchronous: it closes the shot to further program
instructions, compiles and executes earlier quantum work, writes earlier output
and the exit diagnostic, and flushes the output transport before returning. If
execution or output fails, it must still leave no background peripheral access
running and be ready for `shot_end`. It keeps both handles until shot end returns.

Libselene captures a panic's backtrace on the calling program thread. The runtime
must return normally through every Rust and C FFI frame. Only then does the C QIS
interface perform its `longjmp` to the program wrapper on that same thread. The
runtime never invokes a callback to jump out of its own stack. Program threads
need their own valid C program boundary; thread-safe runtime entry does not make
a jump to another thread's boundary valid.

Libselene reports its own failures directly through the encoder, because a broken
runtime must not be needed to report that it failed. Shot markers and final
metadata also belong to the host. The sink synchronises those writes with program
output, but its callbacks must not re-enter the runtime.

## Owning execution

Current runtimes export `SeleneRuntimePluginDescriptorV2` from
`selene/runtime.h`. The descriptor uses API 0.4.x. A plugin can export
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
   runtime's `shot_start_fn`, together with its output sink.
3. The runtime exclusively drives the peripheral during the shot. Libselene can
   temporarily borrow it through the callback interface described below.
4. The runtime's `shot_end_fn` finishes submitted work and releases both handles.
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
failure must be reported by a subsequent synchronising operation or shot end. After a
`ForceResult` instruction succeeds, the requested result must be available: the host does
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

The original Rust interface lives in `selene_core::runtime::v0_3`, and its C
header is `selene/runtime/v0_3.h`. Both describe API 0.3.x and
`SeleneRuntimePluginDescriptorV1`, whose layout and symbols are unchanged. The
loader chooses descriptor V2 when it is advertised and otherwise wraps V1 in
`runtime::adapters::LegacyRuntime`. An invalid advertised V2 is an error rather
than a reason to try V1.

The adapter in `runtime::adapters::v0_3_to_v0_4` implements the current interface
using an API 0.3 runtime. The wrapper translates instruction objects into the
original API functions. Print instructions write directly to the host sink. Exit flushes the old scheduler and
prints its diagnostic before returning, without destroying the old runtime.

The wrapper preserves the original calling-thread path. After recording a user
call, libselene polls `get_next_operations()`, executes the returned batches and
publishes their results, just as the original emulator did. It also preserves
metric collection before legacy shot end, because an older runtime may reset its
counters there. No worker or per-call channel is introduced. An old runtime does
not gain concurrent-entry support: calls on a legacy instance must stay on its
initialising thread.

The simulator and error-model plugin interfaces are unchanged in both paths.

## Rust implementations

The current runtime API is available from `selene_core::runtime` and explicitly
from `selene_core::runtime::v0_4`. New implementations use its `RuntimeInterface`,
`RuntimeInterfaceFactory` and `export_runtime_plugin!`. Their methods take
`&self`, and the implementation synchronises its scheduling state. Hosts construct
`RuntimeInstruction` objects and call the same handler directly. Results provide
checked conversions for the expected qubit, future or value. `destroy` tears
down the plugin instance, while an `Exit` instruction ends program execution
within the current shot.

The new runtime trait is unsafe to implement because scoped host callbacks rely
on its lifetime, exclusivity and execution-thread guarantees. The
`runtime::on_execution_thread` and `runtime::borrow_peripheral` helpers accept
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
