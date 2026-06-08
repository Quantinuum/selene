"""
Definition of the Selene trace schema.

This file must not depend on the rest of selene-core, so that it can be imported
standalone to generate the JSON schema (see hatch_build.py).
"""

from typing import Annotated, Literal, Union, Callable
from pydantic import BaseModel, ConfigDict, Field


class PredicateResult(BaseModel):
    predicate: str
    result: bool


class UserProgramSource(BaseModel):
    kind: Literal["UserProgram"] = "UserProgram"
    index: int


class RuntimeSource(BaseModel):
    kind: Literal["Runtime"] = "Runtime"
    start_time: int
    end_time: int


# in future we hope to add ErrorModelSource, so we can keep track of noise.
# this will require a breaking change, as the error model doesn't presently
# command the simulator via selene's internals (where logging can be done),
# but instead controls a simulator directly.


class AbstractEvent(BaseModel):
    model_config = ConfigDict(
        use_enum_values=True,
        extra="ignore",
        ser_json_bytes="base64",
        val_json_bytes="base64",
    )


class SrcLocation(BaseModel):
    function_name: str
    file_name: str
    line: int | None
    column: int | None


class GateMetadata(BaseModel):
    frames: list[SrcLocation]


class GateEvent(AbstractEvent):
    kind: Literal["Gate"] = "Gate"
    qubits: list[int] = Field(default_factory=list)
    gate_name: str
    params: list[float | int | bool] = Field(default_factory=list)
    predicates: list[PredicateResult] = Field(default_factory=list)
    metadata: GateMetadata | None = None


class MeasurementEvent(AbstractEvent):
    kind: Literal["Measurement"] = "Measurement"
    qubit: int
    metadata: GateMetadata | None = None


class ResetEvent(AbstractEvent):
    kind: Literal["Reset"] = "Reset"
    qubit: int
    metadata: GateMetadata | None = None


class OpaquePayload(AbstractEvent):
    kind: Literal["OpaquePayload"] = "OpaquePayload"
    tag: int
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
    Union[UserProgramSource, RuntimeSource],
    Field(discriminator="kind"),
]


class EventRecord(BaseModel):
    source: Source
    event: Event


class Trace(BaseModel):
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

    def filter(self, predicate: Callable[[EventRecord], bool]) -> "Trace":
        return Trace(events=list(filter(predicate, self.events)))

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
