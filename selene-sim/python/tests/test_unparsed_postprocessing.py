"""Transported raw records can be processed independently of a running Selene."""

from unittest.mock import Mock
import struct

import pytest

from selene_sim.event_hooks import (
    CircuitExtractor,
    MeasurementExtractor,
    MetricStore,
    MultiEventHook,
)
from selene_sim.exceptions import SelenePanicError, SeleneRuntimeError
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


def instruction_log(path, values):
    tag = b"INSTRUCTIONLOG"
    record = struct.pack("<QHH", 0, 3, len(tag)) + tag
    record += b"".join(struct.pack("<HHQ", 1, 0, value) for value in values)
    record += struct.pack("<HHQ", 0, 0, 2**64 - 1)
    path.write_bytes(record)
    return str(path)


def test_instruction_log_reads_multiple_checkpoints_and_publications(tmp_path):
    first, second = tmp_path / "first.bin", tmp_path / "second.bin"
    instruction_log(first, [0, 1, 7])
    instruction_log(second, [0, 3, 7])
    # The backend appends a record after each runtime loop and writes just one
    # end marker when it publishes the file. We should read both checkpoints.
    first.write_bytes(first.read_bytes()[:-8] + second.read_bytes())
    extractor = CircuitExtractor()
    results, error = postprocess_unparsed_stream(
        [[("INSTRUCTIONLOG", [str(first)]), ("INSTRUCTIONLOG", [str(second)])]],
        extractor,
    )
    assert error is None
    assert results == [[]]
    assert extractor.shots[0].instructions == [0, 1, 7, 0, 3, 7, 0, 3, 7]
    first.unlink()
    second.unlink()
    assert len(list(extractor.shots[0])) == 3


@pytest.mark.parametrize(
    "damage", ["missing", "truncated", "no_end_marker", "wrong_tag", "trailing_data"]
)
def test_instruction_log_errors_name_the_file_without_adding_partial_data(
    tmp_path, damage
):
    path = tmp_path / "broken.bin"
    instruction_log(path, [0, 1, 7])
    data = path.read_bytes()
    if damage == "missing":
        path.unlink()
    elif damage == "truncated":
        # A complete first checkpoint must not hide an incomplete second one.
        path.write_bytes(data[:-8] + data[:20])
    elif damage == "no_end_marker":
        path.write_bytes(data[:-8])
    elif damage == "wrong_tag":
        path.write_bytes(data.replace(b"INSTRUCTIONLOG", b"NOT_A_LOG_FILE"))
    else:
        path.write_bytes(data + b"extra")
    extractor = CircuitExtractor()
    with pytest.raises(SeleneRuntimeError) as error:
        postprocess_unparsed_stream([[("INSTRUCTIONLOG", [str(path)])]], extractor)
    assert str(path) in str(error.value)
    assert extractor.shots[0].instructions == []


@pytest.mark.parametrize("payload", [[], [123], ["first.bin", "second.bin"]])
def test_instruction_log_requires_one_filename(payload):
    extractor = CircuitExtractor()
    extractor.on_new_shot()
    with pytest.raises(SeleneRuntimeError, match="single filename"):
        extractor.try_invoke("INSTRUCTIONLOG", payload)


def test_postprocessing_initializes_and_dispatches_hooks_per_shot(tmp_path):
    circuits, measurements, metrics = (
        CircuitExtractor(),
        MeasurementExtractor(),
        MetricStore(),
    )
    hook = MultiEventHook([circuits, measurements, metrics])
    shots = [
        [
            ("INSTRUCTIONLOG", [instruction_log(tmp_path / "first.bin", [0, 1, 7])]),
            ("MEASUREMENTLOG", [0, 3, 1]),
            ("METRICS:INT:count", [7]),
            ("USER:INTARR:values", [[2, 3]]),
        ],
        [
            ("INSTRUCTIONLOG", [instruction_log(tmp_path / "second.bin", [])]),
            ("USER:BOOL:result", [True]),
        ],
    ]
    results, error = postprocess_unparsed_stream(shots, hook)
    assert error is None
    assert results == [[("USER:INTARR:values", [2, 3])], [("USER:BOOL:result", True)]]
    assert [shot.instructions for shot in circuits.shots] == [[0, 1, 7], []]
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
    entries = [("INSTRUCTIONLOG", [instruction_log(tmp_path / "log.bin", [0, 1, 7])])]
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
    assert circuits.shots[0].instructions == [0, 1, 7]


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
