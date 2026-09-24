"""Python models and compatibility adapters for the Selene trace protocol."""

import copy
import json
import math
import re
from collections.abc import Callable, Mapping
from typing import Annotated, Any, Literal

from pydantic import (
    AfterValidator,
    BaseModel,
    ConfigDict,
    Field,
    TypeAdapter,
    WithJsonSchema,
    field_validator,
)
from pydantic_core import core_schema

SCHEMA_VERSION = "0.1.0"
MAX_UINT64 = 2**64 - 1
MAX_SAFE_INTEGER = 2**53 - 1


class _UInt64DecimalString:
    @classmethod
    def __get_pydantic_core_schema__(
        cls, _source_type: Any, _handler: Any
    ) -> core_schema.CoreSchema:
        decimal_string_schema = core_schema.no_info_after_validator_function(
            cls._parse_decimal_string,
            core_schema.str_schema(pattern=r"^(0|[1-9][0-9]*)$"),
        )
        return core_schema.json_or_python_schema(
            json_schema=decimal_string_schema,
            python_schema=core_schema.union_schema(
                [
                    core_schema.int_schema(strict=True, ge=0, le=MAX_UINT64),
                    decimal_string_schema,
                ]
            ),
            serialization=core_schema.plain_serializer_function_ser_schema(
                str,
                return_schema=core_schema.str_schema(),
                when_used="json",
            ),
        )

    @staticmethod
    def _parse_decimal_string(value: str) -> int:
        parsed = int(value)
        if parsed > MAX_UINT64:
            raise ValueError(
                "value must not exceed the maximum unsigned 64-bit integer"
            )
        return parsed

    @classmethod
    def __get_pydantic_json_schema__(cls, schema: Any, handler: Any) -> dict[str, Any]:
        json_schema = handler(schema)
        json_schema["format"] = "uint64"
        # Enforce the bound without relying on a custom JSON Schema format.
        # Each 20-digit alternative is a prefix below (or equal to) MAX_UINT64.
        # The final lookahead asserts absolute end, including after newlines.
        json_schema["pattern"] = (
            r"^(0|[1-9][0-9]{0,18}|1[0-7][0-9]{18}|18[0-3][0-9]{17}"
            r"|184[0-3][0-9]{16}|1844[0-5][0-9]{15}|18446[0-6][0-9]{14}"
            r"|184467[0-3][0-9]{13}|1844674[0-3][0-9]{12}"
            r"|184467440[0-6][0-9]{10}|1844674407[0-2][0-9]{9}"
            r"|18446744073[0-6][0-9]{8}|1844674407370[0-8][0-9]{6}"
            r"|18446744073709[0-4][0-9]{5}|184467440737095[0-4][0-9]{4}"
            r"|18446744073709550[0-9]{3}|18446744073709551[0-5][0-9]{2}"
            r"|1844674407370955160[0-9]|1844674407370955161[0-5])"
            r"(?![\s\S])"
        )
        return json_schema


UInt64DecimalString = Annotated[int, _UInt64DecimalString]
JsonSafeUInt = Annotated[int, Field(strict=True, ge=0, le=MAX_SAFE_INTEGER)]
JsonSafeInt = Annotated[
    int, Field(strict=True, ge=-MAX_SAFE_INTEGER, le=MAX_SAFE_INTEGER)
]


def _validate_float(value: float) -> float:
    if not math.isfinite(value) or (
        value.is_integer() and abs(value) > MAX_SAFE_INTEGER
    ):
        raise ValueError(
            "integer-valued numbers must be within JavaScript's safe range"
        )
    return value


JsonSafeFloat = Annotated[
    float,
    Field(strict=True),
    AfterValidator(_validate_float),
    WithJsonSchema(
        {
            "type": "number",
            "anyOf": [
                {"not": {"type": "integer"}},
                {"minimum": -MAX_SAFE_INTEGER, "maximum": MAX_SAFE_INTEGER},
            ],
        }
    ),
]
StrictBool = Annotated[bool, Field(strict=True)]

__all__ = [
    "MAX_SAFE_INTEGER",
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
    "TraceData",
    "TraceDocument",
    "Traces",
    "UserProgramSource",
    "parse_trace",
    "parse_trace_document",
    "parse_trace_document_json",
    "parse_trace_json",
]


class PredicateResult(BaseModel):
    predicate: str
    result: bool


class UserProgramSource(BaseModel):
    kind: Literal["UserProgram"] = "UserProgram"
    index: JsonSafeUInt


class RuntimeSource(BaseModel):
    kind: Literal["Runtime"] = "Runtime"
    start_time: JsonSafeUInt
    end_time: JsonSafeUInt


class ErrorModelSource(BaseModel):
    kind: Literal["ErrorModel"] = "ErrorModel"
    index: JsonSafeUInt


class SimulatorSource(BaseModel):
    kind: Literal["Simulator"] = "Simulator"
    index: JsonSafeUInt
    duration_ns: JsonSafeUInt


class AbstractEvent(BaseModel):
    model_config = ConfigDict(
        use_enum_values=True,
        extra="ignore",
        # Pydantic's "base64" bytes codec serializes using the URL-safe alphabet.
        ser_json_bytes="base64",
        val_json_bytes="base64",
    )


class GateEvent(AbstractEvent):
    kind: Literal["Gate"] = "Gate"
    qubits: list[JsonSafeUInt] = Field(default_factory=list)
    gate_name: str
    params: list[JsonSafeFloat | JsonSafeInt | StrictBool] = Field(default_factory=list)
    predicates: list[PredicateResult] = Field(default_factory=list)


class MeasurementEvent(AbstractEvent):
    kind: Literal["Measurement"] = "Measurement"
    qubit: JsonSafeUInt


class ResetEvent(AbstractEvent):
    kind: Literal["Reset"] = "Reset"
    qubit: JsonSafeUInt


class OpaquePayload(AbstractEvent):
    kind: Literal["OpaquePayload"] = "OpaquePayload"
    tag: UInt64DecimalString
    data: bytes

    @field_validator("data", mode="before")
    @classmethod
    def validate_base64url_alphabet(cls, value: Any) -> Any:
        # Native bytes are already decoded; strings must use the wire alphabet.
        if (
            isinstance(value, str)
            and re.fullmatch(r"[A-Za-z0-9_-]*={0,2}", value) is None
        ):
            raise ValueError("expected URL-safe Base64 data")
        return value


class KeyValuePairPayload(AbstractEvent):
    kind: Literal["KeyValuePairPayload"] = "KeyValuePairPayload"
    data: dict[
        str,
        str
        | JsonSafeInt
        | JsonSafeFloat
        | StrictBool
        | list[JsonSafeInt]
        | list[JsonSafeFloat]
        | list[str]
        | list[StrictBool],
    ]


CustomPayload = Annotated[
    OpaquePayload | KeyValuePairPayload,
    Field(discriminator="kind"),
]


class CustomEvent(AbstractEvent):
    kind: Literal["Custom"] = "Custom"
    payload: CustomPayload


Event = Annotated[
    GateEvent | MeasurementEvent | ResetEvent | CustomEvent,
    Field(discriminator="kind"),
]
Source = Annotated[
    UserProgramSource | RuntimeSource | ErrorModelSource | SimulatorSource,
    Field(discriminator="kind"),
]


class EventRecord(BaseModel):
    source: Source
    event: Event


class TraceData(BaseModel):
    """The unversioned contents of one emulation trace."""

    model_config = ConfigDict(extra="forbid")

    events: list[EventRecord] = Field(default_factory=list)


class Trace(BaseModel):
    """A serializable Selene trace conforming to protocol version 0.1.0."""

    model_config = ConfigDict(extra="forbid")

    schema_version: Literal["0.1.0"]
    events: list[EventRecord] = Field(default_factory=list)

    def add_runtime_event(self, event: Event, start_time_ns: int, end_time_ns: int):
        self.events.append(
            EventRecord(
                source=RuntimeSource(
                    start_time=start_time_ns,
                    end_time=end_time_ns,
                ),
                event=event,
            )
        )

    def add_user_program_event(self, event: Event, index: int):
        self.events.append(
            EventRecord(
                source=UserProgramSource(index=index),
                event=event,
            )
        )

    def add_error_model_event(self, event: Event, index: int):
        self.events.append(
            EventRecord(
                source=ErrorModelSource(index=index),
                event=event,
            )
        )

    def add_simulator_event(self, event: Event, index: int, duration_ns: int):
        self.events.append(
            EventRecord(
                source=SimulatorSource(index=index, duration_ns=duration_ns),
                event=event,
            )
        )

    def filter(self, predicate: Callable[[EventRecord], bool]) -> "Trace":
        return Trace(
            schema_version=SCHEMA_VERSION,
            events=list(filter(predicate, self.events)),
        )

    def strip_custom_events(self) -> "Trace":
        return self.filter(lambda r: not isinstance(r.event, CustomEvent))

    def strip_opaque_custom_events(self) -> "Trace":
        return self.filter(
            lambda r: (
                not (
                    isinstance(r.event, CustomEvent)
                    and isinstance(r.event.payload, OpaquePayload)
                )
            )
        )

    def get_runtime_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, RuntimeSource))

    def get_user_program_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, UserProgramSource))

    def get_error_model_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, ErrorModelSource))

    def get_simulator_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, SimulatorSource))

    def clear_simulator_perf_timing(self) -> "Trace":
        """Return a copy with simulator event durations set to zero."""
        return Trace(
            schema_version=SCHEMA_VERSION,
            events=[
                EventRecord(
                    source=(
                        SimulatorSource(index=record.source.index, duration_ns=0)
                        if isinstance(record.source, SimulatorSource)
                        else record.source.model_copy(deep=True)
                    ),
                    event=record.event.model_copy(deep=True),
                )
                for record in self.events
            ],
        )


class Traces(BaseModel):
    """A versioned collection of trace data."""

    model_config = ConfigDict(extra="forbid")

    schema_version: Literal["0.1.0"]
    traces: list[TraceData]


TraceDocument = Trace | Traces
_TRACE_DOCUMENT_ADAPTER = TypeAdapter(TraceDocument)


def _upgrade_legacy_trace(value: Mapping[str, Any]) -> dict[str, Any]:
    upgraded = copy.deepcopy(dict(value))
    if "traces" in upgraded:
        raise ValueError("versionless trace collections are not supported")
    upgraded["schema_version"] = SCHEMA_VERSION

    for record in upgraded.get("events", []):
        if not isinstance(record, dict):
            continue
        event = record.get("event")
        if not isinstance(event, dict) or event.get("kind") != "Custom":
            continue
        payload = event.get("payload")
        if not isinstance(payload, dict) or payload.get("kind") != "OpaquePayload":
            continue
        tag = payload.get("tag")
        if isinstance(tag, bool) or not isinstance(tag, int):
            raise ValueError("legacy OpaquePayload.tag must be a JSON integer")
        if not 0 <= tag <= MAX_UINT64:
            raise ValueError(
                "legacy OpaquePayload.tag must be an unsigned 64-bit integer"
            )
        payload["tag"] = str(tag)
        data = payload.get("data")
        if isinstance(data, str):
            payload["data"] = data.replace("+", "-").replace("/", "_")

    return {
        "schema_version": SCHEMA_VERSION,
        "events": upgraded.get("events", []),
    }


def parse_trace(value: Any) -> Trace:
    """Parse a JSON-compatible current or versionless legacy trace value.

    Versionless legacy documents are upgraded to the current in-memory model.
    """
    if not isinstance(value, Mapping):
        raise TypeError("trace document must be a JSON object")

    document = dict(value)
    if "schema_version" not in document:
        document = _upgrade_legacy_trace(document)

    return Trace.model_validate_json(json.dumps(document))


def parse_trace_json(data: str | bytes | bytearray) -> Trace:
    """Parse current or versionless legacy trace JSON without losing integers."""
    return parse_trace(json.loads(data))


def parse_trace_document(value: Any) -> TraceDocument:
    """Parse a current trace or trace collection, or a legacy singular trace."""
    if not isinstance(value, Mapping):
        raise TypeError("trace document must be a JSON object")

    document = dict(value)
    if "schema_version" not in document:
        return parse_trace(document)

    return _TRACE_DOCUMENT_ADAPTER.validate_json(json.dumps(document))


def parse_trace_document_json(data: str | bytes | bytearray) -> TraceDocument:
    """Parse current trace-document JSON or versionless legacy trace JSON."""
    return parse_trace_document(json.loads(data))
