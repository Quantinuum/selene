import sys
from pathlib import Path

import pytest

from selene_toolchain import ObjectFile, Store, Toolchain, inspect_object, target_triple

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
    output.write_bytes(
        bytes(
            Toolchain.bundled()._handle.compile_bytes(
                source.read_bytes(), object_target
            )
        )
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


def test_object_inspection_agrees_for_paths_and_bytes(object_file):
    assert inspect_object(object_file) == inspect_object(object_file.read_bytes())


@pytest.mark.skipif(
    sys.platform != "linux", reason="Uses the ELF linker bundled on Linux"
)
def test_stripped_shared_library_symbols(object_file, object_target, tmp_path):
    if object_target != target_triple():
        pytest.skip("Build plans currently link only native objects")
    plan = (
        Toolchain.bundled()
        .link_shared_library()
        .object(ObjectFile.from_path(object_file))
        .link_flag("--strip-all")
        .plan()
    )
    output = Store.local(tmp_path / "store").build(plan).path
    # After stripping, the only names left are in the dynamic symbol table.
    # qmain and its external references should still be available to callers.
    symbols = inspect_object(output)
    assert "qmain" in symbols.defined_symbols
    # Shared-library startup files also have weak references to optional
    # runtime hooks. The program's references must survive stripping too.
    assert {"selene_load_config", "external_data"} <= symbols.undefined_symbols


@pytest.mark.parametrize(
    "contents", [b"", b"not an object", b"\x7fELFbroken", b"BC\xc0\xdebroken"]
)
def test_invalid_objects_report_diagnostics(contents):
    with pytest.raises(RuntimeError, match="Cannot parse object file"):
        inspect_object(contents)


def test_missing_object_is_reported(tmp_path):
    with pytest.raises(FileNotFoundError):
        inspect_object(tmp_path / "missing.o")
