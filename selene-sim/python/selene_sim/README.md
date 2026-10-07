![Selene Logo](https://raw.githubusercontent.com/quantinuum/selene/refs/heads/main/assets/selene_logo.svg)

# Selene
Selene is a quantum computer emulation platform written primarily in Rust with a python frontend.

Selene is built with flexibility in mind. This includes:
- A plugin system for the addition of additional components including simulators, error models, quantum runtimes to be provided within Selene or as third party plugins
- Support for custom input formats and device APIs through [the selene-core build system](https://github.com/quantinuum/selene/tree/main/selene-core/python/selene_core/build_utils).

## What's included

Out of the box, Selene provides first-class support for the [HUGR](https://github.com/quantinuum/hugr) ecosystem, including execution of [Guppy](https://github.com/quantinuum/guppy) programs in an emulation environment, making use of our [open-source compiler](https://github.com/quantinuum/tket2/tree/main/qis-compiler/). You can find many examples of guppy usage in our [unit tests](https://github.com/quantinuum/selene/tree/main/selene-sim/python/tests/test_guppy.py).

Selene provides a range of simulators, including:
- Statevector simulation using [QuEST](https://github.com/QuEST-Kit/QuEST) and the [quest-sys crate](https://crates.io/crates/quest-sys).
- Stabilizer simulation using [Stim](https://github.com/quantumlib/Stim)
- Coinflip simulation with customisable bias
- Classical Replay, for running pre-recorded measurements without direct simulation
- Quantum Replay, for running pre-recorded measurements with postselection-based simulation

Error models that are currently provided include:
- An 'ideal' error model which adds no noise to simulations
- A depolarizing error model which adds noise to qubit initialisation, measurement, and single- and two-qubit gates

And we offer two example quantum runtimes, including:
- Simple, which executes the program as-is, without any modifications
- SoftRZ, which elides Z rotations through RXY gates, providing the same observable behaviour with fewer quantum operations

## Traces

Pass a `TraceStore` event hook to `runner.run` or `runner.run_shots` to collect
versioned traces directly from the backend:

```python
from selene_sim.event_hooks import TraceStore

with TraceStore() as traces:
    results = [
        list(shot)
        for shot in runner.run_shots(Stim(), n_qubits=10, n_shots=3, event_hook=traces)
    ]
    for event in traces.shots[0].iter_events():
        print(event)
    # Only request this if we need all events in memory at once.
    trace = traces.shots[0].get_trace()
```

The backend writes gzipped JSON Lines files in the run's artifact directory and sends
`TRACE` records containing their filenames through the result stream. The files
must be accessible to the frontend, just like state-result files. `TraceStore`
copies the compressed artifacts into its own temporary directory as the results
are processed, but doesn't decode them. Each shot provides a repeatable event
iterator over its files, including any intermediate metadata flushes. Reading
doesn't cache events. File-format, event-validation, and gzip-integrity errors
are raised during iteration, with filename and line context. Exhaust the iterator
to validate the complete file.

The owned copies allow lazy access after the run directory has been removed.
Use the store as a context manager or call `close()` to remove its copies when
finished. Closing invalidates subsequent file-backed reads; an already
materialised `Trace` is independent of the store. Otherwise the copies are
removed when the store and its shot views are garbage-collected.
For `parse_results=False`, pass the hook to `postprocess_unparsed_stream` as
well, and keep the artifact files until postprocessing has finished.

`CircuitExtractor` uses a `TraceStore` internally and still provides its circuit
and instruction views by iterating events. `extractor.shots[0].get_trace()`
delegates to the shot's materialiser, which returns a complete `Trace` without
caching it. If you want both interfaces, use `extractor.trace_store` rather than
registering the same store as a second event hook.

### Trace artifact format

The `.jsonl.gz` format and its readers/writers belong to
[selene-api-models](../../../selene-trace/README.md#streaming-trace-files).
Selene handles when to drain events, where to keep artifacts, and when their
filenames can be published. The Python API also accepts older uncompressed
whole-document JSON files, although those require whole-file parsing.

Event callbacks only append to a pending buffer. Checked emulator checkpoints
drain that buffer after each runtime batch and after the runtime loop, without
finishing the gzip stream. A metadata flush drains any remaining events, finishes
and closes the file, then publishes its filename. Later events go into a new
file. Failed files are not published or retried, and unfinished files are removed
when their backend writer is dropped.

Runtime batch boundaries and measurement instruction distinctions are kept as
file-level metadata for circuit extraction. They are not gates or additional
trace events. `get_trace()` preserves the existing trace representation,
including measurement events for future reads, without adding that metadata.

## Usage example

Although examples are provided in our [tests](https://github.com/quantinuum/selene/tree/main/selene-sim/python/tests) folder, here is a quick walkthrough to get you started with Selene, HUGR and Guppy.

- First, we define the guppy program that we're interested in emulating:

```python
from guppylang import guppy
from guppylang.std.quantum import *
from hugr.qsystem.result import QsysShot, QsysResult

@guppy
def main() -> None:
    # allocate 10 qubits
    qubits = array(qubit() for _ in range(10))

    # prepare the 10-qubit GHZ state (|0000000000> + |1111111111>)/sqrt(2)
    h(qubits[0])
    for i in range(9):
        cx(qubits[i], qubits[i+1])

    # measure all qubits
    ms = measure_array(qubits)

    # report measurements to the results stream
    result("measurements", ms)

compiled_hugr = main.compile()
```

- Then we compile the resulting HUGR Envelope to LLVM IR or bitcode using the HUGR-QIS compiler

```python
from selene_sim import build
runner = build(compiled_hugr)
```

- Then we can utilise `run` or `run_shots` on the resulting selene instance, choosing a simulator (in this case Quest or Stim) and an error model (in this case DepolarizingErrorModel) to run the program.

```python
from selene_sim import Quest, Stim
# run a single shot with Quest, the statevector simulator
shot = QsysShot(runner.run(simulator=Quest(), n_qubits=10))
print(shot)

# run a single shot with Stim, the stabilizer simulator
shot = QsysShot(runner.run(simulator=Stim(), n_qubits=10))
print(shot)

# run_shots runs efficient multi-shot simulations
# n_processes provides multi-processing across shots
# deterministic results can be achieved by providing a random seed
shots = QsysShot(runner.run(
    simulator=Stim(random_seed=5),
    n_qubits=10,
    n_shots=100,
    n_processes=8
))
print(shots)
```

- As well as simulators, we can customise the emulation by providing an error model, such as the depolarizing error model:

```python
from selene_sim import DepolarizingErrorModel
error_model = DepolarizingErrorModel(
    random_seed=12478918,
    p_init=1e-3,
    p_meas=1e-2,
    p_1q=1e-5,
    p_2q=1e-6,
)

shots = QsysResult(runner.run_shots(
    simulator=Stim(
        random_seed=10
    ), 
    error_model=error_model,
    n_qubits=10,
    n_shots=20,
    n_processes=4,
))
print(shots)
```

- And/or a runtime, such as the SoftRZRuntime, which elides physical RZ gates through subsequent RXY gates:
```python
from selene_sim import SoftRZRuntime

shots = QsysResult(runner.run_shots(
    simulator=Stim(),
    runtime=SoftRZRuntime(),
    error_model=error_model,
    n_qubits=10,
    n_shots=20
))
print(shots)
```
