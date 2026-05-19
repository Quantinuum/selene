import platform
from dataclasses import dataclass
from pathlib import Path

from selene_core import Utility


@dataclass
class ArgReaderPlugin(Utility):
    @property
    def library_file(self) -> Path:
        lib_name = "selene_argreader_plugin"
        lib_dir = Path(__file__).parent / "_dist/lib/"
        match platform.system():
            case "Linux":
                return lib_dir / f"lib{lib_name}.so"
            case "Darwin":
                return lib_dir / f"lib{lib_name}.dylib"
            case "Windows":
                return lib_dir / f"lib{lib_name}.dll.a"
            case system:
                raise RuntimeError(f"Unsupported platform: {system}")

    @property
    def library_search_dirs(self) -> list[Path]:
        return [Path(__file__).parent / "_dist/lib/"]

    @property
    def link_flags(self) -> list[str]:
        if platform.system() == "Windows":
            return [
                "-luserenv",
            ]
        else:
            return []
