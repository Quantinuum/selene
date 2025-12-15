use crate::event_hooks::{BatchOperation, BatchResult, EventHook};
use selene_core::encoder::{OutputStream, OutputStreamError};
use selene_core::runtime::Operation;
use std::collections::{BTreeMap, VecDeque};

enum MeasType {
    Measure,
    MeasureLeaked,
}

/// Information about a completed measurement
struct MeasLogEnt {
    /// Type of measurement
    pub meas_type: MeasType,
    /// ID of measured qubit
    pub qubit_id: u64,
    /// Measurement result (2=leaked)
    pub value: u64,
}

impl MeasLogEnt {
    pub fn write(&self, encoder: &mut OutputStream) -> Result<(), OutputStreamError> {
        let is_meas_leaked: u64 = match self.meas_type {
            MeasType::Measure => 0,
            MeasType::MeasureLeaked => 1,
        };
        encoder.write(is_meas_leaked)?;
        encoder.write(self.qubit_id)?;
        encoder.write(self.value)
    }

    /// Constructor which checks the result value is valid
    pub fn new(meas_type: MeasType, qubit_id: u64, value: u64) -> Self {
        match meas_type {
            MeasType::Measure => {
                assert!(value <= 1, "Invalid value for Measure result")
            }
            MeasType::MeasureLeaked => {
                assert!(value <= 2, "Invalid value for MeasureLeaked result")
            }
        };

        Self {
            meas_type,
            qubit_id,
            value,
        }
    }
}

struct MeasCall {
    pub meas_type: MeasType,
    pub qubit_id: u64,
    pub result_id: u64,
}

#[derive(Default)]
pub struct MeasurementLog {
    /// Unmatched measure calls from the current batch, in program order
    meas_calls: VecDeque<MeasCall>,
    /// per-qubit sequences of measurement results recorded during the current shot
    entries: VecDeque<MeasLogEnt>,
}

impl EventHook for MeasurementLog {
    fn on_runtime_batch(&mut self, operations: &BatchOperation) {
        for op in operations.iter_ops() {
            match *op {
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => {
                    self.meas_calls.push_back(MeasCall {
                        meas_type: MeasType::Measure,
                        qubit_id,
                        result_id,
                    });
                }
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => {
                    self.meas_calls.push_back(MeasCall {
                        meas_type: MeasType::MeasureLeaked,
                        qubit_id,
                        result_id,
                    });
                }
                _ => (),
            }
        }
    }

    fn on_runtime_results(&mut self, results: &BatchResult) {
        // build a map from result ID to value
        // NOTE: we could support duplicate result IDs if the need arises,
        // by storing a sequence of values instead of an individual
        let mut result_map = BTreeMap::<u64, u64>::new();
        for r in results.bool_results.iter() {
            let maybe_prev = result_map.insert(r.result_id, r.value as u64);
            assert!(maybe_prev.is_none(), "Duplicate result ID in result batch");
        }
        for r in results.u64_results.iter() {
            let maybe_prev = result_map.insert(r.result_id, r.value);
            assert!(maybe_prev.is_none(), "Duplicate result ID in result batch");
        }

        // append entries to output using the order in meas_calls
        while let Some(call) = self.meas_calls.pop_front() {
            let result_value = result_map
                .remove(&call.result_id)
                .expect("Result ID from meas call not found in result batch");
            self.entries
                .push_back(MeasLogEnt::new(call.meas_type, call.qubit_id, result_value));
        }
        assert!(
            result_map.is_empty(),
            "Result(s) in result batch do not have a matching call"
        );
    }

    fn write(&self, time_cursor: u64, encoder: &mut OutputStream) -> Result<(), OutputStreamError> {
        encoder.begin_message(time_cursor)?;
        encoder.write("MEASUREMENTLOG")?;
        for entry in self.entries.iter() {
            entry.write(encoder)?;
        }
        encoder.end_message()
    }

    fn on_shot_start(&mut self, _shot_id: u64) {
        self.entries.clear();
    }
}
