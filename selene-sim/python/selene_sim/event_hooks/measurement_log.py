from dataclasses import dataclass
from collections.abc import Iterator

from .event_hook import EventHook

"""
Provides MeasurementExtractor, a class which can be used to extract
a complete log of measurement results from the MEASUREMENTLOG tag emitted by Selene.
"""


@dataclass
class MeasLogEntry:
    is_meas_leaked: bool
    qbid: int
    result_value: int

    def __init__(self, it: Iterator):
        """
        Extract a single result from the Selene data stream.

        Results take the form:
        (is_meas_leaked: u64 | qbid: u64 | result_value: u64)
        """
        self.is_meas_leaked = bool(next(it))
        self.qbid = next(it)
        self.result_value = next(it)

    def __repr__(self):
        tag = "MEASLEAKED" if self.is_meas_leaked else "MEAS"
        return f"{tag}:INTARR:[{self.qbid}, {self.result_value}]"


class MeasurementExtractor(EventHook):
    log_entries: list[list[MeasLogEntry]]

    def __init__(self):
        self.log_entries = []

    def __iter__(self):
        return iter(self.log_entries)

    def __getitem__(self, index: int):
        return self.log_entries[index]

    def get_selene_flags(self) -> list[str]:
        """
        When given --provide-measurement-log, Selene will emit a
        MEASUREMENTLOG tag to the result stream, followed by a dump
        of the results of all measurements performed in program order.
        """
        return ["provide_measurement_log"]

    def try_invoke(self, tag: str, data: list) -> bool:
        if tag != "MEASUREMENTLOG":
            return False
        if (len(data) % 3) != 0:
            raise ValueError("Partial record in measurement result stream")

        it = iter(data)
        while True:
            try:
                self.log_entries[-1].append(MeasLogEntry(it))
            except StopIteration:
                break
        return True

    def on_new_shot(self):
        self.log_entries.append([])
