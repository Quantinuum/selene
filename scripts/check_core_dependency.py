#!/usr/bin/env python3
"""Check that selene-sim requires the current selene-core version."""

import re
import tomllib
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    core = tomllib.loads((root / "selene-core/pyproject.toml").read_text())
    sim = tomllib.loads((root / "pyproject.toml").read_text())
    expected = f"selene-core~={core['project']['version']}"
    requirements = [
        dependency
        for dependency in sim["project"]["dependencies"]
        if re.match(r"selene[-_.]+core\b", dependency, re.IGNORECASE)
    ]
    if requirements != [expected]:
        raise SystemExit(
            f"selene-sim must require {expected!r} to match "
            "selene-core/pyproject.toml; "
            f"found {requirements!r}. Update the dependency in pyproject.toml."
        )
    print(f"selene-sim requires {expected}")


if __name__ == "__main__":
    main()
