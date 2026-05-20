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

    def __post_init__(self):
        if self.shot_start_idx < 0:
            raise ValueError("shot_start_idx must be non-negative")
        if self.shot_end_idx <= self.shot_start_idx:
            raise ValueError("shot_end_idx must be greater than shot_start_idx")
        for key, value in self.records.items():
            if not isinstance(value, (int, float, bool, list)):
                raise ValueError(
                    f"Value for key '{key}' must be int, float, bool, or list"
                )
            if isinstance(value, list) and not all(
                isinstance(item, (int, float, bool)) for item in value
            ):
                raise ValueError(
                    f"All items in the list for key '{key}' must be int, float, or bool"
                )
            if isinstance(value, list) and len(value) == 0:
                raise ValueError(f"List for key '{key}' cannot be empty")
            if not isinstance(key, str):
                raise ValueError(f"Key '{key}' must be a string")
            if len(key) == 0:
                raise ValueError("Key cannot be an empty string")
            if len(key) > 255:
                raise ValueError(f"Key '{key}' cannot be longer than 255 characters")


@dataclass
class RunInputs:
    shot_inputs: list[ShotInput] = field(default_factory=list)


class ArgProvider(AbstractContextManager):
    run_inputs: RunInputs | None
    _file_path: str | None

    def __init__(self):
        self.run_inputs = None
        self._file_path = None

    def set_constant_args(self, **kwargs: valid_value) -> None:
        self.run_inputs = RunInputs(
            shot_inputs=[
                ShotInput(
                    shot_start_idx=0,
                    # We use a large number to represent "unreasonably large", as we don't
                    # know the number of shots in advance.
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
        if self._file_path is not None:
            raise RuntimeError(
                "ArgProvider context is already active; nested or re-entrant use is not supported"
            )
        if "SELENE_ARGREADER_INPUT_FILE" in os.environ:
            raise RuntimeError(
                "SELENE_ARGREADER_INPUT_FILE is already set; nested or concurrent ArgProvider contexts are not supported"
            )
        # write args to a new temporary file; clean up on failure so we don't leak it
        tmp = tempfile.NamedTemporaryFile("w", delete=False, suffix=".yaml")
        try:
            yaml.dump(self.run_inputs, tmp)
        except Exception:
            tmp.close()
            os.remove(tmp.name)
            raise
        tmp.close()
        self._file_path = tmp.name
        os.environ["SELENE_ARGREADER_INPUT_FILE"] = tmp.name
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        try:
            os.environ.pop("SELENE_ARGREADER_INPUT_FILE", None)
            if self._file_path is not None:
                os.remove(self._file_path)
        finally:
            self._file_path = None
