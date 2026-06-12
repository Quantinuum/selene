import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import Runtime


@dataclass
class SimpleRuntimePlugin(Runtime):
    """
    A plugin for running a simple runtime in selene.

    It is a lazy runtime, so when the user program requests a gate to be performed, it is
    not performed immediately, but is stored in a queue. Upon the request for a measurement
    result, operations before and including the measurement are performed in order to
    retrieve the result.
    """

    duration_ns_rxy: int = 0
    duration_ns_rzz: int = 0
    duration_ns_rz: int = 0
    duration_ns_rpp: int = 0
    duration_ns_measure: int = 0
    duration_ns_reset: int = 0
    duration_ns_measure_leaked: int = 0

    def __post_init__(self):
        assert self.duration_ns_rxy >= 0, "duration_ns_rxy must be non-negative"
        assert self.duration_ns_rzz >= 0, "duration_ns_rzz must be non-negative"
        assert self.duration_ns_measure >= 0, "duration_ns_measure must be non-negative"
        assert self.duration_ns_reset >= 0, "duration_ns_reset must be non-negative"
        assert self.duration_ns_rz >= 0, "duration_ns_rz must be non-negative"
        assert self.duration_ns_rpp >= 0, "duration_ns_rpp must be non-negative"
        assert self.duration_ns_measure_leaked >= 0, (
            "duration_ns_measure_leaked must be non-negative"
        )

    def get_init_args(self):
        return [
            f"--duration-ns-rxy={self.duration_ns_rxy}",
            f"--duration-ns-rzz={self.duration_ns_rzz}",
            f"--duration-ns-rz={self.duration_ns_rz}",
            f"--duration-ns-rpp={self.duration_ns_rpp}",
            f"--duration-ns-measure={self.duration_ns_measure}",
            f"--duration-ns-reset={self.duration_ns_reset}",
            f"--duration-ns-measure-leaked={self.duration_ns_measure_leaked}",
        ]

    @property
    def library_file(self):
        libdir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return libdir / "libselene_simple_runtime.so"
            case "Darwin":
                return libdir / "libselene_simple_runtime.dylib"
            case "Windows":
                return libdir / "selene_simple_runtime.dll"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")
