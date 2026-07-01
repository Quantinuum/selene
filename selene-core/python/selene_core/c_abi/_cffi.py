from __future__ import annotations

from functools import cache
from pathlib import Path

from cffi import FFI

from selene_core.headers import get_include_directory


def _source_root() -> Path:
    return Path(__file__).parents[3]


def _header_path(name: str) -> Path:
    source = _source_root() / "c/include/selene" / name
    if source.exists():
        return source
    bundled = get_include_directory() / "selene" / name
    if bundled.exists():
        return bundled
    raise FileNotFoundError(f"Could not find Selene C header {name!r}")


def _cdef_header(path: Path) -> str:
    lines = []
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
        if stripped.startswith('extern "C"'):
            continue
        if stripped.startswith("}  // extern"):
            continue
        lines.append(line)
    return "\n".join(lines)


@cache
def ffi(extra_headers: tuple[Path, ...] = ()) -> FFI:
    result = FFI()
    for builtin_header in (
        "gatewire.h",
        "operation.h",
        "plugin.h",
        "simulator.h",
        "runtime.h",
    ):
        result.cdef(_cdef_header(_header_path(builtin_header)), override=True)
    for extra_header in extra_headers:
        result.cdef(_cdef_header(extra_header), override=True)
    return result
