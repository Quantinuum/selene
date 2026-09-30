import subprocess
import sys

import pytest
from selene_sim import process as process_module


def test_spawn_closes_streams(tmp_path, monkeypatch):
    # Keep hold of the output files so Python doesn't automatically clean them up.
    # This lets us check that spawn() actually closes them itself.
    streams = []

    def popen(argv, *, stdout, stderr, env):
        # Save the files that spawn() gives to Popen so we can inspect them later.
        streams.extend((stdout, stderr))
        return subprocess.Popen(
            [
                sys.executable,
                "-c",
                "import sys; print('out'); print('err', file=sys.stderr)",
            ],
            stdout=stdout,
            stderr=stderr,
            env=env,
        )

    monkeypatch.setattr(process_module, "Popen", popen)
    process = process_module.SeleneProcess(tmp_path / "unused", [], tmp_path, {})

    # Start the child process and keep the returned Popen object for later checks.
    child = process.spawn()
    # spawn() should close the parent copies of both output files right away.
    assert len(streams) == 2
    assert all(stream.closed for stream in streams)
    # Wait for the child to finish so its output is fully written to disk.
    process.wait()
    # The child should exit normally, and the captured output should still be readable.
    assert child.returncode == 0
    assert process.stdout.read_text() == "out\n"
    assert process.stderr.read_text() == "err\n"


def test_spawn_failure_closes_streams(tmp_path, monkeypatch):
    # Keep hold of the output files so Python doesn't automatically clean them up.
    # This lets us check that spawn() actually closes them itself.
    streams = []

    def popen(argv, *, stdout, stderr, env):
        # Save the files that spawn() opens before we make Popen fail on purpose.
        streams.extend((stdout, stderr))
        raise OSError("spawn failed")

    monkeypatch.setattr(process_module, "Popen", popen)
    process = process_module.SeleneProcess(tmp_path / "unused", [], tmp_path, {})

    # The fake Popen raises an error so we can inspect the cleanup path.
    with pytest.raises(OSError, match="spawn failed"):
        process.spawn()

    # Even after the failure, spawn() should close both parent-side files.
    assert len(streams) == 2
    assert all(stream.closed for stream in streams)
    # The process field should stay empty because nothing was started successfully.
    assert process.process is None
