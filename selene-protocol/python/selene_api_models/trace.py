"""Python models for version 0.1.0 of the Selene trace protocol."""

from typing import Annotated, Any, Callable, Literal, Union

from pydantic import BaseModel, ConfigDict, Field
from pydantic_core import core_schema

SCHEMA_VERSION = "0.1.0"
MAX_UINT64 = 2**64 - 1


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
        return json_schema


UInt64DecimalString = Annotated[int, _UInt64DecimalString]

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


class PredicateResult(BaseModel):
    predicate: str
    result: bool


class UserProgramSource(BaseModel):
    kind: Literal["UserProgram"] = "UserProgram"
    index: UInt64DecimalString


class RuntimeSource(BaseModel):
    kind: Literal["Runtime"] = "Runtime"
    start_time: UInt64DecimalString
    end_time: UInt64DecimalString


class ErrorModelSource(BaseModel):
    kind: Literal["ErrorModel"] = "ErrorModel"
    index: UInt64DecimalString


class SimulatorSource(BaseModel):
    kind: Literal["Simulator"] = "Simulator"
    index: UInt64DecimalString
    duration_ns: UInt64DecimalString


class AbstractEvent(BaseModel):
    model_config = ConfigDict(
        use_enum_values=True,
        extra="ignore",
        ser_json_bytes="base64",
        val_json_bytes="base64",
    )


class GateEvent(AbstractEvent):
    kind: Literal["Gate"] = "Gate"
    qubits: list[UInt64DecimalString] = Field(default_factory=list)
    gate_name: str
    params: list[float | int | bool] = Field(default_factory=list)
    predicates: list[PredicateResult] = Field(default_factory=list)


class MeasurementEvent(AbstractEvent):
    kind: Literal["Measurement"] = "Measurement"
    qubit: UInt64DecimalString


class ResetEvent(AbstractEvent):
    kind: Literal["Reset"] = "Reset"
    qubit: UInt64DecimalString


class OpaquePayload(AbstractEvent):
    kind: Literal["OpaquePayload"] = "OpaquePayload"
    tag: UInt64DecimalString
    data: bytes


class KeyValuePairPayload(AbstractEvent):
    kind: Literal["KeyValuePairPayload"] = "KeyValuePairPayload"
    data: dict[
        str, str | int | float | bool | list[int] | list[float] | list[str] | list[bool]
    ]


CustomPayload = Annotated[
    Union[OpaquePayload, KeyValuePairPayload],
    Field(discriminator="kind"),
]


class CustomEvent(AbstractEvent):
    kind: Literal["Custom"] = "Custom"
    payload: CustomPayload


Event = Annotated[
    Union[GateEvent, MeasurementEvent, ResetEvent, CustomEvent],
    Field(discriminator="kind"),
]
Source = Annotated[
    Union[UserProgramSource, RuntimeSource, ErrorModelSource, SimulatorSource],
    Field(discriminator="kind"),
]


class EventRecord(BaseModel):
    source: Source
    event: Event


class Trace(BaseModel):
    """A serializable Selene trace conforming to protocol version 0.1.0."""

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
