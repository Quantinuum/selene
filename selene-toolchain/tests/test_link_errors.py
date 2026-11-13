"""Link failures should identify user inputs and preserve LLD's diagnostics."""

import subprocess
import sys
from pathlib import Path

import pytest

from selene_toolchain import (
    Bitcode,
    Executor,
    LinkDiagnostic,
    LinkError,
    LinkReference,
    Store,
    Toolchain,
)


PROGRAM = b"""
declare void @selene_missing_function()
define i32 @main() {
    call void @selene_missing_function()
    ret i32 0
}
"""


@pytest.mark.parametrize("from_file", [False, True])
def test_link_errors_identify_the_input(tmp_path, from_file):
    name = "caller with spaces café.ll"
    if from_file:
        path = tmp_path / name
        path.write_bytes(PROGRAM)
        source = Bitcode.from_path(path)
    else:
        source = Bitcode.from_bytes(PROGRAM, name=name)
    assert source.name == name
    toolchain = Toolchain.bundled()
    executor = Executor(Store.local(tmp_path / "store"), jobs=2)
    obj = toolchain.compile(source).plan()
    assert executor.build(obj).artifact.name == "caller with spaces café.o"
    plan = toolchain.link_executable().object(obj).plan()
    with pytest.raises(LinkError) as caught:
        executor.build(plan)
    error = caught.value
    # Existing callers can still catch RuntimeError, while more specific callers
    # can use the original LLD output without scraping our displayed message.
    assert isinstance(error, RuntimeError)
    assert "selene_missing_function" in error.diagnostics
    assert "caller with spaces café.o" in error.diagnostics
    assert "caller with spaces café.o" in error.inputs
    assert "selene_missing_function" in error.raw_diagnostics
    assert "artifacts/" not in error.diagnostics.replace("\\", "/")
    assert str(error) == f"link failed:\n{error.diagnostics}"
    assert len(error.entries) == 1
    entry = error.entries[0]
    assert isinstance(entry, LinkDiagnostic)
    assert entry.kind == "undefined_symbol"
    assert entry.severity == "error"
    assert entry.symbol.endswith("selene_missing_function")
    assert str(entry) == error.diagnostics
    assert "ld.lld: error:" not in error.diagnostics
    assert ">>>" not in error.diagnostics
    reference = entry.references[0]
    assert isinstance(reference, LinkReference)
    assert reference.artifact == "caller with spaces café.o"
    assert reference.function.lstrip("_") == "main"


def test_same_named_inputs_are_distinguishable(tmp_path):
    toolchain = Toolchain.bundled()
    sources = [
        Bitcode.from_bytes(PROGRAM, name="program.ll"),
        Bitcode.from_bytes(
            b"declare void @another_missing_function()\n"
            b"define void @helper() { call void @another_missing_function() ret void }",
            name="program.ll",
        ),
    ]
    objects = [toolchain.compile(source).plan() for source in sources]
    executor = Executor(Store.local(tmp_path / "store"), jobs=2)
    identities = [executor.build(obj).artifact.digest for obj in objects]
    plan = toolchain.link_executable().object(objects[0]).object(objects[1]).plan()
    with pytest.raises(LinkError) as caught:
        executor.build(plan)
    error = caught.value
    # Two directories can each contain program.ll. Show a short content digest
    # only when we need it to distinguish their compiled objects.
    for digest in identities:
        label = f"program.o [{digest[:12]}]"
        assert label in error.inputs
        assert label in error.diagnostics


def test_existing_source_filename_is_preserved(tmp_path):
    source = Bitcode.from_bytes(
        b'source_filename = "original_source.rs"\n' + PROGRAM,
        name="generated.ll",
    )
    toolchain = Toolchain.bundled()
    executor = Executor(Store.local(tmp_path / "store"))
    plan = toolchain.link_executable().object(toolchain.compile(source).plan()).plan()
    with pytest.raises(LinkError) as caught:
        executor.build(plan)
    assert "generated.o" in caught.value.inputs
    # ELF's file symbol records the module's original source filename. Giving
    # the artifact a useful name mustn't replace that existing information.
    if sys.platform == "linux":
        assert "original_source.rs" in caught.value.raw_diagnostics


@pytest.mark.parametrize(
    "name", ["", ".", "..", "../escape.ll", "a/b.ll", "a\\b.ll", "a\nb.ll"]
)
def test_artifact_names_are_filenames(name):
    with pytest.raises(RuntimeError, match="Artifact name must be a filename"):
        Bitcode.from_bytes(PROGRAM, name=name)


def test_names_are_part_of_the_plan_identity():
    first = Bitcode.from_bytes(PROGRAM, name="first.ll")
    second = Bitcode.from_bytes(PROGRAM, name="second.ll")
    assert first.digest == second.digest
    toolchain = Toolchain.bundled()
    assert (
        toolchain.compile(first).plan().describe()
        != toolchain.compile(second).plan().describe()
    )


def test_duplicate_symbols_have_structured_definitions(tmp_path):
    # A previous LLD bug left dangling pointers after a duplicate-symbol error
    # and crashed the next link. Check recovery in a child process so that a
    # regression reports this test's failure without taking down all of pytest.
    result = subprocess.run(
        [sys.executable, __file__, str(tmp_path)],
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def check_duplicate_symbols_and_recovery(tmp_path):
    toolchain = Toolchain.bundled()
    executor = Executor(Store.local(tmp_path / "store"))
    first = toolchain.compile(
        Bitcode.from_bytes(
            b"define i32 @main() { ret i32 0 }\ndefine i32 @answer() { ret i32 1 }",
            name="first.ll",
        )
    ).plan()
    second = toolchain.compile(
        Bitcode.from_bytes(
            b"define i32 @answer() { ret i32 2 }",
            name="second.ll",
        )
    ).plan()
    plan = toolchain.link_executable().object(first).object(second).plan()
    with pytest.raises(LinkError) as caught:
        executor.build(plan)
    entry = next(
        entry for entry in caught.value.entries if entry.kind == "duplicate_symbol"
    )
    assert entry.symbol.endswith("answer")
    assert {ref.artifact for ref in entry.references} == {"first.o", "second.o"}
    assert all(ref.relation == "defined_at" for ref in entry.references)
    # Reuse the same backend after the error. The new link has no duplicate
    # definitions, so it should succeed without replaying the old diagnostics.
    plan = toolchain.link_executable().object(first).plan()
    result = executor.build(plan)
    assert result.artifact.symbols().defined_symbols >= {"main", "answer"}


if __name__ == "__main__":
    check_duplicate_symbols_and_recovery(Path(sys.argv[1]))
