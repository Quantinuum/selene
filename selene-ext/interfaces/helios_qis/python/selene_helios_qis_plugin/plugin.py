import enum
import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import QuantumInterface, BuildPlanner

from . import build


class LogLevel(enum.Enum):
    """Enum for log levels."""

    QUIET = 0
    DEBUG = 1
    DIAGNOSTIC = 2


@dataclass
class HeliosInterface(QuantumInterface):
    log_level: LogLevel = LogLevel.QUIET

    @property
    def library_file(self):
        # The Helios interface is now split into a static launcher and a shared
        # runtime. The planner links the launcher into the final executable and
        # adds the shared runtime separately.
        lib_name = "helios_selene_interface_launcher"
        match self.log_level:
            case LogLevel.QUIET:
                lib_name += ""
            case LogLevel.DEBUG:
                lib_name += "_debug"
            case LogLevel.DIAGNOSTIC:
                lib_name += "_diagnostic"
            case _:
                raise ValueError("Invalid log level")
        lib_dir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return lib_dir / f"lib{lib_name}.a"
            case "Darwin":
                return lib_dir / f"lib{lib_name}.a"
            case "Windows":
                mingw_static = lib_dir / f"lib{lib_name}.a"
                if mingw_static.exists():
                    return mingw_static
                return lib_dir / f"{lib_name}.lib"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")

    def register_build_steps(self, planner: BuildPlanner):
        planner.add_step(build.SeleneCompileHUGRToLLVMIRStringStep)
        planner.add_step(build.SeleneCompileHUGRToLLVMBitcodeStringStep)
