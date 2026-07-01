from __future__ import annotations

import os
import tempfile
from pathlib import Path
from typing import ClassVar

import yaml
from selene_core import (
    ErrorModel,
    Gate,
    Gateset,
    Runtime,
    SeleneComponent,
    Simulator,
)
from selene_core.c_abi import SeleneCTypes, ffi

from selene_sim import dist_dir as selene_dist
from selene_sim.backends import IdealErrorModel, SimpleRuntime
from selene_sim.event_hooks import EventHook, NoEventHook
from selene_sim.instance import ShotSpec
from selene_sim.result_handling import DataStream, ResultStream
from selene_sim.result_handling.result_stream import StreamEntry

from ._library import selene_library_path


PathLike = str | os.PathLike | bytes | bytearray

DEFAULT_SHOT_SPEC = ShotSpec(count=1000, offset=0, increment=1)

_SELENE_HEADER = Path(__file__).parents[2] / "_dist/include/selene/selene.h"
_SOURCE_SELENE_HEADER = (
    Path(__file__).parents[4] / "selene-sim/c/include/selene/selene.h"
)
if _SOURCE_SELENE_HEADER.exists():
    _SELENE_HEADER = _SOURCE_SELENE_HEADER
_FFI = ffi((_SELENE_HEADER,))


def _component_config(component: SeleneComponent, default_seed: int | None) -> dict:
    full_name = ".".join(
        (component.__class__.__module__, component.__class__.__qualname__)
    )
    config = {
        "name": full_name,
        "file": component.library_file,
        "args": component.get_init_args(),
    }
    if component.random_seed is not None:
        config["seed"] = component.random_seed
    elif default_seed is not None:
        config["seed"] = default_seed
    return config


def _event_hook_flags(hook: EventHook) -> dict[str, bool]:
    return {flag: True for flag in hook.get_selene_flags()}


def get_selene_lib() -> Path:
    result = Path(selene_dist)
    return result


class SeleneError(RuntimeError):
    def __init__(self, error_code: int):
        super().__init__(f"Detected failure with error code {error_code}")
        self.error_code = error_code


def _encode_text(value: PathLike) -> bytes:
    if isinstance(value, (bytes, bytearray)):
        return bytes(value)
    if isinstance(value, os.PathLike):
        value = os.fspath(value)
    return str(value).encode("utf-8")


def _uint8_buffer(
    payload: bytes | bytearray | memoryview | None,
) -> tuple[object, int]:
    if payload is None:
        return _FFI.NULL, 0
    raw = bytes(payload)
    if not raw:
        return _FFI.NULL, 0
    return _FFI.new("uint8_t[]", raw), len(raw)


def _unwrap(result):
    if result.error_code != 0:
        raise SeleneError(int(result.error_code))
    return result


def _unwrap_void(result) -> None:
    _unwrap(result)


def _unwrap_value(result) -> int | float | bool:
    return _unwrap(result).value


def _unwrap_future(result) -> int:
    return int(_unwrap(result).reference)


class SeleneSimLib:
    def __init__(self) -> None:
        self.ffi = _FFI
        self.types = SeleneCTypes(self.ffi)
        self.lib = self.ffi.dlopen(str(selene_library_path()), self.ffi.RTLD_GLOBAL)

    def load_config(self, config_path: PathLike):
        instance = self.ffi.new(self.types.instance_ptr_ptr)
        config_bytes = _encode_text(config_path)
        config = self.ffi.new("char[]", config_bytes)
        _unwrap_void(self.lib.selene_load_config(instance, config))
        return instance[0]

    def fetch_output(self, instance, chunk_size: int) -> bytes:
        chunk = self.ffi.new(self.types.uint8_array, chunk_size)
        bytes_read = int(
            _unwrap_value(self.lib.selene_fetch_output(instance, chunk, chunk_size))
        )
        if bytes_read == 0:
            raise BlockingIOError
        return bytes(self.ffi.buffer(chunk, bytes_read))

    def write_metadata(self, instance) -> None:
        _unwrap_void(self.lib.selene_write_metadata(instance))

    def exit(self, instance) -> None:
        _unwrap_void(self.lib.selene_exit(instance))

    def _string_ptr(self, value: str):
        encoded = value.encode("utf-8")
        data = self.ffi.new("char[]", encoded)
        result = self.ffi.new(self.types.string_ptr)
        result.data = data
        result.length = len(encoded)
        result.owned = False
        return result, data

    def uint8_buffer(self, payload: bytes | bytearray | memoryview | None):
        return _uint8_buffer(payload)

    def uint64_array(self, values: list[int]):
        return self.ffi.new(self.types.uint64_array, values)

    def dump_state(self, instance, tag: str, qubit_ids) -> None:
        tag_ptr, _tag_data = self._string_ptr(tag)
        _unwrap_void(
            self.lib.selene_dump_state(
                instance,
                tag_ptr[0],
                qubit_ids,
                len(qubit_ids),
            )
        )

    def register_gateset(self, instance, payload: bytes) -> bytes:
        input_data = self.ffi.new(self.types.uint8_array, payload)
        written = self.ffi.new(self.types.size_ptr)
        _unwrap_void(
            self.lib.selene_register_gateset(
                instance,
                input_data,
                len(payload),
                self.ffi.NULL,
                0,
                written,
            )
        )
        output_data = self.ffi.new(self.types.uint8_array, written[0])
        _unwrap_void(
            self.lib.selene_register_gateset(
                instance,
                input_data,
                len(payload),
                output_data,
                written[0],
                written,
            )
        )
        return bytes(self.ffi.buffer(output_data, written[0]))


class InternalOutputStream(DataStream):
    def __init__(self, full_stack: "InteractiveFullStack"):
        self._buffer = bytearray()
        self._full_stack = full_stack

    def read_chunk(self, length: int) -> bytes:
        assert self._full_stack._lib is not None, (
            "Selene library must be loaded to read from output stream"
        )
        if len(self._buffer) < length:
            # make a new buffer to read into
            chunk_size = max(length - len(self._buffer), 4096)
            self._buffer.extend(
                self._full_stack._lib.fetch_output(
                    self._full_stack._instance, chunk_size
                )
            )
        result, self._buffer = self._buffer[:length], self._buffer[length:]
        return bytes(result)

    def next_shot(self):
        pass


class Qubit:
    def __init__(self, qubit_id: int):
        self.id = qubit_id


class InteractiveFullStack:
    _preloaded_lib: ClassVar[SeleneSimLib | None] = None

    @classmethod
    def load_library(cls) -> SeleneSimLib:
        if cls._preloaded_lib is None:
            cls._preloaded_lib = SeleneSimLib()
        return cls._preloaded_lib

    def __init__(
        self,
        *,
        n_qubits: int,
        simulator: Simulator,
        runtime: Runtime | None = None,
        error_model: ErrorModel | None = None,
        event_hook: EventHook | None = None,
        random_seed: int | None = None,
        gateset: Gateset | None = None,
    ):
        self._lib = self.load_library()
        self._event_hook = event_hook or NoEventHook()
        self._shot_spec = DEFAULT_SHOT_SPEC
        self._shot_index = self._shot_spec.offset
        self._pending_state_dumps: list[StreamEntry] = []
        self._pending_entries: list[StreamEntry] = []

        self._tempdir = tempfile.TemporaryDirectory(prefix="selene-sim-interactive-")
        self._run_dir = Path(self._tempdir.name)
        self._artifact_dir = self._run_dir / "artifacts"
        self._artifact_dir.mkdir(parents=True, exist_ok=True)
        self._config_path = self._run_dir / "configuration.yaml"
        self._auto_poll_metadata = True

        self.simulator = simulator
        self.runtime = runtime or SimpleRuntime()
        self.error_model = error_model or IdealErrorModel()
        self.gateset = gateset
        self.emitted_gateset: Gateset | None = None

        try:
            config_data = self._build_configuration(
                n_qubits=n_qubits,
                random_seed=random_seed,
            )
            config_data["shots"] = {
                "count": self._shot_spec.count,
                "offset": self._shot_spec.offset,
                "increment": self._shot_spec.increment,
            }
            config_data["artifact_dir"] = str(self._artifact_dir)
            config_data["output_stream"] = "internal"
            existing_flags = config_data.get("event_hooks", {})
            if existing_flags and not isinstance(existing_flags, dict):
                raise TypeError("event_hooks configuration must be a mapping")
            config_data["event_hooks"] = {
                **(existing_flags or {}),
                **_event_hook_flags(self._event_hook),
            }

            self._configuration = config_data
            self._config_path.write_text(yaml.safe_dump(config_data))

            self._instance = self._lib.load_config(self._config_path)
            if self.gateset is not None:
                self.emitted_gateset = self.register_gateset(self.gateset)
        except Exception:
            self._teardown_environment()
            raise
        self._data_stream = InternalOutputStream(self)
        self._result_stream = ResultStream(self._data_stream)

        self._on_shot_start(self._shot_index)

    def _build_configuration(
        self,
        n_qubits: int,
        random_seed: int | None,
    ) -> dict:
        return {
            "n_qubits": int(n_qubits),
            "simulator": _component_config(self.simulator, random_seed),
            "error_model": _component_config(self.error_model, random_seed),
            "runtime": _component_config(self.runtime, random_seed),
        }

    def _teardown_environment(self):
        if hasattr(self, "_tempdir") and self._tempdir is not None:
            self._tempdir.cleanup()
            self._tempdir = None

    def next_shot(self):
        self._on_shot_end()
        self._shot_index += self._shot_spec.increment
        self._data_stream.next_shot()
        self._on_shot_start(self._shot_index)
        self._poll_results()

    def drain_results(self) -> list[StreamEntry]:
        self._poll_results()
        entries = list(self._pending_entries)
        self._pending_entries.clear()
        return entries

    def drain_state_dumps(self) -> list[StreamEntry]:
        self._poll_results()
        entries = list(self._pending_state_dumps)
        self._pending_state_dumps.clear()
        return entries

    def _poll_results(self):
        while True:
            entry = self._result_stream.try_next_entry()
            if entry is None:
                break
            self._handle_entry(entry)

    def _handle_entry(self, entry: StreamEntry):
        if entry.tag == "SELENE:SHOT_START":
            self._event_hook.on_new_shot()
        elif entry.tag.startswith("METRICS:") or entry.tag in {
            "INSTRUCTIONLOG",
            "MEASUREMENTLOG",
        }:
            self._event_hook.try_invoke(entry.tag, entry.values)
        elif entry.tag.startswith("USER:STATE:"):
            self._pending_state_dumps.append(entry)
        elif entry.tag.startswith("USER:"):
            self._pending_entries.append(entry)

    @property
    def configuration_path(self) -> Path:
        return self._config_path

    @property
    def artifact_dir(self) -> Path:
        return self._artifact_dir

    @property
    def shot_spec(self) -> ShotSpec:
        return self._shot_spec

    @property
    def event_hook(self) -> EventHook:
        return self._event_hook

    def __del__(self):
        self._on_shot_end()
        # Here we invoke selene_exit directly, as the call helpers request metadata to be pushed,
        # which isn't valid after the instance has been destroyed
        self._lib.exit(self._instance)

    def _invoke(self, func_name: str, *args):
        result = getattr(self._lib.lib, func_name)(self._instance, *args)
        if self._auto_poll_metadata:
            assert self._lib is not None
            self._lib.write_metadata(self._instance)
        self._poll_results()
        return result

    def _call_void(self, func_name: str, *args):
        _unwrap_void(self._invoke(func_name, *args))

    def _call_u64(self, func_name: str, *args) -> int:
        return int(_unwrap_value(self._invoke(func_name, *args)))

    def _call_bool(self, func_name: str, *args) -> bool:
        return bool(_unwrap_value(self._invoke(func_name, *args)))

    def _call_future(self, func_name: str, *args) -> int:
        return _unwrap_future(self._invoke(func_name, *args))

    def _call_f64(self, func_name: str, *args) -> float:
        return float(_unwrap_value(self._invoke(func_name, *args)))

    def _call_u32(self, func_name: str, *args) -> int:
        return int(_unwrap_value(self._invoke(func_name, *args)))

    def _on_shot_start(self, shot_index: int) -> None:
        self._call_void("selene_on_shot_start", shot_index)

    def _on_shot_end(self) -> None:
        self._call_void("selene_on_shot_end")

    def custom_runtime_call(
        self, tag: int, payload: bytes | bytearray | memoryview | None = None
    ) -> int:
        buffer, length = _uint8_buffer(payload)
        return self._call_u64("selene_custom_runtime_call", tag, buffer, length)

    def future_read_bool(self, reference: int) -> bool:
        return self._call_bool("selene_future_read_bool", reference)

    def future_read_u64(self, reference: int) -> int:
        return self._call_u64("selene_future_read_u64", reference)

    def get_current_shot(self) -> int:
        return self._call_u64("selene_get_current_shot")

    def qalloc(self) -> Qubit:
        return Qubit(self._call_u64("selene_qalloc"))

    def qfree(self, qubit: Qubit) -> None:
        self._call_void("selene_qfree", qubit.id)

    def lazy_measure(self, qubit: Qubit) -> int:
        return self._call_future("selene_qubit_lazy_measure", qubit.id)

    def lazy_measure_leaked(self, qubit: Qubit) -> int:
        return self._call_future("selene_qubit_lazy_measure_leaked", qubit.id)

    def measure(self, qubit: Qubit) -> bool:
        return self._call_bool("selene_qubit_measure", qubit.id)

    def reset(self, qubit: Qubit) -> None:
        self._call_void("selene_qubit_reset", qubit.id)

    def random_advance(self, delta: int) -> None:
        self._call_void("selene_random_advance", delta)

    def random_f64(self) -> float:
        return self._call_f64("selene_random_f64")

    def random_seed(self, seed: int) -> None:
        self._call_void("selene_random_seed", seed)

    def random_u32(self) -> int:
        return self._call_u32("selene_random_u32")

    def random_u32_bounded(self, bound: int) -> int:
        return self._call_u32("selene_random_u32_bounded", bound)

    def refcount_decrement(self, reference: int) -> None:
        self._call_void("selene_refcount_decrement", reference)

    def refcount_increment(self, reference: int) -> None:
        self._call_void("selene_refcount_increment", reference)

    def register_gateset(self, gateset: Gateset) -> Gateset:
        payload = gateset.serialize()
        return Gateset.deserialize(self._lib.register_gateset(self._instance, payload))

    def gate(self, gate: Gate) -> None:
        payload = gate.serialize()
        buffer, length = self._lib.uint8_buffer(payload)
        _unwrap_void(self._lib.lib.selene_gate(self._instance, buffer, length))
        if self._auto_poll_metadata:
            self._lib.write_metadata(self._instance)
        self._poll_results()

    def get_state(self, qubits: list[Qubit]):
        if not hasattr(self.simulator, "extract_states"):
            raise AttributeError(
                "Simulator must implement extract_states to use get_state"
            )
        qubit_ids = self._lib.uint64_array([q.id for q in qubits])
        random_tag = "USER:STATE:" + os.urandom(8).hex()
        self._lib.dump_state(self._instance, random_tag, qubit_ids)
        if self._auto_poll_metadata:
            self._lib.write_metadata(self._instance)
        self._poll_results()
        tagged_results = [
            (v.tag.replace("USER:", ""), v.values[0]) for v in self.drain_state_dumps()
        ]
        gen = self.simulator.extract_states(tagged_results, True)
        return next(gen)[1]
