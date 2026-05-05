from pathlib import Path
import yaml

from selene_sim import build, Coinflip
from selene_sim.event_hooks import CircuitExtractor
from selene_argreader_plugin import ArgReaderPlugin, ArgProvider


def test_arg_reader(snapshot):
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    arg_provider = ArgProvider()
    arg_provider.set_constant_args(
        casing_is_logarithmic=True,
        num_spurving_bearings=2,
        side_fumbling=-4,
        magneto_reluctance=0.0125,
    )

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=10, simulator=Coinflip())
        )
    snapshot.assert_match(yaml.dump(result), "constant_args.yaml")

    # now try using variable args
    even_shot_args = {
        "casing_is_logarithmic": False,
        "num_spurving_bearings": 4,
        "side_fumbling": 2,
        "magneto_reluctance": 0.025,
    }

    odd_shot_args = {
        "casing_is_logarithmic": True,
        "num_spurving_bearings": 2,
        "side_fumbling": -4,
        "magneto_reluctance": 0.0125,
    }

    arg_provider.set_variable_args([even_shot_args, odd_shot_args] * 5)

    with arg_provider:
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=10, simulator=Coinflip())
        )
    snapshot.assert_match(yaml.dump(result), "variable_args.yaml")


def test_arg_reader_trace(snapshot):
    llvm_file = Path(__file__).parent / "resources/argreader_example.ll"
    instance = build(llvm_file, utilities=[ArgReaderPlugin()])

    arg_provider = ArgProvider()
    arg_provider.set_constant_args(
        casing_is_logarithmic=True,
        num_spurving_bearings=2,
        side_fumbling=-4,
        magneto_reluctance=0.0125,
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
