use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError};
use selene_core::metadata::{DEBUG_INFO_TAG, DEBUG_MODULE_TAG, MetadataResolver};
use selene_core::runtime::{self, BatchOperation, OpMetadata};

pub struct Instruction {
    pub source: Source,
    pub operation: Operation,
    /// Opaque per-op metadata handle, or zero (`NO_METADATA`) if none.
    /// Resolved into `Custom { tag: DEBUG_MODULE_TAG / DEBUG_INFO_TAG }`
    /// instructions emitted immediately before this one at write time.
    pub metadata: OpMetadata,
}
#[derive(Clone)]
#[repr(u64)]
pub enum Source {
    UserProgram = 0,
    RuntimeOptimiser = 1,
    ErrorModel = 2,
}

impl Instruction {
    pub fn write(&self, encoder: &mut OutputStream) -> Result<(), OutputStreamError> {
        let source_id: u64 = self.source.clone() as u64;
        encoder.write(source_id)?;
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
            metadata: selene_core::runtime::NO_METADATA,
        });
    }
    fn on_runtime_batch(&mut self, batch: &BatchOperation) {
        let start = u64::from(batch.start());
        let duration = u64::from(batch.duration());
        self.entries.push(Instruction {
            source: Source::RuntimeOptimiser,
            operation: Operation::BatchStart(start, duration),
            metadata: selene_core::runtime::NO_METADATA,
        });
        for (op, meta) in batch.iter_ops_with_metadata() {
            let operation = match op {
                runtime::Operation::Reset { qubit_id } => Operation::Reset(*qubit_id),
                runtime::Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => Operation::RXY(*qubit_id, *theta, *phi),
                runtime::Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => Operation::RZZ(*qubit_id_1, *qubit_id_2, *theta),
                runtime::Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => Operation::RPP(*qubit_id_1, *qubit_id_2, *theta, *phi),
                runtime::Operation::TK2Gate {
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                } => Operation::TK2(*qubit_id_1, *qubit_id_2, *alpha, *beta, *gamma),
                runtime::Operation::RZGate { qubit_id, theta } => Operation::RZ(*qubit_id, *theta),
                runtime::Operation::Measure { qubit_id, .. } => Operation::FutureRead(*qubit_id),
                runtime::Operation::MeasureLeaked { qubit_id, .. } => {
                    Operation::FutureRead(*qubit_id)
                }
                runtime::Operation::Custom { custom_tag, data } => {
                    Operation::Custom(*custom_tag as u64, data.to_vec())
                }
                &_ => todo!(),
            };
            self.entries.push(Instruction {
                source: Source::RuntimeOptimiser,
                operation,
                metadata: meta,
            });
        }
    }
    fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
        mut metadata_resolver: Option<&mut dyn MetadataResolver>,
    ) -> Result<(), OutputStreamError> {
        encoder.begin_message(time_cursor)?;
        encoder.write("INSTRUCTIONLOG")?;
        for instruction in self.entries.iter() {
            // Lazily resolve metadata: emit any newly-discovered module
            // blobs first (as Custom { DEBUG_MODULE_TAG }), then the
            // backtrace payload (as Custom { DEBUG_INFO_TAG }), then
            // the actual instruction. All synthesised events share the
            // instruction's source (typically RuntimeOptimiser).
            if instruction.metadata != selene_core::runtime::NO_METADATA {
                if let Some(resolver) = metadata_resolver.as_deref_mut() {
                    let module_blobs = resolver
                        .drain_pending_module_blobs()
                        .map_err(|e| OutputStreamError::OtherError(e.to_string()))?;
                    let source_id: u64 = instruction.source.clone() as u64;
                    for blob in module_blobs {
                        encoder.write(source_id)?;
                        encoder.write(9u64)?;
                        encoder.write(DEBUG_MODULE_TAG as u64)?;
                        encoder.write(&blob[..])?;
                    }
                    let payload = resolver
                        .serialize_metadata(instruction.metadata)
                        .map_err(|e| OutputStreamError::OtherError(e.to_string()))?;
                    encoder.write(source_id)?;
                    encoder.write(9u64)?;
                    encoder.write(DEBUG_INFO_TAG as u64)?;
                    encoder.write(&payload[..])?;
                }
            }
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
