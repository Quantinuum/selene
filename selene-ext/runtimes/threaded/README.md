# Threaded runtime

This runtime demonstrates how a runtime can own execution of a quantum endpoint
on a separate thread. It accepts calls from several user threads, while one
worker owns the scheduler and makes every endpoint call.

The example loads the simple runtime as its scheduler. Gates are queued without
waiting for the worker to acknowledge each call. Measurement requests return
future identifiers, and forcing a result executes the pending batches and
publishes their results. A forced endpoint borrow also executes pending work,
while a borrow without flushing leaves it pending. This example drains its
scheduler at shot end as well, but that is its cleanup policy rather than an API
requirement. Once the program has ended there are no further observable quantum
outcomes, so a runtime may discard unobserved quantum work instead. It must still
complete pending output and stop endpoint access before returning both handles.

From Python, select it in the same way as the other bundled runtimes:

```python
from selene_sim import Quest, ThreadedRuntime

results = runner.run_shots(
    simulator=Quest(),
    runtime=ThreadedRuntime(),
    n_qubits=10,
    n_shots=100,
)
```

`ThreadedRuntime` accepts the same gate-duration parameters as `SimpleRuntime`.
Its Python interface supplies the simple runtime library through the native
`--scheduler=<library>` argument. That library is loaded on the worker thread;
it is not required to be thread safe or transferable between threads.

The worker stays alive between shots. Libselene creates and starts its simulator
and error model through host callbacks on that worker, lends the endpoint to
the runtime, and collects metrics and ends the plugins after the runtime returns
it. Cleanup and destruction also happen on the worker, before it is joined.

The architecture and C contracts are described in
[the runtime documentation](../../../selene-core/rust/runtime/README.md).
The [C host example](../../../selene-core/examples/runtime/c/endpoint.c) supplies
its own endpoint and checks execution-thread affinity and borrow behaviour.
The Rust tests compile and run that example as well as exercising concurrent
submissions and recovery after failed execution or inspection.
