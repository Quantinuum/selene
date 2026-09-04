import platform
from dataclasses import dataclass, field
from importlib.metadata import PackageNotFoundError, distribution
from pathlib import Path
from typing import Iterable, Iterator, Literal, cast
from hugr.qsystem.result import TaggedResult
from selene_core import Simulator
from .state import SeleneQuestState


@dataclass
class QuestPlugin(Simulator):
    """
    A plugin for using QuEST, the statevector simulation engine,
    as the backend simulator for selene.

    Attributes:
        backend: The QuEST implementation to use. ``"cpu"`` is available on all
            supported platforms. ``"cuda"`` uses QuEST's native CUDA implementation,
            while ``"cuquantum"`` uses NVIDIA cuStateVec. Both GPU backends are
            available on Linux only.
    """

    backend: Literal["cpu", "cuda", "cuquantum"] = field(default="cpu", kw_only=True)

    def __post_init__(self):
        if self.backend not in ("cpu", "cuda", "cuquantum"):
            raise ValueError(
                "Unsupported QuEST backend "
                f"{self.backend!r}; expected 'cpu', 'cuda', or 'cuquantum'"
            )
        if self.backend != "cpu" and platform.system() != "Linux":
            raise ValueError("The QuEST GPU backends are available on Linux only")

    @property
    def library_file(self):
        libdir = Path(__file__).parent / "_dist/lib/"
        if self.backend == "cuda":
            return libdir / "libselene_quest_cuda_plugin.so"
        if self.backend == "cuquantum":
            return libdir / "libselene_quest_cuquantum_plugin.so"

        match platform.system():
            case "Linux":
                return libdir / "libselene_quest_plugin.so"
            case "Darwin":
                return libdir / "libselene_quest_plugin.dylib"
            case "Windows":
                return libdir / "selene_quest_plugin.dll"
            case _:
                raise RuntimeError(f"Unsupported platform: {platform.system()}")

    @property
    def library_search_dirs(self) -> list[Path]:
        if self.backend != "cuquantum":
            return []

        try:
            return [
                _distribution_library_dir(
                    "custatevec-cu12", "cuquantum/lib/libcustatevec.so.1"
                ),
                _distribution_library_dir(
                    "nvidia-cuda-runtime-cu12",
                    "nvidia/cuda_runtime/lib/libcudart.so.12",
                ),
                _distribution_library_dir(
                    "nvidia-cublas-cu12", "nvidia/cublas/lib/libcublas.so.12"
                ),
            ]
        except (PackageNotFoundError, FileNotFoundError) as error:
            raise RuntimeError(
                "The QuEST cuQuantum backend requires the optional packages "
                "'custatevec-cu12', 'nvidia-cuda-runtime-cu12', and "
                "'nvidia-cublas-cu12'; install them with "
                "`pip install 'selene-sim[quest-cuquantum]'`"
            ) from error

    def get_init_args(self):
        return []

    @staticmethod
    def extract_states_dict(
        results: Iterable[TaggedResult],
        cleanup: bool = True,
    ) -> dict[str, SeleneQuestState]:
        """Extract state results from a shot result stream and return them as a
        dictionary keyed by the state tag. Assumes tags are unique within the shot.

        By default, state files are removed after extraction, as they may take up
        considerable storage space. Pass `cleanup=False` to keep the files.
        """
        return dict(QuestPlugin.extract_states(results, cleanup=cleanup))

    @staticmethod
    def extract_states(
        results: Iterable[TaggedResult],
        cleanup: bool = True,
    ) -> Iterator[tuple[str, SeleneQuestState]]:
        """Extract state results from a shot result stream and return them as a
        pair of (tag, state).

        By default, state files are removed after extraction, as they may take up
        considerable storage space. Pass `cleanup=False` to keep the state files.
        """
        return (
            (
                cast(str, state_tag),
                SeleneQuestState.parse_from_file(pth, cleanup=cleanup),
            )
            for tag, result in results
            if (state_tag := _state_tag(tag)) is not None
            and isinstance(result, str)
            and (pth := Path(result)).is_file()
        )


def _state_tag(tag: str) -> str | None:
    """Strip prefix for state results if it is present and return the remainder."""
    prefix = "STATE:"
    if tag.startswith(prefix):
        return tag[len(prefix) :]
    return None


def _distribution_library_dir(package: str, library: str) -> Path:
    """Find a native library installed by an optional Python distribution."""
    installed = distribution(package)
    for file in installed.files or []:
        if file.as_posix().endswith(library):
            return Path(file.locate()).parent
    raise FileNotFoundError(f"Could not find {library!r} in {package!r}")
