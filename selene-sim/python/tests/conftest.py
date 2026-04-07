"""Shared test fixtures and helpers for selene-sim tests."""

from __future__ import annotations

import platform
import textwrap
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import pytest

_TESTS_DIR = Path(__file__).parent
_QIS_DIR = _TESTS_DIR / "resources" / "qis" / "guppy"
_HUGR_DIR = _TESTS_DIR / "resources" / "hugr"

_DEFAULT_GUPPY_PREAMBLE = """\
from guppylang import guppy
from guppylang.std.angles import angle, pi
from guppylang.std.builtins import array, exit, panic, result
from guppylang.std.debug import state_result
from guppylang.std.quantum import (
    cx,
    cy,
    cz,
    discard,
    discard_array,
    h,
    measure,
    measure_array,
    qubit,
    rx,
    ry,
    rz,
    t,
    tdg,
    toffoli,
    x,
    y,
    z,
)
from guppylang.std.qsystem import measure_leaked
from guppylang.std.qsystem.random import RNG
from guppylang.std.qsystem.utils import get_current_shot
"""


def guppy_python_file(program_body: str, preamble: str = _DEFAULT_GUPPY_PREAMBLE) -> str:
    """Build a full python module string for an inline guppy program."""
    body = textwrap.dedent(program_body).strip()
    pre = textwrap.dedent(preamble).strip()
    return f"{pre}\n\n{body}\n"


def get_platform_suffix() -> str:
    """Return the platform-specific suffix used in QIS file names."""
    arch = platform.machine().lower()
    system = platform.system().lower()
    match arch:
        case "arm64" | "aarch64":
            target_arch = "aarch64"
        case "amd64" | "x86_64":
            target_arch = "x86_64"
        case _:
            raise RuntimeError(f"Unsupported architecture: {arch}")
    match system:
        case "linux":
            target_system = "unknown-linux-gnu"
        case "darwin":
            target_system = "apple-darwin"
        case "windows":
            target_system = "windows-msvc"
        case _:
            raise RuntimeError(f"Unsupported OS: {system}")
    return f"{target_arch}-{target_system}"


_PLATFORM_SUFFIX = get_platform_suffix()
_REGENERATE_GUPPY_SNAPSHOTS = False


ArtifactKind = Literal["qis", "hugr"]


@dataclass(frozen=True)
class InlineGuppyProgram:
    source_text: str
    entrypoint: str | None = None
    artifact_kind: ArtifactKind = "qis"


_INLINE_GUPPY_PROGRAMS: dict[str, InlineGuppyProgram] = {}
_REGENERATED_PROGRAMS: set[str] = set()


def register_inline_guppy_program(
    name: str,
    source_text: str,
    *,
    entrypoint: str | None = None,
    artifact_kind: ArtifactKind = "qis",
) -> None:
    """Register inline guppy source for snapshot lookup and optional regeneration."""
    spec = InlineGuppyProgram(
        source_text=source_text, entrypoint=entrypoint, artifact_kind=artifact_kind
    )
    previous = _INLINE_GUPPY_PROGRAMS.get(name)
    if previous is not None and previous != spec:
        raise RuntimeError(
            f"Conflicting inline guppy program registration for '{name}'. "
            "Program definitions must match across tests."
        )
    _INLINE_GUPPY_PROGRAMS[name] = spec


def register_inline_guppy_programs(
    programs: dict[str, str | InlineGuppyProgram],
    *,
    artifact_kind: ArtifactKind = "qis",
) -> None:
    """Register a set of named inline guppy programs."""
    for name, spec in programs.items():
        if isinstance(spec, InlineGuppyProgram):
            register_inline_guppy_program(
                name,
                spec.source_text,
                entrypoint=spec.entrypoint,
                artifact_kind=spec.artifact_kind,
            )
            continue
        register_inline_guppy_program(name, spec, artifact_kind=artifact_kind)


def pytest_addoption(parser: pytest.Parser) -> None:
    parser.addoption(
        "--regenerate-guppy-snapshots",
        action="store_true",
        default=False,
        help=(
            "Regenerate QIS/HUGR snapshots from inline guppy source embedded in tests."
        ),
    )


def pytest_configure(config: pytest.Config) -> None:
    global _REGENERATE_GUPPY_SNAPSHOTS
    _REGENERATE_GUPPY_SNAPSHOTS = bool(
        config.getoption("--regenerate-guppy-snapshots")
    )


def pytest_collection_finish(session: pytest.Session) -> None:
    if not _REGENERATE_GUPPY_SNAPSHOTS:
        return
    for name in sorted(_INLINE_GUPPY_PROGRAMS):
        _regenerate_snapshot(name)


def _guess_entrypoint(namespace: dict[str, object]) -> object:
    candidate = None
    for value in namespace.values():
        if callable(value) and hasattr(value, "compile"):
            candidate = value
    if candidate is None:
        raise RuntimeError(
            "Could not infer a guppy entrypoint; provide InlineGuppyProgram(entrypoint=...)."
        )
    return candidate


def _regenerate_snapshot(name: str) -> None:
    if name in _REGENERATED_PROGRAMS:
        return
    spec = _INLINE_GUPPY_PROGRAMS.get(name)
    if spec is None:
        return

    namespace: dict[str, object] = {}
    exec(spec.source_text, namespace)  # noqa: S102

    if spec.entrypoint is None:
        entrypoint = _guess_entrypoint(namespace)
    else:
        if spec.entrypoint not in namespace:
            raise RuntimeError(
                f"Entrypoint '{spec.entrypoint}' for program '{name}' not found."
            )
        entrypoint = namespace[spec.entrypoint]

    if not callable(entrypoint) or not hasattr(entrypoint, "compile"):
        raise RuntimeError(
            f"Entrypoint '{spec.entrypoint or '<auto>'}' for '{name}' is not a guppy callable."
        )

    pkg = entrypoint.compile()
    hugr_bytes = pkg.to_bytes()

    if spec.artifact_kind == "hugr":
        path = _HUGR_DIR / f"{name}.hugr"
        path.write_bytes(hugr_bytes)
    else:
        from selene_hugr_qis_compiler import compile_to_llvm_ir

        path = _QIS_DIR / f"{name}-{_PLATFORM_SUFFIX}.ll"
        ir = compile_to_llvm_ir(hugr_bytes)
        path.write_text(ir)

    _REGENERATED_PROGRAMS.add(name)


def _ensure_snapshot(name: str, *, artifact_kind: ArtifactKind) -> Path:
    spec = _INLINE_GUPPY_PROGRAMS.get(name)
    if spec is not None and spec.artifact_kind != artifact_kind:
        raise RuntimeError(
            f"Program '{name}' is registered as {spec.artifact_kind}, not {artifact_kind}."
        )
    if _REGENERATE_GUPPY_SNAPSHOTS:
        _regenerate_snapshot(name)

    path = (
        _QIS_DIR / f"{name}-{_PLATFORM_SUFFIX}.ll"
        if artifact_kind == "qis"
        else _HUGR_DIR / f"{name}.hugr"
    )
    if not path.exists():
        pytest.skip(
            f"{artifact_kind.upper()} file not found: {path}\n"
            "Run 'just generate-qis' or use '--regenerate-guppy-snapshots' with pytest."
        )
    return path


def qis_file(name: str) -> Path:
    """Return the path to a pre-compiled QIS LLVM IR file."""
    return _ensure_snapshot(name, artifact_kind="qis")


def hugr_file(name: str) -> Path:
    """Return the path to a pre-compiled HUGR envelope file."""
    return _ensure_snapshot(name, artifact_kind="hugr")
