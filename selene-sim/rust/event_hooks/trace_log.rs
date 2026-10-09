use super::{EventHook, Operation};
use selene_api_models::trace::{CustomPayload, Event, EventRecord, GateParameter, Source};
use selene_api_models::trace_stream::{
    BatchTiming, MeasurementOperation, TraceStreamEvent, TraceStreamRecord, TraceStreamWriter,
    UIntInstruction, UIntInstructionRecord,
};
use selene_core::encoder::{OutputStream, OutputStreamError, Record};
use selene_core::runtime::BatchOperation;
use std::fs::{File, OpenOptions};
use std::path::PathBuf;

pub struct TraceLog {
    pending: Vec<TraceStreamRecord>,
    artifact_dir: PathBuf,
    shot: u64,
    file_index: u64,
    user_index: u64,
    error_index: u64,
    simulator_index: u64,
    active: Option<(PathBuf, TraceStreamWriter<File>)>,
    failure: Option<String>,
}

impl TraceLog {
    pub fn new(artifact_dir: PathBuf) -> Self {
        Self {
            pending: Vec::new(),
            artifact_dir,
            shot: 0,
            file_index: 0,
            user_index: 0,
            error_index: 0,
            simulator_index: 0,
            active: None,
            failure: None,
        }
    }

    fn event(operation: &Operation) -> Option<Event> {
        let gate = |name: &str, qubits, params| Event::Gate {
            gate_name: name.into(),
            qubits,
            params,
            predicates: Vec::new(),
        };
        let number = GateParameter::Float;
        Some(match operation {
            Operation::QAlloc(q) => gate("QAlloc", vec![*q], vec![]),
            Operation::QFree(q) => gate("QFree", vec![*q], vec![]),
            Operation::RXY(q, theta, phi) => {
                gate("Rxy", vec![*q], vec![number(*theta), number(*phi)])
            }
            Operation::RZ(q, theta) => gate("Rz", vec![*q], vec![number(*theta)]),
            Operation::RZZ(q0, q1, theta) => gate("Rzz", vec![*q0, *q1], vec![number(*theta)]),
            Operation::RPP(q0, q1, theta, phi) => {
                gate("Rpp", vec![*q0, *q1], vec![number(*theta), number(*phi)])
            }
            Operation::Reset(q) => Event::Reset { qubit: *q },
            Operation::MeasureRequest(q)
            | Operation::FutureRead(q)
            | Operation::MeasureLeakedRequest(q) => Event::Measurement { qubit: *q },
            Operation::Custom(tag, data) => Event::Custom {
                payload: CustomPayload::OpaquePayload {
                    tag: *tag,
                    data: data.clone(),
                },
            },
            Operation::LocalBarrier(..)
            | Operation::GlobalBarrier(_)
            | Operation::ClassicalDelay(_) => return None,
            Operation::Postselect(q, target) => gate(
                "Postselect",
                vec![*q],
                vec![GateParameter::Boolean(*target)],
            ),
        })
    }

    fn push_event(&mut self, operation: &Operation, source: Source) {
        let uint_operand = match operation {
            Operation::LocalBarrier(qubits, value) => {
                Some((UIntInstruction::LocalBarrier, *value, qubits.clone()))
            }
            Operation::GlobalBarrier(value) => {
                Some((UIntInstruction::GlobalBarrier, *value, vec![]))
            }
            Operation::ClassicalDelay(value) => {
                Some((UIntInstruction::ClassicalDelay, *value, vec![]))
            }
            _ => None,
        };
        if let Some((uint_instruction, value, qubits)) = uint_operand {
            self.pending
                .push(TraceStreamRecord::UIntInstruction(UIntInstructionRecord {
                    source,
                    uint_instruction,
                    value,
                    qubits,
                }));
            return;
        }
        if let Some(event) = Self::event(operation) {
            let instruction = match operation {
                Operation::FutureRead(_) if matches!(source, Source::UserProgram { .. }) => {
                    Some(MeasurementOperation::FutureRead)
                }
                Operation::MeasureLeakedRequest(_) => {
                    Some(MeasurementOperation::MeasureLeakedRequest)
                }
                _ => None,
            };
            self.pending
                .push(TraceStreamRecord::Event(TraceStreamEvent {
                    record: EventRecord { source, event },
                    instruction,
                }));
        }
    }

    fn discard_active(&mut self) {
        if let Some((path, writer)) = self.active.take() {
            drop(writer);
            let _ = std::fs::remove_file(path);
        }
    }

    fn drain_to_file(&mut self) -> Result<(), OutputStreamError> {
        if self.pending.is_empty() {
            return Ok(());
        }
        if self.active.is_none() {
            let (path, file) = loop {
                let path = self.artifact_dir.join(format!(
                    "trace-{}-{}.msgpack.gz",
                    self.shot, self.file_index
                ));
                self.file_index += 1;
                match OpenOptions::new().write(true).create_new(true).open(&path) {
                    Ok(file) => break (path, file),
                    Err(error) if error.kind() == std::io::ErrorKind::AlreadyExists => continue,
                    Err(error) => return Err(OutputStreamError::IoError(error)),
                }
            };
            self.active = Some((path, TraceStreamWriter::new(file)));
        }
        let (_, writer) = self.active.as_mut().unwrap();
        writer
            .write_records(&self.pending)
            .map_err(OutputStreamError::IoError)?;
        self.pending.clear();
        Ok(())
    }
}

impl Drop for TraceLog {
    fn drop(&mut self) {
        self.discard_active();
    }
}

impl EventHook for TraceLog {
    fn drain_pending(&mut self) -> Result<(), OutputStreamError> {
        if let Some(error) = &self.failure {
            return Err(OutputStreamError::OtherError(error.clone()));
        }
        if let Err(error) = self.drain_to_file() {
            let message = format!("Could not write trace for shot {}: {error}", self.shot);
            self.discard_active();
            self.failure = Some(message.clone());
            return Err(OutputStreamError::OtherError(message));
        }
        Ok(())
    }
    fn on_user_call(&mut self, operation: &Operation) {
        self.push_event(
            operation,
            Source::UserProgram {
                index: self.user_index,
            },
        );
        self.user_index += 1;
    }

    fn on_runtime_batch(&mut self, batch: &BatchOperation) {
        let (start_time, end_time) = batch
            .runtime_source()
            .map(|timing| {
                let start = u64::from(timing.start());
                (start, start + u64::from(timing.duration()))
            })
            .unwrap_or((0, 0));
        // Batch boundaries are transport metadata, not trace events. This
        // preserves the instruction view without changing the public trace.
        self.pending.push(TraceStreamRecord::BatchStart {
            batch_start: BatchTiming {
                start_time,
                end_time,
            },
        });
        for operation in batch.iter_ops() {
            self.push_event(
                &Operation::from_runtime_operation(operation),
                Source::Runtime {
                    start_time,
                    end_time,
                },
            );
        }
    }

    fn on_error_model_output(&mut self, operation: &Operation) {
        self.push_event(
            operation,
            Source::ErrorModel {
                index: self.error_index,
            },
        );
        self.error_index += 1;
    }

    fn on_simulator_call(&mut self, operation: &Operation, duration_ns: u64) {
        self.push_event(
            operation,
            Source::Simulator {
                index: self.simulator_index,
                duration_ns,
            },
        );
        self.simulator_index += 1;
    }

    fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        self.drain_pending()?;
        let Some((path, writer)) = self.active.take() else {
            return Ok(());
        };
        let result = (|| {
            // Finish the gzip trailer and close the file before publishing it.
            let writer = writer.finish().map_err(OutputStreamError::IoError)?;
            drop(writer);
            let filename = path
                .to_str()
                .ok_or_else(|| OutputStreamError::OtherError("Trace path is not UTF-8".into()))?;
            encoder.add_record(Record::new(time_cursor, "TRACE")?.add_entry(filename)?)
        })();
        if let Err(error) = result {
            let _ = std::fs::remove_file(&path);
            self.failure = Some(format!(
                "Could not publish trace {}: {error}",
                path.display()
            ));
            return Err(error);
        }
        Ok(())
    }

    fn on_shot_start(&mut self, shot_id: u64) {
        self.discard_active();
        self.failure = None;
        self.pending.clear();
        self.shot = shot_id;
        self.user_index = 0;
        self.error_index = 0;
        self.simulator_index = 0;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use selene_api_models::trace::Trace;
    use selene_api_models::trace_stream::TraceStreamReader;
    use selene_core::encoder::{InternalBuffer, OutputWriter};

    struct TestDirectory(PathBuf);
    impl TestDirectory {
        fn new() -> Self {
            let path =
                std::env::temp_dir().join(format!("selene-trace-test-{}", rand::random::<u64>()));
            std::fs::create_dir(&path).unwrap();
            Self(path)
        }
        fn read(&self, shot: u64, index: u64) -> Trace {
            let file = File::open(self.0.join(format!("trace-{shot}-{index}.msgpack.gz"))).unwrap();
            Trace {
                schema_version: Default::default(),
                events: TraceStreamReader::new(file)
                    .unwrap()
                    .collect::<Result<_, _>>()
                    .unwrap(),
            }
        }
    }
    impl Drop for TestDirectory {
        fn drop(&mut self) {
            std::fs::remove_dir_all(&self.0).unwrap();
        }
    }

    #[test]
    fn uint64_operands_survive_writing_and_reading() {
        use selene_api_models::trace_stream::TraceStreamRecordReader;
        let directory = TestDirectory::new();
        let mut log = TraceLog::new(directory.0.clone());
        let mut output = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        let values = [
            0,
            (1 << 53) - 1,
            1 << 53,
            (1 << 53) + 1,
            i64::MAX as u64,
            u64::MAX,
        ];
        for value in values {
            log.on_user_call(&Operation::GlobalBarrier(value));
            log.on_user_call(&Operation::LocalBarrier(vec![0, 1], value));
            log.on_user_call(&Operation::ClassicalDelay(value));
        }
        // These are valid instruction operands even when the public JSON
        // model can't represent them. Enabling tracing mustn't fail the shot.
        log.write(0, &mut output).unwrap();
        let file = File::open(directory.0.join("trace-0-0.msgpack.gz")).unwrap();
        let records = TraceStreamRecordReader::new(file)
            .unwrap()
            .collect::<Result<Vec<_>, _>>()
            .unwrap();
        assert_eq!(records.len(), values.len() * 3);
        for (records, value) in records.chunks_exact(3).zip(values) {
            for (record, kind) in records.iter().zip([
                UIntInstruction::GlobalBarrier,
                UIntInstruction::LocalBarrier,
                UIntInstruction::ClassicalDelay,
            ]) {
                let TraceStreamRecord::UIntInstruction(record) = record else {
                    panic!("expected an integer operand")
                };
                assert_eq!(record.value, value);
                assert_eq!(record.uint_instruction, kind);
                assert_eq!(
                    record.qubits,
                    if kind == UIntInstruction::LocalBarrier {
                        vec![0, 1]
                    } else {
                        vec![]
                    }
                );
                assert_eq!(record.as_event().is_ok(), value < (1 << 53));
            }
        }
    }

    #[test]
    fn files_keep_custom_data_and_source_indices_across_flushes() {
        let directory = TestDirectory::new();
        let mut log = TraceLog::new(directory.0.clone());
        let mut output = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        log.on_shot_start(7);
        log.on_user_call(&Operation::Custom(u64::MAX, vec![]));
        log.on_error_model_output(&Operation::Postselect(3, true));
        log.on_simulator_call(&Operation::Reset(3), 123);
        log.write(0, &mut output).unwrap();
        let trace = directory.read(7, 0);
        assert!(
            matches!(&trace.events[0].event, Event::Custom { payload: CustomPayload::OpaquePayload { tag: u64::MAX, data } } if data.is_empty())
        );
        assert_eq!(
            trace.events[2].source,
            Source::Simulator {
                index: 0,
                duration_ns: 123
            }
        );
        let first_trace = trace;

        // A payload larger than the binary stream's array limit goes in the
        // JSON file. Only a short filename should reach the result stream.
        log.on_user_call(&Operation::Custom(42, vec![0xff; 70000]));
        log.write(0, &mut output).unwrap();
        assert_eq!(
            directory.read(7, 1).events[0].source,
            Source::UserProgram { index: 1 }
        );
        let trace = directory.read(7, 1);
        assert!(
            matches!(&trace.events[0].event, Event::Custom { payload: CustomPayload::OpaquePayload { data, .. } } if data == &vec![0xff; 70000])
        );
        assert!(output.try_read(usize::MAX).unwrap().len() < 1024);
        assert_eq!(directory.read(7, 0), first_trace);

        log.on_shot_start(8);
        log.on_user_call(&Operation::Reset(0));
        log.write(0, &mut output).unwrap();
        assert_eq!(
            directory.read(8, 2).events[0].source,
            Source::UserProgram { index: 0 }
        );
    }

    #[test]
    fn failed_serialisation_does_not_publish_a_filename() {
        let directory = TestDirectory::new();
        let mut log = TraceLog::new(directory.0.clone());
        let mut output = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        log.on_user_call(&Operation::RZ(0, f64::NAN));
        assert!(log.write(0, &mut output).is_err());
        // A serialisation failure may already have written part of a line.
        // Retrying must report the failure, not publish an incomplete trace.
        assert!(log.write(0, &mut output).is_err());
        assert!(output.try_read(usize::MAX).unwrap().is_empty());
        assert_eq!(std::fs::read_dir(&directory.0).unwrap().count(), 0);
    }

    #[test]
    fn checkpoints_drain_without_publishing_or_starting_new_files() {
        let directory = TestDirectory::new();
        let mut log = TraceLog::new(directory.0.clone());
        let mut output = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        for _ in 0..100 {
            log.on_user_call(&Operation::Reset(0));
            assert_eq!(log.pending.len(), 1);
            log.drain_pending().unwrap();
            assert!(log.pending.is_empty());
            assert_eq!(log.file_index, 1);
        }
        assert!(output.try_read(usize::MAX).unwrap().is_empty());
        log.write(0, &mut output).unwrap();
        assert_eq!(directory.read(0, 0).events.len(), 100);
        assert!(!output.try_read(usize::MAX).unwrap().is_empty());
    }

    #[test]
    fn dropping_an_unpublished_trace_removes_it() {
        let directory = TestDirectory::new();
        {
            let mut log = TraceLog::new(directory.0.clone());
            log.on_user_call(&Operation::Reset(0));
            log.drain_pending().unwrap();
            assert_eq!(std::fs::read_dir(&directory.0).unwrap().count(), 1);
        }
        assert_eq!(std::fs::read_dir(&directory.0).unwrap().count(), 0);
    }

    #[test]
    fn checkpoint_io_failure_is_not_retried() {
        let directory = TestDirectory::new();
        let missing = directory.0.join("missing");
        let mut log = TraceLog::new(missing.clone());
        log.on_user_call(&Operation::Reset(0));
        assert!(log.drain_pending().is_err());
        std::fs::create_dir(&missing).unwrap();
        assert!(log.drain_pending().is_err());
        assert_eq!(std::fs::read_dir(missing).unwrap().count(), 0);
    }

    #[test]
    #[cfg(target_os = "linux")]
    fn failure_when_finishing_gzip_does_not_publish_a_filename() {
        let directory = TestDirectory::new();
        let mut log = TraceLog::new(directory.0.clone());
        let mut output = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        // /dev/full accepts opening but rejects writes. A small event fits in
        // our buffer, so the checkpoint succeeds and publication discovers the
        // error when it tries to finish the compressed file.
        let file = OpenOptions::new().write(true).open("/dev/full").unwrap();
        log.active = Some((
            directory.0.join("unpublished.msgpack.gz"),
            TraceStreamWriter::new(file),
        ));
        log.on_user_call(&Operation::Reset(0));
        log.drain_pending().unwrap();
        assert!(log.write(0, &mut output).is_err());
        assert!(log.write(0, &mut output).is_err());
        assert!(output.try_read(usize::MAX).unwrap().is_empty());
    }
}
