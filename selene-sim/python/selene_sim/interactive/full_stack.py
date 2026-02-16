from __future__ import annotations

import ctypes
import os
import platform
import sys
import tempfile
from pathlib import Path

import yaml
from selene_core import ErrorModel, Runtime, SeleneComponent, Simulator

from selene_sim import dist_dir as selene_dist
from selene_sim.backends import IdealErrorModel, SimpleRuntime
from selene_sim.event_hooks import EventHook, NoEventHook
from selene_sim.instance import ShotSpec
from selene_sim.result_handling import DataStream, ResultStream, TCPStream
from selene_sim.result_handling.result_stream import StreamEntry
from selene_sim.timeout import Timeout


PathLike = str | os.PathLike | bytes | bytearray

DEFAULT_SHOT_SPEC = ShotSpec(count=1000, offset=0, increment=1)


class _NonBlockingStreamAdapter(DataStream):
    def __init__(self, tcp_stream: TCPStream):
        self._tcp_stream = tcp_stream

    def read_chunk(self, length: int) -> bytes:
        if self._tcp_stream.done:
            return b""
        client = self._ensure_client()
        if client is None:
            raise BlockingIOError
        if not client.has_bytes(length):
            self._pump()
            client = self._ensure_client()
            if client is None or not client.has_bytes(length):
                raise BlockingIOError
        return client.take(length)

    def next_shot(self):
        self._tcp_stream.next_shot()

    def _ensure_client(self):
        if self._tcp_stream.current_shot_client is None:
            self._tcp_stream._update_current_shot_client()
            if self._tcp_stream.current_shot_client is None:
                self._pump()
                self._tcp_stream._update_current_shot_client()
        return self._tcp_stream.current_shot_client

    def _pump(self):
        self._tcp_stream._sync(timeout=0.0)


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


class SeleneInstance(ctypes.Structure):
    pass


SeleneInstancePtr = ctypes.POINTER(SeleneInstance)
SeleneInstancePtrPtr = ctypes.POINTER(SeleneInstancePtr)


class selene_void_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32)]

    def unwrap(self) -> None:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return None


class selene_u64_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_uint64)]

    def unwrap(self) -> int:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return int(self.value)


class selene_u32_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_uint32)]

    def unwrap(self) -> int:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return int(self.value)


class selene_f64_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_double)]

    def unwrap(self) -> float:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return float(self.value)


class selene_bool_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_bool)]

    def unwrap(self) -> bool:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return bool(self.value)


class selene_future_result_t(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("reference", ctypes.c_uint64)]

    def unwrap(self) -> int:
        if self.error_code != 0:
            raise SeleneError(self.error_code)
        return int(self.reference)


class selene_string_t(ctypes.Structure):
    _fields_ = [
        ("data", ctypes.c_char_p),
        ("length", ctypes.c_uint64),
        ("owned", ctypes.c_bool),
    ]

    @staticmethod
    def from_str(s: str) -> selene_string_t:
        encoded = s.encode("utf-8")
        return selene_string_t(
            ctypes.c_char_p(encoded), ctypes.c_uint64(len(encoded)), True
        )


BytePtr = ctypes.POINTER(ctypes.c_uint8)
UInt64Ptr = ctypes.POINTER(ctypes.c_uint64)
BoolPtr = ctypes.POINTER(ctypes.c_bool)
Int64Ptr = ctypes.POINTER(ctypes.c_int64)
DoublePtr = ctypes.POINTER(ctypes.c_double)


def _encode_text(value: PathLike) -> bytes:
    if isinstance(value, (bytes, bytearray)):
        return bytes(value)
    if isinstance(value, os.PathLike):
        value = os.fspath(value)
    return str(value).encode("utf-8")


def _uint8_buffer(
    payload: bytes | bytearray | memoryview | None,
) -> tuple[ctypes.Array | None, int]:
    if payload is None:
        return None, 0
    raw = bytes(payload)
    if not raw:
        return None, 0
    array_type = ctypes.c_uint8 * len(raw)
    return array_type(*raw), len(raw)


class SeleneSimLib(ctypes.CDLL):
    def __init__(self) -> None:
        lib_path = selene_dist / "lib"
        match platform.system():
            case "Darwin":
                lib_path /= "libselene.dylib"
            case "Linux":
                lib_path /= "libselene.so"
            case "Windows":
                lib_path /= "selene.lib"
            case _:
                raise RuntimeError(f"Unsupported OS {sys.platform}")
        assert lib_path.is_file(), f"Selene library not found at {lib_path}"
        super().__init__(str(lib_path))
        self._configure_signatures()

    def _configure_signatures(self):
        self.selene_custom_runtime_call.argtypes = [
            SeleneInstancePtr,
            ctypes.c_uint64,
            BytePtr,
            ctypes.c_uint64,
        ]
        self.selene_custom_runtime_call.restype = selene_u64_result_t
        self.selene_dump_state.argtypes = [
            SeleneInstancePtr,
            selene_string_t,
            UInt64Ptr,
            ctypes.c_uint64,
        ]
        self.selene_dump_state.restype = selene_void_result_t
        self.selene_exit.argtypes = [SeleneInstancePtr]
        self.selene_exit.restype = selene_void_result_t
        self.selene_future_read_bool.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_future_read_bool.restype = selene_bool_result_t
        self.selene_future_read_u64.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_future_read_u64.restype = selene_u64_result_t
        self.selene_get_current_shot.argtypes = [SeleneInstancePtr]
        self.selene_get_current_shot.restype = selene_u64_result_t
        self.selene_get_tc.argtypes = [SeleneInstancePtr]
        self.selene_get_tc.restype = selene_u64_result_t
        self.selene_load_config.argtypes = [SeleneInstancePtrPtr, ctypes.c_char_p]
        self.selene_load_config.restype = selene_void_result_t
        self.selene_on_shot_end.argtypes = [SeleneInstancePtr]
        self.selene_on_shot_end.restype = selene_void_result_t
        self.selene_on_shot_start.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_on_shot_start.restype = selene_void_result_t
        self.selene_qalloc.argtypes = [SeleneInstancePtr]
        self.selene_qalloc.restype = selene_u64_result_t
        self.selene_qfree.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_qfree.restype = selene_void_result_t
        self.selene_qubit_lazy_measure.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_qubit_lazy_measure.restype = selene_future_result_t
        self.selene_qubit_lazy_measure_leaked.argtypes = [
            SeleneInstancePtr,
            ctypes.c_uint64,
        ]
        self.selene_qubit_lazy_measure_leaked.restype = selene_future_result_t
        self.selene_qubit_measure.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_qubit_measure.restype = selene_bool_result_t
        self.selene_qubit_reset.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_qubit_reset.restype = selene_void_result_t
        self.selene_random_advance.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_random_advance.restype = selene_void_result_t
        self.selene_random_f64.argtypes = [SeleneInstancePtr]
        self.selene_random_f64.restype = selene_f64_result_t
        self.selene_random_seed.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_random_seed.restype = selene_void_result_t
        self.selene_random_u32.argtypes = [SeleneInstancePtr]
        self.selene_random_u32.restype = selene_u32_result_t
        self.selene_random_u32_bounded.argtypes = [SeleneInstancePtr, ctypes.c_uint32]
        self.selene_random_u32_bounded.restype = selene_u32_result_t
        self.selene_refcount_decrement.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_refcount_decrement.restype = selene_void_result_t
        self.selene_refcount_increment.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_refcount_increment.restype = selene_void_result_t
        self.selene_rxy.argtypes = [
            SeleneInstancePtr,
            ctypes.c_uint64,
            ctypes.c_double,
            ctypes.c_double,
        ]
        self.selene_rxy.restype = selene_void_result_t
        self.selene_rz.argtypes = [SeleneInstancePtr, ctypes.c_uint64, ctypes.c_double]
        self.selene_rz.restype = selene_void_result_t
        self.selene_rzz.argtypes = [
            SeleneInstancePtr,
            ctypes.c_uint64,
            ctypes.c_uint64,
            ctypes.c_double,
        ]
        self.selene_rzz.restype = selene_void_result_t
        self.selene_set_tc.argtypes = [SeleneInstancePtr, ctypes.c_uint64]
        self.selene_set_tc.restype = selene_void_result_t
        self.selene_shot_count.argtypes = [SeleneInstancePtr]
        self.selene_shot_count.restype = selene_u64_result_t
        self.selene_write_metadata.argtypes = [SeleneInstancePtr]
        self.selene_write_metadata.restype = selene_void_result_t
        self.selene_dump_state.argtypes = [
            SeleneInstancePtr,
            selene_string_t,
            UInt64Ptr,
            ctypes.c_uint64,
        ]
        self.selene_dump_state.restype = selene_void_result_t


class Qubit:
    def __init__(self, qubit_id: int):
        self.id = qubit_id


class InteractiveFullStack:
    @classmethod
    def load_library(cls) -> SeleneSimLib:
        if hasattr(cls, "_lib") and cls._lib is not None:
            return cls._lib
        cls._lib = SeleneSimLib()
        return cls._lib

    def __init__(
        self,
        *,
        n_qubits: int,
        simulator: Simulator,
        runtime: Runtime | None = None,
        error_model: ErrorModel | None = None,
        event_hook: EventHook | None = None,
        random_seed: int | None = None,
    ):
        self._lib = self.load_library()
        self._instance = SeleneInstancePtr()
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

        self._tcp_stream_ctx = TCPStream(
            timeout=Timeout(),
            shot_offset=self._shot_spec.offset,
            shot_increment=self._shot_spec.increment,
        )
        self._tcp_stream = self._tcp_stream_ctx.__enter__()
        self._data_stream = _NonBlockingStreamAdapter(self._tcp_stream)
        self._result_stream = ResultStream(self._data_stream)

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
            config_data["output_stream"] = self._tcp_stream.get_uri()
            existing_flags = config_data.get("event_hooks", {})
            if existing_flags and not isinstance(existing_flags, dict):
                raise TypeError("event_hooks configuration must be a mapping")
            config_data["event_hooks"] = {
                **(existing_flags or {}),
                **_event_hook_flags(self._event_hook),
            }

            self._configuration = config_data
            self._config_path.write_text(yaml.safe_dump(config_data))

            instance_ptr = SeleneInstancePtr()
            config_bytes = _encode_text(self._config_path)
            self._lib.selene_load_config(
                ctypes.byref(instance_ptr), ctypes.c_char_p(config_bytes)
            ).unwrap()
            self._instance = instance_ptr
        except Exception:
            self._teardown_environment()
            raise

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
        if hasattr(self, "_tcp_stream_ctx") and self._tcp_stream_ctx is not None:
            self._tcp_stream_ctx.__exit__(None, None, None)
            self._tcp_stream_ctx = None
            self._tcp_stream = None
            self._result_stream = None
        if hasattr(self, "_tempdir") and self._tempdir is not None:
            self._tempdir.cleanup()
            self._tempdir = None

    def next_shot(self):
        self._poll_results()
        self._on_shot_end()
        self._poll_results()
        self._shot_index += self._shot_spec.increment
        self._tcp_stream.next_shot()
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
        if not hasattr(self, "_result_stream") or self._result_stream is None:
            return
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
        self._call_void("selene_exit")

    def _invoke(self, func_name: str, *args):
        result = getattr(self._lib, func_name)(self._instance, *args)
        if self._auto_poll_metadata:
            assert self._lib is not None
            self._lib.selene_write_metadata(self._instance)
        self._poll_results()
        return result

    def _call_void(self, func_name: str, *args):
        self._invoke(func_name, *args).unwrap()

    def _call_u64(self, func_name: str, *args) -> int:
        return self._invoke(func_name, *args).unwrap()

    def _call_bool(self, func_name: str, *args) -> bool:
        return self._invoke(func_name, *args).unwrap()

    def _call_future(self, func_name: str, *args) -> int:
        return self._invoke(func_name, *args).unwrap()

    def _call_f64(self, func_name: str, *args) -> float:
        return self._invoke(func_name, *args).unwrap()

    def _call_u32(self, func_name: str, *args) -> int:
        return self._invoke(func_name, *args).unwrap()

    def _on_shot_start(self, shot_index: int) -> None:
        self._call_void("selene_on_shot_start", shot_index)

    def _on_shot_end(self) -> None:
        self._call_void("selene_on_shot_end")

    def custom_runtime_call(
        self, tag: int, payload: bytes | bytearray | memoryview | None = None
    ) -> int:
        buffer, length = _uint8_buffer(payload)
        pointer = ctypes.cast(buffer, BytePtr) if buffer is not None else None
        return self._call_u64("selene_custom_runtime_call", tag, pointer, length)

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
        return self._call_u32("selene_random_u32_bounded", ctypes.c_uint32(bound))

    def refcount_decrement(self, reference: int) -> None:
        self._call_void("selene_refcount_decrement", reference)

    def refcount_increment(self, reference: int) -> None:
        self._call_void("selene_refcount_increment", reference)

    def rxy(self, qubit: Qubit, theta: float, phi: float) -> None:
        self._call_void("selene_rxy", qubit.id, theta, phi)

    def rz(self, qubit: Qubit, theta: float) -> None:
        self._call_void("selene_rz", qubit.id, theta)

    def rzz(self, qubit_a: Qubit, qubit_b: Qubit, theta: float) -> None:
        self._call_void("selene_rzz", qubit_a.id, qubit_b.id, theta)

    def get_state(self, qubits: list[Qubit]):
        qubit_ids_t = ctypes.c_uint64 * len(qubits)
        qubit_ids = qubit_ids_t(*[q.id for q in qubits])
        num_qubits = ctypes.c_uint64(len(qubits))
        random_tag = "USER:STATE:" + os.urandom(8).hex()
        self._call_void(
            "selene_dump_state",
            selene_string_t.from_str(random_tag),
            ctypes.cast(qubit_ids, UInt64Ptr),
            num_qubits,
        )
        tagged_results = [
            (v.tag.replace("USER:", ""), v.values[0]) for v in self.drain_state_dumps()
        ]
        gen = self.simulator.extract_states(tagged_results, True)
        return next(gen)[1]
