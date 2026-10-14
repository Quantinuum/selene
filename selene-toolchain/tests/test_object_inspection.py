import json
import subprocess
import sys
from pathlib import Path

import pytest

from selene_toolchain import inspect_object, tool_environment, tool_path

resources = Path(__file__).parent / "resources"


@pytest.fixture(
    params=[
        "x86_64-unknown-linux-gnu",
        "aarch64-unknown-linux-gnu",
        "x86_64-apple-macosx11.0.0",
        "arm64-apple-macosx11.0.0",
        "x86_64-w64-windows-gnu",
    ]
)
def object_target(request):
    return request.param


@pytest.fixture
def object_file(object_target, tmp_path):
    # LLVM can write all these object formats on every host. This means each
    # wheel exercises the readers for the other platforms as well as its own.
    output = tmp_path / "object with spaces café.o"
    source = resources / "object-symbols.ll"
    if "windows" not in object_target:
        source = tmp_path / "symbols.ll"
        source.write_text(
            (resources / "object-symbols.ll").read_text()
            + "\n@qmain_alias = alias i32 (), ptr @qmain\n"
            + "define weak void @weak_helper() { ret void }\n"
        )
    subprocess.run(
        [
            str(tool_path("llc")),
            f"-mtriple={object_target}",
            "-filetype=obj",
            "-relocation-model=pic",
            "-O0",
            str(source),
            "-o",
            str(output),
        ],
        check=True,
        capture_output=True,
        env=tool_environment(),
    )
    return output


@pytest.mark.parametrize("from_bytes", [False, True])
def test_object_symbols_without_system_tools(
    object_file, object_target, monkeypatch, tmp_path, from_bytes
):
    contents = object_file.read_bytes() if from_bytes else object_file
    monkeypatch.setenv("PATH", str(tmp_path / "empty-path"))
    monkeypatch.delenv("HUGRENV_PATH", raising=False)

    symbols = inspect_object(contents)
    # Data belongs in the linker symbol table too. In particular, common_data
    # provides storage even on formats that encode it as an undefined symbol
    # with a nonzero size. We should never ask a plugin to provide it.
    assert {
        "qmain",
        "_keep_underscore",
        "global_data",
        "common_data",
    } <= symbols.defined_symbols
    assert symbols.undefined_symbols == {"selene_load_config", "external_data"}
    assert "common_data" not in symbols.undefined_symbols
    assert "_qmain" not in symbols.defined_symbols
    assert "__keep_underscore" not in symbols.defined_symbols
    if "windows" not in object_target:
        assert {"qmain_alias", "weak_helper"} <= symbols.defined_symbols
        assert "weak_helper" not in symbols.undefined_symbols


def test_object_cli_agrees_for_file_and_stdin(object_file):
    command = [str(tool_path("selene-llvm")), "inspect-object"]
    from_file = subprocess.run(
        [*command, str(object_file)],
        capture_output=True,
        check=True,
        env=tool_environment(),
    )
    from_stdin = subprocess.run(
        [*command, "-"],
        input=object_file.read_bytes(),
        capture_output=True,
        check=True,
        env=tool_environment(),
    )
    assert from_file.stdout == from_stdin.stdout
    result = json.loads(from_file.stdout)
    assert result["schema_version"] == 1
    for key in ("defined_symbols", "undefined_symbols"):
        assert result[key] == sorted(set(result[key]))


@pytest.mark.skipif(
    sys.platform != "linux", reason="Uses the ELF linker bundled on Linux"
)
def test_stripped_shared_library_symbols(object_file, object_target, tmp_path):
    if "linux" not in object_target:
        pytest.skip("The ELF linker needs an ELF object")
    output = tmp_path / "stripped.so"
    subprocess.run(
        [
            str(tool_path("ld.lld")),
            "-shared",
            "--strip-all",
            str(object_file),
            "-o",
            str(output),
        ],
        check=True,
        capture_output=True,
        env=tool_environment(),
    )
    # After stripping, the only names left are in the dynamic symbol table.
    # qmain and its external references should still be available to callers.
    symbols = inspect_object(output)
    assert "qmain" in symbols.defined_symbols
    assert symbols.undefined_symbols == {"selene_load_config", "external_data"}


@pytest.mark.parametrize(
    "contents", [b"", b"not an object", b"\x7fELFbroken", b"BC\xc0\xdebroken"]
)
def test_invalid_objects_report_diagnostics(contents):
    with pytest.raises(RuntimeError, match="Cannot parse object file"):
        inspect_object(contents)


def test_missing_object_is_reported(tmp_path):
    with pytest.raises(RuntimeError, match="Cannot read object file"):
        inspect_object(tmp_path / "missing.o")
