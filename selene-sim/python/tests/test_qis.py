import pytest
from pathlib import Path
import platform

import yaml
from selene_sim.event_hooks import CircuitExtractor, MetricStore, MultiEventHook
from selene_sim import Quest
from selene_sim.build import build
from selene_helios_qis_plugin import HeliosInterface

RESOURCE_DIR = Path(__file__).parent / "resources"
QIS_RESOURCE_DIR = RESOURCE_DIR / "qis"


def get_platform_suffix():
    arch = platform.machine()
    system = platform.system()

    target_system = ""
    target_arch = ""
    match arch.lower():
        case "arm64" | "aarch64":
            target_arch = "aarch64"
        case "amd64" | "x86_64":
            target_arch = "x86_64"
        case _:
            raise RuntimeError(f"Unsupported architecture: {arch}")
    match system.lower():
        case "linux":
            target_system = "unknown-linux-gnu"
        case "darwin" | "macos":
            target_system = "apple-darwin"
        case "windows":
            target_system = "windows-msvc"
        case _:
            raise RuntimeError(f"Unsupported OS: {system}")
    return f"{target_arch}-{target_system}"


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis(snapshot, program_name: str):
    filename = f"{program_name}-{get_platform_suffix()}.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    assert helios_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())

    helios_results = helios_build.run_shots(
        Quest(), n_qubits=10, n_shots=1000, random_seed=1024
    )

    results = {
        "helios": list(list(shot) for shot in helios_results),
    }

    snapshot.assert_match(yaml.dump(results), f"{program_name}.yaml")


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis_circuit_log(snapshot, program_name: str):
    filename = f"{program_name}-{get_platform_suffix()}.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    assert helios_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())

    helios_circuit_extractor = CircuitExtractor()

    helios_results = helios_build.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=helios_circuit_extractor,
    )

    results = {
        "helios": list(list(shot) for shot in helios_results),
    }
    circuits = {
        "helios": repr(helios_circuit_extractor.shots[0].get_user_circuit()),
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
