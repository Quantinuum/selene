"""Collect matching Linux runtime sources as separate release assets."""

import hashlib
import json
import os
import platform
import re
import shlex
import subprocess
from pathlib import Path


def collect_sources() -> None:
    root = Path(__file__).parent
    version_match = re.search(
        r'^version = "([^"]+)"$', (root / "pyproject.toml").read_text(), re.MULTILINE
    )
    if version_match is None:
        raise RuntimeError("Cannot read the toolchain release version")
    version = version_match.group(1)
    destination = root / "source-bundles"
    destination.mkdir(exist_ok=True)
    compiler = shlex.split(os.environ.get("CC", "gcc"))
    inputs = {}
    packages: dict[str, str] = {}
    for name in (
        "Scrt1.o",
        "crti.o",
        "crtbeginS.o",
        "crtendS.o",
        "crtn.o",
        "libgcc.a",
        "libgcc_eh.a",
        "libc_nonshared.a",
    ):
        path = Path(
            subprocess.check_output(
                [*compiler, f"-print-file-name={name}"], text=True
            ).strip()
        ).resolve()
        source_name, package = (
            subprocess.check_output(
                [
                    "rpm",
                    "-qf",
                    "--qf",
                    "%{SOURCERPM}\n%{NAME}-%{VERSION}-%{RELEASE}\n",
                    str(path),
                ],
                text=True,
            )
            .strip()
            .splitlines()
        )
        packages.setdefault(source_name, package)
        inputs[name] = {
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "source": source_name,
        }

    sources = {}
    release = f"https://github.com/Quantinuum/selene/releases/download/selene-toolchain-v{version}"
    for source_name, package in sorted(packages.items()):
        source = destination / source_name
        if not source.exists():
            subprocess.run(
                [
                    "dnf",
                    "download",
                    "--source",
                    "--enablerepo=baseos-source",
                    "--enablerepo=appstream-source",
                    f"--destdir={destination}",
                    package,
                ],
                check=True,
            )
        if not source.is_file():
            raise RuntimeError(
                f"The matching runtime source wasn't downloaded: {source_name}"
            )
        sources[source_name] = {
            "sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            "url": f"{release}/{source_name}",
        }
    # CI publishes these RPMs beside the wheels on GitHub. Only this small
    # manifest goes into the wheel, so users don't download the sources too.
    for previous in destination.glob("*.src.rpm"):
        if previous.name not in sources:
            previous.unlink()
    machine = platform.machine().lower()
    manifest = {
        "version": version,
        "machine": machine,
        "inputs": inputs,
        "sources": sources,
    }
    (destination / f"linux-{machine}.json").write_text(
        json.dumps(manifest, indent=2) + "\n"
    )


if __name__ == "__main__":
    collect_sources()
