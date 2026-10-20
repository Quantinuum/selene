use anyhow::Result;

use selene_core::encoder::Record;
use selene_core::utils::MetricValue;

use crate::selene_instance::SeleneInstance;

impl SeleneInstance {
    fn write_metric(
        &self,
        metric_category: &str,
        metric_tag: &str,
        metric_value: MetricValue,
    ) -> Result<()> {
        let type_str = match metric_value {
            MetricValue::Bool(_) => "BOOL",
            MetricValue::I64(_) => "INT",
            MetricValue::U64(_) => "INT",
            MetricValue::F64(_) => "FLOAT",
        };
        let full_tag = format!("METRICS:{}:{}:{}", type_str, metric_category, metric_tag);
        let mut record = Record::new(self.time_cursor()?, full_tag.as_str())?;
        match metric_value {
            MetricValue::Bool(v) => record.push(v)?,
            MetricValue::I64(v) => record.push(v)?,
            MetricValue::U64(v) => record.push(v)?,
            MetricValue::F64(v) => record.push(v)?,
        };
        self.out_encoder.lock().add_record(record)?;
        Ok(())
    }
    pub fn write_metrics(&self) -> Result<()> {
        self.write_metric(
            "emulator",
            "shot_number",
            MetricValue::U64(self.shot_number),
        )?;
        for (category, tag, value) in self.emulator.metrics()? {
            self.write_metric(category, &tag, value)?;
        }
        Ok(())
    }
    pub fn write_metadata(&self) -> Result<()> {
        self.emulator
            .event_hooks
            .write(self.time_cursor()?, &mut self.out_encoder.lock())?;
        Ok(())
    }
}
