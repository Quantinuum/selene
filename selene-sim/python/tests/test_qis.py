import pytest
import sys
from pathlib import Path

import yaml
from selene_sim.event_hooks import CircuitExtractor, MetricStore, MultiEventHook
from selene_sim import Quest, ThreadedRuntime
from selene_sim.build import build
from selene_helios_qis_plugin import HeliosInterface
from selene_sol_qis_plugin import SolInterface
from selene_base_qis_plugin import BaseQISInterface
from selene_core.build_utils import invoke_zig

RESOURCE_DIR = Path(__file__).parent / "resources"
QIS_RESOURCE_DIR = RESOURCE_DIR / "qis"


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis(snapshot, program_name: str):
    filename = f"{program_name}-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    sol_file = QIS_RESOURCE_DIR / "sol" / filename
    assert helios_file.exists()
    assert sol_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())
    sol_build = build(sol_file, interface=SolInterface())

    helios_results = helios_build.run_shots(
        Quest(), n_qubits=10, n_shots=100, random_seed=1024
    )

    sol_results = sol_build.run_shots(
        Quest(), n_qubits=10, n_shots=100, random_seed=1024
    )

    results = {
        "helios": list(list(shot) for shot in helios_results),
        "sol": list(list(shot) for shot in sol_results),
    }

    assert results["helios"] == results["sol"]

    snapshot.assert_match(yaml.dump(results), f"{program_name}.yaml")


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis_circuit_log(snapshot, program_name: str):
    filename = f"{program_name}-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    sol_file = QIS_RESOURCE_DIR / "sol" / filename
    assert helios_file.exists()
    assert sol_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())
    sol_build = build(sol_file, interface=SolInterface())

    helios_circuit_extractor = CircuitExtractor()
    sol_circuit_extractor = CircuitExtractor()

    helios_results = helios_build.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=helios_circuit_extractor,
    )

    sol_results = sol_build.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=sol_circuit_extractor,
    )

    # trigger shot consumption
    list(list(shot) for shot in helios_results)
    list(list(shot) for shot in sol_results)

    circuits = {
        "helios": repr(helios_circuit_extractor.shots[0].get_user_circuit()),
        "sol": repr(sol_circuit_extractor.shots[0].get_user_circuit()),
    }

    snapshot.assert_match(yaml.dump(circuits), f"{program_name}_circuits.yaml")


def test_simulate_delay():
    filename = "simulate_delay-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    assert helios_file.exists()
    helios_build = build(helios_file, interface=HeliosInterface())
    helios_circuit_extractor = CircuitExtractor()
    metric_store = MetricStore()
    hook = MultiEventHook([helios_circuit_extractor, metric_store])

    helios_results = helios_build.run_shots(
        Quest(),
        n_qubits=2,
        n_shots=1,
        random_seed=1024,
        event_hook=hook,
    )

    results = {
        "helios": list(dict(shot) for shot in helios_results),
    }
    assert results["helios"][0]["qubit_0"] == 0
    assert results["helios"][0]["qubit_1"] == 0

    shot_metrics = metric_store.shots[0]
    # the QIS example adds a simulated delay of 123,450,000 ns, so we check that the metric store reflects this
    # in the total runtime (the default "simple" runtime doesn't add any time taken for operations)
    assert shot_metrics["post_runtime"]["total_duration_ns"] == 1_234_500_000, (
        f"Expected total_duration_ns to be 1,234,500,000 ns, but got {shot_metrics['post_runtime']['total_duration_ns']}"
    )

    optimiser_output = helios_circuit_extractor.shots[0].get_optimiser_output()

    assert optimiser_output == [
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "Reset", "qubit": 0},
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "Reset", "qubit": 1},
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "FutureRead", "qubit": 0},
        # simulated delay happens here, so we expect the next operations to be logged as starting at 1,234,500,000 ns
        {"op": "BatchStart", "start_time_ns": 1234500000, "duration_ns": 0},
        {"op": "FutureRead", "qubit": 1},
    ]

    all_output = list(helios_circuit_extractor.shots[0])
    all_output_serialised = []
    for item in all_output:
        if str(item.source) not in {"Source.USER", "Source.OPTIMISER"}:
            continue
        all_output_serialised.append(
            {"source": str(item.source), "operation": item.operation.to_dict()}
        )

    assert all_output_serialised == [
        {
            "operation": {
                "op": "QAlloc",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "QAlloc",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 1,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "MeasureRequest",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "QFree",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 1234500000,
                "op": "ClassicalDelay",
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "MeasureRequest",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 1234500000,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 1,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "QFree",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
    ]


@pytest.mark.skipif(
    sys.platform == "win32", reason="The QIS fixture uses POSIX threads."
)
@pytest.mark.parametrize("interface", [HeliosInterface, SolInterface])
def test_qis_from_multiple_program_threads(interface, tmp_path):
    class ThreadedInterface(interface):
        @property
        def link_flags(self):
            return [*super().link_flags, "-lpthread"]

    qis = ThreadedInterface()
    program = tmp_path / "threaded.o"
    # Compile the same program against each QIS's installed headers. Its worker
    # threads call the QIS functions, so we exercise the actual C shims as well
    # as libselene and the runtime's separate peripheral thread.
    invoke_zig(
        "cc",
        "-std=c17",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-pthread",
        *(["-DSOL_QIS"] if isinstance(qis, SolInterface) else []),
        "-I",
        BaseQISInterface().library_file.parent.parent / "include",
        "-I",
        qis.library_file.parent.parent / "include",
        "-c",
        QIS_RESOURCE_DIR / "threaded.c",
        "-o",
        program,
        cache_dir=tmp_path / "zig-cache",
    )
    runner = build(program, interface=qis, build_dir=tmp_path / "build")
    shots = [
        list(shot)
        for shot in runner.run_shots(
            Quest(), runtime=ThreadedRuntime(), n_qubits=4, n_shots=3, timeout=30.0
        )
    ]
    assert len(shots) == 3
    for shot in shots:
        assert len(shot) == 4 * 32 + 4 + 1
        assert shot[-1] == ("joined", 4)
        for worker in range(4):
            # Threads may interleave, but each caller's records should remain
            # complete and in order. Workers alternate between zero and one,
            # then use their measurement to bring the qubit back to zero.
            assert [value for tag, value in shot if tag == f"worker_{worker}"] == [
                [round, (worker + round) % 2, 0] for round in range(32)
            ]

        # No worker measures until all four state requests have returned. These
        # snapshots therefore check the forced borrow through the QIS, rather
        # than observing gates that a measurement has already forced to execute.
        states = Quest.extract_states_dict(shot)
        assert set(states) == {f"state_{worker}" for worker in range(4)}
        for worker in range(4):
            density = states[f"state_{worker}"].get_density_matrix()
            assert density[worker % 2, worker % 2] == pytest.approx(1)
