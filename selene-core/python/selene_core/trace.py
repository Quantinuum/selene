"""Selene trace models with strict validation and legacy serialization.

Use :mod:`selene_api_models.trace` for versioned trace output.
"""

from typing import Any

from selene_api_models.trace import (
    SCHEMA_VERSION,
    AbstractEvent,
    CustomEvent,
    CustomPayload,
    ErrorModelSource,
    Event,
    EventRecord,
    GateEvent,
    KeyValuePairPayload,
    MeasurementEvent,
    OpaquePayload,
    PredicateResult,
    ResetEvent,
    RuntimeSource,
    SimulatorSource,
    Source,
    LegacyTrace as Trace,
    UserProgramSource,
    parse_trace as _parse_trace,
    parse_trace_json as _parse_trace_json,
)


def parse_trace(value: Any) -> Trace:
    """Read current or legacy trace data and retain legacy serialization."""
    return _parse_trace(value).as_legacy()


def parse_trace_json(data: str | bytes | bytearray) -> Trace:
    """Read current or legacy trace JSON and retain legacy serialization."""
    return _parse_trace_json(data).as_legacy()


__all__ = [
    "SCHEMA_VERSION",
    "AbstractEvent",
    "CustomEvent",
    "CustomPayload",
    "ErrorModelSource",
    "Event",
    "EventRecord",
    "GateEvent",
    "KeyValuePairPayload",
    "MeasurementEvent",
    "OpaquePayload",
    "PredicateResult",
    "ResetEvent",
    "RuntimeSource",
    "SimulatorSource",
    "Source",
    "Trace",
    "UserProgramSource",
    "parse_trace",
    "parse_trace_json",
]
