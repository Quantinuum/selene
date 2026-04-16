from typing import Annotated, Literal, Union
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


class GateEvent(AbstractEvent):
    kind: Literal["Gate"] = "Gate"
    qubits: list[int] = Field(default_factory=list)
    gate_name: str
    params: list[float] = Field(default_factory=list)
    predicates: list[PredicateResult] = Field(default_factory=list)


class MeasurementEvent(AbstractEvent):
    kind: Literal["Measurement"] = "Measurement"
    qubit: int


class ResetEvent(AbstractEvent):
    kind: Literal["Reset"] = "Reset"
    qubit: int


class CustomEvent(AbstractEvent):
    kind: Literal["Custom"] = "Custom"
    tag: int
    data: bytes


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

    def add_runtime_event(
        self, event: AbstractEvent, start_time_ns: int, end_time_ns: int
    ):
        self.events.append(
            EventRecord(
                source=RuntimeSource(
                    start_time=start_time_ns,
                    end_time=end_time_ns,
                ),
                event=event,
            )
        )

    def add_user_program_event(self, event: AbstractEvent, index: int):
        self.events.append(
            EventRecord(
                source=UserProgramSource(index=index),
                event=event,
            )
        )
