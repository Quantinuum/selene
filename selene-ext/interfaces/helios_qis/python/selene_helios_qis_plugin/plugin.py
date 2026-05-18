import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import QuantumInterface, BuildPlanner
from selene_base_qis_plugin import BaseQISInterface, LogLevel

from . import build


@dataclass
class HeliosInterface(QuantumInterface):
    log_level: LogLevel = LogLevel.QUIET

    @property
    def library_search_dirs(self):
        return [Path(__file__).parent / "_dist/lib/"]

    @property
    def link_flags(self):
        lib_name = "helios_qis_selene_interface_logging_"
        match self.log_level:
            case LogLevel.QUIET:
                lib_name += "off"
            case LogLevel.DEBUG:
                lib_name += "debug"
            case LogLevel.DIAGNOSTIC:
                lib_name += "diagnostic"
            case _:
                raise ValueError("Invalid log level")
        return [f"-l{lib_name}"]

    @property
    def dependencies(self):
        return [BaseQISInterface(log_level=self.log_level)]

    @property
    def library_file(self):
        # The Helios interface is now split into a static launcher and a shared
        # runtime. The planner links the launcher into the final executable and
        # adds the shared runtime separately.
        lib_name = "helios_qis_selene_runner"
        lib_dir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return lib_dir / f"lib{lib_name}.a"
            case "Darwin":
                return lib_dir / f"lib{lib_name}.a"
            case "Windows":
                return lib_dir / f"lib{lib_name}.a"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")

    def register_build_steps(self, planner: BuildPlanner):
        planner.add_step(build.SeleneCompileHUGRToLLVMIRStringStep)
        planner.add_step(build.SeleneCompileHUGRToLLVMBitcodeStringStep)
