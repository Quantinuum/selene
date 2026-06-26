use crate::event_hooks::{EventHook, Operation};
use selene_core::encoder::{OutputStream, OutputStreamError};
use selene_core::gatewire::{DynamicGateSet, GateSemanticId, OwnedGateInstance, builtin};
use selene_core::runtime::{self, BatchOperation};
use std::collections::{BTreeMap, HashMap};

#[derive(Clone, Debug)]
struct GateMetricLabels {
    labels: HashMap<GateSemanticId, String>,
}

impl GateMetricLabels {
    fn from_gateset(gateset: &DynamicGateSet) -> Self {
        let mut label_counts: HashMap<String, usize> = HashMap::new();
        let mut labels = HashMap::new();

        for decl in gateset.declarations() {
            *label_counts
                .entry(sanitize_metric_label(&decl.name))
                .or_default() += 1;
        }
        for decl in gateset.declarations() {
            let mut label = sanitize_metric_label(&decl.name);
            if label_counts.get(&label).copied().unwrap_or_default() > 1 {
                label = format!("{label}_{}", short_semantic_id(decl.semantic_id));
            }
            labels.insert(decl.semantic_id, label);
        }

        Self { labels }
    }

    fn label(&self, semantic_id: GateSemanticId) -> String {
        self.labels
            .get(&semantic_id)
            .cloned()
            .unwrap_or_else(|| format!("semantic_{}", short_semantic_id(semantic_id)))
    }
}

impl Default for GateMetricLabels {
    fn default() -> Self {
        Self::from_gateset(&builtin::all())
    }
}

fn sanitize_metric_label(name: &str) -> String {
    let mut label = String::new();
    let mut last_was_separator = false;

    for ch in name.chars() {
        if ch.is_ascii_alphanumeric() {
            label.push(ch);
            last_was_separator = false;
        } else if !last_was_separator && !label.is_empty() {
            label.push('_');
            last_was_separator = true;
        }
    }

    while label.ends_with('_') {
        label.pop();
    }
    if label.is_empty() {
        "gate".to_string()
    } else {
        label
    }
}

fn short_semantic_id(semantic_id: GateSemanticId) -> String {
    semantic_id
        .bytes
        .iter()
        .take(4)
        .map(|byte| format!("{byte:02x}"))
        .collect()
}

fn write_metric(
    encoder: &mut OutputStream,
    time_cursor: u64,
    key: &str,
    value: u64,
) -> Result<(), OutputStreamError> {
    encoder.begin_message(time_cursor)?;
    encoder.write(key)?;
    encoder.write(value)?;
    encoder.end_message()
}

fn user_gate_semantic_id(operation: &Operation) -> Option<GateSemanticId> {
    match operation {
        Operation::Gate(data) => OwnedGateInstance::deserialize(data)
            .ok()
            .map(|gate| gate.semantic_id),
        _ => None,
    }
}

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
    gate_counts: BTreeMap<String, u64>,
    global_barrier_count: u64,
    local_barrier_count: u64,
}

impl UserProgramMetrics {
    pub fn update(&mut self, operation: &Operation, labels: &GateMetricLabels) {
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
            Operation::LocalBarrier(..) => self.local_barrier_count += 1,
            Operation::GlobalBarrier(..) => self.global_barrier_count += 1,
            _ => {}
        }
        if let Some(semantic_id) = user_gate_semantic_id(operation) {
            *self
                .gate_counts
                .entry(labels.label(semantic_id))
                .or_default() += 1;
        }
    }
    pub fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:qalloc_count",
            self.qalloc_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:qfree_count",
            self.qfree_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:reset_count",
            self.reset_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:measure_request_count",
            self.measure_request_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:measure_leaked_request_count",
            self.measure_leaked_request_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:measure_read_count",
            self.future_read_count,
        )?;
        for (label, count) in &self.gate_counts {
            write_metric(
                encoder,
                time_cursor,
                &format!("METRICS:INT:user_program:gate:{label}:count"),
                *count,
            )?;
        }
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:global_barrier_count",
            self.global_barrier_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:local_barrier_count",
            self.local_barrier_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:max_allocated",
            self.max_allocated,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:user_program:currently_allocated",
            self.currently_allocated,
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
    gate_batch_counts: BTreeMap<String, u64>,
    gate_individual_counts: BTreeMap<String, u64>,
    total_duration_ns: u64,
}

impl PostRuntimeMetrics {
    pub fn update(&mut self, batch: &BatchOperation, labels: &GateMetricLabels) {
        let mut gate_counts: BTreeMap<String, u64> = BTreeMap::new();
        let mut measure_count = 0;
        let mut measure_leaked_count = 0;
        let mut reset_count = 0;
        let mut custom_op_count = 0;
        for op in batch.iter_ops() {
            match op {
                runtime::Operation::Gate { gate } => {
                    *gate_counts
                        .entry(labels.label(gate.semantic_id))
                        .or_default() += 1;
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
                _ => {}
            }
        }

        if let Some(timing) = batch.runtime_source() {
            self.total_duration_ns = std::cmp::max(self.total_duration_ns, u64::from(timing.end()));
        }
        for (label, count) in gate_counts {
            *self.gate_batch_counts.entry(label.clone()).or_default() += 1;
            *self.gate_individual_counts.entry(label).or_default() += count;
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
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:custom_op_batch_count",
            self.custom_op_batch_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:custom_op_individual_count",
            self.custom_op_individual_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:measure_batch_count",
            self.measure_batch_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:measure_individual_count",
            self.measure_individual_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:measure_leaked_batch_count",
            self.measure_leaked_batch_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:measure_leaked_individual_count",
            self.measure_leaked_individual_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:reset_batch_count",
            self.reset_batch_count,
        )?;
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:reset_individual_count",
            self.reset_individual_count,
        )?;
        for (label, count) in &self.gate_batch_counts {
            write_metric(
                encoder,
                time_cursor,
                &format!("METRICS:INT:post_runtime:gate:{label}:batch_count"),
                *count,
            )?;
        }
        for (label, count) in &self.gate_individual_counts {
            write_metric(
                encoder,
                time_cursor,
                &format!("METRICS:INT:post_runtime:gate:{label}:individual_count"),
                *count,
            )?;
        }
        write_metric(
            encoder,
            time_cursor,
            "METRICS:INT:post_runtime:total_duration_ns",
            self.total_duration_ns,
        )
    }
}

#[derive(Debug, Default)]
pub struct HighLevelMetrics {
    user_program_metrics: UserProgramMetrics,
    post_runtime_metrics: PostRuntimeMetrics,
    user_gate_labels: GateMetricLabels,
    runtime_gate_labels: GateMetricLabels,
}
impl EventHook for HighLevelMetrics {
    fn on_user_call(&mut self, operation: &Operation) {
        self.user_program_metrics
            .update(operation, &self.user_gate_labels);
    }
    fn on_gatesets_registered(
        &mut self,
        user_gateset: &DynamicGateSet,
        runtime_gateset: &DynamicGateSet,
    ) {
        self.user_gate_labels = GateMetricLabels::from_gateset(user_gateset);
        self.runtime_gate_labels = GateMetricLabels::from_gateset(runtime_gateset);
    }
    fn on_runtime_batch(&mut self, batch: &BatchOperation) {
        self.post_runtime_metrics
            .update(batch, &self.runtime_gate_labels);
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

#[cfg(test)]
mod tests {
    use super::*;
    use selene_core::gatewire::{GateDecl, GateValue, OperandKind, OperandSpec};

    fn custom_gate() -> (DynamicGateSet, OwnedGateInstance) {
        let semantic_id = GateSemanticId::from_text("test.selene.metrics.magic.v1");
        let declaration = GateDecl::new(
            semantic_id,
            "Magic Phase!",
            [OperandSpec::new("q0", OperandKind::Qubit)],
            1,
        );
        let gateset = DynamicGateSet::from_declarations([declaration]).unwrap();
        let gate = OwnedGateInstance::new(semantic_id, [GateValue::Qubit(0)]);
        (gateset, gate)
    }

    #[test]
    fn user_program_gate_metrics_use_registered_gate_names() {
        let (gateset, gate) = custom_gate();
        let labels = GateMetricLabels::from_gateset(&gateset);
        let mut metrics = UserProgramMetrics::default();

        metrics.update(&Operation::Gate(gate.serialize()), &labels);

        assert_eq!(metrics.gate_counts.get("Magic_Phase"), Some(&1));
    }

    #[test]
    fn post_runtime_gate_metrics_use_registered_gate_names() {
        let (gateset, gate) = custom_gate();
        let labels = GateMetricLabels::from_gateset(&gateset);
        let batch = BatchOperation::simulator(vec![runtime::Operation::Gate { gate }]);
        let mut metrics = PostRuntimeMetrics::default();

        metrics.update(&batch, &labels);

        assert_eq!(metrics.gate_batch_counts.get("Magic_Phase"), Some(&1));
        assert_eq!(metrics.gate_individual_counts.get("Magic_Phase"), Some(&1));
    }
}
