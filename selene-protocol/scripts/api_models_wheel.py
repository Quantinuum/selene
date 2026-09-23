#!/usr/bin/env python3
"""Install or verify the API-model wheel used by wheel integration tests."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from importlib.metadata import distribution
from pathlib import Path


def install(wheel_directory: Path) -> None:
    wheels = sorted(wheel_directory.glob("selene_api_models-*.whl"))
    if len(wheels) != 1:
        raise SystemExit(
            f"Expected exactly one selene-api-models wheel in {wheel_directory}, "
            f"found {len(wheels)}: {wheels}"
        )

    wheel = wheels[0].resolve()
    print(f"Installing API models from {wheel}")
    subprocess.run(
        [
            sys.executable,
            "-m",
            "pip",
            "install",
            "--force-reinstall",
            str(wheel),
        ],
        check=True,
    )


def verify(project_directory: Path) -> None:
    import selene_api_models

    package_file = selene_api_models.__file__
    if package_file is None:
        raise SystemExit("selene_api_models does not have a filesystem location")

    package_path = Path(package_file).resolve()
    project_path = project_directory.resolve()
    print(f"Using selene_api_models from {package_path}")
    if package_path == project_path or project_path in package_path.parents:
        raise SystemExit(
            "selene_api_models was imported from the source checkout instead of "
            f"the candidate wheel: {package_path}"
        )

    direct_url_text = distribution("selene-api-models").read_text("direct_url.json")
    if direct_url_text is None:
        raise SystemExit("selene-api-models has no direct_url.json installation record")
    direct_url = json.loads(direct_url_text).get("url", "")
    print(f"selene-api-models installation source: {direct_url}")
    if not direct_url.endswith(".whl"):
        raise SystemExit(
            "selene-api-models was not installed from the candidate wheel: "
            f"{direct_url}"
        )


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)

    install_parser = commands.add_parser("install")
    install_parser.add_argument("wheel_directory", type=Path)

    verify_parser = commands.add_parser("verify")
    verify_parser.add_argument("project_directory", type=Path)
    return parser.parse_args()


def main() -> None:
    arguments = parse_arguments()
    if arguments.command == "install":
        install(arguments.wheel_directory)
    else:
        verify(arguments.project_directory)


if __name__ == "__main__":
    main()
