from pathlib import Path
import yaml
import pytest

from selene_sim import build, Coinflip
from selene_sim.exceptions import SelenePanicError
from selene_sim.event_hooks import CircuitExtractor
from selene_argreader_plugin import ArgReaderPlugin, ArgProvider

# Note to avoid confusion:
# parameter names are configured by the user program, and we
# are just using e.g. "input_bool" in argreader_example.ll as
# a clear example of what's what for testing purposes.


def test_arg_reader(snapshot):
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    arg_provider = ArgProvider()
    # We can set constant arguments that apply for every shot
    #
    arg_provider.set_constant_args(
        input_bool=True,
        input_u64=2,
        input_i64=-4,
        input_f64=0.0125,
        input_bool_array=[False, True, True, True, True],
        input_u64_array=[8, 2, 5, 4, 1],
        input_i64_array=[10, 20, 15, -25, 30],
        input_f64_array=list(i * 0.125 for i in range(5)),
    )

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=10, simulator=Coinflip())
        )
    snapshot.assert_match(yaml.dump(result), "constant_args.yaml")

    # Or we can provide per-shot variable arguments.
    even_shot_args = {
        "input_bool": False,
        "input_u64": 4,
        "input_i64": 2,
        "input_f64": 0.025,
        "input_bool_array": [True, False, True, True, False],
        "input_u64_array": [8, 2, 5, 4, 1],
        "input_i64_array": [10, 20, 15, -25, 30],
        "input_f64_array": list(i * 0.25 for i in range(5)),
    }

    odd_shot_args = {
        "input_bool": True,
        "input_u64": 2,
        "input_i64": -4,
        "input_f64": 0.0125,
        "input_bool_array": [False, True, True, True, True],
        "input_u64_array": [8, 2, 5, 4, 1],
        "input_i64_array": [-10, 20, 15, -25, 30],
        "input_f64_array": list(i * 0.125 for i in range(5)),
    }

    arg_provider.set_variable_args([even_shot_args, odd_shot_args] * 5)

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=10, simulator=Coinflip())
        )
    snapshot.assert_match(yaml.dump(result), "variable_args.yaml")


def test_arg_reader_validation():
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    first_shot_args = {
        "input_bool": False,
        "input_u64": 4,
        "input_i64": 2,
        "input_f64": 0.025,
        "input_bool_array": [True, False, True, True, False],
        "input_u64_array": [8, 2, 5, 4, 1],
        "input_i64_array": [10, 20, 15, -25, 30],
        "input_f64_array": list(i * 0.25 for i in range(5)),
    }

    second_shot_args = {
        "input_bool": True,
        "input_u64": 2,
        "input_i64": -4,
        "input_f64": 0.0125,
        "input_bool_array": [False, True, True, True, True],
        "input_u64_array": [8, 2, 5, 4, 1],
        "input_i64_array": [-10, 20, 15, -25, 30],
        "input_f64_array": list(i * 0.125 for i in range(5)),
    }

    arg_provider = ArgProvider()
    arg_provider.set_variable_args([first_shot_args, second_shot_args])

    # if we try to run more shots than we have args for, it should panic
    with pytest.raises(
        SelenePanicError, match="No runtime arguments provided for shot 2"
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=3, simulator=Coinflip())
            )

    # if we try to run a shot with an arg that doesn't match the expected type, it should panic.
    # here we pass 4.2 to the input_u64 argument, and expect a panic as a result.
    arg_provider.set_constant_args(
        input_bool=False,
        input_u64=4.2,
        input_i64=2,
        input_f64=0.025,
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'input_u64' has a non-integral floating point value 4.2",
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # if we miss a required arg, it should panic. Here we omit input_i64.
    arg_provider.set_constant_args(
        input_bool=False,
        input_u64=4,
        input_f64=0.025,
        input_bool_array=[True, False, True, True, False],
        input_u64_array=[8, 2, 5, 4, 1],
        input_i64_array=[10, 20, 15, -25, 30],
    )
    with pytest.raises(SelenePanicError, match="Missing runtime argument 'input_i64'"):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # If we provide an array of the wrong length, it should panic. Here we provide too few
    # elements of the input_f64_array.
    arg_provider.set_constant_args(
        input_bool=False,
        input_u64=4,
        input_i64=2,
        input_f64=0.025,
        input_bool_array=[True, False, True, True, False],
        input_u64_array=[8, 2, 5, 4, 1],
        input_i64_array=[10, 20, 15, -25, 30],
        input_f64_array=list(i * 0.25 for i in range(4)),
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'input_f64_array' expects an array of 5 floats",
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # if the array has the wrong value types, it should try to convert and fail if not possible.
    # Here, the only error is that a value in input_i64_array is set to a float that exceeds
    # the bounds of an int64. This should cause a panic because the argument cannot be converted.
    arg_provider.set_constant_args(
        input_bool=False,
        input_u64=4,
        input_i64=2.0,
        input_f64=5,
        input_bool_array=[True, False, True, True, False],
        input_u64_array=[8.0, 2, 5, 4, 1],
        input_i64_array=[10, 20, 15, -25, float(2**64)],
        input_f64_array=list(i for i in range(5)),
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'input_i64_array' contains floating point values which exceed signed integer bounds",
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )


def test_arg_reader_trace(snapshot):
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    # We often wish to trace not just the quantum calls from a program,
    # but also the interaction with plugins. The ArgReader plugin logs its
    # calls with Selene so that if tracing is enabled, we can see the arguments,
    # types and values, within the event-by-event trace.

    arg_provider = ArgProvider()
    arg_provider.set_constant_args(
        input_bool=True,
        input_u64=2,
        input_i64=-4,
        input_f64=0.0125,
        input_bool_array=[False, True, True, True, True],
        input_u64_array=[8, 2, 5, 4, 1],
        input_i64_array=[10, 20, 15, -25, 30],
        input_f64_array=list(i * 0.125 for i in range(5)),
    )

    extractor = CircuitExtractor()

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(
                n_qubits=1, n_shots=1, simulator=Coinflip(), event_hook=extractor
            )
        )

    trace = extractor.shots[0].get_trace()
    json = trace.model_dump_json(indent=2)
    snapshot.assert_match(json, "trace.json")
