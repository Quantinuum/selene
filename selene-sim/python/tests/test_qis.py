import pytest
from pathlib import Path
import platform

import yaml
from selene_sim.event_hooks import CircuitExtractor
from selene_sim import Quest
from selene_sim.build import build
from selene_helios_qis_plugin import HeliosInterface
from selene_sol_qis_plugin import SolInterface

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
    sol_file = QIS_RESOURCE_DIR / "sol" / filename
    assert helios_file.exists()
    assert sol_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())
    sol_build = build(sol_file, interface=SolInterface())

    helios_results = helios_build.run_shots(
        Quest(), n_qubits=10, n_shots=1000, random_seed=1024
    )

    results = {
        "helios": list(list(shot) for shot in helios_results),
    }

    sol_results = sol_build.run_shots(
        Quest(), n_qubits=10, n_shots=1000, random_seed=1024
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
def test_multiplatform_circuit_log(snapshot, program_name: str):
    filename = f"{program_name}-{get_platform_suffix()}.ll"
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

    results = {
        "helios": list(list(shot) for shot in helios_results),
        "sol": list(list(shot) for shot in sol_results),
    }
    circuits = {
        "helios": repr(helios_circuit_extractor.shots[0].get_user_circuit()),
        "sol": repr(sol_circuit_extractor.shots[0].get_user_circuit()),
    }

    snapshot.assert_match(yaml.dump(circuits), f"{program_name}_circuits.yaml")
