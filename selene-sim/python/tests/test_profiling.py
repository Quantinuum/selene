"""
Unit tests for samply-based profiling support.

These tests focus on the process wiring and CLI argument construction. They
use monkeypatching to avoid requiring a real selene executable or samply
binary. Integration profiling tests (which require a compiled program and a
real samply install) are left as manual verification.
"""

import platform
from pathlib import Path
from unittest.mock import MagicMock, patch, call

import pytest

from selene_sim.process import SeleneProcess


# ---------------------------------------------------------------------------
# SeleneProcess: command_prefix
# ---------------------------------------------------------------------------


def _make_process(tmp_path: Path, command_prefix=None) -> SeleneProcess:
    """Create a minimal SeleneProcess for testing spawn()."""
    run_dir = tmp_path / "run"
    run_dir.mkdir()
    kwargs = dict(
        executable=tmp_path / "fake.x",
        library_search_dirs=[],
        run_directory=run_dir,
        configuration={"shots": {"count": 1, "offset": 0, "increment": 1}},
    )
    if command_prefix is not None:
        kwargs["command_prefix"] = command_prefix
    return SeleneProcess(**kwargs)


def test_process_default_no_prefix(tmp_path):
    """With no command_prefix, argv starts with the executable."""
    proc = _make_process(tmp_path)
    with patch("selene_sim.process.Popen") as mock_popen:
        mock_popen.return_value = MagicMock()
        proc.spawn()
        argv = mock_popen.call_args[0][0]
    assert argv[0] == str(tmp_path / "fake.x")


def test_process_command_prefix_prepended(tmp_path):
    """command_prefix items appear before the executable in argv."""
    prefix = ["samply", "record"]
    proc = _make_process(tmp_path, command_prefix=prefix)
    with patch("selene_sim.process.Popen") as mock_popen:
        mock_popen.return_value = MagicMock()
        proc.spawn()
        argv = mock_popen.call_args[0][0]
    assert argv[:2] == ["samply", "record"]
    assert argv[2] == str(tmp_path / "fake.x")


def test_process_save_only_prefix(tmp_path):
    """--save-only and --output flags appear in the prefix."""
    output_file = tmp_path / "profile.json"
    prefix = ["samply", "record", "--save-only", "--output", str(output_file)]
    proc = _make_process(tmp_path, command_prefix=prefix)
    with patch("selene_sim.process.Popen") as mock_popen:
        mock_popen.return_value = MagicMock()
        proc.spawn()
        argv = mock_popen.call_args[0][0]
    assert argv[:5] == [
        "samply",
        "record",
        "--save-only",
        "--output",
        str(output_file),
    ]
    assert argv[5] == str(tmp_path / "fake.x")


# ---------------------------------------------------------------------------
# SeleneInstance.profile(): samply-not-found guard
# ---------------------------------------------------------------------------


def _make_mock_instance(tmp_path: Path):
    """Build a SeleneInstance with enough state to exercise profile()."""
    from selene_sim.instance import SeleneInstance

    executable = tmp_path / "program.selene.x"
    executable.touch()
    artifacts = tmp_path / "artifacts"
    artifacts.mkdir()
    runs = tmp_path / "runs"
    runs.mkdir()
    return SeleneInstance(
        root=tmp_path,
        artifacts=artifacts,
        runs=runs,
        executable=executable,
        library_search_dirs=[],
        interface_symbols=[],
    )


def test_profile_raises_when_samply_missing(tmp_path):
    """profile() raises RuntimeError when samply is not on PATH."""
    from selene_sim import Quest

    instance = _make_mock_instance(tmp_path)

    with patch("shutil.which", return_value=None):
        with pytest.raises(RuntimeError, match="samply"):
            # Consume the generator to trigger the body.
            list(instance.profile(simulator=Quest(), n_qubits=1))


# ---------------------------------------------------------------------------
# SeleneObjectToSeleneExecutableStep: emit_debug forwarding
# ---------------------------------------------------------------------------


def test_selene_object_step_forwards_emit_debug(tmp_path):
    """emit_debug=True in BuildCtx.cfg is forwarded to invoke_zig."""
    from selene_core.build_utils.builtins.selene import SeleneObjectToSeleneExecutableStep
    from selene_core.build_utils.types import BuildCtx, Artifact
    from selene_core.build_utils.builtins.selene import SeleneObjectFileKind

    obj_file = tmp_path / "program.o"
    obj_file.touch()
    artifact = Artifact(resource=obj_file, kind=SeleneObjectFileKind)

    ctx = BuildCtx(
        artifact_dir=tmp_path,
        deps=[],
        cfg={"emit_debug": True},
        verbose=False,
    )

    # Provide a plausible fake selene_sim.dist_dir so the step can locate libs
    fake_lib_dir = tmp_path / "lib"
    fake_lib_dir.mkdir()
    fake_lib = fake_lib_dir / (
        "libselene.dylib" if platform.system() == "Darwin" else "libselene.so"
    )
    fake_lib.touch()

    import selene_sim

    with (
        patch.object(selene_sim, "dist_dir", fake_lib_dir.parent),
        patch("selene_core.build_utils.builtins.selene.invoke_zig") as mock_zig,
        patch("selene_core.build_utils.builtins.selene.invoke_dsymutil") as mock_dsymutil,
    ):
        SeleneObjectToSeleneExecutableStep.apply(ctx, artifact)

        # invoke_zig must have been called with emit_debug=True
        assert mock_zig.called
        _, kwargs = mock_zig.call_args
        assert kwargs.get("emit_debug") is True

        # dsymutil should be called on Darwin only
        if platform.system() == "Darwin":
            assert mock_dsymutil.called
        else:
            assert not mock_dsymutil.called


def test_selene_object_step_no_dsymutil_without_emit_debug(tmp_path):
    """invoke_dsymutil is NOT called when emit_debug is False (the default)."""
    from selene_core.build_utils.builtins.selene import SeleneObjectToSeleneExecutableStep
    from selene_core.build_utils.types import BuildCtx, Artifact
    from selene_core.build_utils.builtins.selene import SeleneObjectFileKind

    obj_file = tmp_path / "program.o"
    obj_file.touch()
    artifact = Artifact(resource=obj_file, kind=SeleneObjectFileKind)
    ctx = BuildCtx(artifact_dir=tmp_path, deps=[], cfg={}, verbose=False)

    fake_lib_dir = tmp_path / "lib"
    fake_lib_dir.mkdir()
    fake_lib = fake_lib_dir / (
        "libselene.dylib" if platform.system() == "Darwin" else "libselene.so"
    )
    fake_lib.touch()

    import selene_sim

    with (
        patch.object(selene_sim, "dist_dir", fake_lib_dir.parent),
        patch("selene_core.build_utils.builtins.selene.invoke_zig"),
        patch("selene_core.build_utils.builtins.selene.invoke_dsymutil") as mock_dsymutil,
    ):
        SeleneObjectToSeleneExecutableStep.apply(ctx, artifact)
        assert not mock_dsymutil.called
