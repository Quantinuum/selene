"""The public API runs against the real Rust extension and LLVM bridge."""

import concurrent.futures
import json
import subprocess
import sys
import textwrap

import pytest

from selene_toolchain import (
    Bitcode,
    Executor,
    SharedLibrary,
    Store,
    Toolchain,
    inspect_object,
)

PROGRAM = b"define i32 @main() { ret i32 0 }"


@pytest.fixture
def toolchain():
    return Toolchain.bundled()


def test_native_build_and_cache_without_executables(toolchain, tmp_path, monkeypatch):
    store = Store.local(tmp_path / "store with spaces")
    # Failure here would mean the implementation still shells out to LLVM.
    monkeypatch.setattr(
        subprocess, "run", lambda *args, **kwargs: pytest.fail("Unexpected subprocess")
    )
    monkeypatch.setenv("PATH", "")
    source = Bitcode.from_bytes(PROGRAM)
    object_plan = toolchain.compile(source).plan()
    plan = toolchain.link_executable().object(object_plan).plan()
    first = store.build(plan)
    second = store.build(plan)
    assert not first.cache_hit
    assert second.cache_hit
    assert first.key == second.key
    assert first.artifact.digest == second.artifact.digest
    description = plan.describe()
    assert description["inputs"][0]["operation"] == "compile"
    records = [
        json.loads(p.read_text()) for p in (store.root / "builds").glob("*.json")
    ]
    assert len(records) == 2
    assert all(record["schema"] == 1 for record in records)
    assert "main" in store.build(object_plan).artifact.symbols().defined_symbols


def test_exported_executable_runs(toolchain, tmp_path):
    store = Store.local(tmp_path / "store")
    plan = (
        toolchain.link_executable()
        .object(toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan())
        .plan()
    )
    result = store.build(plan)
    output = tmp_path / "program.exe"
    result.artifact.copy_to(output)
    subprocess.run([str(output)], check=True)


@pytest.mark.skipif(sys.platform != "win32", reason="Exercises Windows DLL unloading")
def test_python_exits_after_native_linking():
    # LLD leaves a worker pool alive after linking. We need to stop it before
    # Windows unloads the extension, because waiting for workers during DLL
    # destruction can leave Python hanging even though the build succeeded.
    subprocess.run(
        [
            sys.executable,
            "-c",
            textwrap.dedent("""\
                from tempfile import TemporaryDirectory
                from selene_toolchain import Bitcode, Executor, Store, Toolchain

                toolchain = Toolchain.bundled()
                with TemporaryDirectory() as root:
                    source = Bitcode.from_bytes(b"define i32 @main() { ret i32 0 }")
                    plan = toolchain.link_executable().object(
                        toolchain.compile(source).plan()
                    ).plan()
                    Executor(Store.local(root), jobs=2).build(plan)
                """),
        ],
        check=True,
        timeout=30,
    )


def test_input_snapshot_and_invalidation(toolchain, tmp_path):
    path = tmp_path / "program.ll"
    path.write_bytes(PROGRAM)
    source = Bitcode.from_path(path)
    plan = toolchain.compile(source).plan()
    path.write_bytes(b"define i32 @main() { ret i32 9 }")
    store = Store.local(tmp_path / "store")
    first = store.build(plan)
    assert store.build(plan).cache_hit
    changed = store.build(toolchain.compile(Bitcode.from_path(path)).plan())
    assert not changed.cache_hit
    assert first.key != changed.key
    assert first.artifact.digest != changed.artifact.digest
    assert source.to_bytes() == PROGRAM


def test_optimisation_is_in_the_build_key(toolchain, tmp_path):
    module = Bitcode.from_bytes(PROGRAM)
    store = Store.local(tmp_path / "store")
    normal = store.build(toolchain.compile(module).plan())
    optimised = store.build(toolchain.compile(module).optimisation(2).plan())
    assert normal.key != optimised.key
    assert not optimised.cache_hit


def test_parallel_builds_share_a_result(toolchain, tmp_path):
    store = Store.local(tmp_path / "store")
    plan = toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan()
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(lambda _: store.build(plan), range(4)))
    assert sum(not result.cache_hit for result in results) == 1
    assert len({result.artifact.digest for result in results}) == 1


@pytest.mark.parametrize("jobs", [1, 4])
def test_link_failure_doesnt_poison_backend_or_cache(toolchain, tmp_path, jobs):
    executor = Executor(Store.local(tmp_path / "store"), jobs=jobs)
    bad = Bitcode.from_bytes(
        b"declare void @missing()\ndefine i32 @main() { call void @missing() ret i32 0 }"
    )
    plan = toolchain.link_executable().object(toolchain.compile(bad).plan()).plan()
    with pytest.raises(RuntimeError, match="missing"):
        executor.build(plan)
    good = (
        toolchain.link_executable()
        .object(toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan())
        .plan()
    )
    assert not executor.build(good).cache_hit
    assert executor.build(good).cache_hit


def test_corrupt_cached_output_is_rejected(toolchain, tmp_path):
    store = Store.local(tmp_path / "store")
    plan = toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan()
    result = store.build(plan)
    result.path.write_bytes(b"broken")
    with pytest.raises(RuntimeError, match="Corrupt"):
        store.build(plan)


def test_linking_shared_library(toolchain, tmp_path):
    module = Bitcode.from_bytes(b"define i32 @answer() { ret i32 42 }")
    obj = toolchain.compile(module).plan()
    library = Store.local(tmp_path / "store").build(
        toolchain.link_shared_library().object(obj).plan()
    )
    assert isinstance(library.artifact, SharedLibrary)
    assert "answer" in library.artifact.symbols().defined_symbols
    output = tmp_path / ("answer.dll" if sys.platform == "win32" else "libanswer.so")
    library.artifact.copy_to(output)
    # Inspecting the symbols doesn't tell us whether the loader can initialise
    # the library. Load it in another process so Windows can release the DLL
    # before pytest removes the temporary directory.
    subprocess.run(
        [
            sys.executable,
            "-c",
            "import ctypes, sys\nassert ctypes.CDLL(sys.argv[1]).answer() == 42",
            str(output),
        ],
        check=True,
    )


def test_linker_escape_hatch_disables_cache(toolchain, tmp_path):
    plan = (
        toolchain.link_executable()
        .object(toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan())
        .link_flag("--version")
        .plan()
    )
    assert plan.describe()["cacheable"] is False


def test_native_target_mismatch_is_rejected(toolchain, tmp_path):
    wrong = (
        b'target triple = "wasm32-unknown-unknown"\ndefine i32 @main() { ret i32 0 }'
    )
    plan = toolchain.compile(Bitcode.from_bytes(wrong)).plan()
    with pytest.raises(RuntimeError, match="incompatible"):
        Store.local(tmp_path / "store").build(plan)


def test_clean_preserves_captured_artifacts(toolchain, tmp_path):
    store = Store.local(tmp_path / "store")
    result = store.build(toolchain.compile(Bitcode.from_bytes(PROGRAM)).plan())
    assert store.clean(dry_run=True) > 0
    assert result.path.exists()
    assert store.clean() > 0
    assert result.path.exists()
    assert not list((store.root / "builds").glob("*.json"))


@pytest.mark.parametrize("contents", ["object.o", None, [1, 2]])
def test_object_api_rejects_unsupported_inputs(contents):
    with pytest.raises(TypeError, match="Unsupported type for object contents"):
        inspect_object(contents)


@pytest.mark.skipif(
    __import__("sys").platform == "win32",
    reason="DLL deployment is separate from linking",
)
def test_executable_can_use_a_stored_shared_library(toolchain, tmp_path):
    store = Store.local(tmp_path / "store")
    library_source = Bitcode.from_bytes(b"define i32 @answer() { ret i32 42 }")
    library = store.build(
        toolchain.link_shared_library()
        .object(toolchain.compile(library_source).plan())
        .plan()
    )
    main = Bitcode.from_bytes(
        b"declare i32 @answer()\ndefine i32 @main() { %a = call i32 @answer() %bad = icmp ne i32 %a, 42 %result = zext i1 %bad to i32 ret i32 %result }"
    )
    plan = (
        toolchain.link_executable()
        .object(toolchain.compile(main).plan())
        .library(library.artifact)
        .plan()
    )
    executable = store.build(plan)
    output = tmp_path / "program"
    executable.artifact.copy_to(output)
    # The linker's temporary directory has gone away, but the stored shared
    # library should still be found through the executable's runtime search path.
    subprocess.run([str(output)], check=True)
    assert store.build(plan).cache_hit


def test_target_override_is_explicit_and_recorded(toolchain, tmp_path):
    source = Bitcode.from_bytes(
        b'target triple = "wasm32-unknown-unknown"\ndefine i32 @main() { ret i32 0 }'
    )
    plan = toolchain.compile(source).retarget().plan()
    assert plan.describe()["retarget"] is True
    assert Store.local(tmp_path / "store").build(
        plan
    ).artifact.symbols().defined_symbols >= {"main"}


def test_thin_archives_cannot_hide_inputs_from_the_cache(toolchain):
    from selene_toolchain import StaticLibrary

    library = StaticLibrary.from_bytes(b"!<thin>\n")
    with pytest.raises(RuntimeError, match="self-contained"):
        toolchain.link_executable().library(library).plan()


def test_distribution_contains_libraries_and_dependency_notices():
    from selene_toolchain import dist_dir

    # Compilation and linking no longer require generic command-line tools.
    for name in ("llc", "ld.lld", "ld64.lld", "selene-llvm"):
        assert not (dist_dir / "bin" / name).exists()
        assert not (dist_dir / "bin" / f"{name}.exe").exists()
    notices = json.loads((dist_dir / "licenses/rust/dependencies.json").read_text())
    assert {"pyo3", "sha2", "cc"} <= {notice["name"] for notice in notices}
