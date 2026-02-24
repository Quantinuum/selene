# Selene Tutorial Notebooks

These notebooks provide a pedagogical path through Selene functionality that is also covered by the Python test suite.

## Suggested order

1. `01_basics_build_and_results.ipynb`  
   Build a Guppy program, run it, inspect parsed/unparsed results, and clean up artifacts.
2. `02_determinism_noise_and_replay.ipynb`  
   Control reproducibility, add depolarizing noise, and use classical/quantum replay.
3. `03_runtimes_hooks_and_state_debug.ipynb`  
   Compare runtimes, collect metrics/circuits/measurements, and inspect state outputs.
4. `04_qir_and_interactive_workflows.ipynb`  
   Build from QIR (`.ll`, `.bc`, bytes) and use interactive simulator/runtime/full-stack APIs.
5. `05_reliability_timeouts_and_errors.ipynb`  
   Use strict build validation, configure timeouts, and handle Selene exceptions.
6. `06_selene_core_plugin_in_c.ipynb`  
   Build a minimal simulator plugin in C (compiled with ziglang), add a Python wrapper, and run a Guppy program.
7. `07_selene_core_build_planner_extension.ipynb`  
   Add a custom `.c` artifact kind (`int qmain` detector), register custom build steps, and build a Selene executable.

## Coverage mapping (high level)

- Basics and results: `test_guppy.py`, `test_unparsed.py`, `test_cleanup.py`
- Determinism/noise/replay: `test_determinism.py`, `test_depolarising_error_model.py`, `test_replay.py`
- Runtime and hooks: `test_runtimes.py`, `test_debug.py`
- Interactive APIs: `test_interactive.py`
- QIR: `test_qir.py`
- Reliability and failures: `test_build_validation.py`, `test_timeout.py`, `test_exceptions.py`
- Plugin authoring with selene-core: `selene-core/examples/simulator/*`, `selene-core/python/selene_core/*.py`
- Build planner extension: `selene-core/python/selene_core/build_utils/*`
