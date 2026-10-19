//! Program instructions entering a runtime. These are distinct from the
//! scheduled operations sent to the quantum peripheral.
use super::{
    RuntimeInterface,
    output::{ExitRequest, ExitRequestRaw, PrintRequest, PrintRequestRaw},
};
use anyhow::{Result, anyhow, ensure};

#[derive(Clone, Debug)]
pub enum RuntimeInstruction {
    QAlloc,
    QFree {
        qubit_id: u64,
    },
    RXYGate {
        qubit_id: u64,
        theta: f64,
        phi: f64,
    },
    RZZGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    },
    RZGate {
        qubit_id: u64,
        theta: f64,
    },
    RPPGate {
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    },
    Measure {
        qubit_id: u64,
    },
    MeasureLeaked {
        qubit_id: u64,
    },
    Reset {
        qubit_id: u64,
    },
    ForceResult {
        result_id: u64,
    },
    GetBoolResult {
        result_id: u64,
    },
    GetU64Result {
        result_id: u64,
    },
    IncrementFutureRefcount {
        future: u64,
    },
    DecrementFutureRefcount {
        future: u64,
    },
    LocalBarrier {
        qubits: Vec<u64>,
        sleep_ns: u64,
    },
    GlobalBarrier {
        sleep_ns: u64,
    },
    CustomCall {
        tag: u64,
        data: Vec<u8>,
    },
    SimulateDelay {
        delay_ns: u64,
    },
    Print {
        request: PrintRequest,
    },
    Exit {
        request: ExitRequest,
    },
}

#[derive(Clone, Debug, PartialEq)]
pub enum RuntimeInstructionResult {
    None,
    Qubit(u64),
    Future(u64),
    Bool(Option<bool>),
    U64(Option<u64>),
}

/// Convenience methods for callers. Runtime implementations implement only
/// handle_instruction, so the Rust and C plugin contracts have one vocabulary.
pub trait RuntimeInstructions: RuntimeInterface {
    fn qalloc(&self) -> Result<u64> {
        match self.handle_instruction(RuntimeInstruction::QAlloc)? {
            RuntimeInstructionResult::Qubit(value) => Ok(value),
            _ => Err(anyhow!("Unexpected runtime result for QAlloc")),
        }
    }
    fn qfree(&self, qubit_id: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::QFree { qubit_id })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for QFree")),
        }
    }
    fn rxy_gate(&self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::RXYGate {
            qubit_id,
            theta,
            phi,
        })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for RXYGate")),
        }
    }
    fn rzz_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::RZZGate {
            qubit_id_1,
            qubit_id_2,
            theta,
        })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for RZZGate")),
        }
    }
    fn rz_gate(&self, qubit_id: u64, theta: f64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::RZGate { qubit_id, theta })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for RZGate")),
        }
    }
    fn rpp_gate(&self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::RPPGate {
            qubit_id_1,
            qubit_id_2,
            theta,
            phi,
        })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for RPPGate")),
        }
    }
    fn measure(&self, qubit_id: u64) -> Result<u64> {
        match self.handle_instruction(RuntimeInstruction::Measure { qubit_id })? {
            RuntimeInstructionResult::Future(value) => Ok(value),
            _ => Err(anyhow!("Unexpected runtime result for Measure")),
        }
    }
    fn measure_leaked(&self, qubit_id: u64) -> Result<u64> {
        match self.handle_instruction(RuntimeInstruction::MeasureLeaked { qubit_id })? {
            RuntimeInstructionResult::Future(value) => Ok(value),
            _ => Err(anyhow!("Unexpected runtime result for MeasureLeaked")),
        }
    }
    fn reset(&self, qubit_id: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::Reset { qubit_id })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for Reset")),
        }
    }
    fn force_result(&self, result_id: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::ForceResult { result_id })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for ForceResult")),
        }
    }
    fn get_bool_result(&self, result_id: u64) -> Result<Option<bool>> {
        match self.handle_instruction(RuntimeInstruction::GetBoolResult { result_id })? {
            RuntimeInstructionResult::Bool(value) => Ok(value),
            _ => Err(anyhow!("Unexpected runtime result for GetBoolResult")),
        }
    }
    fn get_u64_result(&self, result_id: u64) -> Result<Option<u64>> {
        match self.handle_instruction(RuntimeInstruction::GetU64Result { result_id })? {
            RuntimeInstructionResult::U64(value) => Ok(value),
            _ => Err(anyhow!("Unexpected runtime result for GetU64Result")),
        }
    }
    fn increment_future_refcount(&self, future: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::IncrementFutureRefcount { future })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!(
                "Unexpected runtime result for IncrementFutureRefcount"
            )),
        }
    }
    fn decrement_future_refcount(&self, future: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::DecrementFutureRefcount { future })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!(
                "Unexpected runtime result for DecrementFutureRefcount"
            )),
        }
    }
    fn local_barrier(&self, qubits: &[u64], sleep_ns: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::LocalBarrier {
            qubits: qubits.to_vec(),
            sleep_ns,
        })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for LocalBarrier")),
        }
    }
    fn global_barrier(&self, sleep_ns: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::GlobalBarrier { sleep_ns })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for GlobalBarrier")),
        }
    }
    fn custom_call(&self, tag: u64, data: &[u8]) -> Result<u64> {
        match self.handle_instruction(RuntimeInstruction::CustomCall {
            tag,
            data: data.to_vec(),
        })? {
            RuntimeInstructionResult::U64(value) => {
                Ok(value.ok_or_else(|| anyhow!("Missing custom call result"))?)
            }
            _ => Err(anyhow!("Unexpected runtime result for CustomCall")),
        }
    }
    fn simulate_delay(&self, delay_ns: u64) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::SimulateDelay { delay_ns })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for SimulateDelay")),
        }
    }
    fn print(&self, request: PrintRequest) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::Print { request })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for Print")),
        }
    }
    fn exit(&self, request: ExitRequest) -> Result<()> {
        match self.handle_instruction(RuntimeInstruction::Exit { request })? {
            RuntimeInstructionResult::None => Ok(()),
            _ => Err(anyhow!("Unexpected runtime result for Exit")),
        }
    }
}
impl<T: RuntimeInterface + ?Sized> RuntimeInstructions for T {}

/// C instruction tags are fixed-width integers. Unknown tags are rejected
/// before reading the corresponding union member.
#[repr(u32)]
#[derive(Clone, Copy)]
pub enum RuntimeInstructionTag {
    /// Allocate a qubit. Return Qubit with UINT64_MAX when none is free.
    QAlloc = 0,
    /// Release a previously allocated qubit address.
    QFree = 1,
    /// Schedule an RXY gate. theta and phi are in radians.
    RXYGate = 2,
    /// Schedule an RZZ gate. theta is in radians.
    RZZGate = 3,
    /// Schedule an RZ gate. theta is in radians.
    RZGate = 4,
    /// Schedule an RPP gate. theta and phi are in radians.
    RPPGate = 5,
    /// Schedule a measurement and return its new future, starting with one reference.
    Measure = 6,
    /// Schedule a leakage measurement and return a future with one reference.
    MeasureLeaked = 7,
    /// Schedule a reset of the allocated qubit.
    Reset = 8,
    /// Execute and publish the requested result before returning.
    ForceResult = 9,
    /// Read a bool future. An unavailable result is not itself an error.
    GetBoolResult = 10,
    /// Read a u64 future. An unavailable result is not itself an error.
    GetU64Result = 11,
    /// Add a reference to a live future.
    IncrementFutureRefcount = 12,
    /// Remove a reference. A future with no references must not be used again.
    DecrementFutureRefcount = 13,
    /// Place a scheduling barrier on the listed qubits, then sleep_ns of delay.
    LocalBarrier = 14,
    /// Place a scheduling barrier on all allocated qubits, then sleep_ns of delay.
    GlobalBarrier = 15,
    /// Perform a runtime-specific call and return its u64 value.
    CustomCall = 16,
    /// Schedule delay_ns of simulated inactivity.
    SimulateDelay = 17,
    /// Print a tagged value. Acceptance need not flush pending quantum work.
    Print = 18,
    /// Close program input and finish prior work and output before returning.
    Exit = 19,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct QFreeInstruction {
    pub qubit_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RXYGateInstruction {
    pub qubit_id: u64,
    pub theta: f64,
    pub phi: f64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RZZGateInstruction {
    pub qubit_id_1: u64,
    pub qubit_id_2: u64,
    pub theta: f64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RZGateInstruction {
    pub qubit_id: u64,
    pub theta: f64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RPPGateInstruction {
    pub qubit_id_1: u64,
    pub qubit_id_2: u64,
    pub theta: f64,
    pub phi: f64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct MeasureInstruction {
    pub qubit_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct MeasureLeakedInstruction {
    pub qubit_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ResetInstruction {
    pub qubit_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ForceResultInstruction {
    pub result_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GetBoolResultInstruction {
    pub result_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GetU64ResultInstruction {
    pub result_id: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct IncrementFutureRefcountInstruction {
    pub future: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct DecrementFutureRefcountInstruction {
    pub future: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct LocalBarrierInstruction {
    pub qubits: *const u64,
    pub qubits_length: u64,
    pub sleep_ns: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct GlobalBarrierInstruction {
    pub sleep_ns: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct CustomCallInstruction {
    pub tag: u64,
    pub data: *const u8,
    pub data_length: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct SimulateDelayInstruction {
    pub delay_ns: u64,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub union RuntimeInstructionPayload {
    pub qfree: QFreeInstruction,
    pub rxy_gate: RXYGateInstruction,
    pub rzz_gate: RZZGateInstruction,
    pub rz_gate: RZGateInstruction,
    pub rpp_gate: RPPGateInstruction,
    pub measure: MeasureInstruction,
    pub measure_leaked: MeasureLeakedInstruction,
    pub reset: ResetInstruction,
    pub force_result: ForceResultInstruction,
    pub get_bool_result: GetBoolResultInstruction,
    pub get_u64_result: GetU64ResultInstruction,
    pub increment_future_refcount: IncrementFutureRefcountInstruction,
    pub decrement_future_refcount: DecrementFutureRefcountInstruction,
    pub local_barrier: LocalBarrierInstruction,
    pub global_barrier: GlobalBarrierInstruction,
    pub custom_call: CustomCallInstruction,
    pub simulate_delay: SimulateDelayInstruction,
    pub print: *const PrintRequestRaw,
    pub exit: *const ExitRequestRaw,
}

/// The tag selects exactly one payload member. QAlloc ignores the payload.
/// All buffers are borrowed for this call; a runtime must copy queued work.
#[repr(C)]
pub struct RuntimeInstructionRaw {
    pub struct_size: u64,
    pub tag: u32,
    pub payload: RuntimeInstructionPayload,
}

/// The kind of result returned by an instruction.
#[repr(u32)]
#[derive(Clone, Copy)]
pub enum RuntimeInstructionResultTag {
    None = 0,
    Qubit = 1,
    Future = 2,
    Bool = 3,
    U64 = 4,
}

/// tag is a RuntimeInstructionResultTag value. QAlloc returns Qubit, Measure
/// and MeasureLeaked return Future, GetBoolResult returns Bool, and GetU64Result
/// and CustomCall return U64. Other instructions return None. available is true
/// for qubits, futures and custom-call values. Result queries can return false
/// when unavailable, without reserving any u64 value. Bool values are zero or one.
#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct RuntimeInstructionResultRaw {
    pub tag: u32,
    pub available: bool,
    pub value: u64,
}
impl RuntimeInstructionResult {
    pub fn as_raw(&self) -> RuntimeInstructionResultRaw {
        let (tag, available, value) = match self {
            Self::None => (0, false, 0),
            Self::Qubit(v) => (1, true, *v),
            Self::Future(v) => (2, true, *v),
            Self::Bool(v) => (3, v.is_some(), u64::from(v.unwrap_or(false))),
            Self::U64(v) => (4, v.is_some(), v.unwrap_or(0)),
        };
        RuntimeInstructionResultRaw {
            tag,
            available,
            value,
        }
    }
    pub fn from_raw(raw: RuntimeInstructionResultRaw) -> Result<Self> {
        Ok(match raw.tag {
            0 => Self::None,
            1 if raw.available => Self::Qubit(raw.value),
            2 if raw.available => Self::Future(raw.value),
            3 if !raw.available || raw.value <= 1 => {
                Self::Bool(raw.available.then_some(raw.value != 0))
            }
            4 => Self::U64(raw.available.then_some(raw.value)),
            _ => return Err(anyhow!("Invalid runtime instruction result")),
        })
    }
}
impl RuntimeInstruction {
    /// Copy a borrowed C instruction and all its input buffers.
    ///
    /// # Safety
    /// The pointer and selected payload must describe live, aligned buffers of
    /// their advertised types. The tag must match the initialised union member.
    pub unsafe fn from_raw(raw: *const RuntimeInstructionRaw) -> Result<Self> {
        ensure!(!raw.is_null(), "Null runtime instruction");
        ensure!(
            unsafe { (*raw).struct_size } >= size_of::<RuntimeInstructionRaw>() as u64,
            "Undersized runtime instruction"
        );
        let raw = unsafe { &*raw };
        Ok(match raw.tag {
            0 => Self::QAlloc,
            1 => {
                let value = unsafe { raw.payload.qfree };
                Self::QFree {
                    qubit_id: value.qubit_id,
                }
            }
            2 => {
                let value = unsafe { raw.payload.rxy_gate };
                Self::RXYGate {
                    qubit_id: value.qubit_id,
                    theta: value.theta,
                    phi: value.phi,
                }
            }
            3 => {
                let value = unsafe { raw.payload.rzz_gate };
                Self::RZZGate {
                    qubit_id_1: value.qubit_id_1,
                    qubit_id_2: value.qubit_id_2,
                    theta: value.theta,
                }
            }
            4 => {
                let value = unsafe { raw.payload.rz_gate };
                Self::RZGate {
                    qubit_id: value.qubit_id,
                    theta: value.theta,
                }
            }
            5 => {
                let value = unsafe { raw.payload.rpp_gate };
                Self::RPPGate {
                    qubit_id_1: value.qubit_id_1,
                    qubit_id_2: value.qubit_id_2,
                    theta: value.theta,
                    phi: value.phi,
                }
            }
            6 => {
                let value = unsafe { raw.payload.measure };
                Self::Measure {
                    qubit_id: value.qubit_id,
                }
            }
            7 => {
                let value = unsafe { raw.payload.measure_leaked };
                Self::MeasureLeaked {
                    qubit_id: value.qubit_id,
                }
            }
            8 => {
                let value = unsafe { raw.payload.reset };
                Self::Reset {
                    qubit_id: value.qubit_id,
                }
            }
            9 => {
                let value = unsafe { raw.payload.force_result };
                Self::ForceResult {
                    result_id: value.result_id,
                }
            }
            10 => {
                let value = unsafe { raw.payload.get_bool_result };
                Self::GetBoolResult {
                    result_id: value.result_id,
                }
            }
            11 => {
                let value = unsafe { raw.payload.get_u64_result };
                Self::GetU64Result {
                    result_id: value.result_id,
                }
            }
            12 => {
                let value = unsafe { raw.payload.increment_future_refcount };
                Self::IncrementFutureRefcount {
                    future: value.future,
                }
            }
            13 => {
                let value = unsafe { raw.payload.decrement_future_refcount };
                Self::DecrementFutureRefcount {
                    future: value.future,
                }
            }
            14 => {
                let value = unsafe { raw.payload.local_barrier };
                Self::LocalBarrier {
                    qubits: unsafe {
                        super::output::read_slice(value.qubits, value.qubits_length)?
                    }
                    .to_vec(),
                    sleep_ns: value.sleep_ns,
                }
            }
            15 => {
                let value = unsafe { raw.payload.global_barrier };
                Self::GlobalBarrier {
                    sleep_ns: value.sleep_ns,
                }
            }
            16 => {
                let value = unsafe { raw.payload.custom_call };
                Self::CustomCall {
                    tag: value.tag,
                    data: unsafe { super::output::read_slice(value.data, value.data_length)? }
                        .to_vec(),
                }
            }
            17 => {
                let value = unsafe { raw.payload.simulate_delay };
                Self::SimulateDelay {
                    delay_ns: value.delay_ns,
                }
            }
            18 => Self::Print {
                request: unsafe { PrintRequest::from_raw(raw.payload.print)? },
            },
            19 => Self::Exit {
                request: unsafe { ExitRequest::from_raw(raw.payload.exit)? },
            },
            _ => return Err(anyhow!("Unknown runtime instruction tag")),
        })
    }
    pub fn with_raw<T>(&self, call: impl FnOnce(&RuntimeInstructionRaw) -> T) -> T {
        let (tag, payload) = match self {
            Self::QAlloc => (
                0,
                RuntimeInstructionPayload {
                    qfree: QFreeInstruction { qubit_id: 0 },
                },
            ),
            Self::QFree { qubit_id } => (
                1,
                RuntimeInstructionPayload {
                    qfree: QFreeInstruction {
                        qubit_id: *qubit_id,
                    },
                },
            ),
            Self::RXYGate {
                qubit_id,
                theta,
                phi,
            } => (
                2,
                RuntimeInstructionPayload {
                    rxy_gate: RXYGateInstruction {
                        qubit_id: *qubit_id,
                        theta: *theta,
                        phi: *phi,
                    },
                },
            ),
            Self::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            } => (
                3,
                RuntimeInstructionPayload {
                    rzz_gate: RZZGateInstruction {
                        qubit_id_1: *qubit_id_1,
                        qubit_id_2: *qubit_id_2,
                        theta: *theta,
                    },
                },
            ),
            Self::RZGate { qubit_id, theta } => (
                4,
                RuntimeInstructionPayload {
                    rz_gate: RZGateInstruction {
                        qubit_id: *qubit_id,
                        theta: *theta,
                    },
                },
            ),
            Self::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            } => (
                5,
                RuntimeInstructionPayload {
                    rpp_gate: RPPGateInstruction {
                        qubit_id_1: *qubit_id_1,
                        qubit_id_2: *qubit_id_2,
                        theta: *theta,
                        phi: *phi,
                    },
                },
            ),
            Self::Measure { qubit_id } => (
                6,
                RuntimeInstructionPayload {
                    measure: MeasureInstruction {
                        qubit_id: *qubit_id,
                    },
                },
            ),
            Self::MeasureLeaked { qubit_id } => (
                7,
                RuntimeInstructionPayload {
                    measure_leaked: MeasureLeakedInstruction {
                        qubit_id: *qubit_id,
                    },
                },
            ),
            Self::Reset { qubit_id } => (
                8,
                RuntimeInstructionPayload {
                    reset: ResetInstruction {
                        qubit_id: *qubit_id,
                    },
                },
            ),
            Self::ForceResult { result_id } => (
                9,
                RuntimeInstructionPayload {
                    force_result: ForceResultInstruction {
                        result_id: *result_id,
                    },
                },
            ),
            Self::GetBoolResult { result_id } => (
                10,
                RuntimeInstructionPayload {
                    get_bool_result: GetBoolResultInstruction {
                        result_id: *result_id,
                    },
                },
            ),
            Self::GetU64Result { result_id } => (
                11,
                RuntimeInstructionPayload {
                    get_u64_result: GetU64ResultInstruction {
                        result_id: *result_id,
                    },
                },
            ),
            Self::IncrementFutureRefcount { future } => (
                12,
                RuntimeInstructionPayload {
                    increment_future_refcount: IncrementFutureRefcountInstruction {
                        future: *future,
                    },
                },
            ),
            Self::DecrementFutureRefcount { future } => (
                13,
                RuntimeInstructionPayload {
                    decrement_future_refcount: DecrementFutureRefcountInstruction {
                        future: *future,
                    },
                },
            ),
            Self::LocalBarrier { qubits, sleep_ns } => (
                14,
                RuntimeInstructionPayload {
                    local_barrier: LocalBarrierInstruction {
                        qubits: qubits.as_ptr(),
                        qubits_length: qubits.len() as u64,
                        sleep_ns: *sleep_ns,
                    },
                },
            ),
            Self::GlobalBarrier { sleep_ns } => (
                15,
                RuntimeInstructionPayload {
                    global_barrier: GlobalBarrierInstruction {
                        sleep_ns: *sleep_ns,
                    },
                },
            ),
            Self::CustomCall { tag, data } => (
                16,
                RuntimeInstructionPayload {
                    custom_call: CustomCallInstruction {
                        tag: *tag,
                        data: data.as_ptr(),
                        data_length: data.len() as u64,
                    },
                },
            ),
            Self::SimulateDelay { delay_ns } => (
                17,
                RuntimeInstructionPayload {
                    simulate_delay: SimulateDelayInstruction {
                        delay_ns: *delay_ns,
                    },
                },
            ),
            Self::Print { request } => {
                return call(&RuntimeInstructionRaw {
                    struct_size: size_of::<RuntimeInstructionRaw>() as u64,
                    tag: 18,
                    payload: RuntimeInstructionPayload {
                        print: &request.as_raw(),
                    },
                });
            }
            Self::Exit { request } => {
                return request.with_raw(|request| {
                    call(&RuntimeInstructionRaw {
                        struct_size: size_of::<RuntimeInstructionRaw>() as u64,
                        tag: 19,
                        payload: RuntimeInstructionPayload { exit: request },
                    })
                });
            }
        };
        call(&RuntimeInstructionRaw {
            struct_size: size_of::<RuntimeInstructionRaw>() as u64,
            tag,
            payload,
        })
    }
}
