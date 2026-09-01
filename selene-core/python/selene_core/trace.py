"""Compatibility re-export for the public Selene trace model.

New integrations should import :mod:`selene_api_models.trace` directly. This module will
remain available during the transition so existing Selene integrations keep
working unchanged.
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
]
