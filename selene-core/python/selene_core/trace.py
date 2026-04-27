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


class ErrorModelSource(BaseModel):
    kind: Literal["ErrorModel"] = "ErrorModel"
    index: int


class SimulatorSource(BaseModel):
    kind: Literal["Simulator"] = "Simulator"
    index: int
    duration_ns: int


class AbstractEvent(BaseModel):
    model_config = ConfigDict(
        use_enum_values=True,
        extra="ignore",
        ser_json_bytes="base64",
        val_json_bytes="base64",
    )


class GateEvent(AbstractEvent):
    kind: Literal["Gate"] = "Gate"
    qubits: list[int] = Field(default_factory=list)
    gate_name: str
    params: list[float | int | bool] = Field(default_factory=list)
    predicates: list[PredicateResult] = Field(default_factory=list)


class MeasurementEvent(AbstractEvent):
    kind: Literal["Measurement"] = "Measurement"
    qubit: int


class ResetEvent(AbstractEvent):
    kind: Literal["Reset"] = "Reset"
    qubit: int


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
    Union[UserProgramSource, RuntimeSource, ErrorModelSource, SimulatorSource],
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

    def get_error_model_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, ErrorModelSource))

    def get_simulator_trace(self) -> "Trace":
        return self.filter(lambda e: isinstance(e.source, SimulatorSource))

    def clear_simulator_perf_timing(self) -> "Trace":
        return Trace(
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
            ]
        )
