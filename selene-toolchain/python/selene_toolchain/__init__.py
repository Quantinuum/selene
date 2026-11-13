"""Immutable artifacts and native LLVM build plans, backed by a Rust library."""

import atexit
import json
import os
import platform
import sys
from dataclasses import dataclass
from enum import IntEnum
from functools import cache
from pathlib import Path
from typing import ClassVar, Iterable

dist_dir = Path(__file__).parent / "_dist"
# Keep handles alive for local Windows builds too. Repaired wheels additionally
# use delvewheel's package-level DLL directory.
_dll_directories: list[object] = []
if sys.platform == "win32":
    for _directory in (dist_dir / "bin", dist_dir / "lib"):
        if _directory.is_dir():
            _dll_directories.append(os.add_dll_directory(str(_directory)))

from . import _native  # noqa: E402

LinkError = _native.LinkError
LinkDiagnostic = _native.LinkDiagnostic
LinkReference = _native.LinkReference

if sys.platform == "win32":
    atexit.register(_native._shutdown)


class Optimisation(IntEnum):
    NONE = 0
    LESS = 1
    DEFAULT = 2
    AGGRESSIVE = 3


@dataclass(frozen=True)
class ModuleSymbols:
    defined_functions: frozenset[str]
    declared_functions: frozenset[str]


@dataclass(frozen=True)
class ObjectSymbols:
    defined_symbols: frozenset[str]
    undefined_symbols: frozenset[str]


@dataclass(frozen=True)
class Artifact:
    """An immutable snapshot, independent of later changes to the source file."""

    _handle: _native.Artifact
    _kind: ClassVar[str]

    @classmethod
    def from_path(cls, path: Path | str):
        return cls(_native.Artifact.from_path(cls._kind, Path(path)))

    @classmethod
    def from_bytes(cls, data: bytes, *, name: str | None = None):
        return cls(_native.Artifact.from_bytes(cls._kind, data, name=name))

    @property
    def name(self) -> str:
        return self._handle.name

    @property
    def digest(self) -> str:
        return self._handle.digest

    def copy_to(self, path: Path | str) -> None:
        self._handle.copy_to(Path(path))

    def to_bytes(self) -> bytes:
        return bytes(self._handle.bytes())

    def symbols(self, toolchain=None) -> ObjectSymbols:
        toolchain = toolchain or Toolchain.bundled()
        result = toolchain._inspect(self)
        return ObjectSymbols(
            frozenset(result["defined_symbols"]), frozenset(result["undefined_symbols"])
        )

    def target(self, toolchain=None) -> str:
        return (toolchain or Toolchain.bundled())._inspect(self)["target"]


class Bitcode(Artifact):
    """LLVM IR or bitcode. Functions and linker symbols are different queries."""

    _kind = "bitcode"

    def symbols(self, toolchain=None) -> ObjectSymbols:
        raise TypeError(
            "Use functions() for LLVM modules, or inspect symbols after compiling an object"
        )

    def functions(self, toolchain=None) -> ModuleSymbols:
        result = (toolchain or Toolchain.bundled())._inspect(self)
        return ModuleSymbols(
            frozenset(result["defined_functions"]),
            frozenset(result["declared_functions"]),
        )


class ObjectFile(Artifact):
    _kind = "object"


class StaticLibrary(Artifact):
    _kind = "static_library"


class SharedLibrary(Artifact):
    _kind = "shared_library"


class Executable(Artifact):
    _kind = "executable"


@dataclass(frozen=True)
class Plan:
    _handle: _native.Plan

    def describe(self) -> dict:
        return json.loads(self._handle.describe())


@dataclass(frozen=True)
class CompileBuilder:
    toolchain: "Toolchain"
    source: Bitcode
    level: int = 0
    retargeting: bool = False

    def optimisation(self, level: Optimisation | int) -> "CompileBuilder":
        return CompileBuilder(self.toolchain, self.source, int(level), self.retargeting)

    def retarget(self, enabled: bool = True) -> "CompileBuilder":
        return CompileBuilder(self.toolchain, self.source, self.level, enabled)

    def plan(self) -> Plan:
        return Plan(
            self.toolchain._handle.compile_plan(
                self.source._handle, self.level, self.retargeting
            )
        )


@dataclass(frozen=True)
class LinkBuilder:
    toolchain: "Toolchain"
    shared: bool = False
    inputs: tuple = ()
    system: tuple[str, ...] = ()
    directories: tuple[Path, ...] = ()
    flags: tuple[str, ...] = ()

    def _with(self, **changes):
        from dataclasses import replace

        return replace(self, **changes)

    def object(self, artifact: ObjectFile | Plan) -> "LinkBuilder":
        return self._with(inputs=(*self.inputs, artifact))

    def library(self, artifact: StaticLibrary | SharedLibrary) -> "LinkBuilder":
        return self._with(inputs=(*self.inputs, artifact))

    def system_library(self, name: str) -> "LinkBuilder":
        return self._with(system=(*self.system, name))

    def search_directory(self, path: Path | str) -> "LinkBuilder":
        return self._with(directories=(*self.directories, Path(path)))

    def link_flag(self, flag: str) -> "LinkBuilder":
        return self._with(flags=(*self.flags, flag))

    def plan(self) -> Plan:
        return Plan(
            self.toolchain._handle.link_plan(
                [item._handle for item in self.inputs],
                list(self.system),
                list(self.directories),
                list(self.flags),
                self.shared,
            )
        )


class Toolchain:
    def __init__(self, directory: Path | str):
        self._handle = _native.Toolchain(Path(directory))

    @classmethod
    @cache
    def bundled(cls) -> "Toolchain":
        return cls(dist_dir)

    @property
    def version(self) -> str:
        return self._handle.version()

    def _inspect(self, artifact: Artifact) -> dict:
        return json.loads(self._handle.inspect(artifact._handle))

    def compile(self, source: Bitcode) -> CompileBuilder:
        return CompileBuilder(self, source)

    def link_executable(self) -> LinkBuilder:
        return LinkBuilder(self)

    def link_shared_library(self) -> LinkBuilder:
        return LinkBuilder(self, shared=True)


class BuildResult:
    def __init__(self, handle):
        self._handle = handle

    @property
    def artifact(self) -> Artifact:
        handle = self._handle.artifact
        cls = {
            "object": ObjectFile,
            "shared_library": SharedLibrary,
            "executable": Executable,
        }[handle.kind]
        return cls(handle)

    @property
    def path(self) -> Path:
        return self._handle.path

    @property
    def cache_hit(self) -> bool:
        return self._handle.cache_hit

    @property
    def diagnostics(self) -> str:
        return self._handle.diagnostics

    @property
    def key(self) -> str:
        return self._handle.key


class Store:
    def __init__(self, directory: Path | str | None = None):
        self._handle = _native.Store(None if directory is None else Path(directory))

    @classmethod
    @cache
    def default(cls) -> "Store":
        return cls()

    @classmethod
    def local(cls, directory: Path | str) -> "Store":
        return cls(directory)

    @property
    def root(self) -> Path:
        return self._handle.root

    def build(self, plan: Plan) -> BuildResult:
        """Build with the default single-worker executor."""
        return BuildResult(self._handle.build(plan._handle))

    def clean(self, *, dry_run: bool = False) -> int:
        """Evict build records and temporary files, preserving captured libraries."""
        return self._handle.clean(dry_run)


class Executor:
    def __init__(self, store: Store | None = None, *, jobs: int = 1):
        if jobs < 1:
            raise ValueError("jobs must be greater than zero")
        self._store = Store.default() if store is None else store
        self._handle = _native.Executor(self._store._handle, jobs=jobs)

    @property
    def store(self) -> Store:
        return self._store

    @property
    def jobs(self) -> int:
        return self._handle.jobs

    def build(self, plan: Plan) -> BuildResult:
        return BuildResult(self._handle.build(plan._handle))


def inspect_module(contents: str | Path | bytes) -> ModuleSymbols:
    if isinstance(contents, Path):
        if contents.suffix not in (".ll", ".bc"):
            raise ValueError(
                f"Unsupported file extension for LLVM contents: {contents.suffix}"
            )
        contents = contents.read_bytes()
    elif isinstance(contents, str):
        contents = contents.encode()
    elif not isinstance(contents, bytes):
        raise TypeError(f"Unsupported type for LLVM contents: {type(contents)}")
    return Bitcode.from_bytes(contents).functions()


def inspect_object(contents: Path | bytes) -> ObjectSymbols:
    if isinstance(contents, Path):
        contents = contents.read_bytes()
    elif not isinstance(contents, bytes):
        raise TypeError(f"Unsupported type for object contents: {type(contents)}")
    return ObjectFile.from_bytes(contents).symbols()


def compile_object(source: Path, output: Path, *, verbose: bool = False) -> None:
    # The old llc adapter always overrode target metadata with the host target.
    # Keep that policy explicit here; new build plans default to validation.
    plan = Toolchain.bundled().compile(Bitcode.from_path(source)).retarget().plan()
    _build_to(plan, output, verbose)


def link_executable(
    objects: Iterable[Path],
    output: Path,
    *,
    libraries: Iterable[Path] = (),
    library_search_dirs: Iterable[Path] = (),
    link_flags: Iterable[str] = (),
    verbose: bool = False,
) -> None:
    builder = Toolchain.bundled().link_executable()
    for path in objects:
        builder = builder.object(ObjectFile.from_path(path))
    for path in libraries:
        cls = StaticLibrary if path.suffix in (".a", ".lib") else SharedLibrary
        builder = builder.library(cls.from_path(path))
    for path in library_search_dirs:
        builder = builder.search_directory(path)
    for flag in link_flags:
        builder = builder.link_flag(flag)
    _build_to(builder.plan(), output, verbose)


def _build_to(plan: Plan, output: Path, verbose: bool) -> None:
    result = Store.default().build(plan)
    result.artifact.copy_to(output)
    if verbose:
        print(f"LLVM build {result.key}: {'cached' if result.cache_hit else 'built'}")
        if result.diagnostics:
            print(result.diagnostics)


def target_triple() -> str:
    machine = platform.machine().lower()
    arch = {"amd64": "x86_64", "arm64": "aarch64"}.get(machine, machine)
    if arch not in ("x86_64", "aarch64"):
        raise RuntimeError(f"Unsupported architecture: {machine}")
    system = platform.system()
    if system == "Linux":
        return f"{arch}-unknown-linux-gnu"
    if system == "Darwin":
        return f"{arch}-apple-macosx11.0.0"
    if system == "Windows" and arch == "x86_64":
        return "x86_64-w64-windows-gnu"
    raise RuntimeError(f"Unsupported platform: {system} {arch}")


def tool_path(name: str) -> Path:
    """Find the remaining diagnostic utilities; builds use LLVM libraries."""
    path = (
        dist_dir / "bin" / (name + (".exe" if platform.system() == "Windows" else ""))
    )
    if not path.is_file():
        raise RuntimeError(f"Missing selene-toolchain tool: {path}")
    return path


def tool_environment() -> dict[str, str]:
    env = os.environ.copy()
    if platform.system() == "Windows":
        env["PATH"] = os.pathsep.join(
            [
                str(dist_dir / "bin"),
                str(dist_dir.parent.parent / "selene_toolchain.libs"),
                str(Path(sys.executable).parent),
                env.get("PATH", ""),
            ]
        )
    return env
