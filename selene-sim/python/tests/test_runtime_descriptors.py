"""The interactive loader supports legacy and concurrent descriptors."""

import os
import shlex
import subprocess
import sys
from pathlib import Path

import pytest
from selene_core import Runtime
from selene_sim.interactive.runtime import InteractiveRuntime, SeleneSimRuntimeLib


class RuntimeFile(Runtime):
    def __init__(self, library: Path):
        super().__init__()
        self.library = library

    @property
    def library_file(self) -> Path:
        return self.library

    def get_init_args(self) -> list[str]:
        return []


@pytest.fixture
def plugin(tmp_path, request):
    root = Path(__file__).resolve().parents[3] / "selene-core"
    library = tmp_path / ("plugin.dylib" if sys.platform == "darwin" else "plugin.so")
    if sys.platform == "win32":
        pytest.skip("C fixture uses the Unix shared-library linker")
    args = shlex.split(os.environ.get("CC", "cc")) + [
        "-dynamiclib" if sys.platform == "darwin" else "-shared",
        "-fPIC",
        "-std=c11",
        "-I",
        str(root / "c/include"),
        str(root / "tests/support/runtime_v1.c"),
        str(root / "tests/support/runtime_v2.c"),
        "-o",
        str(library),
    ]
    args += ["-D" + define for define in request.param]
    subprocess.run(args, check=True, capture_output=True, timeout=20)
    return RuntimeFile(library)


@pytest.mark.parametrize(
    "plugin,expected",
    [
        ([], 0),
        (["DATA_SYMBOL"], 0),
        (["WITH_V2"], 999),
        (["WITH_V2", "DATA_SYMBOL"], 999),
    ],
    indirect=["plugin"],
)
def test_interactive_descriptor_selection(plugin, expected):
    runtime = InteractiveRuntime(n_qubits=16, runtime=plugin)
    try:
        assert runtime.qalloc() == expected
    finally:
        assert runtime._lib.selene_runtime_shot_end(runtime._instance) == 0
        assert runtime._lib.selene_runtime_exit(runtime._instance) == 0


@pytest.mark.parametrize(
    "plugin,message",
    [
        (["BAD_V2=1"], "null"),
        (["BAD_V2=2"], "too small"),
        (["BAD_V2=3"], "version"),
    ],
    indirect=["plugin"],
)
def test_invalid_v2_does_not_fall_back_to_v1(plugin, message):
    with pytest.raises(RuntimeError, match=message):
        SeleneSimRuntimeLib(plugin)
