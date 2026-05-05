import yaml
from dataclasses import dataclass, field
from contextlib import AbstractContextManager
from types import TracebackType
import os
import tempfile

valid_value = int | float | bool | list[int] | list[float] | list[bool]


@dataclass
class ShotInput:
    shot_start_idx: int
    shot_end_idx: int
    records: dict[str, valid_value] = field(default_factory=dict)


@dataclass
class RunInputs:
    shot_inputs: list[ShotInput] = field(default_factory=list)


class ArgProvider(AbstractContextManager):
    run_inputs: RunInputs | None

    def __init__(self):
        self.run_inputs = None

    def set_constant_args(self, **kwargs: valid_value) -> None:
        self.run_inputs = RunInputs(
            shot_inputs=[
                ShotInput(
                    shot_start_idx=0,
                    shot_end_idx=2**64 - 1,
                    records=kwargs,
                )
            ]
        )

    def set_variable_args(self, args: list[dict[str, valid_value]]) -> None:
        self.run_inputs = RunInputs()
        for i, arg in enumerate(args):
            self.run_inputs.shot_inputs.append(
                ShotInput(
                    shot_start_idx=i,
                    shot_end_idx=i + 1,
                    records=arg,
                )
            )

    def __enter__(self) -> "ArgProvider":
        # write args to a new temporary file
        with tempfile.NamedTemporaryFile("w", delete=False) as f:
            yaml.dump(self.run_inputs, f)
            os.environ["SELENE_ARGREADER_INPUT_FILE"] = f.name
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        del os.environ["SELENE_ARGREADER_INPUT_FILE"]
