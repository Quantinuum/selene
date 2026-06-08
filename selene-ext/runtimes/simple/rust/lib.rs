use std::collections::VecDeque;

use anyhow::{Result, bail};
use clap::Parser;
use selene_core::{
    export_runtime_plugin,
    metadata::{DEBUG_INFO_TAG, ResolvedBacktrace, UnresolvedBacktrace},
    runtime::{BatchOperation, Operation, RuntimeInterface, interface::RuntimeInterfaceFactory},
    utils::MetricValue,
};

/// Number of frames to capture at a QIS gate call site.
const FRAME_CAP: usize = 2;

/// Capture a backtrace at the current call site and serialise it to MessagePack bytes.
/// Returns `None` if serialisation fails.
fn capture_backtrace() -> Option<Box<[u8]>> {
    let mut unresolved = UnresolvedBacktrace::create(FRAME_CAP);
    let resolved = ResolvedBacktrace::from_unresolved(&mut unresolved);
    resolved.serialize_msgpack().ok().map(Vec::into_boxed_slice)
}

#[derive(Parser, Debug)]
struct Params {
    #[arg(long)]
    duration_ns_rxy: u64,
    #[arg(long)]
    duration_ns_rzz: u64,
    #[arg(long)]
    duration_ns_rz: u64,
    #[arg(long)]
    duration_ns_rpp: u64,
    #[arg(long)]
    duration_ns_tk2: u64,
    #[arg(long)]
    duration_ns_measure: u64,
    #[arg(long)]
    duration_ns_reset: u64,
    #[arg(long)]
    duration_ns_measure_leaked: u64,
}

#[derive(Debug, Clone, PartialEq)]
enum QubitStatus {
    Free,
    Active,
}

// We model bool and u64 results through the same
// interface, but change how we read/write them
// depending on the type of result requested.
#[derive(Debug, Clone)]
struct FutureResult {
    measured: bool,
    value: u64,
}

struct SimpleRuntime {
    qubits: Vec<QubitStatus>,
    operation_queue: VecDeque<BatchOperation>,
    future_results: Vec<FutureResult>,
    start: selene_core::time::Instant,
    params: Params,
}

impl SimpleRuntime {
    pub fn new(n_qubits: u64, start: selene_core::time::Instant, params: Params) -> Self {
        Self {
            qubits: vec![QubitStatus::Free; n_qubits as usize],
            operation_queue: VecDeque::with_capacity(10000),
            future_results: Vec::with_capacity(1000),
            start,
            params,
        }
    }

    pub fn push(&mut self, op: Operation, backtrace: Option<Box<[u8]>>) {
        let duration_ns = match op {
            Operation::RXYGate { .. } => self.params.duration_ns_rxy,
            Operation::RZZGate { .. } => self.params.duration_ns_rzz,
            Operation::RZGate { .. } => self.params.duration_ns_rz,
            Operation::RPPGate { .. } => self.params.duration_ns_rpp,
            Operation::TK2Gate { .. } => self.params.duration_ns_tk2,
            Operation::Measure { .. } => self.params.duration_ns_measure,
            Operation::Reset { .. } => self.params.duration_ns_reset,
            Operation::MeasureLeaked { .. } => self.params.duration_ns_measure_leaked,
            _ => 0,
        };
        let mut ops = Vec::with_capacity(2);
        if let Some(data) = backtrace {
            ops.push(Operation::Custom {
                custom_tag: DEBUG_INFO_TAG,
                data,
            });
        }
        ops.push(op);
        self.operation_queue
            .push_back(BatchOperation::new(ops, self.start, duration_ns.into()));
        self.start += duration_ns.into();
    }
}

impl RuntimeInterface for SimpleRuntime {
    fn exit(&mut self) -> Result<()> {
        self.operation_queue.clear();
        self.qubits.clear();
        self.future_results.clear();
        Ok(())
    }
    // Engine ops
    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        Ok(self.operation_queue.pop_front())
    }

    fn shot_start(&mut self, _shot_id: u64, _seed: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&mut self) -> Result<()> {
        self.qubits = vec![QubitStatus::Free; self.qubits.len()];
        self.operation_queue.clear();
        self.future_results.clear();
        Ok(())
    }
    fn global_barrier(&mut self, _sleep_ns: u64) -> Result<()> {
        // This runtime isn't lazy, so a barrier is not relevant
        // to its operation.
        Ok(())
    }
    fn local_barrier(&mut self, _qubits: &[u64], _sleep_ns: u64) -> Result<()> {
        // This runtime isn't lazy, so a barrier is not relevant
        // to its operation.
        Ok(())
    }
    // Allocation
    fn qalloc(&mut self) -> Result<u64> {
        for (i, qubit) in self.qubits.iter_mut().enumerate() {
            if *qubit == QubitStatus::Free {
                *qubit = QubitStatus::Active;
                return Ok(i as u64);
            }
        }
        Ok(u64::MAX)
    }
    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("freeing out-of-bounds qubit {qubit_id}")
        } else {
            self.qubits[qubit_id as usize] = QubitStatus::Free;
            Ok(())
        }
    }
    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("applying rxy gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active = self.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        self.push(
            Operation::RXYGate {
                qubit_id,
                theta,
                phi,
            },
            capture_backtrace(),
        );
        Ok(())
    }
    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        if qubit_id_1 >= self.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= self.qubits.len() as u64 {
            bail!("applying rzz gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        self.push(
            Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            },
            capture_backtrace(),
        );
        Ok(())
    }
    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("applying rz gate to out-of-bounds qubit {qubit_id}");
        }
        let QubitStatus::Active = self.qubits[qubit_id as usize] else {
            bail!("Qubit {qubit_id} is not active");
        };
        self.push(Operation::RZGate { qubit_id, theta }, capture_backtrace());
        Ok(())
    }
    fn tk2_gate(
        &mut self,
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Result<()> {
        if qubit_id_1 >= self.qubits.len() as u64 {
            bail!("applying tk2 gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= self.qubits.len() as u64 {
            bail!("applying tk2 gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        let QubitStatus::Active = self.qubits[qubit_id_1 as usize] else {
            bail!("Qubit {qubit_id_1} is not active");
        };
        let QubitStatus::Active = self.qubits[qubit_id_2 as usize] else {
            bail!("Qubit {qubit_id_2} is not active");
        };
        self.push(
            Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                alpha,
                beta,
                gamma,
            },
            capture_backtrace(),
        );
        Ok(())
    }
    fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        if qubit_id_1 >= self.qubits.len() as u64 {
            bail!("applying rpp gate to out-of-bounds qubit1 {qubit_id_1}");
        }
        if qubit_id_2 >= self.qubits.len() as u64 {
            bail!("applying rpp gate to out-of-bounds qubit2 {qubit_id_2}");
        }
        let QubitStatus::Active = self.qubits[qubit_id_1 as usize] else {
            bail!("Qubit {qubit_id_1} is not active");
        };
        let QubitStatus::Active = self.qubits[qubit_id_2 as usize] else {
            bail!("Qubit {qubit_id_2} is not active");
        };
        self.push(
            Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            },
            capture_backtrace(),
        );
        Ok(())
    }
    // Lifetime ops
    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = self.future_results.len() as u64;
        self.future_results.push(FutureResult {
            measured: false,
            value: 0,
        });
        self.push(
            Operation::Measure {
                qubit_id,
                result_id,
            },
            capture_backtrace(),
        );
        Ok(result_id)
    }
    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("measuring out-of-bounds qubit {qubit_id}")
        }
        let result_id = self.future_results.len() as u64;
        self.future_results.push(FutureResult {
            measured: false,
            value: 0,
        });
        self.push(
            Operation::MeasureLeaked {
                qubit_id,
                result_id,
            },
            capture_backtrace(),
        );
        Ok(result_id)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        if qubit_id >= self.qubits.len() as u64 {
            bail!("resetting out-of-bounds qubit {qubit_id}")
        }
        self.push(Operation::Reset { qubit_id }, capture_backtrace());
        Ok(())
    }
    fn force_result(&mut self, result_id: u64) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("forcing out-of-bounds measurement {result_id}")
        }
        // This runtime isn't lazy, so if a result has been defined,
        // the measurement should already be done.
        Ok(())
    }
    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        if result_id >= self.future_results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &self.future_results[result_id as usize];
        Ok(if result.measured {
            Some(result.value > 0)
        } else {
            None
        })
    }
    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        self.future_results[result_id as usize].value = if result { 1 } else { 0 };
        self.future_results[result_id as usize].measured = true;
        Ok(())
    }
    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        if result_id >= self.future_results.len() as u64 {
            bail!("getting out-of-bounds measurement {result_id}");
        }
        let result = &self.future_results[result_id as usize];
        Ok(if result.measured {
            Some(result.value)
        } else {
            None
        })
    }
    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        if result_id >= self.future_results.len() as u64 {
            bail!("setting out-of-bounds measurement {result_id}");
        }
        self.future_results[result_id as usize].value = result;
        self.future_results[result_id as usize].measured = true;
        Ok(())
    }

    fn increment_future_refcount(&mut self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn decrement_future_refcount(&mut self, _future_ref: u64) -> Result<()> {
        Ok(())
    }
    fn get_metric(&mut self, _nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        self.start += selene_core::time::Duration::from(delay_ns);
        Ok(())
    }
}

#[derive(Default)]
struct SimpleRuntimeFactory;

impl RuntimeInterfaceFactory for SimpleRuntimeFactory {
    type Interface = SimpleRuntime;

    fn init(
        self: std::sync::Arc<Self>,
        n_qubits: u64,
        start: selene_core::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let args: Vec<String> = args.iter().map(|s| s.as_ref().to_string()).collect();

        match Params::try_parse_from(args) {
            Ok(params) => Ok(Box::new(SimpleRuntime::new(n_qubits, start, params))),
            Err(e) => bail!("Failed to parse runtime parameters: {e}"),
        }
    }
}

export_runtime_plugin!(crate::SimpleRuntimeFactory);
