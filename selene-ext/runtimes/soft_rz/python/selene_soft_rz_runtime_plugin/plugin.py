import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import Runtime


@dataclass
class SoftRZRuntimePlugin(Runtime):
    """
    A plugin for running a soft_rz runtime in selene.

    It is a lazy runtime, so when the user program requests a gate to be performed, it is
    not performed immediately, but is stored in a queue. Upon the request for a measurement
    result, operations before and including the measurement are performed in order to
    retrieve the result.
    """

    duration_ns_rxy: int = 0
    duration_ns_rzz: int = 0
    duration_ns_measure: int = 0
    duration_ns_reset: int = 0
    duration_ns_measure_leaked: int = 0
    max_batch_size: int = 1

    def __post_init__(self):
        assert self.duration_ns_rxy >= 0, "duration_ns_rxy must be non-negative"
        assert self.duration_ns_rzz >= 0, "duration_ns_rzz must be non-negative"
        assert self.duration_ns_measure >= 0, "duration_ns_measure must be non-negative"
        assert self.duration_ns_reset >= 0, "duration_ns_reset must be non-negative"
        assert self.duration_ns_measure_leaked >= 0, (
            "duration_ns_measure_leaked must be non-negative"
        )
        assert self.max_batch_size > 0, "max_batch_size must be positive"

    def get_init_args(self):
        return [
            f"--duration-ns-rxy={self.duration_ns_rxy}",
            f"--duration-ns-rzz={self.duration_ns_rzz}",
            f"--duration-ns-measure={self.duration_ns_measure}",
            f"--duration-ns-reset={self.duration_ns_reset}",
            f"--duration-ns-measure-leaked={self.duration_ns_measure_leaked}",
            f"--max-batch-size={self.max_batch_size}",
        ]

    @property
    def library_file(self):
        libdir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return libdir / "libselene_soft_rz_runtime.so"
            case "Darwin":
                return libdir / "libselene_soft_rz_runtime.dylib"
            case "Windows":
                return libdir / "selene_soft_rz_runtime.dll"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")
