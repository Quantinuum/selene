import platform
from pathlib import Path

from selene_simple_runtime_plugin import SimpleRuntimePlugin


class ThreadedRuntimePlugin(SimpleRuntimePlugin):
    """A runtime that drives its quantum endpoint on a separate thread.

    Gates are queued until a measurement result, a forced endpoint borrow,
    or shot end requires them. Gate durations use the same parameters as the
    simple runtime, so we can compare their results and traces directly.
    """

    def get_init_args(self):
        scheduler = SimpleRuntimePlugin().library_file
        return [f"--scheduler={scheduler}", *super().get_init_args()]

    @property
    def library_file(self):
        libdir = Path(__file__).parent / "_dist/lib"
        match platform.system():
            case "Linux":
                return libdir / "libselene_threaded_runtime.so"
            case "Darwin":
                return libdir / "libselene_threaded_runtime.dylib"
            case "Windows":
                return libdir / "selene_threaded_runtime.dll"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")
