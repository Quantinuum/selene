# Runtime plugin thread safety: step 1

Status: implemented; multithreaded user execution remains subsequent work.

## Objective

Prepare runtime plugin interfaces and implementations for multithreaded user
programs. This step establishes and implements the runtime concurrency contract;
enabling multithreaded user execution in the emulator is subsequent work.

Correctness takes priority. Use mutexes where needed, and include straightforward
changes that permit useful parallelism. No lock-free design or extensive
performance redesign is required.

## Concurrency contract

The contract applies to concurrent calls on the **same runtime instance**.
Separate instances must also be safe to use concurrently; shared plugin state
must not introduce races between them.

| Calls | Required behavior |
| --- | --- |
| Allocation/free, gates, measurement/reset, barriers, custom calls, simulated delays | May overlap other operational calls on the same instance. |
| Forcing results, reading/publishing results, future reference-count updates | May overlap user calls and operation retrieval. |
| `get_next_operations` | One consumer per instance; may overlap user calls. The consumer retrieves and executes batches in order and publishes results. |
| `shot_start`, `shot_end`, `exit` | Caller ensures no other calls overlap on that instance. |
| Metric collection | Caller ensures the instance is quiescent throughout collection: no calls are in progress and no new calls begin until collection finishes. Between shots is an appropriate collection point. |
| Initialization | Completes before the new instance is shared. |

Thread safety does not require simultaneous execution internally. Serializing
operations with a per-instance mutex is valid. Existing validity and lifetime
requirements for qubits, results, and input/output buffers remain applicable.
This step does not define new user-language semantics for conflicting operations
on a shared qubit.

## Forced results and draining

`get_next_operations` returns operations, not measurement values. The consumer
executes returned measurements and publishes their values through
`set_bool_result` or `set_u64_result`.

After `force_result(r)` successfully returns, subsequent draining must expose the
operations needed to resolve `r`, unless those operations have already been
handed to the consumer or the result is already available. Executing those
operations and publishing their results must make `r` available through its
result getter.

This preserves the existing drain-batches guarantee. It does not require the
measurement to appear in the very next batch. Concurrent submissions must not
indefinitely postpone a forced measurement. A force request overlapping a batch
retrieval must not be lost.

The eventual host integration must wait for the requested result itself, rather
than assume a particular batch belongs to the requesting thread. An empty batch
alone is not proof that an already-dispatched measurement result is available.
The consumer remains responsible for executing dispatched work and publishing
results.

No internal runtime lock may be held while waiting for a measurement result in a
way that prevents the consumer from retrieving work or publishing that result.

## Interface changes

- Change the opaque `RuntimeInstance` from `*mut c_void` to `*const c_void`, with
  the corresponding const pointee in the generated C header.
- Preserve mutable output pointers, including `init`'s `*mut RuntimeInstance`
  and result/metric output buffers. This is not a blanket conversion of all
  pointers to const.
- Apply the instance-pointer change consistently to the plugin descriptor,
  loaded plugin wrapper, inline operation interface, adapter, and export helper.
- Use shared Rust receivers for every method, including lifecycle and metrics,
  and require `Send + Sync`. Implementors synchronize mutable state internally.
  All calls must remain memory-safe if overlapped; host-side lifecycle exclusion
  remains a protocol requirement for correct shot semantics.
- Document the concurrency rules in the Rust API and C-facing plugin contract.
  Const pointers express shared access; they do not establish thread safety by
  themselves.

## Implementation guidance

Audit both Rust-to-FFI paths. The export helper currently reconstructs a `Box`
and obtains mutable access for each call; the inline adapter also obtains mutable
access for each call. These patterns must be replaced or protected so overlapping
calls cannot create overlapping exclusive references.

Update the bundled simple and soft-RZ runtimes and the runtime example to satisfy
the new contract. Start with per-instance synchronization where appropriate.
Separate independently accessed state when that is straightforward and useful;
do not require a particular lock layout. Review queue operations, forced flush
state, result publication, and reference counts together for races and progress.

Keep synchronization scoped to instances wherever possible. Do not add unchecked
`Send`/`Sync` implementations merely to satisfy compilation: any unsafe boundary
must be justified by ownership, synchronization, and the documented plugin
contract. Preserve call-scoped ownership of output buffers and batch callbacks.

The host-side single-consumer rule covers ordered execution and result
publication, not just exclusion between two retrieval calls. Runtime changes
must support this future integration without claiming that user-program
multithreading is enabled by this step.

## Compatibility

Bump the runtime API minor version because existing plugins have not promised
this concurrency contract, even if the pointer change preserves binary layout.
Keep packed and decomposed version constants consistent and ensure old runtime
API versions are rejected. Regenerate the runtime C header using the repository's
existing process and update affected fixtures and documentation.

## Implementation entry points

- `selene-core/rust/runtime/plugin.rs`: instance type, descriptor, loader, wrapper.
- `selene-core/rust/runtime/interface.rs`: Rust traits and behavioral contract.
- `selene-core/rust/runtime/helper.rs`: exported plugin entry points.
- `selene-core/rust/runtime/inline.rs`: inline handle, function table, adapter.
- `selene-core/rust/runtime.rs`: core runtime wrapper.
- `selene-core/rust/runtime/version.rs`: API version and compatibility checks.
- `selene-core/c/include/selene/runtime.h` and
  `selene-core/cbindgen/runtime.toml`: C API generation.
- `selene-ext/runtimes/simple/rust/lib.rs` and
  `selene-ext/runtimes/soft_rz/rust/lib.rs`: bundled implementations.
- `selene-core/examples/runtime`: example implementation.
- `selene-sim/rust/emulator.rs`: existing forcing/draining integration to preserve;
  broader concurrent host execution is outside this step.

## Acceptance criteria

1. Rust interfaces, exported entry points, inline adapters, and generated C
   declarations agree on const instance pointers and mutable output pointers.
2. Every runtime method has an unambiguous concurrency classification, including
   lifecycle and quiescent metric collection.
3. Bundled and example runtimes compile against the new interface, and existing
   sequential runtime behavior remains covered by passing relevant tests.
4. Focused concurrency tests exercise submission and forcing while a single
   consumer drains and publishes results. Multiple forced results resolve,
   including when their operations were already dispatched.
5. Tests exercise concurrent result access/publication and reference-count
   operations under valid lifetimes, checking for lost updates and duplicate or
   missing work. Use controlled synchronization rather than timing-only sleeps
   to exercise important interleavings.
6. Tests cover the export-helper and inline-adapter paths sufficiently to verify
   that synchronization is applied at those boundaries, not just in direct calls
   to a runtime implementation.
7. Version checks reject the previous runtime API version, and generated headers
   and version constants are consistent.

## Out of scope

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
plugin wrapper takes a shared access lock for operational calls and an exclusive
access lock for lifecycle/metric calls, and separately serializes retrieval. This
upholds per-call C ABI exclusion even when safe Rust callers race. The host
remains responsible for ordered execution/publication, lifecycle sequencing, and
keeping the instance idle throughout a complete metric enumeration.

Native tests cover concurrent submission/forcing/draining, already-dispatched
results, leakage forcing, sequential gate behavior, independent result access,
and parallel FFI entry with reference-count updates. The example also has a
regression test for its corrected local-barrier indices. Version rejection,
Clippy, Rust documentation, generated-header consistency, and C/C++ header checks
were validated. The emulator compiles against the new API. The Python integration
suite has not been run; the current Python environment lacks `selene_sim`.
