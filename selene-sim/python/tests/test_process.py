import subprocess
import sys

import pytest
from selene_sim import process as process_module


def test_spawn_closes_parent_streams_and_preserves_output(tmp_path, monkeypatch):
    streams = []

    def popen(argv, *, stdout, stderr, env):
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

    child = process.spawn()
    assert len(streams) == 2
    assert all(stream.closed for stream in streams)
    process.wait()
    assert child.returncode == 0
    assert process.stdout.read_text() == "out\n"
    assert process.stderr.read_text() == "err\n"


def test_spawn_closes_parent_streams_on_failure(tmp_path, monkeypatch):
    streams = []

    def popen(argv, *, stdout, stderr, env):
        streams.extend((stdout, stderr))
        raise OSError("spawn failed")

    monkeypatch.setattr(process_module, "Popen", popen)
    process = process_module.SeleneProcess(tmp_path / "unused", [], tmp_path, {})

    with pytest.raises(OSError, match="spawn failed"):
        process.spawn()

    assert len(streams) == 2
    assert all(stream.closed for stream in streams)
    assert process.process is None
