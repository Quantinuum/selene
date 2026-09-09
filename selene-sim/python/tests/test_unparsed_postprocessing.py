"""Transported raw records can be processed independently of a running Selene."""

from unittest.mock import Mock

import pytest

from selene_sim.event_hooks import (
    CircuitExtractor,
    MeasurementExtractor,
    MetricStore,
    MultiEventHook,
)
from selene_sim.exceptions import SelenePanicError
from selene_sim.result_handling.exception_encoding import encode_exception
from selene_sim.result_handling.extract_shot import (
    InstructionLogEntry,
    ShotMeasurements,
    UserStateResult,
    UserResult,
    MetricValue,
    ShotExitMessage,
)
from selene_sim.result_handling.parse_shot import (
    postprocess_unparsed_stream,
    unparsed_interface,
    parsed_interface,
)


def test_raw_payloads_survive_extraction():
    entries = [
        InstructionLogEntry(tag="INSTRUCTIONLOG", values=[1, "source", b"data", [2]]),
        ShotMeasurements(tag="MEASUREMENTLOG", values=[0, 3, 1]),
        UserStateResult(tag="STATE:state", path="state.json"),
    ]
    stream, process = Mock(), Mock()
    assert list(unparsed_interface(iter(entries), stream, process)) == [
        ("INSTRUCTIONLOG", [1, "source", b"data", [2]]),
        ("MEASUREMENTLOG", [0, 3, 1]),
        ("STATE:state", ["state.json"]),
    ]
    stream.taint.assert_not_called()
    process.terminate.assert_not_called()


def test_postprocessing_initializes_and_dispatches_hooks_per_shot():
    circuits, measurements, metrics = (
        CircuitExtractor(),
        MeasurementExtractor(),
        MetricStore(),
    )
    hook = MultiEventHook([circuits, measurements, metrics])
    shots = [
        [
            ("INSTRUCTIONLOG", ["source", b"data"]),
            ("MEASUREMENTLOG", [0, 3, 1]),
            ("METRICS:INT:count", [7]),
            ("USER:INTARR:values", [[2, 3]]),
        ],
        [("INSTRUCTIONLOG", []), ("USER:BOOL:result", [True])],
    ]
    results, error = postprocess_unparsed_stream(shots, hook)
    assert error is None
    assert results == [[("USER:INTARR:values", [2, 3])], [("USER:BOOL:result", True)]]
    assert [shot.instructions for shot in circuits.shots] == [["source", b"data"], []]
    assert len(measurements.log_entries) == 2
    assert measurements[0][0].qbid == 3
    assert measurements[0][0].result_value == 1
    assert measurements[1] == []
    assert metrics.shots == [{"DEFAULT": {"count": 7}}, {}]


def test_postprocessing_filters_unsupported_values_without_hooks():
    shots = [
        [
            ("USER:INTARR:values", [[1, 2]]),
            ("METRICS:INT:count", [7]),
            ("STATE:state", ["state.json"]),
            ("INSTRUCTIONLOG", ["source", b"data", [1]]),
            ("BYTES", [b"data"]),
        ]
    ]
    assert postprocess_unparsed_stream(shots) == (
        [[("USER:INTARR:values", [1, 2]), ("METRICS:INT:count", 7)]],
        None,
    )


def test_postprocessing_preserves_logs_before_panic(tmp_path):
    stdout, stderr = tmp_path / "stdout", tmp_path / "stderr"
    stdout.write_text("")
    stderr.write_text("")
    entries = [("INSTRUCTIONLOG", ["source", b"data"])]
    entries.extend(
        (tag, [value])
        for tag, value in encode_exception(
            SelenePanicError("failed", 1001), stdout, stderr
        )
    )
    circuits = CircuitExtractor()
    results, error = postprocess_unparsed_stream([entries], circuits)
    assert isinstance(error, SelenePanicError)
    assert results == [[("EXIT:INT:failed", 1001)]]
    assert circuits.shots[0].instructions == ["source", b"data"]


@pytest.mark.parametrize(
    "value", [0, -1, 1.25, False, True, [], [1], [1, 2], [False, True]]
)
def test_result_contracts_are_preserved(value):
    # The parsed route strips prefixes; the postprocessed route retains them.
    # Array values, including empty and singleton arrays, must not be flattened.
    entry = UserResult(tag="USER:VALUE:result", value=value)
    parsed = list(parsed_interface([entry], Mock(), Mock(), Mock()))
    assert parsed == [("result", value)]
    raw = unparsed_interface(iter([entry]), Mock(), Mock())
    assert postprocess_unparsed_stream([raw]) == ([[(entry.tag, value)]], None)


def test_postprocessing_retains_metrics_exits_and_empty_shots():
    shots = [
        [],
        [
            MetricValue(name="METRICS:INT:count", value=7),
            ShotExitMessage(message="EXIT:INT:finished", code=42),
        ],
        [],
    ]
    raw_shots = (unparsed_interface(iter(shot), Mock(), Mock()) for shot in shots)
    assert postprocess_unparsed_stream(raw_shots) == (
        [[], [("METRICS:INT:count", 7), ("EXIT:INT:finished", 42)], []],
        None,
    )


def test_custom_hook_receives_arrays_as_single_arguments():
    hook = Mock()
    hook.try_invoke.return_value = False
    raw = unparsed_interface(
        iter([UserResult(tag="USER:INTARR:array", value=[1, 2])]), Mock(), Mock()
    )
    assert postprocess_unparsed_stream([raw], hook) == (
        [[("USER:INTARR:array", [1, 2])]],
        None,
    )
    hook.on_new_shot.assert_called_once_with()
    hook.try_invoke.assert_called_once_with("USER:INTARR:array", [[1, 2]])
