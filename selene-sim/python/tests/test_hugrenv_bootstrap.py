import io
import tarfile

import pytest

from scripts.bootstrap_hugrenv import safe_extract


def test_extract_keeps_archive_binary_links(tmp_path):
    archive = tmp_path / "hugrenv.tar.gz"
    with tarfile.open(archive, "w:gz") as tar:
        link = tarfile.TarInfo("hugrverse/bin/llvm-addr2line")
        link.type = tarfile.SYMTYPE
        link.linkname = "llvm-symbolizer"
        tar.addfile(link)

        binary = tarfile.TarInfo("hugrverse/bin/llvm-symbolizer")
        binary.size = 4
        tar.addfile(binary, io.BytesIO(b"tool"))

    destination = tmp_path / "install"
    destination.mkdir()
    safe_extract(archive, destination)

    assert (destination / "bin/llvm-addr2line").read_bytes() == b"tool"


def test_extract_rejects_links_outside_destination(tmp_path):
    archive = tmp_path / "hugrenv.tar.gz"
    with tarfile.open(archive, "w:gz") as tar:
        link = tarfile.TarInfo("hugrverse/bin/escape")
        link.type = tarfile.SYMTYPE
        link.linkname = "../../../escape"
        tar.addfile(link)

    destination = tmp_path / "install"
    destination.mkdir()
    with pytest.raises(RuntimeError, match="Archive link escapes destination"):
        safe_extract(archive, destination)
