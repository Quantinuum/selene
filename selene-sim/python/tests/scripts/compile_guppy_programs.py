"""Regenerate guppy QIS/HUGR snapshots from inline test program declarations.

Usage:
    python -m pytest --regenerate-guppy-snapshots --collect-only selene-sim/python/tests
or:
    uv run selene-sim/python/tests/scripts/compile_guppy_programs.py
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> int:
    repo_root = Path(__file__).resolve().parents[4]
    tests_dir = repo_root / "selene-sim" / "python" / "tests"
    cmd = [
        sys.executable,
        "-m",
        "pytest",
        "--regenerate-guppy-snapshots",
        "--collect-only",
        str(tests_dir),
    ]
    return subprocess.run(cmd, cwd=repo_root, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
