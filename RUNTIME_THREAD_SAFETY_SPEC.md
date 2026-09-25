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
| Allocation/free, gates, measurement/reset, barriers, custom calls, simulated delays | May overlap other operational calls on the same instance. |
| Forcing results, reading/publishing results, future reference-count updates | May overlap user calls and operation retrieval. |
| `get_next_operations` | One consumer per instance; may overlap user calls. The consumer retrieves and executes batches in order and publishes results. |
| `shot_start`, `exit` | Caller excludes other calls on that instance. |
| `shot_end` | Serialized with start, exit, and metrics; existing worker operations and required retrieval/publication may overlap until workers join. |
| Metric collection | Caller ensures the instance is quiescent throughout collection: no calls are in progress and no new calls begin until collection finishes. Between shots is an appropriate collection point. |
| Initialization | Completes before the new instance is shared. |

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

- Enabling user-program threads or implementing their scheduling and waiting in
  the emulator.
- Multiple simultaneous batch consumers for one runtime instance.
- Concurrent lifecycle operations or metric collection during runtime activity.
- General thread-safety changes to simulator and error-model plugin interfaces.
- A new deterministic ordering policy for independent user threads, or a broad
  runtime performance redesign.

## Implementation handoff

Runtime API version is now 0.4.0. Every Rust receiver is shared, and runtime
interfaces and factories require `Send + Sync`. Implementations synchronize
lifecycle and metric access internally as well as operational access. FFI adapters
use shared references for every call; no `UnsafeCell` or mutable-access helper is
needed.

The simple, soft-RZ, and example runtimes use a scheduling mutex and a separate
result read/write lock. Calls needing both acquire scheduling before results.
Result publication and readers do not acquire the scheduling lock. The loaded
plugin wrapper serializes start, end, exit, and metrics with a separate lifecycle
mutex. Operations and end share an access lock; start, exit, and metrics take it
exclusively. Acquiring the lifecycle mutex first prevents a queued start, exit,
or metric writer from blocking worker callbacks while end joins them. Retrieval
is serialized separately. The host stops unrelated submissions before end and
retains the instance and library until workers have joined. The host
remains responsible for ordered execution/publication, lifecycle sequencing, and
keeping the instance idle throughout a complete metric enumeration.

Native tests cover concurrent submission/forcing/draining, already-dispatched
results, leakage forcing, sequential gate behavior, independent result access,
and parallel FFI entry with reference-count updates. The example also has a
regression test for its corrected local-barrier indices. Version rejection,
Clippy, Rust documentation, generated-header consistency, and C/C++ header checks
were validated. The emulator compiles against the new API. The Python integration
suite has not been run; the current Python environment lacks `selene_sim`.
