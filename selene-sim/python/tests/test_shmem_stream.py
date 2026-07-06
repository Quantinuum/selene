from textwrap import dedent

import pytest

from selene_sim.build import build
from selene_sim import Quest


GUPPY_SOURCE = dedent(
    """
    from guppylang.decorator import guppy
    from guppylang.std.quantum import qubit, h, measure_array
    from guppylang.std.builtins import result, array
    from guppylang.std.qsystem.utils import get_current_shot


    @guppy
    def main() -> None:
        qubits = array(qubit() for _ in range(4))
        for i in range(len(qubits)):
            h(qubits[i])
        bits = measure_array(qubits)
        result("a", bits[0].read())
        result("b", bits[1].read())
        result("c", bits[2].read())
        result("d", bits[3].read())
        result("shot", get_current_shot())
    """
)


def _run(runner, transport, n_shots=50, **kwargs):
    return [
        dict(shot)
        for shot in runner.run_shots(
            simulator=Quest(random_seed=1234),
            n_qubits=4,
            n_shots=n_shots,
            random_seed=99,
            transport=transport,
            **kwargs,
        )
    ]


def test_shmem_matches_tcp(compiled_guppy):
    """The shared-memory transport must yield identical results to TCP."""
    llvm_file = compiled_guppy(
        program_name="shmem_matches_tcp",
        guppy_source=GUPPY_SOURCE,
    )
    runner = build(llvm_file, "no_results")

    tcp_results = _run(runner, transport="tcp")
    shmem_results = _run(runner, transport="shmem")

    assert shmem_results == tcp_results
    assert len(shmem_results) == 50


def test_shmem_small_capacity_forces_wraparound(compiled_guppy):
    """A tiny FIFO exercises backpressure/wrap-around and must still be correct."""
    llvm_file = compiled_guppy(
        program_name="shmem_small_capacity",
        guppy_source=GUPPY_SOURCE,
    )
    runner = build(llvm_file, "no_results")

    tcp_results = _run(runner, transport="tcp")
    shmem_results = _run(runner, transport="shmem", shmem_capacity=256)

    assert shmem_results == tcp_results


def test_shmem_rejects_multiple_processes(compiled_guppy):
    """The single-writer FIFO must reject n_processes > 1 with a clear error."""
    llvm_file = compiled_guppy(
        program_name="shmem_reject_multiprocess",
        guppy_source=GUPPY_SOURCE,
    )
    runner = build(llvm_file, "no_results")

    with pytest.raises(ValueError, match="single-writer"):
        # The generator must be advanced for run_shots' body to execute.
        list(
            runner.run_shots(
                simulator=Quest(random_seed=1234),
                n_qubits=4,
                n_shots=4,
                transport="shmem",
                n_processes=2,
            )
        )
