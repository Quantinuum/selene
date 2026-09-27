import hashlib
import json
import os
import platform
import shutil
import tarfile
import tempfile
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCKFILE = ROOT / "hugrenv.lock"
DESTINATION = ROOT / ".hugrenv"


def detect_target() -> tuple[str, str, str]:
    system = platform.system()
    machine = platform.machine().lower()

    if system == "Linux":
        arch = {"x86_64": "x86_64", "amd64": "x86_64", "aarch64": "aarch64"}.get(machine)
        if arch is None:
            raise RuntimeError(f"Unsupported platform: {system} {platform.machine()}")
        return "manylinux_2_28", arch, f"manylinux_2_28_{arch}"

    if system == "Darwin":
        arch = {"x86_64": "x86_64", "arm64": "aarch64", "aarch64": "aarch64"}.get(
            machine
        )
        if arch is None:
            raise RuntimeError(f"Unsupported platform: {system} {platform.machine()}")
        return "macosx_11_0", arch, f"macosx_11_0_{arch}"

    if system == "Windows":
        arch = {"amd64": "amd64", "x86_64": "amd64"}.get(machine)
        if arch is None:
            raise RuntimeError(f"Unsupported platform: {system} {platform.machine()}")
        return "win", arch, f"win_{arch}"

    raise RuntimeError(f"Unsupported platform: {system} {platform.machine()}")


def expected_hash(lock_data: dict, target_platform: str, target_arch: str) -> str:
    try:
        return lock_data["archive_hashes"][target_platform][target_arch]["llvm"]
    except KeyError as exc:
        raise RuntimeError(
            f"No pinned Hugrenv archive hash found in {LOCKFILE.name} for "
            f"{target_platform}_{target_arch}"
        ) from exc


def compute_file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fileobj:
        for chunk in iter(lambda: fileobj.read(1024 * 1024), b""):
            digest.update(chunk)
    return f"sha256:{digest.hexdigest()}"


def download(url: str, destination: Path) -> None:
    with urllib.request.urlopen(url) as response, destination.open("wb") as fileobj:
        shutil.copyfileobj(response, fileobj)


def safe_extract(archive: Path, destination: Path) -> None:
    destination = destination.resolve()
    with tarfile.open(archive, "r:gz") as tar:
        members = [member for member in tar.getmembers() if member.name not in ("", ".")]
        top_level_names = {Path(member.name).parts[0] for member in members}
        if len(top_level_names) != 1:
            raise RuntimeError(
                "Unexpected Hugrenv archive layout: expected a single top-level directory"
            )
        top_level_name = top_level_names.pop()

        for member in members:
            member_parts = Path(member.name).parts
            if member_parts[0] != top_level_name:
                raise RuntimeError(
                    f"Unexpected Hugrenv archive member outside {top_level_name}: {member.name}"
                )
            stripped_parts = member_parts[1:]
            if not stripped_parts:
                continue
            member_path = (destination / Path(*stripped_parts)).resolve()
            if member_path != destination and destination not in member_path.parents:
                raise RuntimeError(f"Archive member escapes destination: {member.name}")
            if member.isdir():
                member_path.mkdir(parents=True, exist_ok=True)
                continue
            if not member.isreg():
                raise RuntimeError(
                    f"Unsupported archive member type for {member.name}: only regular files "
                    "and directories are allowed"
                )
            member_path.parent.mkdir(parents=True, exist_ok=True)
            source = tar.extractfile(member)
            if source is None:
                raise RuntimeError(f"Failed to read archive member: {member.name}")
            with source, member_path.open("wb") as fileobj:
                shutil.copyfileobj(source, fileobj)
            os.chmod(member_path, member.mode & 0o777)


def remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path)


def replace_destination(source: Path, destination: Path) -> None:
    backup = destination.parent / f"{destination.name}.backup"
    remove_path(backup)

    had_destination = destination.exists() or destination.is_symlink()
    if had_destination:
        destination.rename(backup)

    try:
        source.rename(destination)
    except Exception:
        if had_destination and (backup.exists() or backup.is_symlink()):
            backup.rename(destination)
        raise
    else:
        remove_path(backup)


def main() -> None:
    lock_data = json.loads(LOCKFILE.read_text())
    version = lock_data["version"]
    target_platform, target_arch, asset_target = detect_target()
    marker = f"{version}-{asset_target}"

    version_file = DESTINATION / ".version"
    if DESTINATION.is_dir() and version_file.is_file():
        installed_version = version_file.read_text().strip()
        if installed_version == marker:
            print(f"Hugrenv {version} ({asset_target}) is already installed in .hugrenv")
            return

    url = (
        "https://github.com/Quantinuum/hugrverse-env/releases/download/"
        f"v{version}/hugrenv-llvm-{asset_target}.tar.gz"
    )
    expected = expected_hash(lock_data, target_platform, target_arch)
    print(f"Downloading {url}")

    with tempfile.TemporaryDirectory(dir=ROOT, prefix=".hugrenv-download-") as tmp_dir:
        tmp_path = Path(tmp_dir)
        archive = tmp_path / "hugrenv-llvm.tar.gz"
        extract_dir = tmp_path / "extract"
        download(url, archive)
        actual = compute_file_hash(archive)
        if actual != expected:
            raise RuntimeError(
                f"Downloaded Hugrenv hash mismatch: expected {expected}, got {actual}"
            )
        extract_dir.mkdir()
        safe_extract(archive, extract_dir)
        (extract_dir / ".version").write_text(marker)

        replace_destination(extract_dir, DESTINATION)

    print(f"Installed Hugrenv {version} ({asset_target}) into .hugrenv")


if __name__ == "__main__":
    main()
