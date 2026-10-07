use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError, Record};
use selene_core::runtime::BatchOperation;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};

pub struct Instruction {
    pub source: Source,
    pub operation: Operation,
    pub duration_ns: Option<u64>,
}
#[derive(Clone)]
#[repr(u64)]
pub enum Source {
    UserProgram = 0,
    RuntimeOptimiser = 1,
    ErrorModel = 2,
    Simulator = 3,
}

impl Instruction {
    pub fn write(&self, record: &mut Record) -> Result<(), OutputStreamError> {
        let source_id: u64 = self.source.clone() as u64;
        record.push(source_id)?;
        if let Some(duration_ns) = self.duration_ns {
            record.push(duration_ns)?;
        }
        match &self.operation {
            Operation::BatchStart(start_time, duration) => {
                record.push(0u64)?;
                record.push(*start_time)?;
                record.push(*duration)?;
            }
            Operation::QAlloc(address) => {
                record.push(1u64)?;
                record.push(*address)?;
            }
            Operation::QFree(address) => {
                record.push(2u64)?;
                record.push(*address)?;
            }
            Operation::Reset(qubit1) => {
                record.push(3u64)?;
                record.push(*qubit1)?;
            }
            Operation::MeasureRequest(qubit1) => {
                record.push(4u64)?;
                record.push(*qubit1)?;
            }
            Operation::FutureRead(qubit1) => {
                record.push(5u64)?;
                record.push(*qubit1)?;
            }
            Operation::RXY(qubit1, angle1, angle2) => {
                record.push(6u64)?;
                record.push(*qubit1)?;
                record.push(*angle1)?;
                record.push(*angle2)?;
            }
            Operation::RZ(qubit1, angle) => {
                record.push(7u64)?;
                record.push(*qubit1)?;
                record.push(*angle)?;
            }
            Operation::RZZ(qubit1, qubit2, angle) => {
                record.push(8u64)?;
                record.push(*qubit1)?;
                record.push(*qubit2)?;
                record.push(*angle)?;
            }
            Operation::Custom(tag, data) => {
                record.push(9u64)?;
                record.push(*tag)?;
                record.push(!data.is_empty())?;
                if !data.is_empty() {
                    record.push(&**data)?;
                }
            }
            Operation::LocalBarrier(qubits, sleep_time) => {
                record.push(10u64)?;
                record.push(qubits.len() as u64)?;
                for qubit in qubits.iter() {
                    record.push(*qubit)?;
                }
                record.push(*sleep_time)?;
            }
            Operation::GlobalBarrier(sleep_time) => {
                record.push(11u64)?;
                record.push(*sleep_time)?;
            }
            Operation::MeasureLeakedRequest(qubit1) => {
                record.push(12u64)?;
                record.push(*qubit1)?;
            }
            Operation::ClassicalDelay(duration) => {
                record.push(13u64)?;
                record.push(*duration)?;
            }
            Operation::RPP(qubit1, qubit2, theta, phi) => {
                record.push(14u64)?;
                record.push(*qubit1)?;
                record.push(*qubit2)?;
                record.push(*theta)?;
                record.push(*phi)?;
            }
            Operation::Postselect(qubit1, target_value) => {
                record.push(16u64)?;
                record.push(*qubit1)?;
                record.push(*target_value)?;
            }
        }
        Ok(())
    }
}

pub struct InstructionLog {
    entries: Vec<Instruction>,
    artifact_dir: PathBuf,
    file: Option<LogFile>,
    failure: Option<String>,
}

struct LogFile {
    writer: Option<File>,
    path: PathBuf,
    published: bool,
}

fn file_error(path: &Path, error: std::io::Error) -> OutputStreamError {
    OutputStreamError::IoError(std::io::Error::new(
        error.kind(),
        format!("Instruction log {}: {error}", path.display()),
    ))
}

impl Drop for LogFile {
    fn drop(&mut self) {
        self.writer.take();
        if !self.published {
            // A failed or abandoned log must never be mistaken for a complete one.
            let _ = std::fs::remove_file(&self.path);
        }
    }
}

impl InstructionLog {
    pub fn new(artifact_dir: PathBuf) -> Self {
        Self {
            entries: Vec::new(),
            artifact_dir,
            file: None,
            failure: None,
        }
    }

    fn ensure_file(&mut self) -> Result<&mut LogFile, OutputStreamError> {
        if self.file.is_none() {
            static NEXT_FILE: AtomicU64 = AtomicU64::new(0);
            loop {
                let id = NEXT_FILE.fetch_add(1, Ordering::Relaxed);
                let path = self
                    .artifact_dir
                    .join(format!("instruction-log-{}-{id}.bin", std::process::id()));
                match OpenOptions::new().write(true).create_new(true).open(&path) {
                    Ok(file) => {
                        self.file = Some(LogFile {
                            writer: Some(file),
                            path,
                            published: false,
                        });
                        break;
                    }
                    Err(error) if error.kind() == std::io::ErrorKind::AlreadyExists => continue,
                    Err(error) => return Err(file_error(&path, error)),
                }
            }
        }
        Ok(self.file.as_mut().unwrap())
    }

    fn drain(&mut self) -> Result<(), OutputStreamError> {
        if self.entries.is_empty() {
            return Ok(());
        }
        // The file uses the same records as the result stream. Their timestamps
        // aren't used by circuit extraction, so checkpoints can use zero here.
        let mut record = Record::new(0, "INSTRUCTIONLOG")?;
        for instruction in &self.entries {
            instruction.write(&mut record)?;
        }
        let bytes = record.into_bytes()?;
        let file = self.ensure_file()?;
        file.writer
            .as_mut()
            .unwrap()
            .write_all(&bytes)
            .map_err(|error| file_error(&file.path, error))?;
        self.entries.clear();
        Ok(())
    }
}

impl EventHook for InstructionLog {
    fn drain_pending(&mut self) -> Result<(), OutputStreamError> {
        if let Some(error) = &self.failure {
            return Err(OutputStreamError::OtherError(error.clone()));
        }
        if let Err(error) = self.drain() {
            self.failure = Some(format!(
                "Could not write instruction log in {}: {error}",
                self.artifact_dir.display()
            ));
            self.file = None;
            return Err(error);
        }
        Ok(())
    }
    fn on_user_call(&mut self, operation: &Operation) {
        self.entries.push(Instruction {
            source: Source::UserProgram,
            operation: operation.clone(),
            duration_ns: None,
        });
    }
    fn on_runtime_batch(&mut self, batch: &BatchOperation) {
        if let Some(timing) = batch.runtime_source() {
            let start = u64::from(timing.start());
            let duration = u64::from(timing.duration());
            self.entries.push(Instruction {
                source: Source::RuntimeOptimiser,
                operation: Operation::BatchStart(start, duration),
                duration_ns: None,
            });
        }
        for op in batch.iter_ops() {
            self.entries.push(Instruction {
                source: Source::RuntimeOptimiser,
                operation: Operation::from_runtime_operation(op),
                duration_ns: None,
            });
        }
    }
    fn on_error_model_output(&mut self, operation: &Operation) {
        self.entries.push(Instruction {
            source: Source::ErrorModel,
            operation: operation.clone(),
            duration_ns: None,
        });
    }
    fn on_simulator_call(&mut self, operation: &Operation, duration_ns: u64) {
        self.entries.push(Instruction {
            source: Source::Simulator,
            operation: operation.clone(),
            duration_ns: Some(duration_ns),
        });
    }
    fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        // Custom calls can arrive without another runtime loop. Drain those too
        // before we finish the file and tell the frontend where to find it.
        self.drain_pending()?;
        self.ensure_file()?;
        let mut file = self.file.take().unwrap();
        let result = (|| {
            let mut writer = file.writer.take().unwrap();
            writer
                .write_all(&u64::MAX.to_le_bytes())
                .map_err(|error| file_error(&file.path, error))?;
            writer
                .flush()
                .map_err(|error| file_error(&file.path, error))?;
            drop(writer);
            let path = file.path.to_str().ok_or_else(|| {
                OutputStreamError::OtherError(format!(
                    "Instruction log path is not UTF-8: {}",
                    file.path.display()
                ))
            })?;
            encoder.add_record(Record::new(time_cursor, "INSTRUCTIONLOG")?.add_entry(path)?)
        })();
        if let Err(error) = result {
            self.failure = Some(format!(
                "Could not finish instruction log {}: {error}",
                file.path.display()
            ));
            return Err(error);
        }
        file.published = true;
        Ok(())
    }
    fn on_shot_start(&mut self, _shot_id: u64) {
        self.entries.clear();
        self.file = None;
        self.failure = None;
    }
    fn on_shot_end(&mut self) {}
}

#[cfg(test)]
mod tests {
    use super::*;
    use selene_core::encoder::{InternalBuffer, OutputWriter};

    struct TestDirectory(PathBuf);

    impl TestDirectory {
        fn new() -> Self {
            let path = std::env::temp_dir().join(format!(
                "selene-instruction-log-test-{}-{}",
                std::process::id(),
                rand::random::<u64>()
            ));
            std::fs::create_dir(&path).unwrap();
            Self(path)
        }

        fn files(&self) -> Vec<PathBuf> {
            std::fs::read_dir(&self.0)
                .unwrap()
                .map(|entry| entry.unwrap().path())
                .collect()
        }
    }

    impl Drop for TestDirectory {
        fn drop(&mut self) {
            std::fs::remove_dir_all(&self.0).unwrap();
        }
    }

    #[test]
    fn oversized_custom_data_leaves_room_for_a_panic_record() {
        let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        let directory = TestDirectory::new();
        let mut log = InstructionLog::new(directory.0.clone());
        // An earlier checkpoint may already be on disk. If a later record
        // can't be encoded, we must discard the file rather than publish it.
        log.on_user_call(&Operation::QAlloc(7));
        log.drain_pending().unwrap();
        log.on_user_call(&Operation::Custom(42, vec![0; u16::MAX as usize + 1]));
        assert!(matches!(
            log.write(0, &mut encoder),
            Err(OutputStreamError::OversizeArrayError(_))
        ));
        assert!(encoder.try_read(usize::MAX).unwrap().is_empty());
        assert!(directory.files().is_empty());
        assert!(log.write(0, &mut encoder).is_err());

        // This is the same writer the FFI error handler uses. It should still
        // be able to emit the panic because none of the failed log was sent.
        crate::selene_instance::print::print_directly_to_stream(
            &mut encoder,
            0,
            "EXIT:INT:Array size 65536 exceeds maximum size",
            100001u64,
        )
        .unwrap();
        let output = encoder.try_read(usize::MAX).unwrap();
        assert_eq!(&output[..8], &0u64.to_le_bytes());
        let tag = b"EXIT:INT:Array size 65536 exceeds maximum size";
        let value_start = 12 + tag.len();
        assert_eq!(&output[8..12], &[3, 0, tag.len() as u8, 0]);
        assert_eq!(&output[12..value_start], tag);
        assert_eq!(&output[value_start..value_start + 4], &[1, 0, 0, 0]);
        assert_eq!(
            &output[value_start + 4..value_start + 12],
            &100001u64.to_le_bytes()
        );
        assert_eq!(&output[value_start + 12..], &[0; 4]);
    }

    #[test]
    fn custom_data_is_optional() {
        for data in [vec![], vec![0xff], vec![1, 2, 3]] {
            let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
            let directory = TestDirectory::new();
            let mut log = InstructionLog::new(directory.0.clone());
            log.on_user_call(&Operation::Custom(42, data.clone()));
            log.on_user_call(&Operation::QAlloc(7));
            log.write(0, &mut encoder).unwrap();

            let mut expected = Record::new(0, "INSTRUCTIONLOG")
                .unwrap()
                .add_entry(0u64)
                .unwrap()
                .add_entry(9u64)
                .unwrap()
                .add_entry(42u64)
                .unwrap()
                .add_entry(!data.is_empty())
                .unwrap();
            if !data.is_empty() {
                expected.push(data.as_slice()).unwrap();
            }
            // The following allocation must start immediately after the flag
            // when there's no data, or after the byte array when there is.
            expected.push(0u64).unwrap();
            expected.push(1u64).unwrap();
            expected.push(7u64).unwrap();
            let mut reference =
                OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
            reference.add_record(expected).unwrap();
            reference.end_of_stream().unwrap();
            let files = directory.files();
            assert_eq!(files.len(), 1);
            assert_eq!(
                std::fs::read(&files[0]).unwrap(),
                reference.try_read(usize::MAX).unwrap()
            );
            let mut expected_path =
                OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
            expected_path
                .add_record(
                    Record::new(0, "INSTRUCTIONLOG")
                        .unwrap()
                        .add_entry(files[0].to_str().unwrap())
                        .unwrap(),
                )
                .unwrap();
            assert_eq!(
                encoder.try_read(usize::MAX).unwrap(),
                expected_path.try_read(usize::MAX).unwrap()
            );
        }
    }

    #[test]
    fn checkpoints_write_during_the_shot_and_publications_use_separate_files() {
        let directory = TestDirectory::new();
        let mut log = InstructionLog::new(directory.0.clone());
        let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        log.on_shot_start(7);
        log.on_user_call(&Operation::QAlloc(1));
        log.drain_pending().unwrap();
        assert!(log.entries.is_empty());
        let path = log.file.as_ref().unwrap().path.clone();
        let checkpoint = std::fs::read(&path).unwrap();
        assert!(!checkpoint.is_empty());
        assert!(encoder.try_read(usize::MAX).unwrap().is_empty());

        log.on_user_call(&Operation::Reset(1));
        log.drain_pending().unwrap();
        assert!(std::fs::read(&path).unwrap().starts_with(&checkpoint));
        assert!(std::fs::metadata(&path).unwrap().len() > checkpoint.len() as u64);
        log.on_user_call(&Operation::Custom(42, vec![]));
        log.write(9, &mut encoder).unwrap();
        let completed = std::fs::read(&path).unwrap();
        assert!(completed.ends_with(&u64::MAX.to_le_bytes()));

        // Interactive execution can publish more than once in a shot. Neither
        // a second publication nor the next shot should overwrite the first.
        log.on_user_call(&Operation::QFree(1));
        log.write(10, &mut encoder).unwrap();
        log.on_shot_start(8);
        log.write(0, &mut encoder).unwrap();
        assert_eq!(directory.files().len(), 3);
        assert_eq!(std::fs::read(&path).unwrap(), completed);
        assert!(
            directory
                .files()
                .iter()
                .any(|file| std::fs::read(file).unwrap() == u64::MAX.to_le_bytes())
        );
    }

    #[test]
    fn abandoned_logs_are_removed() {
        let directory = TestDirectory::new();
        let mut log = InstructionLog::new(directory.0.clone());
        log.on_user_call(&Operation::QAlloc(1));
        log.drain_pending().unwrap();
        log.on_shot_start(2);
        assert!(directory.files().is_empty());
        log.on_user_call(&Operation::QAlloc(2));
        log.drain_pending().unwrap();
        drop(log);
        assert!(directory.files().is_empty());
    }

    #[test]
    fn missing_artifact_directory_does_not_publish_a_path() {
        let directory = TestDirectory::new();
        let mut log = InstructionLog::new(directory.0.join("missing"));
        let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        log.on_user_call(&Operation::QAlloc(1));
        assert!(matches!(
            log.drain_pending(),
            Err(OutputStreamError::IoError(_))
        ));
        assert!(log.write(0, &mut encoder).is_err());
        assert!(encoder.try_read(usize::MAX).unwrap().is_empty());
    }

    #[test]
    fn io_failure_discards_the_file_without_publishing_it() {
        for fail_at_finish in [false, true] {
            let directory = TestDirectory::new();
            let mut log = InstructionLog::new(directory.0.clone());
            let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
            log.on_user_call(&Operation::QAlloc(1));
            log.drain_pending().unwrap();
            let file = log.file.as_mut().unwrap();
            let path = file.path.clone();
            // Replace the writable handle with a read-only one. This lets us
            // exercise a real write failure without relying on a full disk.
            file.writer = Some(File::open(&path).unwrap());
            if !fail_at_finish {
                log.on_user_call(&Operation::Reset(1));
            }
            let error = log.write(0, &mut encoder).unwrap_err();
            assert!(matches!(error, OutputStreamError::IoError(_)));
            assert!(error.to_string().contains(path.to_str().unwrap()));
            assert!(directory.files().is_empty());
            assert!(encoder.try_read(usize::MAX).unwrap().is_empty());
            assert!(log.write(0, &mut encoder).is_err());
        }
    }
}
