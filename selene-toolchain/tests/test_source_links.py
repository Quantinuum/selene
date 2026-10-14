import hashlib
import importlib.util
import json
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest


@pytest.fixture
def build_hook():
    # These checks exercise the release packaging without rebuilding LLVM.
    # The native tools aren't relevant to whether a source link matches a
    # copied runtime file.
    pytest.importorskip("hatchling")
    spec = importlib.util.spec_from_file_location(
        "toolchain_build_hook", Path(__file__).parents[1] / "hatch_build.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.ToolchainBuildHook


@pytest.fixture
def llvm_hugrenv(tmp_path):
    prefix = tmp_path / "hugrenv"
    config = prefix / "lib/cmake/llvm/LLVMConfig.cmake"
    config.parent.mkdir(parents=True)
    config.write_text("# LLVM package config\n")
    return prefix


@pytest.fixture
def source_release(tmp_path, monkeypatch):
    monkeypatch.setenv("CIBUILDWHEEL", "1")
    sources = tmp_path / "source-bundles"
    sources.mkdir()
    dist = tmp_path / "dist"
    (dist / "runtime").mkdir(parents=True)
    (dist / "runtime/libgcc.a").write_bytes(b"runtime")
    (sources / "gcc.src.rpm").write_bytes(b"source and build recipe")
    manifest = {
        "version": "0.1.0",
        "machine": "x86_64",
        "inputs": {
            "libgcc.a": {
                "sha256": hashlib.sha256(b"runtime").hexdigest(),
                "source": "gcc.src.rpm",
            }
        },
        "sources": {
            "gcc.src.rpm": {
                "sha256": hashlib.sha256(b"source and build recipe").hexdigest(),
                "url": "https://example.com/gcc.src.rpm",
            }
        },
    }
    (sources / "linux-x86_64.json").write_text(json.dumps(manifest))
    return tmp_path, dist


def check_sources(build_hook, source_release):
    root, dist = source_release
    build_hook._source_manifest(
        SimpleNamespace(metadata=SimpleNamespace(version="0.1.0")),
        root,
        dist,
        "x86_64",
    )


def test_release_wheel_only_gets_source_links(build_hook, source_release):
    check_sources(build_hook, source_release)
    root, dist = source_release
    # Users should get enough information to download the matching sources,
    # but they shouldn't have to download the source RPM with every install.
    assert (dist / "sources.json").read_bytes() == (
        root / "source-bundles/linux-x86_64.json"
    ).read_bytes()
    assert not list(dist.rglob("*.src.rpm"))


@pytest.mark.parametrize("changed", ["runtime", "source", "coverage", "version"])
def test_release_rejects_mismatched_sources(build_hook, source_release, changed):
    root, dist = source_release
    if changed == "runtime":
        (dist / "runtime/libgcc.a").write_bytes(b"different compiler build")
    elif changed == "source":
        (root / "source-bundles/gcc.src.rpm").write_bytes(b"different sources")
    elif changed == "coverage":
        (dist / "runtime/another.a").write_bytes(b"another runtime library")
    else:
        path = root / "source-bundles/linux-x86_64.json"
        manifest = json.loads(path.read_text())
        manifest["version"] = "0.2.0"
        path.write_text(json.dumps(manifest))
    # If the build environment changes, old source links could still look
    # plausible. We should refuse to publish them unless they match the files
    # we're actually distributing and the release we're building.
    with pytest.raises(RuntimeError):
        check_sources(build_hook, source_release)


def test_local_build_doesnt_inherit_release_links(
    build_hook, source_release, monkeypatch
):
    monkeypatch.delenv("CIBUILDWHEEL")
    check_sources(build_hook, source_release)
    assert not (source_release[1] / "sources.json").exists()


@pytest.mark.parametrize("changed", [False, True])
def test_windows_links_match_the_compiler_build(
    build_hook, tmp_path, monkeypatch, changed
):
    monkeypatch.setenv("CIBUILDWHEEL", "1")
    (tmp_path / "vendor").mkdir()
    (tmp_path / "dist/licenses").mkdir(parents=True)
    (tmp_path / "mingw/bin").mkdir(parents=True)
    info = tmp_path / "mingw/build-info.txt"
    info.write_bytes(b"configure arguments and patch list")
    links = {
        "compiler_version": "14.2.0",
        "build_information_sha256": hashlib.sha256(info.read_bytes()).hexdigest(),
        "sources": {"GCC": "https://example.com/gcc-14.2.0.tar.xz"},
    }
    (tmp_path / "vendor/windows-sources.json").write_text(json.dumps(links))
    monkeypatch.setattr("subprocess.check_output", lambda *args, **kwargs: "14.2.0\n")
    monkeypatch.setattr("shutil.which", lambda name: str(tmp_path / "mingw/bin/gcc"))
    if changed:
        # Two compiler distributions can report the same GCC version but use
        # different patches. The version number alone shouldn't let the new
        # distribution inherit links to the old build's sources.
        info.write_bytes(b"different patch list for the same GCC version")
        with pytest.raises(RuntimeError, match="source links"):
            build_hook._windows_source_links(tmp_path, tmp_path / "dist", ["gcc"])
    else:
        build_hook._windows_source_links(tmp_path, tmp_path / "dist", ["gcc"])
        assert json.loads((tmp_path / "dist/sources.json").read_text()) == links
        assert (
            tmp_path / "dist/licenses/MinGW-build-info.txt"
        ).read_bytes() == info.read_bytes()


@pytest.mark.parametrize("llvm_build", ["mingw", "msvc", "other-mingw"])
def test_windows_llvm_requires_the_same_mingw_build(
    build_hook, tmp_path, monkeypatch, llvm_build
):
    compiler = tmp_path / "mingw/bin/gcc.exe"
    compiler.parent.mkdir(parents=True)
    (compiler.parent.parent / "build-info.txt").write_bytes(b"our MinGW build")
    monkeypatch.setenv("CC", str(compiler))
    hugrenv = tmp_path / "hugrenv"
    (hugrenv / "bin").mkdir(parents=True)
    (tmp_path / "dist/bin").mkdir(parents=True)
    if llvm_build != "msvc":
        info = hugrenv / "share/mingw/build-info.txt"
        info.parent.mkdir(parents=True)
        info.write_bytes(
            b"our MinGW build" if llvm_build == "mingw" else b"another MinGW build"
        )
    for name in ("libgcc_s_seh-1.dll", "libstdc++-6.dll", "libwinpthread-1.dll"):
        (hugrenv / "bin" / name).write_bytes(name.encode())
    # MSVC's archive doesn't have the MinGW build information. A different
    # MinGW distribution can also use incompatible runtime DLLs, so neither
    # should get as far as linking the inspector against LLVM.
    if llvm_build != "mingw":
        with pytest.raises(RuntimeError, match="win_mingw_amd64|build information"):
            build_hook._windows_llvm_runtime(hugrenv, tmp_path / "dist")
    else:
        build_hook._windows_llvm_runtime(hugrenv, tmp_path / "dist")
        assert {p.name for p in (tmp_path / "dist/bin").iterdir()} == {
            "libgcc_s_seh-1.dll",
            "libstdc++-6.dll",
            "libwinpthread-1.dll",
        }


def test_windows_inspector_uses_the_mingw_compilers(
    build_hook, tmp_path, monkeypatch, llvm_hugrenv
):
    compiler_bin = tmp_path / "MinGW with spaces/bin"
    monkeypatch.setenv("CC", f'"{compiler_bin}/gcc.exe"')
    monkeypatch.setenv("CXX", f'"{compiler_bin}/g++.exe"')
    commands = []
    monkeypatch.setattr(
        "subprocess.run", lambda command, **kwargs: commands.append((command, kwargs))
    )
    # We only inspect CMake's arguments here. The native Windows build and
    # execution tests run in CI, so this test doesn't invoke a compiler.
    build_hook._build_inspector(tmp_path, llvm_hugrenv, tmp_path / "dist", "Windows")
    configure, options = commands[0]
    assert configure[configure.index("-G") + 1] == "Ninja"
    assert f"-DCMAKE_C_COMPILER={(compiler_bin / 'gcc.exe').as_posix()}" in configure
    assert f"-DCMAKE_CXX_COMPILER={(compiler_bin / 'g++.exe').as_posix()}" in configure
    assert options["env"]["CC"] == f'"{compiler_bin}/gcc.exe"'
    assert options["env"]["CXX"] == f'"{compiler_bin}/g++.exe"'


def test_windows_inspector_rejects_mixed_compilers(
    build_hook, tmp_path, monkeypatch, llvm_hugrenv
):
    monkeypatch.setenv("CC", str(tmp_path / "mingw/bin/gcc.exe"))
    monkeypatch.setenv("CXX", str(tmp_path / "other/bin/g++.exe"))
    with pytest.raises(RuntimeError, match="same MinGW installation"):
        build_hook._build_inspector(
            tmp_path, llvm_hugrenv, tmp_path / "dist", "Windows"
        )


@pytest.mark.skipif(sys.platform == "win32", reason="Nix symlink layout")
def test_inspector_uses_the_real_llvm_package_directory(
    build_hook, tmp_path, monkeypatch, llvm_hugrenv
):
    config = llvm_hugrenv / "lib/cmake/llvm/LLVMConfig.cmake"
    real_config = tmp_path / "llvm-source/lib/cmake/llvm/LLVMConfig.cmake"
    real_config.parent.mkdir(parents=True)
    config.rename(real_config)
    config.symlink_to(real_config)
    commands = []
    monkeypatch.setattr(
        "subprocess.run", lambda command, **kwargs: commands.append(command)
    )
    # Nix's joined prefix contains symlinks, while LLVM's unpacked archive has
    # the config files beside their exports. CMake should load that real
    # directory so its includes don't lead back into the joined prefix.
    build_hook._build_inspector(tmp_path, llvm_hugrenv, tmp_path / "dist", "Linux")
    assert f"-DLLVM_DIR={real_config.parent}" in commands[0]


@pytest.mark.skipif(sys.platform == "win32", reason="Linux host mount paths")
def test_container_llvm_config_symlink_points_into_host_mount(build_hook, monkeypatch):
    joined = Path("/host/nix/store/join/lib/cmake/llvm/LLVMConfig.cmake")
    target = Path("/nix/store/source/lib/cmake/llvm/LLVMConfig.cmake")
    monkeypatch.setattr(Path, "is_symlink", lambda path: path == joined)
    monkeypatch.setattr(Path, "readlink", lambda path: target)
    # Docker mounts the host under /host. The symlink still contains the
    # host's original absolute path, so the resolved path needs that prefix.
    assert build_hook._resolve(joined) == Path("/host") / target.relative_to("/")


def test_missing_llvm_package_reports_the_path(build_hook, tmp_path):
    with pytest.raises(RuntimeError, match="LLVMConfig.cmake.*HUGRENV_PATH"):
        build_hook._build_inspector(
            tmp_path, tmp_path / "missing", tmp_path / "dist", "Linux"
        )
