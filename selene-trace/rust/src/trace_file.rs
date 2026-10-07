//! Incremental, gzipped JSON Lines transport for trace events.
//!
//! This framing is versioned separately from the event schema. Writers own no
//! paths: callers choose where to write and only publish a file after finish()
//! succeeds. Dropping a writer is not a substitute for checking finish().

use crate::trace::{EventRecord, SCHEMA_VERSION};
use flate2::{Compression, read::MultiGzDecoder, write::GzEncoder};
use serde::{Deserialize, Serialize};
use std::io::{self, BufRead, BufReader, BufWriter, Read, Write};

pub const FORMAT: &str = "selene.trace.jsonl";
pub const FORMAT_VERSION: u64 = 1;

/// Instruction distinctions which are not represented by the public trace
/// model. They belong to the file transport, not to its EventRecords.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum MeasurementOperation {
    FutureRead,
    MeasureLeakedRequest,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub struct TraceFileEvent {
    #[serde(flatten)]
    pub record: EventRecord,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub instruction: Option<MeasurementOperation>,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct BatchTiming {
    pub start_time: u64,
    pub end_time: u64,
}

/// A file record can carry an event or a batch boundary. TraceReader exposes
/// only the events, while TraceRecordReader also exposes instruction metadata.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum TraceRecord {
    Event(TraceFileEvent),
    BatchStart { batch_start: BatchTiming },
}

fn header() -> serde_json::Value {
    serde_json::json!({
        "format": FORMAT,
        "format_version": FORMAT_VERSION,
        "schema_version": SCHEMA_VERSION,
    })
}

fn invalid_data(error: impl std::fmt::Display) -> io::Error {
    io::Error::new(io::ErrorKind::InvalidData, error.to_string())
}

/// A buffered gzip writer. Appending events does not finish or flush gzip.
pub struct TraceWriter<W: Write> {
    writer: BufWriter<GzEncoder<W>>,
    header_written: bool,
    failed: bool,
}

impl<W: Write> TraceWriter<W> {
    /// Construct a writer without performing I/O. The header is written at the
    /// first append, or at finish for an empty trace.
    pub fn new(writer: W) -> Self {
        Self {
            writer: BufWriter::new(GzEncoder::new(writer, Compression::fast())),
            header_written: false,
            failed: false,
        }
    }

    /// Append a batch at a caller-selected checkpoint. After any error this
    /// writer is unusable, because an incomplete line may already be written.
    pub fn write_events(&mut self, events: &[EventRecord]) -> io::Result<()> {
        self.write_items(events)
    }

    /// Append file records, including optional instruction metadata.
    pub fn write_records(&mut self, records: &[TraceRecord]) -> io::Result<()> {
        self.write_items(records)
    }

    fn write_items<T: Serialize>(&mut self, events: &[T]) -> io::Result<()> {
        if self.failed {
            return Err(io::Error::other("Trace writer previously failed"));
        }
        self.failed = true;
        if !self.header_written {
            serde_json::to_writer(&mut self.writer, &header()).map_err(invalid_data)?;
            self.writer.write_all(b"\n")?;
            self.header_written = true;
        }
        for event in events {
            serde_json::to_writer(&mut self.writer, event).map_err(invalid_data)?;
            self.writer.write_all(b"\n")?;
        }
        self.failed = false;
        Ok(())
    }

    /// Finish gzip, flush the destination, and return it to its owner.
    pub fn finish(mut self) -> io::Result<W> {
        self.write_events(&[])?;
        let compressor = self
            .writer
            .into_inner()
            .map_err(|error| error.into_error())?;
        let mut output = compressor.finish()?;
        output.flush()?;
        Ok(output)
    }
}

/// A lazy file-record reader. Exhaust it to check the complete gzip stream, including
/// its checksum. An error includes line context and terminates iteration.
pub struct TraceRecordReader<R: Read> {
    reader: BufReader<MultiGzDecoder<R>>,
    line: String,
    line_number: usize,
    done: bool,
}

impl<R: Read> TraceRecordReader<R> {
    /// Read and validate the header, leaving events for iteration.
    pub fn new(reader: R) -> io::Result<Self> {
        let mut result = Self {
            reader: BufReader::new(MultiGzDecoder::new(reader)),
            line: String::new(),
            line_number: 0,
            done: false,
        };
        let header_result = (|| {
            result.read_line()?;
            let actual: serde_json::Value =
                serde_json::from_str(&result.line).map_err(invalid_data)?;
            if actual != header() {
                return Err(invalid_data(format!(
                    "Unsupported trace file header: {actual}"
                )));
            }
            Ok(())
        })();
        header_result.map_err(|error: io::Error| result.context(error))?;
        Ok(result)
    }

    fn context(&self, error: io::Error) -> io::Error {
        io::Error::new(
            error.kind(),
            format!("Trace file at line {}: {error}", self.line_number),
        )
    }

    fn read_line(&mut self) -> io::Result<usize> {
        self.line.clear();
        self.line_number += 1;
        let size = self.reader.read_line(&mut self.line)?;
        if size > 0 && !self.line.ends_with('\n') {
            return Err(invalid_data("Incomplete trace line"));
        }
        Ok(size)
    }
}

impl<R: Read> Iterator for TraceRecordReader<R> {
    type Item = io::Result<TraceRecord>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.done {
            return None;
        }
        let result = match self.read_line() {
            Ok(0) => {
                self.done = true;
                return None;
            }
            Ok(_) => serde_json::from_str(&self.line).map_err(invalid_data),
            Err(error) => Err(error),
        };
        if result.is_err() {
            self.done = true;
        }
        Some(result.map_err(|error| self.context(error)))
    }
}

/// Read the public trace events, excluding file-level instruction metadata.
pub struct TraceReader<R: Read>(TraceRecordReader<R>);

impl<R: Read> TraceReader<R> {
    pub fn new(reader: R) -> io::Result<Self> {
        Ok(Self(TraceRecordReader::new(reader)?))
    }
}

impl<R: Read> Iterator for TraceReader<R> {
    type Item = io::Result<EventRecord>;

    fn next(&mut self) -> Option<Self::Item> {
        loop {
            match self.0.next()? {
                Ok(TraceRecord::Event(event)) => return Some(Ok(event.record)),
                Ok(TraceRecord::BatchStart { .. }) => continue,
                Err(error) => return Some(Err(error)),
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::trace::{Event, GateParameter, Source};

    const EXAMPLE: &str = include_str!("../tests/fixtures/events.jsonl");

    fn compress(contents: &[u8]) -> Vec<u8> {
        let mut encoder = GzEncoder::new(Vec::new(), Compression::fast());
        encoder.write_all(contents).unwrap();
        encoder.finish().unwrap()
    }

    #[test]
    fn shared_example_and_checkpointed_writer_round_trip() {
        let data = compress(EXAMPLE.as_bytes());
        let events = TraceReader::new(data.as_slice())
            .unwrap()
            .collect::<io::Result<Vec<_>>>()
            .unwrap();
        assert_eq!(events.len(), 3);
        let mut writer = TraceWriter::new(Vec::new());
        for event in &events {
            writer.write_events(std::slice::from_ref(event)).unwrap();
        }
        let written = writer.finish().unwrap();
        let actual = TraceReader::new(written.as_slice())
            .unwrap()
            .collect::<io::Result<Vec<_>>>()
            .unwrap();
        assert_eq!(actual, events);
    }

    #[test]
    fn instruction_metadata_does_not_change_trace_events() {
        let event = EventRecord {
            source: Source::UserProgram { index: 0 },
            event: Event::Measurement { qubit: 3 },
        };
        // Even empty batches with identical times must remain distinguishable
        // in the instruction view, but neither boundary is a trace event.
        let boundary = TraceRecord::BatchStart {
            batch_start: BatchTiming {
                start_time: 0,
                end_time: 0,
            },
        };
        let records = vec![
            boundary.clone(),
            boundary,
            TraceRecord::Event(TraceFileEvent {
                record: event.clone(),
                instruction: Some(MeasurementOperation::FutureRead),
            }),
        ];
        let mut writer = TraceWriter::new(Vec::new());
        writer.write_records(&records).unwrap();
        let data = writer.finish().unwrap();
        assert_eq!(
            TraceRecordReader::new(data.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            records
        );
        assert_eq!(
            TraceReader::new(data.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            vec![event]
        );
    }

    #[test]
    fn empty_trace_still_has_a_valid_header() {
        let data = TraceWriter::new(Vec::new()).finish().unwrap();
        assert_eq!(TraceReader::new(data.as_slice()).unwrap().count(), 0);
    }

    #[test]
    fn unsupported_header_is_rejected() {
        for contents in [
            EXAMPLE.replace("\"format_version\":1", "\"format_version\":99"),
            EXAMPLE.replace("0.1.0", "99.0.0"),
            EXAMPLE.replace("selene.trace.jsonl", "something-else"),
        ] {
            let data = compress(contents.as_bytes());
            let error = TraceReader::new(data.as_slice()).err().unwrap();
            assert!(error.to_string().contains("line 1"));
        }
    }

    #[test]
    fn event_errors_are_lazy_and_terminate_iteration() {
        let mut lines = EXAMPLE.lines();
        let contents = format!(
            "{}\n{}\nnot json\n",
            lines.next().unwrap(),
            lines.next().unwrap()
        );
        let data = compress(contents.as_bytes());
        let mut reader = TraceReader::new(data.as_slice()).unwrap();
        assert!(reader.next().unwrap().is_ok());
        assert!(
            reader
                .next()
                .unwrap()
                .unwrap_err()
                .to_string()
                .contains("line 3")
        );
        assert!(reader.next().is_none());
    }

    #[test]
    fn incomplete_lines_and_gzip_are_rejected() {
        let missing_newline = compress(EXAMPLE.trim_end().as_bytes());
        let mut truncated = compress(EXAMPLE.as_bytes());
        truncated.truncate(truncated.len() - 8);
        let mut bad_checksum = compress(EXAMPLE.as_bytes());
        let checksum_index = bad_checksum.len() - 8;
        bad_checksum[checksum_index] ^= 1;
        for data in [missing_newline, truncated, bad_checksum] {
            assert!(
                TraceReader::new(data.as_slice())
                    .unwrap()
                    .collect::<io::Result<Vec<_>>>()
                    .is_err()
            );
        }
    }

    #[test]
    fn invalid_event_poisons_the_writer() {
        let event = EventRecord {
            source: Source::UserProgram { index: 0 },
            event: Event::Gate {
                qubits: vec![0],
                gate_name: "Rz".into(),
                params: vec![GateParameter::Float(f64::NAN)],
                predicates: vec![],
            },
        };
        let mut writer = TraceWriter::new(Vec::new());
        assert!(writer.write_events(&[event]).is_err());
        assert!(writer.write_events(&[]).is_err());
        assert!(writer.finish().is_err());
    }

    #[test]
    fn finish_reports_destination_errors() {
        struct Broken;
        impl Write for Broken {
            fn write(&mut self, _: &[u8]) -> io::Result<usize> {
                Err(io::Error::other("destination failed"))
            }
            fn flush(&mut self) -> io::Result<()> {
                Ok(())
            }
        }
        let mut writer = TraceWriter::new(Broken);
        writer.write_events(&[]).unwrap();
        assert!(writer.finish().is_err());
    }
}
