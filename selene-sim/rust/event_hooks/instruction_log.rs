use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError, Record};
use selene_core::runtime::BatchOperation;

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

#[derive(Default)]
pub struct InstructionLog {
    entries: Vec<Instruction>,
}

impl EventHook for InstructionLog {
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
        let mut record = Record::new(time_cursor, "INSTRUCTIONLOG")?;
        for instruction in self.entries.iter() {
            instruction.write(&mut record)?;
        }
        encoder.add_record(record)?;
        self.entries.clear();
        Ok(())
    }
    fn on_shot_start(&mut self, _shot_id: u64) {
        self.entries.clear();
    }
    fn on_shot_end(&mut self) {}
}

#[cfg(test)]
mod tests {
    use super::*;
    use selene_core::encoder::{InternalBuffer, OutputWriter};

    #[test]
    fn oversized_custom_data_leaves_room_for_a_panic_record() {
        let mut encoder = OutputStream::new(OutputWriter::Internal(InternalBuffer::default()));
        let mut log = InstructionLog::default();
        log.on_user_call(&Operation::Custom(42, vec![0; u16::MAX as usize + 1]));
        assert!(matches!(
            log.write(0, &mut encoder),
            Err(OutputStreamError::OversizeArrayError(_))
        ));
        assert!(encoder.try_read(usize::MAX).unwrap().is_empty());

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
            let mut log = InstructionLog::default();
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
            assert_eq!(
                encoder.try_read(usize::MAX).unwrap(),
                reference.try_read(usize::MAX).unwrap()
            );
        }
    }
}
