"""A :class:`DataStream` backed by a fixed-size, single-writer/single-reader
shared-memory byte FIFO.

The FIFO itself is implemented in Rust and exposed through ``libselene`` via a
small C ABI (see ``selene-sim/rust/ffi_shmem.rs``). This module wraps those
functions with ``ctypes``.

The segment is created and destroyed by *this* process (the one that calls
``run_shots``); the spawned selene writer process merely opens it using the OS
id carried in the ``shmem:<os_id>`` output-stream URI.
"""

import ctypes
import platform
import time
from pathlib import Path

from selene_sim.exceptions import SeleneStartupError, SeleneTimeoutError
from selene_sim.timeout import Timeout, Timer

from .data_stream import DataStream

# Location of the bundled distribution directory (selene_sim/_dist), computed
# directly from this file's location to avoid a circular import of the
# `selene_sim` package during its own initialisation.
_DIST_DIR = Path(__file__).resolve().parent.parent / "_dist"

# Default FIFO capacity in bytes (1 MiB).
DEFAULT_CAPACITY = 1024 * 1024

# Poll interval, in seconds, used while waiting for the writer to make more
# data available.
_POLL_INTERVAL = 0.00005


class _U64Result(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_uint64)]


class _BoolResult(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32), ("value", ctypes.c_bool)]


class _VoidResult(ctypes.Structure):
    _fields_ = [("error_code", ctypes.c_uint32)]


def _libselene_path() -> Path:
    lib_path = _DIST_DIR / "lib"
    match platform.system():
        case "Darwin":
            return lib_path / "libselene.dylib"
        case "Linux":
            return lib_path / "libselene.so"
        case "Windows":
            return lib_path / "selene.dll"
        case other:
            raise RuntimeError(f"Unsupported OS {other}")


class _ShmemLib:
    """Lazily-loaded ctypes wrapper around the shmem FIFO C ABI in libselene."""

    _instance: "_ShmemLib | None" = None

    def __init__(self) -> None:
        path = _libselene_path()
        assert path.is_file(), f"Selene library not found at {path}"
        lib = ctypes.CDLL(str(path))

        lib.selene_shmem_create.argtypes = [ctypes.c_uint64]
        lib.selene_shmem_create.restype = ctypes.c_void_p

        lib.selene_shmem_get_os_id.argtypes = [
            ctypes.c_void_p,
            ctypes.c_char_p,
            ctypes.c_uint64,
        ]
        lib.selene_shmem_get_os_id.restype = _U64Result

        lib.selene_shmem_read.argtypes = [
            ctypes.c_void_p,
            ctypes.c_char_p,
            ctypes.c_uint64,
        ]
        lib.selene_shmem_read.restype = _U64Result

        lib.selene_shmem_writer_closed.argtypes = [ctypes.c_void_p]
        lib.selene_shmem_writer_closed.restype = _BoolResult

        lib.selene_shmem_destroy.argtypes = [ctypes.c_void_p]
        lib.selene_shmem_destroy.restype = _VoidResult

        self.lib = lib

    @classmethod
    def load(cls) -> "_ShmemLib":
        if cls._instance is None:
            cls._instance = _ShmemLib()
        return cls._instance


class ShmemStream(DataStream):
    """A results stream backed by a shared-memory FIFO.

    This transport supports exactly one writer (one selene process). It creates
    the shared-memory segment on entry and destroys it on exit.
    """

    def __init__(
        self,
        capacity: int = DEFAULT_CAPACITY,
        timeout: Timeout = Timeout(),
        logfile: Path | None = None,
        shot_offset: int = 0,
        shot_increment: int = 1,
    ):
        if capacity <= 0:
            raise ValueError("Shared-memory FIFO capacity must be positive")
        self.capacity = capacity
        self.done = False
        self.handle: int | None = None
        self.os_id: str | None = None
        self.receive_buffer = b""
        self.logfile = logfile
        self.logfile_handle = None
        self.current_shot = shot_offset
        self.shot_increment = shot_increment
        self._lib = _ShmemLib.load()
        # A reusable buffer for reading out of the FIFO.
        self._read_buf = ctypes.create_string_buffer(capacity)
        self.overall_timer = Timer(timeout.overall)
        self.shot_timer = Timer(timeout.per_shot)
        self.read_timer = Timer(timeout.per_result)
        self.connect_timer = Timer(timeout.backend_startup)

    def __enter__(self):
        handle = self._lib.lib.selene_shmem_create(self.capacity)
        if not handle:
            raise SeleneStartupError(
                "Failed to create shared-memory FIFO segment",
                "",
                "",
            )
        self.handle = handle
        # Retrieve the OS id assigned to the segment.
        id_buf = ctypes.create_string_buffer(256)
        result = self._lib.lib.selene_shmem_get_os_id(handle, id_buf, 256)
        if result.error_code != 0:
            raise SeleneStartupError(
                f"Failed to read shared-memory OS id (error {result.error_code})",
                "",
                "",
            )
        assert result.value <= 256, "Shared-memory OS id larger than expected"
        self.os_id = id_buf.raw[: result.value].decode("utf-8")
        if self.logfile is not None:
            self.logfile_handle = self.logfile.open("wb")
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.done = True
        if self.logfile_handle is not None:
            self.logfile_handle.close()
            self.logfile_handle = None
        if self.handle is not None:
            self._lib.lib.selene_shmem_destroy(self.handle)
            self.handle = None

    def get_uri(self) -> str:
        assert self.os_id is not None, "get_uri called on an unopened stream"
        return f"shmem:{self.os_id}"

    def _writer_closed(self) -> bool:
        assert self.handle is not None
        result = self._lib.lib.selene_shmem_writer_closed(self.handle)
        return bool(result.value)

    def _drain_available(self) -> int:
        """Read all currently-available bytes out of the FIFO into the receive
        buffer, returning the number of bytes read."""
        assert self.handle is not None
        result = self._lib.lib.selene_shmem_read(
            self.handle, self._read_buf, self.capacity
        )
        n = result.value
        if n:
            data = self._read_buf.raw[:n]
            self.receive_buffer += data
            if self.logfile_handle is not None:
                self.logfile_handle.write(data)
        return n

    def read_chunk(self, length: int) -> bytes:
        if self.done:
            return b""
        assert self.handle is not None, "read_chunk called on an unopened stream"

        self.read_timer.reset()
        while len(self.receive_buffer) < length:
            read = self._drain_available()
            if read:
                # Got data; keep pulling without sleeping in case more is ready.
                continue
            # No data currently available. If the writer has closed and the FIFO
            # is drained, there will never be more data.
            if self._writer_closed() and self._drain_available() == 0:
                break
            remaining = Timer.min_remaining_seconds(
                [self.read_timer, self.shot_timer, self.overall_timer]
            )
            if remaining is not None and remaining <= 0:
                break
            time.sleep(_POLL_INTERVAL)

        if len(self.receive_buffer) < length:
            # Either the stream ended or we timed out.
            if self._writer_closed():
                self.done = True
                result = self.receive_buffer
                self.receive_buffer = b""
                return result
            raise SeleneTimeoutError(
                f"Timed out waiting for shot results: {self._timer_expiry_str()}",
                "",
                "",
            )

        result = self.receive_buffer[:length]
        self.receive_buffer = self.receive_buffer[length:]
        return result

    def next_shot(self):
        self.current_shot += self.shot_increment
        self.shot_timer.reset()

    def _timer_expiry_str(self) -> str:
        expired_names = []
        for name, timer in (
            ("backend_startup", self.connect_timer),
            ("per_shot", self.shot_timer),
            ("per_result", self.read_timer),
            ("overall", self.overall_timer),
        ):
            if timer.has_expired():
                expired_names.append(f"'{name}'")
        if expired_names:
            return f"Expired timers: {', '.join(expired_names)}"
        return "No expired timers"
