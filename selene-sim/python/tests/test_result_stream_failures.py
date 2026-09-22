"""Reproduce failures that are hidden by unparsed exception serialisation."""

import errno
import socket
import struct
import sys
from pathlib import Path
from unittest.mock import Mock

import pytest

from selene_sim.exceptions import SeleneRuntimeError
from selene_sim.result_handling.data_stream import FileStream, TCPStream
from selene_sim.result_handling.extract_shot import extract_shot
from selene_sim.result_handling.parse_shot import (
    postprocess_unparsed_stream,
    unparsed_interface,
)
from selene_sim.result_handling.result_stream import ResultStream
from selene_sim.timeout import Timeout


def record_header(tag):
    encoded = tag.encode("utf-8")
    return struct.pack("<QHH", 0, ResultStream.STR_TAG, len(encoded)) + encoded


def shot_prefix():
    return (
        record_header("SELENE:SHOT_START")
        + struct.pack("<HHQHH", ResultStream.UINT_TAG, 0, 0, 0, 0)
        + record_header("USER:INT:answer")
        + struct.pack("<HH", ResultStream.INT_TAG, 0)
    )


def capture_unparsed_failure(stream, tmp_path):
    # We only stand in for process management. Reading, extracting, encoding and
    # postprocessing all use the real implementations, including the log files.
    process = Mock()
    process.stdout = tmp_path / "stdout"
    process.stderr = tmp_path / "stderr"
    process.stdout.write_text("")
    process.stderr.write_text("")
    caught = []

    def entries():
        try:
            yield from extract_shot(stream)
        except SeleneRuntimeError as error:
            caught.append(error)
            raise

    raw = unparsed_interface(entries(), stream, process)
    _, decoded = postprocess_unparsed_stream([raw])
    assert len(caught) == 1
    original = caught[0]
    assert isinstance(decoded, SeleneRuntimeError)
    assert decoded.message == original.message
    # The original cause is available on the parsing machine, but the caller's
    # reconstructed exception no longer contains it.
    assert decoded.__cause__ is None
    assert stream.tainted
    process.terminate.assert_called_once()
    return original


def buffer_prefix(transport, peer):
    peer.sendall(struct.pack("<QQQ", 0, 1, 1) + shot_prefix())
    transport._wait_for_current_shot_client()
    # Receive the header before closing the peer so the failure happens while
    # reading the integer value, rather than while reading the timestamp or tag.
    transport._wait_for_current_shot_bytes(len(shot_prefix()))


@pytest.mark.skipif(sys.platform != "linux", reason="Uses Linux SO_LINGER layout")
@pytest.mark.parametrize("reset", [False, True], ids=["orderly-eof", "tcp-reset"])
def test_disconnect_during_value(tmp_path, reset):
    with TCPStream(timeout=Timeout(overall=5.0)) as transport:
        with socket.create_connection((transport.host, transport.port)) as peer:
            buffer_prefix(transport, peer)
            if reset:
                # A zero linger timeout makes close send a real TCP reset. We
                # don't inject a Python exception into the reader.
                peer.setsockopt(
                    socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0)
                )
            peer.close()
            error = capture_unparsed_failure(ResultStream(transport), tmp_path)

    if reset:
        assert "Could not read from result client" in error.message
        assert "shot offset 0, increment 1, count 1" in error.message
        assert "ConnectionResetError" in error.message
        assert isinstance(error.__cause__, ConnectionResetError)
    else:
        assert error.message == "Parsing error: Unexpected end of stream"
        assert error.__cause__ is None


@pytest.mark.skipif(sys.platform != "linux", reason="Requires Linux /dev/full")
@pytest.mark.parametrize("buffering", [0, -1], ids=["write", "close"])
def test_result_log_failure(tmp_path, buffering):
    with TCPStream(timeout=Timeout(overall=5.0)) as transport:
        with socket.create_connection((transport.host, transport.port)) as peer:
            buffer_prefix(transport, peer)
            assert transport.current_shot_client is not None
            # /dev/full rejects writes with ENOSPC. With buffering enabled the
            # write succeeds, but closing the log when the peer disconnects
            # flushes those bytes and fails. Both should report the log failure.
            with Path("/dev/full").open("wb", buffering=buffering) as logfile:
                transport.current_shot_client.logfile_handle = logfile
                try:
                    peer.sendall(struct.pack("<qHH", 42, 0, 0))
                    peer.shutdown(socket.SHUT_WR)
                    error = capture_unparsed_failure(ResultStream(transport), tmp_path)
                finally:
                    transport.current_shot_client.logfile_handle = None

    operation = "write" if buffering == 0 else "close"
    assert f"Could not {operation} result log '/dev/full'" in error.message
    assert "shot offset 0, increment 1, count 1" in error.message
    assert "OSError" in error.message
    assert f"[Errno {errno.ENOSPC}]" in error.message
    assert isinstance(error.__cause__, OSError)
    assert error.__cause__.errno == errno.ENOSPC


def test_invalid_utf8_in_string_value(tmp_path):
    # This fixture deliberately contains a bad string, unlike the transport
    # cases above. Its length and record boundaries are otherwise correct.
    recording = tmp_path / "results.bin"
    recording.write_bytes(
        record_header("INSTRUCTIONLOG")
        + struct.pack("<HH", ResultStream.STR_TAG, 1)
        + b"\xff"
        + struct.pack("<HH", 0, 0)
    )
    transport = FileStream(recording)
    try:
        error = capture_unparsed_failure(ResultStream(transport), tmp_path)
    finally:
        transport.handle.close()
    assert (
        "Invalid UTF-8 in value 1 of record 'INSTRUCTIONLOG' (1 bytes)" in error.message
    )
    assert "UnicodeDecodeError" in error.message
    assert isinstance(error.__cause__, UnicodeDecodeError)


def test_result_log_open_failure(tmp_path):
    logfile = tmp_path / "missing-directory" / "results.log"
    with TCPStream(timeout=Timeout(overall=5.0), logfile=logfile) as transport:
        with socket.create_connection((transport.host, transport.port)) as peer:
            peer.sendall(struct.pack("<QQQ", 0, 1, 1) + shot_prefix())
            error = capture_unparsed_failure(ResultStream(transport), tmp_path)
        assert not transport.clients

    assert "Could not open result log" in error.message
    assert str(logfile.parent) in error.message
    assert "FileNotFoundError" in error.message
    assert isinstance(error.__cause__, FileNotFoundError)


@pytest.mark.skipif(sys.platform != "linux", reason="Uses Linux SO_LINGER layout")
def test_reset_identifies_another_worker(tmp_path):
    with TCPStream(timeout=Timeout(overall=5.0)) as transport:
        with socket.create_connection((transport.host, transport.port)) as current:
            buffer_prefix(transport, current)
            with socket.create_connection((transport.host, transport.port)) as other:
                other.sendall(struct.pack("<QQQ", 1, 2, 3))
                transport._accept_new_connection()
                other_address = other.getsockname()
                other.setsockopt(
                    socket.SOL_SOCKET, socket.SO_LINGER, struct.pack("ii", 1, 0)
                )
            # We're waiting for shot 0, but the reset belongs to the worker
            # providing shots 1, 3 and 5. Its identity must survive postprocessing.
            error = capture_unparsed_failure(ResultStream(transport), tmp_path)

    assert str(other_address) in error.message
    assert "shot offset 1, increment 2, count 3" in error.message
    assert "ConnectionResetError" in error.message
    assert isinstance(error.__cause__, ConnectionResetError)
