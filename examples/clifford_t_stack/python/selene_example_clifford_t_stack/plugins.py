from __future__ import annotations

import os
import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import ErrorModel, Runtime, Simulator


def _package_root() -> Path:
    return Path(__file__).resolve().parent


def _project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _source_root() -> Path | None:
    root = _project_root()
    if (root / "Cargo.toml").exists() and (root / "src").exists():
        return root
    return None


def _dist_root() -> Path:
    return _package_root() / "_dist"


def _platform_library_name(lib_name: str) -> str:
    match platform.system():
        case "Linux":
            return f"lib{lib_name}.so"
        case "Darwin":
            return f"lib{lib_name}.dylib"
        case "Windows":
            return f"{lib_name}.dll"
        case other:
            raise RuntimeError(f"Unsupported platform: {other}")


def _library_file(
    *,
    env_var: str,
    lib_name: str,
    source_subdir: Path | None = None,
    legacy_env_var: str | None = None,
) -> Path:
    override = os.environ.get(legacy_env_var) if legacy_env_var is not None else None
    override = os.environ.get(env_var, override)
    if override:
        return Path(override)

    filename = _platform_library_name(lib_name)
    source_root = _source_root()
    if source_root is not None:
        if source_subdir is not None:
            candidate = source_root / source_subdir / filename
            if candidate.exists():
                return candidate
        debug_library = source_root / "target" / "debug" / filename
        if debug_library.exists():
            return debug_library
        release_library = source_root / "target" / "release" / filename
        if release_library.exists():
            return release_library
    return _dist_root() / "lib" / filename


def library_file() -> Path:
    return rust_library_file()


def rust_library_file() -> Path:
    return _library_file(
        env_var="SELENE_EXAMPLE_CLIFFORD_T_RUST_LIB",
        lib_name="selene_example_clifford_t_stack",
        legacy_env_var="SELENE_EXAMPLE_CLIFFORD_T_LIB",
    )


def qrack_library_file() -> Path:
    return _library_file(
        env_var="SELENE_EXAMPLE_CLIFFORD_T_QRACK_LIB",
        lib_name="selene_example_clifford_t_qrack",
        source_subdir=Path("target/qrack-simulator-release"),
    )


@dataclass
class CliffordTRuntime(Runtime):
    @property
    def library_file(self) -> Path:
        return rust_library_file()

    def get_init_args(self) -> list[str]:
        return []


@dataclass
class CliffordTErrorModel(ErrorModel):
    flip_probability: float = 1.0

    @property
    def library_file(self) -> Path:
        return rust_library_file()

    def get_init_args(self) -> list[str]:
        return [str(self.flip_probability)]


@dataclass
class CliffordTQrackSimulator(Simulator):
    @property
    def library_file(self) -> Path:
        return qrack_library_file()

    def get_init_args(self) -> list[str]:
        return []
