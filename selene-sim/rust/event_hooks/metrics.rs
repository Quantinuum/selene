use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError, Record};
use selene_core::runtime::{self, BatchOperation};

#[derive(Default, Debug)]
struct UserProgramMetrics {
    max_allocated: u64,
    currently_allocated: u64,
    qalloc_count: u64,
    qfree_count: u64,
    reset_count: u64,
    measure_request_count: u64,
    measure_leaked_request_count: u64,
    future_read_count: u64,
    rxy_count: u64,
    rz_count: u64,
    rzz_count: u64,
    global_barrier_count: u64,
    local_barrier_count: u64,
}

impl UserProgramMetrics {
    pub fn update(&mut self, operation: &Operation) {
        match operation {
            Operation::QAlloc(_) => {
                self.qalloc_count += 1;
                self.currently_allocated += 1;
                self.max_allocated = self.max_allocated.max(self.currently_allocated);
            }
            Operation::QFree(_) => {
                self.qfree_count += 1;
                self.currently_allocated -= 1;
            }
            Operation::Reset(_) => self.reset_count += 1,
            Operation::MeasureRequest(_) => self.measure_request_count += 1,
            Operation::MeasureLeakedRequest(_) => self.measure_leaked_request_count += 1,
            Operation::FutureRead(_) => self.future_read_count += 1,
            Operation::RXY(..) => self.rxy_count += 1,
            Operation::RZ(..) => self.rz_count += 1,
            Operation::RZZ(..) => self.rzz_count += 1,
            Operation::LocalBarrier(..) => self.local_barrier_count += 1,
            Operation::GlobalBarrier(..) => self.global_barrier_count += 1,
            _ => {}
        }
    }
    pub fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:qalloc_count")?
                .add_entry(self.qalloc_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:qfree_count")?
                .add_entry(self.qfree_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:reset_count")?
                .add_entry(self.reset_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:user_program:measure_request_count",
            )?
            .add_entry(self.measure_request_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:user_program:measure_leaked_request_count",
            )?
            .add_entry(self.measure_leaked_request_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:measure_read_count")?
                .add_entry(self.future_read_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:rxy_count")?
                .add_entry(self.rxy_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:rzz_count")?
                .add_entry(self.rzz_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:rz_count")?
                .add_entry(self.rz_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:global_barrier_count")?
                .add_entry(self.global_barrier_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:local_barrier_count")?
                .add_entry(self.local_barrier_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:max_allocated")?
                .add_entry(self.max_allocated)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:user_program:currently_allocated")?
                .add_entry(self.currently_allocated)?,
        )
    }
}

#[derive(Default, Debug)]
struct PostRuntimeMetrics {
    custom_op_batch_count: u64,
    custom_op_individual_count: u64,
    measure_batch_count: u64,
    measure_individual_count: u64,
    measure_leaked_batch_count: u64,
    measure_leaked_individual_count: u64,
    reset_batch_count: u64,
    reset_individual_count: u64,
    rxy_batch_count: u64,
    rxy_individual_count: u64,
    rzz_batch_count: u64,
    rzz_individual_count: u64,
    rz_batch_count: u64,
    rz_individual_count: u64,
    rpp_individual_count: u64,
    rpp_batch_count: u64,
    total_duration_ns: u64,
}

impl PostRuntimeMetrics {
    pub fn update(&mut self, batch: &BatchOperation) {
        let mut rxy_count = 0;
        let mut rzz_count = 0;
        let mut rz_count = 0;
        let mut rpp_count = 0;
        let mut measure_count = 0;
        let mut measure_leaked_count = 0;
        let mut reset_count = 0;
        let mut custom_op_count = 0;
        for op in batch.iter_ops() {
            match op {
                runtime::Operation::RXYGate { .. } => {
                    rxy_count += 1;
                }
                runtime::Operation::RZZGate { .. } => {
                    rzz_count += 1;
                }
                runtime::Operation::RZGate { .. } => {
                    rz_count += 1;
                }
                runtime::Operation::RPPGate { .. } => {
                    rpp_count += 1;
                }
                runtime::Operation::Measure { .. } => {
                    measure_count += 1;
                }
                runtime::Operation::MeasureLeaked { .. } => {
                    measure_leaked_count += 1;
                }
                runtime::Operation::Reset { .. } => {
                    reset_count += 1;
                }
                runtime::Operation::Custom { .. } => {
                    custom_op_count += 1;
                }
                _ => {
                    // Ignore other operations
                }
            }
        }

        if let Some(timing) = batch.runtime_source() {
            self.total_duration_ns = std::cmp::max(self.total_duration_ns, u64::from(timing.end()));
        }
        if rxy_count > 0 {
            self.rxy_batch_count += 1;
            self.rxy_individual_count += rxy_count;
        }
        if rzz_count > 0 {
            self.rzz_batch_count += 1;
            self.rzz_individual_count += rzz_count;
        }
        if rz_count > 0 {
            self.rz_batch_count += 1;
            self.rz_individual_count += rz_count;
        }
        if rpp_count > 0 {
            self.rpp_batch_count += 1;
            self.rpp_individual_count += rpp_count;
        }
        if measure_count > 0 {
            self.measure_batch_count += 1;
            self.measure_individual_count += measure_count;
        }
        if measure_leaked_count > 0 {
            self.measure_leaked_batch_count += 1;
            self.measure_leaked_individual_count += measure_leaked_count;
        }
        if reset_count > 0 {
            self.reset_batch_count += 1;
            self.reset_individual_count += reset_count;
        }
        if custom_op_count > 0 {
            self.custom_op_batch_count += 1;
            self.custom_op_individual_count += custom_op_count;
        }
    }
    pub fn write(
        &self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:custom_op_batch_count",
            )?
            .add_entry(self.custom_op_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:custom_op_individual_count",
            )?
            .add_entry(self.custom_op_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:measure_batch_count")?
                .add_entry(self.measure_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:measure_individual_count",
            )?
            .add_entry(self.measure_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:measure_leaked_batch_count",
            )?
            .add_entry(self.measure_leaked_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:measure_leaked_individual_count",
            )?
            .add_entry(self.measure_leaked_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:reset_batch_count")?
                .add_entry(self.reset_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(
                time_cursor,
                "METRICS:INT:post_runtime:reset_individual_count",
            )?
            .add_entry(self.reset_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rxy_batch_count")?
                .add_entry(self.rxy_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rxy_individual_count")?
                .add_entry(self.rxy_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rz_batch_count")?
                .add_entry(self.rz_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rz_individual_count")?
                .add_entry(self.rz_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rzz_batch_count")?
                .add_entry(self.rzz_batch_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:rzz_individual_count")?
                .add_entry(self.rzz_individual_count)?,
        )?;
        encoder.add_record(
            Record::new(time_cursor, "METRICS:INT:post_runtime:total_duration_ns")?
                .add_entry(self.total_duration_ns)?,
        )
    }
}

#[derive(Default, Debug)]
pub struct HighLevelMetrics {
    user_program_metrics: UserProgramMetrics,
    post_runtime_metrics: PostRuntimeMetrics,
}
impl EventHook for HighLevelMetrics {
    fn on_user_call(&mut self, operation: &Operation) {
        self.user_program_metrics.update(operation);
    }
    fn on_runtime_batch(&mut self, batch: &BatchOperation) {
        self.post_runtime_metrics.update(batch);
    }
    fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        self.user_program_metrics.write(time_cursor, encoder)?;
        self.post_runtime_metrics.write(time_cursor, encoder)?;
        Ok(())
    }
    fn on_shot_start(&mut self, _shot_id: u64) {
        self.user_program_metrics = UserProgramMetrics::default();
        self.post_runtime_metrics = PostRuntimeMetrics::default();
    }
    fn on_shot_end(&mut self) {}
}
