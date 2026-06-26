# Clifford+T Stack Example

This is a complete, buildable Selene example that uses a custom Clifford+T
gateset instead of Selene's builtin `RZ`, `PhasedX`, `ZZPhase`, or `PhasedXX`
gates.

The example follows the normal Selene workflow:

1. A user program is provided to `selene_sim.build`.
2. A custom `QuantumInterface` registers build-planner kinds and steps.
3. The build step invokes Zig to compile the user program and a C QIS shim into
   a Selene object file.
4. Selene's existing build steps link that object into a normal executable.
5. `instance.run_shots(...)` runs the executable with the custom runtime, error
   model, and simulator plugins.
6. The C QIS shim registers the Clifford+T gateset with Selene after
   `selene_load_config`, then emits generic `selene_gate(...)` calls.

The simulator is a C++ plugin backed by Qrack's `QStabilizerHybrid`. It starts
from Qrack's stabilizer machinery, enables exact near-Clifford/T-injection
handling, and reports an error if Qrack falls back to a full generic engine.
The runtime and error model remain Rust plugins.

## Step 1: Build and Test the Rust Plugins

Run from this directory:

```bash
direnv exec ../.. cargo test --manifest-path "$PWD/Cargo.toml"
```

The Rust tests compile the example runtime/error-model library and exercise the
in-process interface/runtime/error-model path with a small Rust test simulator.
They check that:

- The runtime, error model, and simulator negotiate the Clifford+T gateset.
- The Rust `CliffordTInterface` emits gatewire gate instances.
- The error model forwards gates and injects an `X` after each one-qubit gate
  according to its configured probability.
- The final gate stream is still a valid Clifford+T stream.

## Step 2: Run the Real Selene Build Workflow

The local `justfile` creates a virtual environment, installs Selene, installs
this example, and runs the Python tests:

```bash
just setup
just test
```

The setup recipe uses:

```bash
python -m venv venv
venv/bin/pip install ../../
venv/bin/pip install ../../selene-core
venv/bin/pip install .
venv/bin/pip install pytest
```

The `pip install .` step runs the example's Hatch build hook, which builds the
Rust runtime/error-model library and the C++ Qrack simulator plugin.

If you want to run those pieces manually, the equivalent native build/test flow
is:

```bash
direnv exec ../.. cargo build --manifest-path "$PWD/Cargo.toml"
direnv exec ../.. cmake -S "$PWD/cpp" -B "$PWD/target/qrack-simulator-release" -DCMAKE_BUILD_TYPE=Release
direnv exec ../.. cmake --build "$PWD/target/qrack-simulator-release" --target selene_example_clifford_t_qrack --parallel
PYTHONPATH="$PWD/python" direnv exec ../.. "$PWD/venv/bin/python" -m pytest -s "$PWD/python/tests"
```

The final Python test does the real Selene thing:

```python
from selene_sim.build import build
from selene_sim.event_hooks import MetricStore
from selene_example_clifford_t_stack import (
    CliffordTErrorModel,
    CliffordTInterface,
    CliffordTQrackSimulator,
    CliffordTRuntime,
    example_program_path,
)

metrics = MetricStore()
instance = build(
    example_program_path(),
    interface=CliffordTInterface(),
)

shots = instance.run_shots(
    simulator=CliffordTQrackSimulator(),
    runtime=CliffordTRuntime(),
    error_model=CliffordTErrorModel(),
    event_hook=metrics,
    n_qubits=2,
    n_shots=1,
)

shot = dict(next(iter(shots)))
assert shot["q0"] == shot["q1"]
assert metrics.shots[0]["error_model"]["injected_x"] == 2
```

## Step 3: Read the User Program

The user program is ordinary C in `programs/bell.ct.c`:

```c
#include <clifford_t_qis.h>

void ct_program(void) {
    uint64_t q0 = ct_qalloc();
    uint64_t q1 = ct_qalloc();

    ct_h(q0);
    ct_t(q0);
    ct_cnot(q0, q1);

    bool m0 = ct_measure(q0);
    bool m1 = ct_measure(q1);

    ct_record_bool("q0", m0);
    ct_record_bool("q1", m1);
}
```

The program only sees the small QIS header in `c/include/clifford_t_qis.h`.
It does not know about gatewire serialization, runtime batching, error-model
injection, or simulator details.

## Step 4: Follow the Build Extension

`python/selene_example_clifford_t_stack/build.py` defines:

- `CliffordTCSourceKind`, which identifies `.ct.c` user programs.
- `CliffordTCToSeleneObjectStep`, which compiles the user program and the C
  shim with `invoke_zig`.
- `CliffordTInterface`, which registers the kind and step with Selene's
  `BuildPlanner`.

The custom build step produces a normal `SeleneObjectFileKind`. From there, the
existing Selene build steps link the executable in the usual way.

## Step 5: Follow Gateset Registration

The C shim in `c/src/clifford_t_interface.c` owns the non-interactive gateset
registration boundary:

```text
main(...)
  -> selene_load_config(...)
  -> register Clifford+T gateset with selene_register_gateset(...)
  -> for each shot:
       selene_on_shot_start(...)
       ct_program()
       selene_on_shot_end(...)
  -> selene_exit(...)
```

This mirrors the Helios and Sol interfaces: the compiled program registers the
frontend gateset after Selene has been configured, and Selene performs the
runtime -> error model -> simulator handshake before accepting gate operations.

## Step 6: Inspect the Gates

The Rust gates are defined in `src/gates.rs` with `define_gate!`:

```rust
define_gate! {
    pub struct T [
        id = "example.clifford_t.T.v1",
        display = "T",
        version = 1,
    ] { q0: Qubit }
}
```

The C shim declares the same semantic IDs through `selene/gatewire.h` before it
registers the gateset. The semantic ID is the compatibility key. The display
name is only for humans and metrics.

## Step 7: Play Interactively

The same Python package also exposes interactive helpers for quick experiments:

```python
from selene_sim.interactive import InteractiveSimulator
from selene_example_clifford_t_stack import (
    CliffordTQrackSimulator,
    clifford_t_gateset,
    h,
    t,
    cnot,
)

gates = clifford_t_gateset()
sim = InteractiveSimulator(
    simulator=CliffordTQrackSimulator(),
    n_qubits=2,
    gateset=gates,
)

sim.gate(h(0))
sim.gate(t(0))
sim.gate(cnot(0, 1))
m0 = sim.measure(0)
m1 = sim.measure(1)
assert m1 == m0
```

This path is useful for exploration, but the compiled-program example above is
the primary Selene workflow.

## File Map

- `programs/bell.ct.c` is the user program passed to `selene_sim.build`.
- `c/include/clifford_t_qis.h` is the user-facing C QIS header.
- `c/src/clifford_t_interface.c` is the C shim that registers the gateset and
  emits `selene_gate(...)` calls.
- `python/selene_example_clifford_t_stack/build.py` extends Selene's build
  planner.
- `python/selene_example_clifford_t_stack/gates.py` exposes Python gateset and
  gate constructors for interactive use.
- `python/selene_example_clifford_t_stack/plugins.py` exposes Python plugin
  classes for the native Rust and C++ plugin libraries.
- `cpp/src/qrack_simulator.cpp` is the Qrack-backed simulator plugin.
- `src/gates.rs` defines the Clifford+T gatewire gateset.
- `src/interface.rs` is the Rust in-process QIS-style emitter used by tests.
- `src/runtime.rs` is the runtime plugin.
- `src/error_model.rs` is the error model plugin.
- `src/simulator.rs` is a small in-process simulator used by Rust tests.
- `src/tests.rs` exercises the Rust pieces without going through Python.

The important lesson is that every layer negotiates and decodes by semantic ID.
The build system is also extensible: a custom interface can teach Selene how to
compile a new user-program format without bypassing the normal executable and
`run_shots` flow.
