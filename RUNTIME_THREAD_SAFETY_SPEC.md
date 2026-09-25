# How runtime plugins share work between threads

A user program can have several threads submitting quantum operations to the
same runtime. The runtime schedules those operations, while one consumer thread
runs them on the simulator and writes back measurement results. This guide
explains how those parts cooperate and where they need to wait for each other.

For instructions on writing a plugin, start with the
[Selene-Core README](selene-core/README.md#writing-a-runtime-plugin).

## Who can call what?

Most runtime calls can overlap. A user thread can submit a gate while another
reads a result and the consumer collects the next batch. Each plugin must protect
its mutable state, including any state shared between separate instances.
A mutex is fine. Supporting concurrent callers doesn't mean every operation
needs to execute in parallel inside the plugin.

There are a few points where the host needs to pause other calls:

| Activity | How the host coordinates it |
| --- | --- |
| Initializing an instance | Finish initialization before sharing it. |
| Submitting operations, forcing or reading results, updating reference counts | Allow concurrent calls on the same instance. |
| Collecting batches and publishing results | Use one consumer that collects and executes batches in order. User calls can overlap this work. |
| Starting or ending a shot, or exiting | Wait for other calls to finish and keep new calls out. |
| Collecting metrics | Keep the instance idle for the whole collection, including the gaps between calls for individual metrics. |

These rules don't remove the need to keep qubits, result references, and buffers
valid while using them. They also don't give independent user threads a
deterministic order when they operate on the same qubit.

## Following a measurement through the system

Suppose a user thread schedules a measurement and receives a result ID. The
runtime may keep that measurement in its queue while it builds a batch. When
the user needs the value, `force_result` tells the runtime to make the required
work available to the consumer.

The consumer calls `get_next_operations`, runs the returned work, and publishes
measurement values through `set_bool_result` or `set_u64_result`. It may need to
process several batches to reach a forced measurement. Other threads can keep
submitting work, but they must not postpone the forced measurement indefinitely.
A force request that arrives during batch retrieval must still take effect.

The measurement might already be with the consumer when it is forced. In that
case there's no need to queue it again. The user still needs to check its result
getter: an empty queue doesn't mean the consumer has finished the batch it took
earlier. Once the consumer has executed the measurement and published its value,
the getter must report that value as ready.

Don't hold a runtime lock while waiting if the consumer needs that lock to
collect work or publish the result. Otherwise each side ends up waiting for
the other.

## How Selene coordinates the calls

The emulator's [consumer](selene-sim/rust/emulator/consumer.rs) owns the simulator
and error model. It creates them, makes all their calls, and drops them on its
own thread. Those plugins therefore don't need to support concurrent calls.
Calls through the quantum instruction set (QIS) interface explicitly ask the
consumer to collect work. It can therefore sleep between requests instead of
polling the runtime.

Output records and random-number operations each run one at a time. Their order
between user threads can vary. The output time cursor is also shared, so setting
it and printing are separate operations: another thread can change it in between.
The host must join its user threads before destroying the Selene instance.

## Implementing the Rust interface

[`RuntimeInterface`](selene-core/rust/runtime/interface.rs) and its factory
require `Send + Sync`. Every runtime method takes `&self`, including shot
boundaries and metrics. An implementation must remain memory-safe even if Rust
callers overlap those methods. The host's coordination is needed for correct
shot behavior, but safe Rust code cannot rely on that coordination to prevent
invalid memory access.

The simple, soft-RZ, and example runtimes keep scheduling state under one mutex
and results under a separate read/write lock. This lets the consumer publish a
result without waiting for scheduling. Whenever a call needs both locks, it
takes the scheduling lock first and the result lock second. Using one order
prevents callers from deadlocking by each holding the lock the other needs.

The export helper and inline adapter borrow the runtime through shared
references. The inline handle points into the adapter itself, so its owner must
keep the adapter alive and at the same address while the handle is in use.
The core `Runtime` wrapper does this by owning the adapter in a `Box`.

## Loading C plugins

New plugins export a v2 descriptor for API 0.4.x. Its `RuntimeInstanceV2` handle
is a const pointer because callers share access. The plugin still synchronizes
its mutable state. Output pointers remain writable, including the pointer used
to return a newly initialized instance.

The loaded-plugin wrapper uses locks to prevent lifecycle and metric calls
from overlapping other calls. It also allows only one batch retrieval at a time.
Those locks protect individual calls into C. The host still needs to keep a
whole metric collection idle and execute collected batches in order.

Older v1 plugins, built for API 0.3.x, keep their original mutable-pointer handle
and function signatures. Selene gives each legacy instance a dedicated thread
for initialization, calls, and cleanup. The adapter sends requests to that
thread and waits for replies. It copies inputs and returns owned batches and
values, keeping borrowed plugin memory and callbacks on the plugin's thread.
Cleanup runs at most once, either on explicit exit or when the adapter is dropped.
Calls after explicit exit return errors.

A legacy result getter must return "not ready" if the value is unavailable.
Waiting inside that getter would block the thread that must also accept result
publication. The adapter cannot run those two calls concurrently to break the
deadlock.

The loader prefers v2. It only tries v1 when neither v2 export is present, and
reports a broken v2 interface as an error. V2 accepts API 0.4.x and v1 accepts
API 0.3.x, including patch releases within each minor version. Older Rust source
still needs updating when it adopts the current trait.

## Where to look in the code

- [Runtime traits](selene-core/rust/runtime/interface.rs) describe what plugin
  authors implement and what callers can expect.
- [Plugin loading](selene-core/rust/runtime/plugin.rs) checks descriptors and
  protects calls into concurrent C plugins.
- [The legacy adapter](selene-core/rust/runtime/plugin/legacy.rs) keeps each old
  plugin instance on its own thread.
- [The export helper](selene-core/rust/runtime/helper.rs) and
  [inline adapter](selene-core/rust/runtime/inline.rs) connect Rust runtimes to
  the C interface.
- [The emulator](selene-sim/rust/emulator.rs) sends work to its consumer and
  reads back measurement results.

The runtime tests exercise concurrent submission, forcing, result access, and
reference counting. Separate FFI tests exercise the export helper and inline
adapter. The legacy compatibility tests compile a fixture against a frozen old
header, so changes to today's header cannot hide a break in the old ABI.
