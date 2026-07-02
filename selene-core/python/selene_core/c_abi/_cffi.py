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


_EXTRA_DECLARATIONS = {
    "runtime.h": """
        extern const SeleneRuntimePluginDescriptorV1 selene_runtime_plugin_descriptor_v1;
        const SeleneRuntimePluginDescriptorV1 *selene_runtime_get_plugin_descriptor_v1(void);
    """,
    "simulator.h": """
        extern const SeleneSimulatorPluginDescriptorV1 selene_simulator_plugin_descriptor_v1;
        const SeleneSimulatorPluginDescriptorV1 *selene_simulator_get_plugin_descriptor_v1(void);
    """,
}


@cache
def ffi(
    extra_headers: tuple[Path, ...] = (),
    builtin_headers: tuple[str, ...] = ("gatewire.h",),
) -> FFI:
    result = FFI()
    for builtin_header in builtin_headers:
        result.cdef(_cdef_header(_header_path(builtin_header)), override=True)
        if extra_declarations := _EXTRA_DECLARATIONS.get(builtin_header):
            result.cdef(extra_declarations, override=True)
    for extra_header in extra_headers:
        result.cdef(_cdef_header(extra_header), override=True)
    return result
