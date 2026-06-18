"""
Utilities for working with gate metadata in the Selene trace.

Currently, this metadata includes:
- Source code location (optionally w/ multiple bt frames)

The runtime emits captured backtraces in an *unresolved* form, paired
with module-table entries that describe each loaded library. This
module:

* collects ``DEBUG_MODULE_TAG`` events into an in-memory module table,
* decodes ``DEBUG_INFO_TAG`` events (lists of ``{module_id, svma}`` frames),
* resolves each frame against the on-disk binary via the ``symbolic``
  package, and
* attaches the resulting :class:`SrcLocation` list as metadata on the
  following gate / measure / reset event.

Modules whose on-disk binary is missing or cannot be opened produce
``<unknown>`` placeholder frames, mirroring the Rust-side fallback in
``selene_core::metadata::ResolvedBacktrace::from_unresolved``.
"""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path

import msgpack

from .trace import (
    CustomEvent,
    EventRecord,
    SrcLocation,
    GateMetadata,
    GateEvent,
    MeasurementEvent,
    OpaquePayload,
    ResetEvent,
    Trace,
)

#: Tag value used to identify custom operations carrying backtrace metadata.
#: Must match ``selene_core::metadata::DEBUG_INFO_TAG`` in the Rust crate.
DEBUG_INFO_TAG: int = 0x6FCFC512E44136EB

#: Tag value used to identify custom operations carrying module-table
#: entries. Each such event carries a single :class:`ResolvedModule`-style
#: payload describing one loaded library; entries must precede any
#: ``DEBUG_INFO_TAG`` event that references their ``module_id``.
#: Must match ``selene_core::metadata::DEBUG_MODULE_TAG`` in the Rust crate.
DEBUG_MODULE_TAG: int = 0x6FCFC512E44136EC


def _is_debug_info_event(record: EventRecord) -> bool:
    """Return True if *record* is a DEBUG_INFO_TAG custom event."""
    return (
        isinstance(record.event, CustomEvent)
        and isinstance(record.event.payload, OpaquePayload)
        and record.event.payload.tag == DEBUG_INFO_TAG
    )


def _is_debug_module_event(record: EventRecord) -> bool:
    """Return True if *record* is a DEBUG_MODULE_TAG custom event."""
    return (
        isinstance(record.event, CustomEvent)
        and isinstance(record.event.payload, OpaquePayload)
        and record.event.payload.tag == DEBUG_MODULE_TAG
    )


#: Sentinel module id used by the Rust side when ``dladdr`` fails to
#: identify the module owning an IP. Must match
#: ``selene_core::metadata::UNKNOWN_MODULE_ID``.
_UNKNOWN_MODULE_ID: int = 0xFFFFFFFF


class _ModuleEntry:
    """Decoded ``DEBUG_MODULE_TAG`` payload."""

    __slots__ = ("module_id", "path", "bias")

    def __init__(self, module_id: int, path: str, bias: int) -> None:
        self.module_id = module_id
        self.path = path
        self.bias = bias


def _parse_debug_module(record: EventRecord) -> _ModuleEntry:
    assert isinstance(record.event, CustomEvent)
    assert isinstance(record.event.payload, OpaquePayload)
    raw = msgpack.unpackb(record.event.payload.data, raw=False)
    return _ModuleEntry(
        module_id=int(raw["module_id"]),
        path=str(raw["path"]),
        bias=int(raw["bias"]),
    )


def _candidate_debug_paths(path: str) -> list[str]:
    """Return paths that may contain DWARF debug info for *path*.

    On macOS, debug info is typically split out into a sibling ``.dSYM``
    bundle by ``dsymutil``. On Linux it may live in a sibling
    ``.debug`` file under ``/usr/lib/debug``. The original binary is
    always returned first so embedded DWARF (Linux PIE / ELF) is
    preferred when present.
    """
    candidates = [path]
    # macOS dSYM: <binary>.dSYM/Contents/Resources/DWARF/<basename>
    dsym_dwarf = (
        Path(path + ".dSYM") / "Contents" / "Resources" / "DWARF" / Path(path).name
    )
    if dsym_dwarf.is_file():
        candidates.append(str(dsym_dwarf))
    # Linux separate-debug-file convention: <binary>.debug next to the binary.
    debug_sibling = Path(path + ".debug")
    if debug_sibling.is_file():
        candidates.append(str(debug_sibling))
    return candidates


@lru_cache(maxsize=64)
def _load_symcache(path: str):
    """Load and cache a `symbolic.SymCache` for a given binary path.

    Returns ``None`` if no debug-info source can be opened for *path*.
    Prefers an object that advertises a ``debug`` feature (i.e. carries
    DWARF) over one that only has a symbol table.

    The cache is keyed on the path string and persists for the lifetime
    of the process; this is intentional because a given binary's
    on-disk contents do not change during a trace consumer's run.
    """
    try:
        # Imported lazily so that consumers that never resolve debug
        # info do not pay the import cost.
        from symbolic import Archive, SymCache
    except ImportError:
        return None

    best_obj = None
    best_has_debug = False
    for candidate in _candidate_debug_paths(path):
        try:
            archive = Archive.open(candidate)
        except Exception:
            continue
        for obj in archive.iter_objects():
            has_debug = "debug" in (obj.features or set())
            if best_obj is None or (has_debug and not best_has_debug):
                best_obj = obj
                best_has_debug = has_debug
            if best_has_debug:
                break
        if best_has_debug:
            break

    if best_obj is None:
        return None
    try:
        return SymCache.from_object(best_obj)
    except Exception:
        return None


_UNKNOWN_FRAME = SrcLocation(
    function_name="<unknown>", file_name=None, line=None, column=None
)


def _resolve_frame(module: "_ModuleEntry | None", svma: int) -> list[SrcLocation]:
    """Resolve a single captured ``(module_id, svma)`` pair to one or
    more :class:`SrcLocation` entries (one per inlined frame).

    Falls back to a single ``<unknown>`` placeholder when the module is
    unknown, missing, or lacks the relevant debug info.
    """
    if module is None:
        return [_UNKNOWN_FRAME]
    cache = _load_symcache(module.path)
    if cache is None:
        return [_UNKNOWN_FRAME]
    try:
        locs = cache.lookup(svma)
    except Exception:
        return [_UNKNOWN_FRAME]
    if not locs:
        return [_UNKNOWN_FRAME]
    out: list[SrcLocation] = []
    for loc in locs:
        out.append(
            SrcLocation(
                function_name=loc.symbol or "<unknown>",
                file_name=loc.full_path or None,
                line=loc.line if loc.line and loc.line > 0 else None,
                column=None,
            )
        )
    return out


def _parse_debug_info(
    record: EventRecord, modules: dict[int, _ModuleEntry]
) -> GateMetadata:
    """Deserialise a DEBUG_INFO_TAG custom event payload into a
    :class:`GateMetadata`, resolving frames against *modules*."""
    assert isinstance(record.event, CustomEvent)
    assert isinstance(record.event.payload, OpaquePayload)
    raw = msgpack.unpackb(record.event.payload.data, raw=False)
    frames: list[SrcLocation] = []
    for frame in raw["frames"]:
        module_id = int(frame["module_id"])
        svma = int(frame["svma"])
        module = modules.get(module_id) if module_id != _UNKNOWN_MODULE_ID else None
        frames.extend(_resolve_frame(module, svma))
    return GateMetadata(frames=frames)


def resolve_debug_info(trace: Trace) -> Trace:
    """Transform a :class:`~selene_core.trace.Trace` by moving debug info into gate metadata.

    ``DEBUG_MODULE_TAG`` custom events are accumulated into an in-memory
    module table; ``DEBUG_INFO_TAG`` events are then decoded and
    resolved against that table, attached as the ``metadata`` field on
    the immediately following gate / measure / reset event. Both kinds
    of debug-info custom events are removed from the output trace.

    :raises ValueError: if two consecutive ``DEBUG_INFO_TAG`` events are
        encountered (which would indicate a malformed stream).
    """
    output_events: list[EventRecord] = []
    pending_metadata: GateMetadata | None = None
    modules: dict[int, _ModuleEntry] = {}

    for record in trace.events:
        if _is_debug_module_event(record):
            entry = _parse_debug_module(record)
            modules[entry.module_id] = entry
            continue

        if _is_debug_info_event(record):
            if pending_metadata is not None:
                raise ValueError(
                    "Two adjacent debug info events encountered in trace; "
                    "expected a gate/measure/reset between debug info entries."
                )
            pending_metadata = _parse_debug_info(record, modules)
            continue

        if pending_metadata is not None:
            if isinstance(record.event, (GateEvent, MeasurementEvent, ResetEvent)):
                new_event = record.event.model_copy(
                    update={"metadata": pending_metadata}
                )
                output_events.append(EventRecord(source=record.source, event=new_event))
            else:
                # Debug info preceded a non-gate event; discard metadata and keep the event.
                output_events.append(record)
            pending_metadata = None
        else:
            output_events.append(record)

    return Trace(events=output_events)
