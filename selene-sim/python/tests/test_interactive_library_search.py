import ctypes
import os
from pathlib import Path

import pytest

from selene_sim.interactive import _library
from selene_sim.interactive._library import LibrarySearch


def test_posix_library_search_loads_a_missing_dependency(monkeypatch, tmp_path):
    if os.name == "nt":
        pytest.skip("POSIX dependency resolution test")

    dependency = tmp_path / "libdependency.so"
    dependency.touch()
    attempts = 0
    loaded = []

    def load_plugin():
        nonlocal attempts
        attempts += 1
        if attempts == 1:
            raise OSError(
                "libdependency.so: cannot open shared object file: "
                "No such file or directory"
            )
        return "plugin"

    def load_dependency(path, *, mode):
        loaded.append((Path(path), mode))
        return object()

    monkeypatch.setattr(ctypes, "CDLL", load_dependency)

    search = LibrarySearch([tmp_path])
    assert search.load(load_plugin) == "plugin"
    assert loaded == [(dependency, ctypes.RTLD_GLOBAL)]


def test_windows_library_search_keeps_directory_handles_open(monkeypatch, tmp_path):
    class Handle:
        def __init__(self):
            self.closed = False

        def close(self):
            self.closed = True

    handles = []

    def add_dll_directory(path):
        assert path == tmp_path
        handle = Handle()
        handles.append(handle)
        return handle

    monkeypatch.setattr(_library, "_IS_WINDOWS", True)
    monkeypatch.setattr(os, "add_dll_directory", add_dll_directory, raising=False)

    search = LibrarySearch([tmp_path])
    assert len(handles) == 1
    assert not handles[0].closed

    search.close()
    assert handles[0].closed
