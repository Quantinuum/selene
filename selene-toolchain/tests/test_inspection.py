from pathlib import Path

import pytest

from selene_toolchain import inspect_module

resources = Path(__file__).parent / "resources"


@pytest.mark.parametrize("source_kind", ["ir", "bitcode", "ir_file", "bitcode_file"])
def test_function_inspection_without_system_tools(tmp_path, monkeypatch, source_kind):
    if source_kind == "ir":
        contents = (resources / "symbols.ll").read_text()
    elif source_kind == "bitcode":
        contents = (resources / "symbols.bc").read_bytes()
    else:
        suffix = ".ll" if source_kind == "ir_file" else ".bc"
        contents = tmp_path / f"input with spaces café{suffix}"
        contents.write_bytes((resources / f"symbols{suffix}").read_bytes())
    monkeypatch.setenv("PATH", str(tmp_path / "empty-path"))
    monkeypatch.delenv("HUGRENV_PATH", raising=False)

    symbols = inspect_module(contents)
    # We're inspecting functions in the module, so unused declarations and
    # internal definitions should still appear. Globals and aliases shouldn't
    # appear even though llvm-nm would list them in its symbol table.
    assert symbols.defined_functions == {
        "qmain",
        "internal_helper",
        'quoted" name\\tail',
        "café",
    }
    assert symbols.declared_functions == {"setup", "unused_function", "weak_function"}


@pytest.mark.parametrize("suffix", [".ll", ".bc"])
def test_inspection_agrees_for_paths_and_bytes(suffix):
    source = resources / f"symbols{suffix}"
    assert inspect_module(source) == inspect_module(source.read_bytes())


@pytest.mark.parametrize(
    "contents", ["define this is invalid", b"BC\xc0\xdebroken bitcode"]
)
def test_invalid_modules_report_llvm_diagnostics(contents):
    with pytest.raises(RuntimeError, match="LLVM module inspection failed") as failure:
        inspect_module(contents)
    assert "error" in str(failure.value).lower()


def test_missing_file_is_reported(tmp_path):
    with pytest.raises(FileNotFoundError):
        inspect_module(tmp_path / "missing.ll")


def test_function_names_must_be_utf8():
    with pytest.raises(RuntimeError, match="function names must be valid UTF-8"):
        inspect_module('declare void @"invalid\\FF"()')


def test_empty_module():
    symbols = inspect_module("")
    assert symbols.defined_functions == frozenset()
    assert symbols.declared_functions == frozenset()
