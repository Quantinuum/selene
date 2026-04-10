import pytest
from textwrap import dedent

from selene_sim.build import build
from selene_sim import Quest


def test_file_deletion(compiled_guppy):
    guppy_source = dedent(
        """
        from guppylang import guppy
        from guppylang.std.quantum import discard, qubit

        @guppy
        def main() -> None:
            q0 = qubit()
            discard(q0)
        """
    )

    llvm_file = compiled_guppy(
        program_name="file_deletion",
        guppy_source=guppy_source,
    )

    # with runner 1, we test that delete_files() deletes all files,
    # including compiled artifacts, preventing us from running the
    # program again. We verify that run directories are also deleted.
    runner_1 = build(llvm_file)
    # with runner 2, we test that delete_run_directories() deletes
    # run directories, i.e. files generated during the course of
    # `run()` or `run_shots()`. The instance can be invoked again.
    runner_2 = build(llvm_file)

    got = list(runner_1.run(Quest(), n_qubits=1))
    runner_1.delete_files()
    with pytest.raises(FileNotFoundError):
        got = list(runner_1.run(Quest(), n_qubits=1))
    assert not runner_1.root.exists()
    # these are included in case we later decide to move files
    # out of the build root. In this case we may have neglected
    # to clean them up.
    #
    # If at the time this is intentional behaviour,
    # then we can change this test.
    assert not runner_1.executable.exists()
    assert not runner_1.runs.exists()
    assert not runner_1.artifacts.exists()

    got = list(runner_2.run(Quest(), n_qubits=1))
    assert len(list(runner_2.runs.iterdir())) == 1

    runner_2.delete_run_directories()
    # we are only cleaning up runs, so everything needed
    # for creating new runs should still work.
    assert runner_2.root.exists()
    assert runner_2.artifacts.exists()
    assert runner_2.runs.exists()
    assert len(list(runner_2.runs.iterdir())) == 0

    # this should not fail
    got = list(runner_2.run(Quest(), n_qubits=1))

    # and we should see one run dir
    assert len(list(runner_2.runs.iterdir())) == 1
