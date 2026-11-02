"""Generated native files must survive Hatch's platform-independent exclusions."""

import importlib.util
import zipfile
from pathlib import Path, PureWindowsPath

from hatchling.builders.wheel import WheelBuilder


def test_windows_extension_and_runtime_are_in_the_wheel(tmp_path, monkeypatch):
    spec = importlib.util.spec_from_file_location(
        "toolchain_wheel_hook", Path(__file__).parents[1] / "hatch_build.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    package = tmp_path / "python/selene_toolchain"
    runtime = package / "_dist"
    (runtime / "bin").mkdir(parents=True)
    (runtime / "runtime").mkdir()
    (package / "__init__.py").write_text("")
    (package / "py.typed").write_text("")
    (package / "_native.pyd").write_bytes(b"native extension")
    (runtime / "bin/llvm-symbolizer.exe").write_bytes(b"symbolizer")
    (runtime / "runtime/libgcc.a").write_bytes(b"runtime archive")
    (tmp_path / ".gitignore").write_text("_dist/\n")
    (tmp_path / "pyproject.toml").write_text(
        '[project]\nname = "selene-toolchain"\nversion = "0.1.0"\n'
        '[tool.hatch.build.targets.wheel]\npackages = ["python/selene_toolchain"]\n'
    )
    builder = WheelBuilder(str(tmp_path))
    data = builder.get_default_build_data()
    builder.set_build_data_defaults(data)
    data["tag"] = "cp310-abi3-win_amd64"

    # Hatch excludes .pyd files through its default *.py[cdo] pattern. We
    # should only get the extension when our hook explicitly includes it.
    excluded_dir = tmp_path / "without-artifacts"
    excluded_dir.mkdir()
    with builder.config.set_build_data(data):
        excluded = builder.build_standard(str(excluded_dir), **data)
    with zipfile.ZipFile(excluded) as wheel:
        assert "selene_toolchain/_native.pyd" not in wheel.namelist()

    relative_to = Path.relative_to
    with monkeypatch.context() as windows:
        # Exercise the hook with Windows relative paths even on a Linux
        # developer machine. str(path) would produce backslash patterns here.
        windows.setattr(
            Path,
            "relative_to",
            lambda path, *other: PureWindowsPath(relative_to(path, *other)),
        )
        module.ToolchainBuildHook._include_artifacts(tmp_path, runtime, data)

    included_dir = tmp_path / "with-artifacts"
    included_dir.mkdir()
    with builder.config.set_build_data(data):
        included = builder.build_standard(str(included_dir), **data)
    with zipfile.ZipFile(included) as wheel:
        assert wheel.read("selene_toolchain/_native.pyd") == b"native extension"
        assert (
            wheel.read("selene_toolchain/_dist/bin/llvm-symbolizer.exe")
            == b"symbolizer"
        )
        assert (
            wheel.read("selene_toolchain/_dist/runtime/libgcc.a") == b"runtime archive"
        )
