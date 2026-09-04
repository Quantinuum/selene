import ctypes
import platform
from textwrap import dedent

import pytest
import yaml

from selene_quest_plugin import QuestPlugin
from selene_sim.build import build


N_QUBITS = 10
N_SHOTS = 100
RANDOM_SEED = 8675309


def _require_cuda_device() -> None:
    if platform.system() != "Linux":
        pytest.skip("the QuEST GPU backends are available on Linux only")

    try:
        cuda_driver = ctypes.CDLL("libcuda.so.1")
    except OSError as error:
        pytest.skip(f"the CUDA driver is unavailable: {error}")

    cuda_driver.cuInit.argtypes = [ctypes.c_uint]
    cuda_driver.cuInit.restype = ctypes.c_int
    cuda_driver.cuDeviceGetCount.argtypes = [ctypes.POINTER(ctypes.c_int)]
    cuda_driver.cuDeviceGetCount.restype = ctypes.c_int

    init_result = cuda_driver.cuInit(0)
    if init_result != 0:
        pytest.skip(f"the CUDA driver could not be initialized (error {init_result})")

    device_count = ctypes.c_int()
    count_result = cuda_driver.cuDeviceGetCount(ctypes.byref(device_count))
    if count_result != 0 or device_count.value == 0:
        pytest.skip("no CUDA-capable GPU is available")


def _quest_backends() -> dict[str, QuestPlugin]:
    _require_cuda_device()
    plugins = {
        "cpu": QuestPlugin(backend="cpu"),
        "cuda": QuestPlugin(backend="cuda"),
        "cuquantum": QuestPlugin(backend="cuquantum"),
    }

    for name, plugin in plugins.items():
        if not plugin.library_file.is_file():
            pytest.skip(f"the QuEST {name} plugin is not installed")
        try:
            library_search_dirs = plugin.library_search_dirs
        except RuntimeError as error:
            pytest.skip(str(error))
        if any(not directory.is_dir() for directory in library_search_dirs):
            pytest.skip(f"a runtime library directory for QuEST {name} is missing")

    return plugins


@pytest.mark.cuda
def test_backends_agree_for_seeded_hadamard_measurements(
    compiled_guppy, snapshot
) -> None:
    guppy_source = dedent(
        f"""
        from guppylang.decorator import guppy
        from guppylang.std.builtins import array, result
        from guppylang.std.quantum import collect_measurements, h, measure_array, qubit

        @guppy
        def main() -> None:
            qubits = array(qubit() for _ in range({N_QUBITS}))
            for index in range(len(qubits)):
                h(qubits[index])
            measurements = collect_measurements(measure_array(qubits))
            result("measurements", measurements)
        """
    )
    llvm_file = compiled_guppy(
        program_name="hadamard_measure_all",
        guppy_source=guppy_source,
    )
    plugins = _quest_backends()
    runner = build(llvm_file)

    results = {
        name: [
            dict(shot)
            for shot in runner.run_shots(
                plugin,
                n_qubits=N_QUBITS,
                n_shots=N_SHOTS,
                random_seed=RANDOM_SEED,
            )
        ]
        for name, plugin in plugins.items()
    }

    assert results["cuda"] == results["cpu"]
    assert results["cuquantum"] == results["cpu"]
    assert len(results["cpu"]) == N_SHOTS
    assert all(len(shot["measurements"]) == N_QUBITS for shot in results["cpu"])
    assert all(set(shot["measurements"]) <= {0, 1} for shot in results["cpu"])
    assert len({tuple(shot["measurements"]) for shot in results["cpu"]}) > 1
    snapshot_results = [
        "".join(str(bit) for bit in shot["measurements"]) for shot in results["cpu"]
    ]
    snapshot.assert_match(yaml.dump(snapshot_results), "hadamard_measurements.yaml")
