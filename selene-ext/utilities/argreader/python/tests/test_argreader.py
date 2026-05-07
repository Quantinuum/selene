from pathlib import Path
import yaml
import pytest

from selene_sim import build, Coinflip
from selene_sim.exceptions import SelenePanicError
from selene_sim.event_hooks import CircuitExtractor
from selene_argreader_plugin import ArgReaderPlugin, ArgProvider

"""
For these tests, we use the sample argreader usage provided in
resources/argreader_example.ll, in which we fetch and print the
configuration for Rockwell's Retroencabulator (a parody of a
nonsensical machine that has become a long-running in-joke in
engineering circles).

The configuration of the retroencabulator includes demonstrations
of:
- a boolean parameter (casing_is_logarithmic)
- an unsigned integer parameter (num_spurving_bearings)
- a signed integer parameter (side_fumbling)
- a floating point parameter (magneto_reluctance)
- an array of 5 booleans (cardinal_grammeters)
- an array of 5 unsigned integers (marzelvane_sizes)
- an array of 5 signed integers (tremie_pipe_lengths)
- an array of 5 floats (encabulation_extents)

and these tests demonstrate working examples, as well as intentional
validation failures (and an explanation of their importance in the
fictional context of retroencabulation) for each of these types.
"""


def test_arg_reader(snapshot):
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    arg_provider = ArgProvider()
    # We can set constant arguments that apply for every shot
    arg_provider.set_constant_args(
        casing_is_logarithmic=True,
        num_spurving_bearings=2,
        side_fumbling=-4,
        magneto_reluctance=0.0125,
        cardinal_grammeters=[False, True, True, True, True],
        marzelvane_sizes=[8, 2, 5, 4, 1],
        tremie_pipe_lengths=[10, 20, 15, -25, 30],
        encabulation_extents=list(i * 0.125 for i in range(5)),
    )

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=10, simulator=Coinflip())
        )
    snapshot.assert_match(yaml.dump(result), "constant_args.yaml")

    # Or we can provide per-shot variable arguments.
    even_shot_args = {
        "casing_is_logarithmic": False,
        "num_spurving_bearings": 4,
        "side_fumbling": 2,
        "magneto_reluctance": 0.025,
        "cardinal_grammeters": [True, False, True, True, False],
        "marzelvane_sizes": [8, 2, 5, 4, 1],
        "tremie_pipe_lengths": [10, 20, 15, -25, 30],
        "encabulation_extents": list(i * 0.25 for i in range(5)),
    }

    odd_shot_args = {
        "casing_is_logarithmic": True,
        "num_spurving_bearings": 2,
        "side_fumbling": -4,
        "magneto_reluctance": 0.0125,
        "cardinal_grammeters": [False, True, True, True, True],
        "marzelvane_sizes": [8, 2, 5, 4, 1],
        "tremie_pipe_lengths": [-10, 20, 15, -25, 30],
        "encabulation_extents": list(i * 0.125 for i in range(5)),
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
        "casing_is_logarithmic": False,
        "num_spurving_bearings": 4,
        "side_fumbling": 2,
        "magneto_reluctance": 0.025,
        "cardinal_grammeters": [True, False, True, True, False],
        "marzelvane_sizes": [8, 2, 5, 4, 1],
        "tremie_pipe_lengths": [10, 20, 15, -25, 30],
        "encabulation_extents": list(i * 0.25 for i in range(5)),
    }

    second_shot_args = {
        "casing_is_logarithmic": True,
        "num_spurving_bearings": 2,
        "side_fumbling": -4,
        "magneto_reluctance": 0.0125,
        "cardinal_grammeters": [False, True, True, True, True],
        "marzelvane_sizes": [8, 2, 5, 4, 1],
        "tremie_pipe_lengths": [-10, 20, 15, -25, 30],
        "encabulation_extents": list(i * 0.125 for i in range(5)),
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
    #
    # While spurving bearings may come in fractional units from some suppliers, retroencabulation
    # requires complete spurving bearings to properly align the anhydrous nangling pins.
    arg_provider.set_constant_args(
        casing_is_logarithmic=False,
        num_spurving_bearings=4.2,
        side_fumbling=2,
        magneto_reluctance=0.025,
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'num_spurving_bearings' has a non-integral floating point value 4.2",
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # if we miss a required arg, it should panic
    #
    # In this case, no side-fumbling parameter is provided. Retroencabulation without taking
    # side-fumbling into account can cause space-time anomalies.
    arg_provider.set_constant_args(
        casing_is_logarithmic=False,
        num_spurving_bearings=4,
        magneto_reluctance=0.025,
        cardinal_grammeters=[True, False, True, True, False],
        marzelvane_sizes=[8, 2, 5, 4, 1],
        tremie_pipe_lengths=[10, 20, 15, -25, 30],
    )
    with pytest.raises(
        SelenePanicError, match="Missing runtime argument 'side_fumbling'"
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # If we provide an array of the wrong length, it should panic
    #
    # Here we provide insufficient encabulation extents. Retroencabulation requires all extents to be
    # provided to avoid sublimation of the amulite.
    arg_provider.set_constant_args(
        casing_is_logarithmic=False,
        num_spurving_bearings=4,
        side_fumbling=2,
        magneto_reluctance=0.025,
        cardinal_grammeters=[True, False, True, True, False],
        marzelvane_sizes=[8, 2, 5, 4, 1],
        tremie_pipe_lengths=[10, 20, 15, -25, 30],
        encabulation_extents=list(i * 0.25 for i in range(4)),
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'encabulation_extents' expects an array of 5 floats",
    ):
        with arg_provider:
            result = list(
                list(r)
                for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
            )

    # if the array has the wrong value types, it should try to convert and fail if not possible.
    # here the only error is that a value in tremie_pipe_lengths is set to a float that exceeds
    # the bounds of an int64. This should cause a panic because the argument cannot be converted.
    #
    # In the case of retroencabulation, this helps prevent catastrophic undertoasting of the
    # electroscoptic bifurcator, a lesson learned from The Incident.
    arg_provider.set_constant_args(
        casing_is_logarithmic=False,
        num_spurving_bearings=4,
        side_fumbling=2.0,
        magneto_reluctance=5,
        cardinal_grammeters=[True, False, True, True, False],
        marzelvane_sizes=[8.0, 2, 5, 4, 1],
        tremie_pipe_lengths=[10, 20, 15, -25, float(2**64)],
        encabulation_extents=list(i for i in range(5)),
    )
    with pytest.raises(
        SelenePanicError,
        match="Runtime argument 'tremie_pipe_lengths' contains floating point values which exceed signed integer bounds",
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
    # types and values, within the synchronised trace.

    # In the context of quantum-classical retroencabulation, this can help us
    # identify how the entropic dampers within the retroencabulator are interacting
    # with the quasi-retrofugal modulation in the qubit life support system, which
    # is of particular use when diagnosing the quantum tunneling of the spamshaft
    # into the tremie pipework, or of unexpected backstreaming of the panendermic
    # semi-boloid.

    arg_provider = ArgProvider()
    arg_provider.set_constant_args(
        casing_is_logarithmic=True,
        num_spurving_bearings=2,
        side_fumbling=-4,
        magneto_reluctance=0.0125,
        cardinal_grammeters=[False, True, True, True, True],
        marzelvane_sizes=[8, 2, 5, 4, 1],
        tremie_pipe_lengths=[10, 20, 15, -25, 30],
        encabulation_extents=list(i * 0.125 for i in range(5)),
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
