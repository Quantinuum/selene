import warnings

from .types import ArtifactKind, Artifact, Step, LibDep, BuildCtx  # noqa: F401
from .planner import BuildPlanner
from .builtins import register_builtins
from .utils import invoke_zig  # noqa: F401
from .symbols import (
    SymbolTable,  # noqa: F401
    get_symbols_from_object,  # noqa: F401
    get_symbols_from_llvm,  # noqa: F401
)


def get_undefined_symbols_from_object(obj):
    warnings.warn(
        "get_undefined_symbols_from_object is deprecated; use get_symbols_from_object(...).undefined_functions instead.",
        DeprecationWarning,
        stacklevel=2,
    )
    return get_symbols_from_object(obj).undefined_functions


def get_undefined_symbols_from_llvm(contents):
    warnings.warn(
        "get_undefined_symbols_from_llvm is deprecated; use get_symbols_from_llvm(...).undefined_functions instead.",
        DeprecationWarning,
        stacklevel=2,
    )
    return get_symbols_from_llvm(contents).undefined_functions


# The default planner, which is globally accessible and can be
# accessed from anywhere. It is pre-loaded with builtin artifact
# kinds and steps between them.
DEFAULT_BUILD_PLANNER = BuildPlanner()
register_builtins(DEFAULT_BUILD_PLANNER)
