use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError};
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
    pub fn write(&self, encoder: &mut OutputStream) -> Result<(), OutputStreamError> {
        let source_id: u64 = self.source.clone() as u64;
        encoder.write(source_id)?;
        if let Some(duration_ns) = self.duration_ns {
            encoder.write(duration_ns)?;
        }
        match &self.operation {
            Operation::BatchStart(start_time, duration) => {
                encoder.write(0u64)?;
                encoder.write(*start_time)?;
                encoder.write(*duration)?;
            }
            Operation::QAlloc(address) => {
                encoder.write(1u64)?;
                encoder.write(*address)?;
            }
            Operation::QFree(address) => {
                encoder.write(2u64)?;
                encoder.write(*address)?;
            }
            Operation::Reset(qubit1) => {
                encoder.write(3u64)?;
                encoder.write(*qubit1)?;
            }
            Operation::MeasureRequest(qubit1) => {
                encoder.write(4u64)?;
                encoder.write(*qubit1)?;
            }
            Operation::FutureRead(qubit1) => {
                encoder.write(5u64)?;
                encoder.write(*qubit1)?;
            }
            Operation::RXY(qubit1, angle1, angle2) => {
                encoder.write(6u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*angle1)?;
                encoder.write(*angle2)?;
            }
            Operation::RZ(qubit1, angle) => {
                encoder.write(7u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*angle)?;
            }
            Operation::RZZ(qubit1, qubit2, angle) => {
                encoder.write(8u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*qubit2)?;
                encoder.write(*angle)?;
            }
            Operation::Custom(tag, data) => {
                encoder.write(9u64)?;
                encoder.write(*tag)?;
                encoder.write(&**data)?;
            }
            Operation::LocalBarrier(qubits, sleep_time) => {
                encoder.write(10u64)?;
                encoder.write(qubits.len() as u64)?;
                for qubit in qubits.iter() {
                    encoder.write(*qubit)?;
                }
                encoder.write(*sleep_time)?;
            }
            Operation::GlobalBarrier(sleep_time) => {
                encoder.write(11u64)?;
                encoder.write(*sleep_time)?;
            }
            Operation::MeasureLeakedRequest(qubit1) => {
                encoder.write(12u64)?;
                encoder.write(*qubit1)?;
            }
            Operation::ClassicalDelay(duration) => {
                encoder.write(13u64)?;
                encoder.write(*duration)?;
            }
            Operation::RPP(qubit1, qubit2, theta, phi) => {
                encoder.write(14u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*qubit2)?;
                encoder.write(*theta)?;
                encoder.write(*phi)?;
            }
            Operation::TK2(qubit1, qubit2, alpha, beta, gamma) => {
                encoder.write(15u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*qubit2)?;
                encoder.write(*alpha)?;
                encoder.write(*beta)?;
                encoder.write(*gamma)?;
            }
            Operation::Postselect(qubit1, target_value) => {
                encoder.write(16u64)?;
                encoder.write(*qubit1)?;
                encoder.write(*target_value)?;
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
        encoder.begin_message(time_cursor)?;
        encoder.write("INSTRUCTIONLOG")?;
        for instruction in self.entries.iter() {
            instruction.write(encoder)?;
        }
        self.entries.clear();
        encoder.end_message()?;
        Ok(())
    }
    fn on_shot_start(&mut self, _shot_id: u64) {
        self.entries.clear();
    }
    fn on_shot_end(&mut self) {}
}
