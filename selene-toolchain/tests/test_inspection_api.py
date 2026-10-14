import json
import subprocess
from pathlib import Path

import pytest

import selene_toolchain


@pytest.fixture
def inspector(monkeypatch):
    calls = []

    def run(command, **kwargs):
        calls.append((command, kwargs))
        return subprocess.CompletedProcess(
            command,
            0,
            json.dumps(
                {
                    "schema_version": 1,
                    "defined_symbols": ["qmain", "global_data"],
                    "undefined_symbols": ["setup"],
                    "defined_functions": ["qmain"],
                    "declared_functions": ["setup", "unused"],
                }
            ).encode(),
            b"",
        )

    monkeypatch.setattr(
        selene_toolchain, "tool_path", lambda name: Path("/packaged") / name
    )
    monkeypatch.setattr(
        selene_toolchain, "tool_environment", lambda: {"PATH": "/wheel/dlls"}
    )
    monkeypatch.setattr(selene_toolchain.subprocess, "run", run)
    return calls


@pytest.mark.parametrize("from_file", [False, True])
def test_object_api_preserves_input(inspector, tmp_path, from_file):
    contents = (
        tmp_path / "object with spaces café.obj" if from_file else b"\x00\xff\r\n"
    )
    symbols = selene_toolchain.inspect_object(contents)
    assert symbols.defined_symbols == {"qmain", "global_data"}
    assert symbols.undefined_symbols == {"setup"}
    command, options = inspector[0]
    assert command[:2] == [str(Path("/packaged/selene-llvm")), "inspect-object"]
    assert command[2:] == ([str(contents)] if from_file else [])
    assert options["input"] == (None if from_file else contents)
    assert options["env"] == {"PATH": "/wheel/dlls"}


def test_module_api_still_reads_function_fields(inspector):
    symbols = selene_toolchain.inspect_module("; café\n")
    assert symbols.defined_functions == {"qmain"}
    assert symbols.declared_functions == {"setup", "unused"}
    command, options = inspector[0]
    assert command[1] == "inspect"
    assert options["input"] == "; café\n".encode()


@pytest.mark.parametrize(
    "response",
    [
        b"invalid json",
        b"null",
        b"[]",
        b'{"schema_version": 2}',
        b'{"schema_version": 1, "defined_functions": [], "declared_functions": []}',
        b'{"schema_version": 1, "defined_symbols": "qmain", "undefined_symbols": []}',
        b'{"schema_version": 1, "defined_symbols": [], "undefined_symbols": [42]}',
    ],
)
def test_object_api_rejects_invalid_responses(inspector, monkeypatch, response):
    monkeypatch.setattr(
        selene_toolchain.subprocess,
        "run",
        lambda *args, **kwargs: subprocess.CompletedProcess(args, 0, response, b""),
    )
    with pytest.raises(RuntimeError, match="Invalid response from selene-llvm"):
        selene_toolchain.inspect_object(b"object")


def test_object_api_reports_native_diagnostics(inspector, monkeypatch):
    monkeypatch.setattr(
        selene_toolchain.subprocess,
        "run",
        lambda *args, **kwargs: subprocess.CompletedProcess(
            args, 1, b"", b"Cannot parse object file: truncated header"
        ),
    )
    with pytest.raises(
        RuntimeError, match="Object inspection failed.*exit 1"
    ) as failure:
        selene_toolchain.inspect_object(b"object")
    assert "truncated header" in str(failure.value)


def test_object_api_reports_missing_tool(inspector, monkeypatch):
    def run(*args, **kwargs):
        raise FileNotFoundError("selene-llvm is missing")

    monkeypatch.setattr(selene_toolchain.subprocess, "run", run)
    with pytest.raises(RuntimeError, match="Unable to run selene-llvm"):
        selene_toolchain.inspect_object(b"object")


@pytest.mark.parametrize("contents", ["object.o", None, [1, 2]])
def test_object_api_rejects_unsupported_inputs(contents):
    with pytest.raises(TypeError, match="Unsupported type for object contents"):
        selene_toolchain.inspect_object(contents)
