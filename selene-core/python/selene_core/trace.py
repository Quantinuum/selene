"""Compatibility re-export for the public Selene trace model.

New integrations should import :mod:`selene_api_models.trace` directly. This
module preserves the old import path during the transition, but uses the
current models. Construct traces with an explicit version:
``Trace(schema_version=SCHEMA_VERSION, events=[])``. The previous
``Trace(events=[])`` constructor call must be updated.

Use ``parse_trace`` or ``parse_trace_json`` to upgrade versionless legacy
serialized traces to the current model.
"""

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
    Trace,
    UserProgramSource,
    parse_trace,
    parse_trace_json,
)

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
