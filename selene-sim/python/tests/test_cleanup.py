import pytest

from conftest import (
    guppy_python_file,
    hugr_file,
    register_inline_guppy_programs,
)

from selene_sim.build import build
from selene_sim import Quest


INLINE_GUPPY_PROGRAMS = {
    "simple_discard": """@guppy
def main() -> None:
    q0 = qubit()
    discard(q0)
""",
}

INLINE_GUPPY_PROGRAMS = {
    name: guppy_python_file(source) for name, source in INLINE_GUPPY_PROGRAMS.items()
}
register_inline_guppy_programs(INLINE_GUPPY_PROGRAMS, artifact_kind="hugr")


def test_delete_files():
    runner = build(hugr_file("simple_discard"))
    got = list(runner.run(Quest(), n_qubits=1))
    runner.delete_files()
    with pytest.raises(FileNotFoundError):
        got = list(runner.run(Quest(), n_qubits=1))
    assert not runner.root.exists()
    # these are included in case we later decide to move files
    # out of the build root. In this case we may have neglected
    # to clean them up.
    #
    # If at the time this is intentional behaviour,
    # then we can change this test.
    assert not runner.executable.exists()
    assert not runner.runs.exists()
    assert not runner.artifacts.exists()


def test_delete_run_directories():
    runner = build(hugr_file("simple_discard"))
    got = list(runner.run(Quest(), n_qubits=1))
    assert len(list(runner.runs.iterdir())) == 1

    runner.delete_run_directories()
    # we are only cleaning up runs, so everything needed
    # for creating new runs should still work.
    assert runner.root.exists()
    assert runner.artifacts.exists()
    assert runner.runs.exists()
    assert len(list(runner.runs.iterdir())) == 0

    # this should not fail
    got = list(runner.run(Quest(), n_qubits=1))

    # and we should see one run dir
    assert len(list(runner.runs.iterdir())) == 1
