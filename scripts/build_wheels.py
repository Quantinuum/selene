"""Build wheels with a Hugrenv path visible to isolated source builds."""

import os
import subprocess
from pathlib import Path


root = Path(__file__).resolve().parents[1]
hugrenv_path = Path(os.environ.get("HUGRENV_PATH") or root / ".hugrenv").expanduser()
if not hugrenv_path.is_absolute():
    hugrenv_path = root / hugrenv_path

env = os.environ.copy()
env["HUGRENV_PATH"] = str(hugrenv_path)
subprocess.run(["uv", "build", "--all-packages"], cwd=root, env=env, check=True)
