import enum
import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import QuantumInterface


class LogLevel(enum.Enum):
    """Enum for log levels."""

    QUIET = 0
    DEBUG = 1
    DIAGNOSTIC = 2


@dataclass
class BaseQISInterface(QuantumInterface):
    log_level: LogLevel = LogLevel.QUIET

    @property
    def library_search_dirs(self):
        return [Path(__file__).parent / "_dist/lib/"]

    @property
    def library_file(self):
        lib_name = "qis_interface"

        lib_name = "base_qis_selene_interface_logging_"
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
                return lib_dir / f"{lib_name}.dll.a"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")
