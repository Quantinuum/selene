# Selene

![Selene Logo](assets/selene_logo.svg)

Selene is a quantum computer emulation platform written primarily in Rust with a python frontend.

Selene is built with flexibility in mind. This includes:

- A plugin system for the addition of additional components including simulators, error models, quantum runtimes to be provided within Selene or as third party plugins
- Support for custom input formats and device APIs through [the selene-core build system](selene-core/python/selene_core/build_utils).

## What's included

Out of the box, Selene provides first-class support for:

- The [HUGR](https://github.com/quantinuum/hugr) ecosystem, including execution of [Guppy](https://github.com/quantinuum/guppy) programs in an emulation environment, making use of our [open-source compiler](https://github.com/Quantinuum/tket2/tree/main/qis-compiler). You can find many examples of guppy usage in our [unit tests](selene-sim/python/tests/test_guppy.py).
- [QIR](https://www.qir-alliance.org/) (Quantum Intermediate Representation) programs, supporting both LLVM IR and bitcode formats, compiled using our [open-source QIR compiler](https://github.com/Quantinuum/qir-qis). You can find QIR examples in our [QIR tests](selene-sim/python/tests/test_qir.py).

Selene provides a range of simulators, including:

- Statevector simulation using [QuEST](https://github.com/QuEST-Kit/QuEST)
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

## Installation

To install selene, `pip install selene-sim`.

This will automatically install our core interfaces, the hugr compiler, bundled components, and the Selene python frontend.

## Usage examples

Although examples are provided in the [python tests](selene-sim/python/tests) folder, here are examples of using Selene with different input formats.

### Using Selene with HUGR and Guppy

```python
#################################
# Defining the program in Guppy #
#################################
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

################################
# Building the selene instance #
################################
from selene_sim import build, Quest, Stim
runner = build(compiled_hugr)

# this instance can now be used with various runtime-configurable
# components. Let's start simple with two popular simulators.

shot = QsysShot(runner.run(simulator=Quest(), n_qubits=10))
print(shot)

shot = QsysShot(runner.run(simulator=Stim(), n_qubits=10))
print(shot)

# deterministic results can be achieved by providing a random seed
shot = QsysShot(runner.run(simulator=Stim(random_seed=5), n_qubits=10))
print(shot)

##############################
# add noise and run 20 shots #
##############################

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

###################################################
# use a runtime that eliminates physical RZ gates #
###################################################

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

### Using Selene with QIR

Selene also supports QIR (Quantum Intermediate Representation) programs. Here's an example using QIR LLVM IR:

```python
from selene_sim import build, Quest
from hugr.qsystem.result import QsysResult

# QIR LLVM IR for a simple Bell state preparation and measurement
qir_ll = """
%Qubit = type opaque
%Result = type opaque

@a = internal constant [2 x i8] c"a\\00"
@b = internal constant [2 x i8] c"b\\00"

declare void @__quantum__qis__h__body(%Qubit*)
declare void @__quantum__qis__cnot__body(%Qubit*, %Qubit*)
declare void @__quantum__qis__mz__body(%Qubit*, %Result*) #1
declare void @__quantum__rt__result_record_output(%Result*, i8*)

define void @main() #0 {
  call void @__quantum__qis__h__body(%Qubit* null)
  call void @__quantum__qis__cnot__body(%Qubit* null, %Qubit* inttoptr (i64 1 to %Qubit*))
  call void @__quantum__qis__mz__body(%Qubit* null, %Result* null)
  call void @__quantum__qis__mz__body(%Qubit* inttoptr (i64 1 to %Qubit*), %Result* inttoptr (i64 1 to %Result*))
  call void @__quantum__rt__result_record_output(%Result* null, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @a, i32 0, i32 0))
  call void @__quantum__rt__result_record_output(%Result* inttoptr (i64 1 to %Result*), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @b, i32 0, i32 0))
  ret void
}

attributes #0 = { "entry_point" "qir_profiles"="base_profile" "output_labeling_schema"="schema_id" "required_num_qubits"="2" "required_num_results"="2" }
attributes #1 = { "irreversible" }

!llvm.module.flags = !{!0, !1, !2, !3}

!0 = !{i32 1, !"qir_major_version", i32 1}
!1 = !{i32 7, !"qir_minor_version", i32 0}
!2 = !{i32 1, !"dynamic_qubit_management", i1 false}
!3 = !{i32 1, !"dynamic_result_management", i1 false}
"""

# Build the Selene runner from QIR LLVM IR
runner = build(qir_ll)

# Run multiple shots with Quest simulator
shots = QsysResult(runner.run_shots(
    simulator=Quest(random_seed=42),
    n_qubits=2,
    n_shots=10
))
print(shots)

# You can also load QIR from files:
# - LLVM IR files (.ll): runner = build(Path("program.ll"))
# - Bitcode files (.bc): runner = build(Path("program.bc"))
```
