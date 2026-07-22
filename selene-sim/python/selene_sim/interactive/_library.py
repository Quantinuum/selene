from __future__ import annotations

import ctypes
import os
import re
from pathlib import Path
from typing import Callable, Protocol, TypeVar

from selene_core import SeleneComponent


T = TypeVar("T")
_IS_WINDOWS = os.name == "nt"


class _DirectoryHandle(Protocol):
    def close(self) -> None: ...


class LibrarySearch:
    """Apply component library search directories to an in-process load.

    When interactively loading dynamic libraries in python, one cannot
    locally modify the environment in which dependencies are found, e.g.
    LD_LIBRARY_PATH, DYLD_LIBRARY_PATH, or PATH. Instead, the environment
    variables at launch of the python process itself are used. As plugins
    may have dependencies, such as libcudart.so, we need a way to load them
    in interactive sessions.
    """

    def __init__(self, search_dirs: list[Path]):
        self.search_dirs = list(dict.fromkeys(Path(path) for path in search_dirs))
        self._directory_handles: list[_DirectoryHandle] = []
        self._dependencies: list[ctypes.CDLL] = []
        self._loaded_dependency_paths: set[Path] = set()
        self._loading: set[Path] = set()

        if _IS_WINDOWS:
            add_dll_directory = getattr(os, "add_dll_directory")
            try:
                for directory in self.search_dirs:
                    self._directory_handles.append(add_dll_directory(directory))
            except Exception:
                self.close()
                raise

    def load(self, callback: Callable[[], T]) -> T:
        """Run a library load, resolving missing POSIX dependencies on demand."""
        while True:
            try:
                return callback()
            except OSError as error:
                dependency = self._find_missing_dependency(error)
                if dependency is None:
                    raise
                self._load_dependency(dependency)

    def _find_missing_dependency(self, error: OSError) -> Path | None:
        if _IS_WINDOWS:
            return None

        message = str(error)
        linux_match = re.search(
            r"(?:^|: )([^/:\s]+): cannot open shared object file", message
        )
        macos_match = re.search(r"Library not loaded: (\S+)", message)
        match = linux_match or macos_match
        if match is None:
            return None

        library_name = Path(match.group(1)).name
        for directory in self.search_dirs:
            candidate = directory / library_name
            if candidate.is_file():
                return candidate
        return None

    def _load_dependency(self, dependency: Path) -> None:
        dependency = dependency.resolve()
        if dependency in self._loading or dependency in self._loaded_dependency_paths:
            raise OSError(f"Cyclic dynamic library dependency involving {dependency}")

        self._loading.add(dependency)
        try:
            library = self.load(
                lambda: ctypes.CDLL(str(dependency), mode=ctypes.RTLD_GLOBAL)
            )
            self._dependencies.append(library)
            self._loaded_dependency_paths.add(dependency)
        finally:
            self._loading.remove(dependency)

    def close(self) -> None:
        for handle in reversed(self._directory_handles):
            handle.close()
        self._directory_handles.clear()

    def __del__(self):
        self.close()


def load_component_library(
    component: SeleneComponent,
) -> tuple[ctypes.CDLL, LibrarySearch]:
    """Load a component library and retain everything needed by its loader."""
    search = LibrarySearch(component.library_search_dirs)
    try:
        library = search.load(lambda: ctypes.CDLL(str(component.library_file)))
    except Exception:
        search.close()
        raise
    return library, search
