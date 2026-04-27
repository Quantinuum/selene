use std::cell::RefCell;
use std::rc::Rc;

use selene_core::encoder::{OutputStream, OutputStreamError};
use selene_core::error_model::BatchResult;
use selene_core::runtime::BatchOperation;

pub mod instruction_log;
pub mod measurement_log;
pub mod metrics;

#[derive(Clone)]
pub enum Operation {
    QFree(u64),
    QAlloc(u64),
    RXY(u64, f64, f64),
    RZZ(u64, u64, f64),
    RZ(u64, f64),
    RPP(u64, u64, f64, f64),
    TK2(u64, u64, f64, f64, f64),
    Reset(u64),
    MeasureRequest(u64),
    MeasureLeakedRequest(u64),
    FutureRead(u64),
    BatchStart(u64, u64),
    GlobalBarrier(u64),
    LocalBarrier(Vec<u64>, u64),
    Custom(u64, Vec<u8>),
    ClassicalDelay(u64),
    Postselect(u64, bool),
}

impl Operation {
    pub fn from_runtime_operation(operation: &selene_core::runtime::Operation) -> Self {
        match operation {
            selene_core::runtime::Operation::Reset { qubit_id } => Operation::Reset(*qubit_id),
            selene_core::runtime::Operation::RXYGate {
                qubit_id,
                theta,
                phi,
            } => Operation::RXY(*qubit_id, *theta, *phi),
            selene_core::runtime::Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            } => Operation::RZZ(*qubit_id_1, *qubit_id_2, *theta),
            selene_core::runtime::Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            } => Operation::RPP(*qubit_id_1, *qubit_id_2, *theta, *phi),
            selene_core::runtime::Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                alpha,
                beta,
                gamma,
            } => Operation::TK2(*qubit_id_1, *qubit_id_2, *alpha, *beta, *gamma),
            selene_core::runtime::Operation::RZGate { qubit_id, theta } => {
                Operation::RZ(*qubit_id, *theta)
            }
            selene_core::runtime::Operation::Measure { qubit_id, .. } => {
                Operation::FutureRead(*qubit_id)
            }
            selene_core::runtime::Operation::MeasureLeaked { qubit_id, .. } => {
                Operation::FutureRead(*qubit_id)
            }
            selene_core::runtime::Operation::Custom { custom_tag, data } => {
                Operation::Custom(*custom_tag as u64, data.to_vec())
            }
            _ => todo!(
                "Unsupported runtime operation in instruction log: {:?}",
                operation
            ),
        }
    }

    pub fn from_simulator_operation(operation: &selene_core::runtime::Operation) -> Self {
        match operation {
            selene_core::runtime::Operation::Reset { qubit_id } => Operation::Reset(*qubit_id),
            selene_core::runtime::Operation::RXYGate {
                qubit_id,
                theta,
                phi,
            } => Operation::RXY(*qubit_id, *theta, *phi),
            selene_core::runtime::Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            } => Operation::RZZ(*qubit_id_1, *qubit_id_2, *theta),
            selene_core::runtime::Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            } => Operation::RPP(*qubit_id_1, *qubit_id_2, *theta, *phi),
            selene_core::runtime::Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                alpha,
                beta,
                gamma,
            } => Operation::TK2(*qubit_id_1, *qubit_id_2, *alpha, *beta, *gamma),
            selene_core::runtime::Operation::RZGate { qubit_id, theta } => {
                Operation::RZ(*qubit_id, *theta)
            }
            selene_core::runtime::Operation::Measure { qubit_id, .. } => {
                Operation::MeasureRequest(*qubit_id)
            }
            selene_core::runtime::Operation::MeasureLeaked { qubit_id, .. } => {
                Operation::MeasureLeakedRequest(*qubit_id)
            }
            selene_core::runtime::Operation::Custom { custom_tag, data } => {
                Operation::Custom(*custom_tag as u64, data.to_vec())
            }
            _ => todo!(
                "Unsupported simulator operation in instruction log: {:?}",
                operation
            ),
        }
    }
}

pub trait EventHook {
    fn on_user_call(&mut self, _: &Operation) {}
    fn on_runtime_batch(&mut self, _: &BatchOperation) {}
    fn on_error_model_output(&mut self, _: &Operation) {}
    fn on_simulator_call(&mut self, _: &Operation, _: u64) {}
    fn on_runtime_results(&mut self, _: &BatchResult) {}
    fn write(
        &mut self,
        _time_cursor: u64,
        _encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        Ok(())
    }
    fn on_shot_start(&mut self, _shot_id: u64) {}
    fn on_shot_end(&mut self) {}
}

#[derive(Default)]
pub struct MultiEventHook {
    hooks: Vec<Box<dyn EventHook>>,
}
impl MultiEventHook {
    pub fn add_hook(&mut self, hook: Box<dyn EventHook>) {
        self.hooks.push(hook);
    }
}

impl EventHook for MultiEventHook {
    fn on_user_call(&mut self, operation: &Operation) {
        for hook in self.hooks.iter_mut() {
            hook.on_user_call(operation);
        }
    }
    fn on_runtime_batch(&mut self, operation: &BatchOperation) {
        for hook in self.hooks.iter_mut() {
            hook.on_runtime_batch(operation);
        }
    }
    fn on_error_model_output(&mut self, operation: &Operation) {
        for hook in self.hooks.iter_mut() {
            hook.on_error_model_output(operation);
        }
    }
    fn on_simulator_call(&mut self, operation: &Operation, duration_ns: u64) {
        for hook in self.hooks.iter_mut() {
            hook.on_simulator_call(operation, duration_ns);
        }
    }
    fn on_runtime_results(&mut self, results: &BatchResult) {
        for hook in self.hooks.iter_mut() {
            hook.on_runtime_results(results);
        }
    }
    fn write(
        &mut self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        for hook in self.hooks.iter_mut() {
            hook.write(time_cursor, encoder)?;
        }
        Ok(())
    }
    fn on_shot_start(&mut self, shot_id: u64) {
        for hook in self.hooks.iter_mut() {
            hook.on_shot_start(shot_id);
        }
    }
    fn on_shot_end(&mut self) {
        for hook in self.hooks.iter_mut() {
            hook.on_shot_end();
        }
    }
}

#[derive(Clone, Default)]
pub struct SharedEventHook {
    hooks: Rc<RefCell<MultiEventHook>>,
}

impl SharedEventHook {
    fn with_hooks<T>(&self, callback: impl FnOnce(&mut MultiEventHook) -> T) -> T {
        let mut hooks = self.hooks.borrow_mut();
        callback(&mut hooks)
    }

    pub fn add_hook(&self, hook: Box<dyn EventHook>) {
        self.with_hooks(|hooks| hooks.add_hook(hook));
    }

    pub fn on_user_call(&self, operation: &Operation) {
        self.with_hooks(|hooks| hooks.on_user_call(operation));
    }

    pub fn on_runtime_batch(&self, batch: &BatchOperation) {
        self.with_hooks(|hooks| hooks.on_runtime_batch(batch));
    }

    pub fn on_error_model_output(&self, operation: &Operation) {
        self.with_hooks(|hooks| hooks.on_error_model_output(operation));
    }

    pub fn on_simulator_call(&self, operation: &Operation, duration_ns: u64) {
        self.with_hooks(|hooks| hooks.on_simulator_call(operation, duration_ns));
    }

    pub fn on_runtime_results(&self, results: &BatchResult) {
        self.with_hooks(|hooks| hooks.on_runtime_results(results));
    }

    pub fn write(
        &self,
        time_cursor: u64,
        encoder: &mut OutputStream,
    ) -> Result<(), OutputStreamError> {
        self.with_hooks(|hooks| hooks.write(time_cursor, encoder))
    }

    pub fn on_shot_start(&self, shot_id: u64) {
        self.with_hooks(|hooks| hooks.on_shot_start(shot_id));
    }

    pub fn on_shot_end(&self) {
        self.with_hooks(|hooks| hooks.on_shot_end());
    }
}
