#!/usr/bin/env python3
"""Print the shared API-model package version, or fail if versions differ."""

import json
import tomllib
from pathlib import Path


def main() -> None:
    package_directory = Path(__file__).resolve().parents[1]
    versions = {
        "Python": tomllib.loads((package_directory / "pyproject.toml").read_text())[
            "project"
        ]["version"],
        "Rust": tomllib.loads((package_directory / "rust/Cargo.toml").read_text())[
            "package"
        ]["version"],
        "TypeScript": json.loads(
            (package_directory / "typescript/package.json").read_text()
        )["version"],
    }
    if len(set(versions.values())) != 1:
        raise SystemExit(
            "API-model package versions must match; "
            + ", ".join(f"{name}={version}" for name, version in versions.items())
        )
    print(versions["Python"])


if __name__ == "__main__":
    main()
