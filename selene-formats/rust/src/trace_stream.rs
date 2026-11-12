//! Gzipped MessagePack trace streams, independent of the JSON document format.
//!
//! Objects are consecutive MessagePack maps: a versioned header, then records.
//! A final nil marks successful completion. Call finish() before publishing the
//! destination, and exhaust readers to check that marker and the gzip checksum.

use crate::trace::{
    CustomPayload, Event, EventRecord, GateParameter, MAX_SAFE_INTEGER, SCHEMA_VERSION, Source,
};
use base64::{Engine as _, engine::general_purpose::URL_SAFE};
use flate2::{Compression, read::MultiGzDecoder, write::GzEncoder};
use serde::{Deserialize, Serialize};
use std::io::{self, BufRead, BufReader, BufWriter, Read, Write};

pub const FORMAT: &str = "selene.trace.msgpack";
pub const FORMAT_VERSION: u64 = 1;

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum MeasurementOperation {
    FutureRead,
    MeasureLeakedRequest,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub struct TraceStreamEvent {
    #[serde(flatten)]
    pub record: EventRecord,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub instruction: Option<MeasurementOperation>,
}

#[derive(Clone, Debug, Deserialize, PartialEq)]
#[serde(try_from = "BatchTimingFields")]
pub struct BatchTiming {
    pub start_time: u64,
    pub end_time: u64,
}

#[derive(Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct BatchTimingFields {
    start_time: u64,
    end_time: u64,
}

impl TryFrom<BatchTimingFields> for BatchTiming {
    type Error = &'static str;
    fn try_from(value: BatchTimingFields) -> Result<Self, Self::Error> {
        if value.end_time < value.start_time {
            return Err("Batch end_time must be greater than or equal to start_time");
        }
        Ok(Self {
            start_time: value.start_time,
            end_time: value.end_time,
        })
    }
}

impl Serialize for BatchTiming {
    fn serialize<S: serde::Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        if self.end_time < self.start_time {
            return Err(serde::ser::Error::custom(
                "Batch end_time must be greater than or equal to start_time",
            ));
        }
        BatchTimingFields {
            start_time: self.start_time,
            end_time: self.end_time,
        }
        .serialize(serializer)
    }
}

/// Boundaries are stream metadata, not extra events in the public trace.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum TraceStreamRecord {
    Event(TraceStreamEvent),
    BatchStart { batch_start: BatchTiming },
    UIntInstruction(UIntInstructionRecord),
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum UIntInstruction {
    GlobalBarrier,
    LocalBarrier,
    ClassicalDelay,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct UIntInstructionRecord {
    pub source: Source,
    pub uint_instruction: UIntInstruction,
    pub value: u64,
    pub qubits: Vec<u64>,
}

impl UIntInstructionRecord {
    pub fn as_event(&self) -> io::Result<EventRecord> {
        if self.value > MAX_SAFE_INTEGER {
            return Err(invalid(format!(
                "{:?} operand {} cannot be represented in trace schema {SCHEMA_VERSION}; use the instruction records instead",
                self.uint_instruction, self.value
            )));
        }
        if let Some(qubit) = self.qubits.iter().find(|&&qubit| qubit > MAX_SAFE_INTEGER) {
            return Err(invalid(format!(
                "{:?} qubit ID {qubit} cannot be represented in trace schema {SCHEMA_VERSION}; use the instruction records instead",
                self.uint_instruction
            )));
        }
        Ok(EventRecord {
            source: self.source.clone(),
            event: Event::Gate {
                gate_name: format!("{:?}", self.uint_instruction),
                qubits: self.qubits.clone(),
                params: vec![GateParameter::Integer(self.value as i64)],
                predicates: vec![],
            },
        })
    }
}

// The public models keep their normal serde representation. These wrappers
// change only the stream's opaque payloads, so other binary users can still
// round-trip EventRecord through its derived Deserialize implementation.
struct StreamEvent<'a>(&'a Event);
impl Serialize for StreamEvent<'_> {
    fn serialize<S: serde::Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        use serde::ser::SerializeStruct;
        if let Event::Custom {
            payload: CustomPayload::OpaquePayload { tag, data },
        } = self.0
        {
            struct Bytes<'a>(&'a [u8]);
            impl Serialize for Bytes<'_> {
                fn serialize<S: serde::Serializer>(
                    &self,
                    serializer: S,
                ) -> Result<S::Ok, S::Error> {
                    serializer.serialize_bytes(self.0)
                }
            }
            #[derive(Serialize)]
            struct Payload<'a> {
                kind: &'static str,
                tag: u64,
                data: Bytes<'a>,
            }
            let mut event = serializer.serialize_struct("Event", 2)?;
            event.serialize_field("kind", "Custom")?;
            event.serialize_field(
                "payload",
                &Payload {
                    kind: "OpaquePayload",
                    tag: *tag,
                    data: Bytes(data),
                },
            )?;
            event.end()
        } else {
            self.0.serialize(serializer)
        }
    }
}

#[derive(Serialize)]
struct StreamEventRecord<'a> {
    source: &'a Source,
    event: StreamEvent<'a>,
    #[serde(skip_serializing_if = "Option::is_none")]
    instruction: Option<&'a MeasurementOperation>,
}

struct StreamRecord<'a>(&'a TraceStreamRecord);
impl Serialize for StreamRecord<'_> {
    fn serialize<S: serde::Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        match self.0 {
            TraceStreamRecord::Event(event) => StreamEventRecord {
                source: &event.record.source,
                event: StreamEvent(&event.record.event),
                instruction: event.instruction.as_ref(),
            }
            .serialize(serializer),
            record => record.serialize(serializer),
        }
    }
}

fn header() -> serde_json::Value {
    serde_json::json!({"format": FORMAT, "format_version": FORMAT_VERSION, "schema_version": SCHEMA_VERSION})
}

fn invalid(error: impl std::fmt::Display) -> io::Error {
    io::Error::new(io::ErrorKind::InvalidData, error.to_string())
}

pub struct TraceStreamWriter<W: Write> {
    writer: BufWriter<GzEncoder<W>>,
    header_written: bool,
    shot: Option<u64>,
    failed: bool,
}

impl<W: Write> TraceStreamWriter<W> {
    pub fn new(writer: W) -> Self {
        Self {
            writer: BufWriter::new(GzEncoder::new(writer, Compression::fast())),
            header_written: false,
            shot: None,
            failed: false,
        }
    }

    /// Create a stream whose header identifies the emulation shot.
    pub fn with_shot(writer: W, shot: u64) -> Self {
        Self {
            shot: Some(shot),
            ..Self::new(writer)
        }
    }

    pub fn write_events(&mut self, events: &[EventRecord]) -> io::Result<()> {
        self.write_items(events.iter().map(|record| StreamEventRecord {
            source: &record.source,
            event: StreamEvent(&record.event),
            instruction: None,
        }))
    }

    pub fn write_records(&mut self, records: &[TraceStreamRecord]) -> io::Result<()> {
        self.write_items(records.iter().map(StreamRecord))
    }

    fn write_items<T: Serialize>(
        &mut self,
        records: impl IntoIterator<Item = T>,
    ) -> io::Result<()> {
        if self.failed {
            return Err(invalid("Trace stream writer previously failed"));
        }
        // A failed append may already have written part of a record, so even
        // a caller that ignores the error mustn't be able to finish this stream.
        self.failed = true;
        if !self.header_written {
            let mut metadata = header();
            if let Some(shot) = self.shot {
                metadata["shot"] = shot.into();
            }
            rmp_serde::encode::write_named(&mut self.writer, &metadata).map_err(invalid)?;
            self.header_written = true;
        }
        for record in records {
            rmp_serde::encode::write_named(&mut self.writer, &record).map_err(invalid)?;
        }
        self.failed = false;
        Ok(())
    }

    pub fn finish(mut self) -> io::Result<W> {
        self.write_events(&[])?;
        self.writer.write_all(&[0xc0])?;
        let compressor = self
            .writer
            .into_inner()
            .map_err(|error| error.into_error())?;
        let mut output = compressor.finish()?;
        output.flush()?;
        Ok(output)
    }
}

/// Convert a decoded MessagePack value to the existing model's validation input.
/// Serde's internally tagged enums buffer fields without preserving the binary
/// deserializer's is_human_readable flag. Adapt the two JSON-specific fields here
/// rather than relaxing their validation for ordinary JSON documents. No JSON
/// text is produced or parsed in this path.
fn record_value(mut value: rmpv::Value) -> io::Result<serde_json::Value> {
    use rmpv::Value as V;
    fn field<'a>(fields: &'a mut [(V, V)], name: &str) -> Option<&'a mut V> {
        fields
            .iter_mut()
            .find(|(key, _)| key.as_str() == Some(name))
            .map(|(_, value)| value)
    }
    if let V::Map(fields) = &mut value
        && let Some(V::Map(event)) = field(fields, "event")
        && field(event, "kind").and_then(|value| value.as_str()) == Some("Custom")
        && let Some(V::Map(payload)) = field(event, "payload")
        && field(payload, "kind").and_then(|value| value.as_str()) == Some("OpaquePayload")
    {
        for (key, value) in payload {
            match key.as_str() {
                Some("tag") => {
                    let tag = value
                        .as_u64()
                        .ok_or_else(|| invalid("OpaquePayload.tag must be uint64"))?;
                    *value = format!("0x{tag:X}").into();
                }
                Some("data") => {
                    let V::Binary(bytes) = value else {
                        return Err(invalid("OpaquePayload.data must be binary"));
                    };
                    *value = URL_SAFE.encode(bytes).into();
                }
                _ => {}
            }
        }
    }
    model_value(value)
}

fn model_value(value: rmpv::Value) -> io::Result<serde_json::Value> {
    use rmpv::Value as V;
    Ok(match value {
        V::Nil => serde_json::Value::Null,
        V::Boolean(value) => value.into(),
        V::Integer(value) => match value.as_u64() {
            Some(value) => value.into(),
            None => value.as_i64().unwrap().into(),
        },
        V::F32(value) => serde_json::Number::from_f64(value.into())
            .ok_or_else(|| invalid("Non-finite float"))?
            .into(),
        V::F64(value) => serde_json::Number::from_f64(value)
            .ok_or_else(|| invalid("Non-finite float"))?
            .into(),
        V::String(value) => value
            .into_str()
            .ok_or_else(|| invalid("Invalid UTF-8"))?
            .into(),
        V::Array(values) => values
            .into_iter()
            .map(model_value)
            .collect::<io::Result<Vec<_>>>()?
            .into(),
        V::Map(fields) => {
            let mut map = serde_json::Map::new();
            for (key, value) in fields {
                let key = key
                    .as_str()
                    .ok_or_else(|| invalid("Expected a string map key"))?
                    .to_owned();
                if map.insert(key, model_value(value)?).is_some() {
                    return Err(invalid("Duplicate map key"));
                }
            }
            map.into()
        }
        V::Binary(_) | V::Ext(_, _) => return Err(invalid("Unexpected binary or extension value")),
    })
}

pub struct TraceStreamRecordReader<R: Read> {
    reader: BufReader<MultiGzDecoder<R>>,
    record_number: usize,
    done: bool,
    previous_schema: bool,
    shot: Option<u64>,
}

impl<R: Read> TraceStreamRecordReader<R> {
    pub fn new(reader: R) -> io::Result<Self> {
        let mut result = Self {
            reader: BufReader::new(MultiGzDecoder::new(reader)),
            record_number: 0,
            done: false,
            previous_schema: false,
            shot: None,
        };
        let value = rmpv::decode::read_value(&mut result.reader)
            .map_err(|error| invalid(format!("Trace stream header: {error}")))?;
        let mut actual = model_value(value)?;
        if let Some(number) = actual.as_object_mut().and_then(|map| map.remove("shot")) {
            result.shot = Some(
                number
                    .as_u64()
                    .ok_or_else(|| invalid("Invalid shot in trace stream header"))?,
            );
        }
        let mut previous = header();
        previous["schema_version"] = "0.1.0".into();
        if actual != header() && actual != previous {
            return Err(invalid("Unsupported trace stream header"));
        }
        result.previous_schema = actual == previous;
        Ok(result)
    }

    pub fn shot(&self) -> Option<u64> {
        self.shot
    }
}

impl<R: Read> Iterator for TraceStreamRecordReader<R> {
    type Item = io::Result<TraceStreamRecord>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.done {
            return None;
        }
        self.record_number += 1;
        let result = (|| {
            let value = rmpv::decode::read_value(&mut self.reader).map_err(invalid)?;
            if value.is_nil() {
                if !self.reader.fill_buf()?.is_empty() {
                    return Err(invalid("Data after trace stream end marker"));
                }
                return Ok(None);
            }
            let record: TraceStreamRecord =
                serde_json::from_value(record_value(value)?).map_err(invalid)?;
            if self.previous_schema
                && matches!(&record, TraceStreamRecord::Event(event) if matches!(event.record.event, Event::FutureRead { .. } | Event::FutureResult { .. }))
            {
                return Err(invalid(
                    "FutureRead and FutureResult require trace schema 0.2.0",
                ));
            }
            Ok(Some(record))
        })();
        match result {
            Ok(Some(record)) => Some(Ok(record)),
            Ok(None) => {
                self.done = true;
                None
            }
            Err(error) => {
                self.done = true;
                Some(Err(invalid(format!(
                    "Trace stream record {}: {error}",
                    self.record_number
                ))))
            }
        }
    }
}

pub struct TraceStreamReader<R: Read>(TraceStreamRecordReader<R>);

impl<R: Read> TraceStreamReader<R> {
    pub fn new(reader: R) -> io::Result<Self> {
        Ok(Self(TraceStreamRecordReader::new(reader)?))
    }

    pub fn shot(&self) -> Option<u64> {
        self.0.shot()
    }
}

impl<R: Read> Iterator for TraceStreamReader<R> {
    type Item = io::Result<EventRecord>;
    fn next(&mut self) -> Option<Self::Item> {
        loop {
            match self.0.next()? {
                Ok(TraceStreamRecord::Event(event)) => return Some(Ok(event.record)),
                Ok(TraceStreamRecord::BatchStart { .. }) => continue,
                Ok(TraceStreamRecord::UIntInstruction(record)) => return Some(record.as_event()),
                Err(error) => return Some(Err(error)),
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::trace::{CustomPayload, Event, GateParameter, Source};

    #[test]
    fn non_measurement_future_results_round_trip() {
        let outcome = crate::trace::FutureResultValue::try_from(
            serde_json::json!({"ready": true, "values": [7, null, 0.5]}),
        )
        .unwrap();
        let records = vec![
            EventRecord {
                source: Source::UserProgram { index: 0 },
                event: Event::FutureRead { result_id: 123 },
            },
            EventRecord {
                source: Source::Runtime {
                    start_time: 0,
                    end_time: 0,
                },
                event: Event::FutureResult {
                    result_id: 123,
                    outcome,
                },
            },
        ];
        let mut writer = TraceStreamWriter::new(Vec::new());
        writer.write_events(&records).unwrap();
        let data = writer.finish().unwrap();
        assert_eq!(
            TraceStreamReader::new(data.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            records
        );
    }

    #[test]
    fn string_future_result_values_round_trip_in_streams() {
        for outcome in [
            serde_json::json!("text"),
            serde_json::json!(["text"]),
            serde_json::json!({"nested": "text"}),
        ] {
            let record = serde_json::json!({"source": {"kind": "Runtime", "start_time": 0, "end_time": 0}, "event": {"kind": "FutureResult", "result_id": 42, "outcome": outcome}});
            let mut bytes = rmp_serde::to_vec_named(&header()).unwrap();
            bytes.extend(rmp_serde::to_vec_named(&record).unwrap());
            bytes.push(0xc0);
            let data = compress(&bytes);
            let records = TraceStreamReader::new(data.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap();
            assert_eq!(serde_json::to_value(&records[0]).unwrap(), record);
            let mut writer = TraceStreamWriter::new(Vec::new());
            writer.write_events(&records).unwrap();
            let written = writer.finish().unwrap();
            assert_eq!(
                TraceStreamReader::new(written.as_slice())
                    .unwrap()
                    .collect::<io::Result<Vec<_>>>()
                    .unwrap(),
                records
            );
        }
    }

    #[test]
    fn structured_future_result_values_round_trip() {
        for outcome in [
            serde_json::json!({"kind": 1, "tag": 42, "data": [true, null]}),
            serde_json::json!({"nested": {"kind": 1, "tag": 42, "data": [true, null]}}),
            serde_json::json!([true, null, {"value": 0.25}]),
            serde_json::json!({"__proto__": {"x": 1}, "constructor": true}),
        ] {
            let events = vec![
                EventRecord {
                    source: Source::Runtime {
                        start_time: 0,
                        end_time: 1,
                    },
                    event: Event::Measurement {
                        qubit: 3,
                        result_id: Some(42),
                        measurement_type: crate::trace::MeasurementType::Other(
                            "com.example/Custom".into(),
                        ),
                    },
                },
                EventRecord {
                    source: Source::Runtime {
                        start_time: 1,
                        end_time: 1,
                    },
                    event: Event::FutureResult {
                        result_id: 42,
                        outcome: outcome.try_into().unwrap(),
                    },
                },
            ];
            let mut writer = TraceStreamWriter::new(Vec::new());
            writer.write_events(&events).unwrap();
            let data = writer.finish().unwrap();
            assert_eq!(
                TraceStreamReader::new(data.as_slice())
                    .unwrap()
                    .collect::<io::Result<Vec<_>>>()
                    .unwrap(),
                events
            );
        }
    }

    #[test]
    fn previous_schema_reads_measurements_but_rejects_future_events() {
        for kind in ["Measurement", "FutureRead", "FutureResult"] {
            let mut previous = header();
            previous["schema_version"] = "0.1.0".into();
            let event = match kind {
                "FutureRead" => serde_json::json!({"kind": kind, "result_id": 42}),
                "FutureResult" => serde_json::json!({"kind": kind, "result_id": 42, "outcome": 0}),
                _ => serde_json::json!({"kind": kind, "qubit": 3}),
            };
            let record = serde_json::json!({"source": {"kind": "Runtime", "start_time": 0, "end_time": 0}, "event": event});
            let mut bytes = rmp_serde::to_vec_named(&previous).unwrap();
            bytes.extend(rmp_serde::to_vec_named(&record).unwrap());
            bytes.push(0xc0);
            let data = compress(&bytes);
            let records = TraceStreamReader::new(data.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>();
            assert_eq!(records.is_err(), kind != "Measurement");
        }
    }

    #[test]
    fn event_reader_rejects_unsafe_instruction_qubits() {
        for qubit in [MAX_SAFE_INTEGER, MAX_SAFE_INTEGER + 1, u64::MAX] {
            let record = UIntInstructionRecord {
                source: Source::UserProgram { index: 0 },
                uint_instruction: UIntInstruction::LocalBarrier,
                value: 0,
                qubits: vec![0, qubit],
            };
            let mut writer = TraceStreamWriter::new(Vec::new());
            writer
                .write_records(&[TraceStreamRecord::UIntInstruction(record.clone())])
                .unwrap();
            let bytes = writer.finish().unwrap();
            // The instruction stream supports uint64 qubit IDs, but its public
            // event view must reject IDs outside the JSON schema's safe range.
            let decoded = TraceStreamRecordReader::new(bytes.as_slice())
                .unwrap()
                .next()
                .unwrap()
                .unwrap();
            assert_eq!(decoded, TraceStreamRecord::UIntInstruction(record));
            let event = TraceStreamReader::new(bytes.as_slice())
                .unwrap()
                .next()
                .unwrap();
            if qubit <= MAX_SAFE_INTEGER {
                assert!(event.is_ok());
            } else {
                assert!(
                    event
                        .unwrap_err()
                        .to_string()
                        .contains(&format!("qubit ID {qubit}"))
                );
            }
        }
    }

    #[test]
    fn batch_timings_require_ordered_boundaries() {
        for (start, end) in [(0, 0), (1, 1), (0, u64::MAX)] {
            let value = serde_json::json!({"start_time": start, "end_time": end});
            assert!(serde_json::from_value::<BatchTiming>(value).is_ok());
        }
        let value = serde_json::json!({"start_time": 2, "end_time": 1});
        assert!(serde_json::from_value::<BatchTiming>(value.clone()).is_err());
        let mut bytes = rmp_serde::to_vec_named(&header()).unwrap();
        bytes.extend(rmp_serde::to_vec_named(&serde_json::json!({"batch_start": value})).unwrap());
        bytes.push(0xc0);
        let data = compress(&bytes);
        assert!(
            TraceStreamRecordReader::new(data.as_slice())
                .unwrap()
                .next()
                .unwrap()
                .is_err()
        );
        let record = TraceStreamRecord::BatchStart {
            batch_start: BatchTiming {
                start_time: 2,
                end_time: 1,
            },
        };
        let mut writer = TraceStreamWriter::new(Vec::new());
        assert!(writer.write_records(&[record]).is_err());
        assert!(writer.finish().is_err());
    }

    #[test]
    fn public_events_round_trip_without_the_stream_codec() {
        // The stream has its own encoding, but serialising the public model
        // directly must still produce something its Deserialize can read.
        let record = event();
        for bytes in [
            rmp_serde::to_vec(&record).unwrap(),
            rmp_serde::to_vec_named(&record).unwrap(),
        ] {
            let decoded: EventRecord = rmp_serde::from_slice(&bytes).unwrap();
            assert_eq!(decoded, record);
        }
        let json = serde_json::to_value(&record).unwrap();
        assert_eq!(json["event"]["payload"]["tag"], "0xFFFFFFFFFFFFFFFF");
        assert_eq!(json["event"]["payload"]["data"], "AP8=");
    }

    fn fixture() -> Vec<u8> {
        include_str!("../tests/fixtures/trace-stream.msgpack.hex")
            .trim()
            .as_bytes()
            .chunks_exact(2)
            .map(|pair| u8::from_str_radix(std::str::from_utf8(pair).unwrap(), 16).unwrap())
            .collect()
    }

    fn compress(bytes: &[u8]) -> Vec<u8> {
        let mut output = GzEncoder::new(Vec::new(), Compression::fast());
        output.write_all(bytes).unwrap();
        output.finish().unwrap()
    }

    fn event() -> EventRecord {
        EventRecord {
            source: Source::UserProgram { index: 0 },
            event: Event::Custom {
                payload: CustomPayload::OpaquePayload {
                    tag: u64::MAX,
                    data: vec![0, 255],
                },
            },
        }
    }

    #[test]
    fn shared_fixture_is_identical_in_both_languages() {
        let bytes = fixture();
        let compressed = compress(&bytes);
        assert_eq!(
            TraceStreamReader::new(compressed.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            vec![event()]
        );
        let mut writer = TraceStreamWriter::new(Vec::new());
        writer.write_events(&[event()]).unwrap();
        let compressed = writer.finish().unwrap();
        let mut actual = Vec::new();
        MultiGzDecoder::new(compressed.as_slice())
            .read_to_end(&mut actual)
            .unwrap();
        assert_eq!(actual, bytes);
    }

    #[test]
    fn checkpoints_and_metadata_preserve_order() {
        let boundary = TraceStreamRecord::BatchStart {
            batch_start: BatchTiming {
                start_time: 0,
                end_time: u64::MAX,
            },
        };
        let record = TraceStreamRecord::Event(TraceStreamEvent {
            record: event(),
            instruction: Some(MeasurementOperation::FutureRead),
        });
        let records = [boundary.clone(), boundary, record];
        let mut writer = TraceStreamWriter::new(Vec::new());
        for record in &records {
            writer.write_records(std::slice::from_ref(record)).unwrap();
        }
        let bytes = writer.finish().unwrap();
        assert_eq!(
            TraceStreamRecordReader::new(bytes.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            records
        );
        assert_eq!(
            TraceStreamReader::new(bytes.as_slice())
                .unwrap()
                .collect::<io::Result<Vec<_>>>()
                .unwrap(),
            vec![event()]
        );
    }

    #[test]
    fn empty_stream_is_complete() {
        let bytes = TraceStreamWriter::new(Vec::new()).finish().unwrap();
        assert!(
            TraceStreamReader::new(bytes.as_slice())
                .unwrap()
                .next()
                .is_none()
        );
    }

    #[test]
    fn incomplete_records_and_trailing_bytes_are_errors() {
        let bytes = fixture();
        let missing_end = bytes[..bytes.len() - 1].to_vec();
        let mut partial_record = missing_end.clone();
        partial_record.push(0x81);
        let mut trailing = bytes.clone();
        trailing.push(0x81);
        let mut extra_end = bytes.clone();
        extra_end.push(0xc0);
        for contents in [missing_end, partial_record, trailing, extra_end] {
            let compressed = compress(&contents);
            let mut reader = TraceStreamReader::new(compressed.as_slice()).unwrap();
            assert!(reader.next().unwrap().is_ok());
            let error = reader.next().unwrap().unwrap_err();
            assert!(error.to_string().contains("record 2"));
            assert!(reader.next().is_none());
        }
    }

    #[test]
    fn gzip_integrity_and_header_are_checked() {
        let bytes = compress(&fixture());
        let mut bad_checksum = bytes.clone();
        let index = bad_checksum.len() - 8;
        bad_checksum[index] ^= 1;
        for bytes in [
            bytes[..bytes.len() - 8].to_vec(),
            bad_checksum,
            compress(b"{\"format\":\"selene.trace.jsonl\"}\n"),
        ] {
            let result = TraceStreamReader::new(bytes.as_slice())
                .and_then(|reader| reader.collect::<io::Result<Vec<_>>>());
            assert!(result.is_err());
        }
        for version in [
            serde_json::json!(99),
            serde_json::json!(true),
            serde_json::json!(1.0),
        ] {
            let mut value = header();
            value["format_version"] = version;
            let bytes = compress(&rmp_serde::to_vec_named(&value).unwrap());
            assert!(TraceStreamReader::new(bytes.as_slice()).is_err());
        }
    }

    #[test]
    fn failed_serialisation_cannot_be_finished() {
        let invalid_event = EventRecord {
            source: Source::UserProgram { index: 0 },
            event: Event::Gate {
                qubits: vec![],
                gate_name: "Rz".into(),
                params: vec![GateParameter::Float(f64::NAN)],
                predicates: vec![],
            },
        };
        let mut writer = TraceStreamWriter::new(Vec::new());
        assert!(writer.write_events(&[invalid_event]).is_err());
        assert!(writer.write_events(&[event()]).is_err());
        assert!(writer.finish().is_err());
    }

    #[test]
    fn destination_failure_is_reported_at_finish() {
        struct Broken;
        impl Write for Broken {
            fn write(&mut self, _: &[u8]) -> io::Result<usize> {
                Err(io::Error::other("destination failed"))
            }
            fn flush(&mut self) -> io::Result<()> {
                Ok(())
            }
        }
        let mut writer = TraceStreamWriter::new(Broken);
        writer.write_events(&[event()]).unwrap();
        assert!(writer.finish().is_err());
    }

    #[test]
    fn shot_metadata_preserves_full_uint64_range() {
        for shot in [0, 17, MAX_SAFE_INTEGER, MAX_SAFE_INTEGER + 1, u64::MAX] {
            let mut writer = TraceStreamWriter::with_shot(Vec::new(), shot);
            writer.write_events(&[event()]).unwrap();
            let bytes = writer.finish().unwrap();
            let reader = TraceStreamReader::new(bytes.as_slice()).unwrap();
            assert_eq!(reader.shot(), Some(shot));
            assert_eq!(
                reader.collect::<io::Result<Vec<_>>>().unwrap(),
                vec![event()]
            );
        }
        let bytes = TraceStreamWriter::new(Vec::new()).finish().unwrap();
        assert_eq!(
            TraceStreamRecordReader::new(bytes.as_slice())
                .unwrap()
                .shot(),
            None
        );
    }

    #[test]
    fn invalid_shot_headers_are_rejected() {
        for shot in [
            serde_json::json!(-1),
            serde_json::json!(1.0),
            serde_json::json!(true),
            serde_json::json!("7"),
            serde_json::Value::Null,
        ] {
            let mut metadata = header();
            metadata["shot"] = shot;
            let bytes = compress(&rmp_serde::to_vec_named(&metadata).unwrap());
            assert!(TraceStreamReader::new(bytes.as_slice()).is_err());
        }
    }
}
