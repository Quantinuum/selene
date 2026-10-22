import socket
import struct
from datetime import timedelta
from unittest.mock import Mock

import pytest

from selene_sim.exceptions import SeleneStartupError, SeleneTimeoutError
from selene_sim.result_handling.data_stream import TCPStream
from selene_sim.timeout import Timer, Timeout


@pytest.mark.parametrize("stop_time", [2.0, 10.0])
def test_timer_stop_and_reset(monkeypatch, stop_time):
    clock = Mock(return_value=0.0)
    monkeypatch.setattr("selene_sim.timeout.time.perf_counter", clock)
    timer = Timer(timedelta(seconds=5))

    # We can stop the timer before or after its deadline. Either way it should
    # no longer expire or limit a wait, even as more time passes.
    clock.return_value = stop_time
    timer.stop()
    clock.return_value = 20.0
    assert not timer.has_expired()
    assert timer.remaining() is None
    assert Timer.min_remaining_seconds([timer]) is None

    # Stopping shouldn't remove the configured duration. If we reset at 20
    # seconds, we should get a new five-second deadline.
    timer.reset()
    assert timer.remaining_seconds() == 5.0
    clock.return_value = 25.0
    assert timer.has_expired()


def test_result_timeout_does_not_report_completed_startup(monkeypatch):
    clock = Mock(return_value=0.0)
    monkeypatch.setattr("selene_sim.timeout.time.perf_counter", clock)
    timeout = Timeout(
        backend_startup=timedelta(seconds=5),
        per_shot=timedelta(seconds=10),
    )
    with TCPStream(timeout=timeout) as stream:
        with socket.create_connection((stream.host, stream.port)) as peer:
            peer.sendall(struct.pack("<QQQ", 0, 1, 1))
            stream._wait_for_current_shot_client()

            # The backend connected before its startup deadline, but the shot
            # hasn't sent any results. Once the shot times out, the old startup
            # deadline has also passed. We should only report the shot timer
            # because the connection wait finished and stopped its timer.
            clock.return_value = 10.0
            with pytest.raises(SeleneTimeoutError) as caught:
                stream.read_chunk(1)

    assert caught.value.message == (
        "Timed out waiting for shot results: Expired timers: 'per_shot'"
    )


def test_startup_timer_restarts_for_another_client(monkeypatch):
    clock = Mock(return_value=0.0)
    monkeypatch.setattr("selene_sim.timeout.time.perf_counter", clock)
    with TCPStream(timeout=Timeout(backend_startup=timedelta(seconds=5))) as stream:
        with socket.create_connection((stream.host, stream.port)) as peer:
            peer.sendall(struct.pack("<QQQ", 0, 2, 1))
            stream._wait_for_current_shot_client()
            assert stream.connect_timer.end_timestamp is None

            # This client only provides even-numbered shots. Shot 1 needs
            # another client, so we should start a fresh connection timer even
            # though we stopped it after the first connection succeeded.
            clock.return_value = 20.0
            stream.next_shot()

            def wait_for_deadline(timeout):
                assert timeout == 5.0
                clock.return_value = 25.0
                return False

            monkeypatch.setattr(stream, "_sync", wait_for_deadline)
            with pytest.raises(SeleneStartupError) as caught:
                stream.read_chunk(1)

    assert caught.value.message == (
        "Timed out waiting for a client to connect for shot 1: "
        "Expired timers: 'backend_startup'"
    )
