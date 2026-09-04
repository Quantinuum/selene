import platform
from pathlib import Path

import pytest

from selene_quest_plugin import QuestPlugin


def test_cpu_backend_is_the_default() -> None:
    plugin = QuestPlugin()

    filenames = {
        "Linux": "libselene_quest_plugin.so",
        "Darwin": "libselene_quest_plugin.dylib",
        "Windows": "selene_quest_plugin.dll",
    }
    assert plugin.backend == "cpu"
    assert plugin.library_file.name == filenames[platform.system()]


def test_cuda_backend_uses_cuda_library(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(platform, "system", lambda: "Linux")

    plugin = QuestPlugin(backend="cuda")

    assert plugin.library_file.name == "libselene_quest_cuda_plugin.so"


def test_cuquantum_backend_uses_cuquantum_library(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(platform, "system", lambda: "Linux")

    plugin = QuestPlugin(backend="cuquantum")

    assert plugin.library_file.name == "libselene_quest_cuquantum_plugin.so"


@pytest.mark.parametrize("backend", ["cuda", "cuquantum"])
def test_gpu_backends_are_linux_only(
    monkeypatch: pytest.MonkeyPatch, backend: str
) -> None:
    monkeypatch.setattr(platform, "system", lambda: "Darwin")

    with pytest.raises(ValueError, match="GPU backends are available on Linux only"):
        QuestPlugin(backend=backend)  # type: ignore[arg-type]


def test_unknown_backend_is_rejected() -> None:
    with pytest.raises(ValueError, match="expected 'cpu', 'cuda', or 'cuquantum'"):
        QuestPlugin(backend="other")  # type: ignore[arg-type]


def test_backend_is_keyword_only() -> None:
    plugin = QuestPlugin(123)

    assert plugin.random_seed == 123
    assert plugin.backend == "cpu"
    assert isinstance(plugin.library_file, Path)
