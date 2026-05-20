"""
The Helios QIS interface is split into two conceptual parts.

The first is a dynamic library (interface) comprising the shims from QIS
functionality (specific to Helios) to the Selene library functions, e.g.:
```
    ___rxy(qubit, theta, phi) -> selene_rxy(selene_instance, qubit, theta, phi)
```
it also contains a function to invoke a callback through a shot loop.
It is linked to a base QIS interface that exposes common functions, e.g.
get_current_shot(), that do not depend on device-specific implementations.

The second is a static library (runtime) that links to the user's qmain
function, passing it into the callback.


----------------        --------------------
|              |        |                  |
| User program | ------ | Static runtime   |
|              |        |                  |
----------------        --------------------
               \        /
                \      /
          -----------------------     -------------------------
          |  Dynamic helios-qis |_____| Dynamic base QIS shim |
          |  shim interface     |     |  interface            |
          -----------------------     -------------------------
                   |
                   |
             --------------
             | libselene  |
             --------------

This design keeps the dynamic library self-contained without depending
on the undefined qmain(), necessary for cross-platform support. By
utilising the base QIS interface, we support utilities that depend on
wider QIS functionality (e.g. that depend on getting the current shot
index) without tying to specific QIS implementations.
"""

import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import QuantumInterface, BuildPlanner
from selene_base_qis_plugin import BaseQISInterface, LogLevel

from . import build


@dataclass
class HeliosQISShimInterface(BaseQISInterface):
    log_level: LogLevel = LogLevel.QUIET

    @property
    def library_search_dirs(self):
        return [Path(__file__).parent / "_dist/lib/"]

    @property
    def dependencies(self):
        return [BaseQISInterface(log_level=self.log_level)]

    @property
    def library_file(self):
        # The Helios interface is now split into a static launcher and a shared
        # runtime. The planner links the launcher into the final executable and
        # adds the shared runtime separately.
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
        lib_dir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return lib_dir / f"lib{lib_name}.so"
            case "Darwin":
                return lib_dir / f"lib{lib_name}.dylib"
            case "Windows":
                return lib_dir / f"lib{lib_name}.dll.a"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")


@dataclass
class HeliosInterface(QuantumInterface):
    log_level: LogLevel = LogLevel.QUIET

    @property
    def library_search_dirs(self):
        return [Path(__file__).parent / "_dist/lib/"]

    @property
    def dependencies(self):
        return [HeliosQISShimInterface(log_level=self.log_level)]

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
