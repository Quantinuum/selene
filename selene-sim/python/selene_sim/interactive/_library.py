from __future__ import annotations

import ctypes
import platform
import sys
from functools import cache
from pathlib import Path

from selene_sim import dist_dir as selene_dist


def selene_library_path() -> Path:
    lib_path = selene_dist / "lib"
    match platform.system():
        case "Darwin":
            lib_path /= "libselene.dylib"
        case "Linux":
            lib_path /= "libselene.so"
        case "Windows":
            lib_path /= "selene.dll"
        case _:
            raise RuntimeError(f"Unsupported OS {sys.platform}")
    if not lib_path.is_file():
        raise FileNotFoundError(f"Selene library not found at {lib_path}")
    return lib_path


@cache
def load_selene_global() -> ctypes.CDLL:
    return ctypes.CDLL(str(selene_library_path()), mode=ctypes.RTLD_GLOBAL)
