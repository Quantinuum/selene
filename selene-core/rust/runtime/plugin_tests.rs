//! Probe guards inside foreign callbacks without relying on thread scheduling.
use super::*;
use std::sync::{Mutex, RwLock, TryLockError};

unsafe fn check_access(handle: RuntimeInstance, exclusive: bool) -> Errno {
    // SAFETY: the test pins the RuntimePlugin in a Box and uses its access
    // lock as the opaque handle for these test-only foreign functions.
    let access = unsafe { &*handle.cast::<RwLock<()>>() };
    let writer_blocked = matches!(access.try_write(), Err(TryLockError::WouldBlock));
    let reader_blocked = matches!(access.try_read(), Err(TryLockError::WouldBlock));
    if writer_blocked && reader_blocked == exclusive {
        0
    } else {
        -1
    }
}
unsafe extern "C" fn init_fn(
    _handle: *mut RuntimeInstance,
    _n_qubits: u64,
    _start: u64,
    _argc: u32,
    _argv: *const *const ffi::c_char,
) -> Errno {
    0
}
unsafe extern "C" fn exit_fn(handle: RuntimeInstance) -> Errno {
    unsafe { check_access(handle, true) }
}
unsafe extern "C" fn get_next_operations_fn(
    handle: RuntimeInstance,
    _ops: RuntimeGetOperationHandle,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn shot_start_fn(handle: RuntimeInstance, _shot_id: u64, _seed: u64) -> Errno {
    unsafe { check_access(handle, true) }
}
unsafe extern "C" fn shot_end_fn(handle: RuntimeInstance) -> Errno {
    unsafe { check_access(handle, true) }
}
unsafe extern "C" fn get_metrics_fn(
    handle: RuntimeInstance,
    _nth_metric: u8,
    _tag_out: *mut ffi::c_char,
    _datatype_out: *mut u8,
    _value_out: *mut u64,
) -> i32 {
    let status = unsafe { check_access(handle, true) };
    if status == 0 { 1 } else { status }
}
unsafe extern "C" fn qalloc_fn(handle: RuntimeInstance, _qaddress_out: *mut u64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn qfree_fn(handle: RuntimeInstance, _qaddress: u64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn local_barrier_fn(
    handle: RuntimeInstance,
    _qubits: *const u64,
    _qubits_len: u64,
    _sleep_ns: u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn global_barrier_fn(handle: RuntimeInstance, _sleep_ns: u64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn rxy_gate_fn(
    handle: RuntimeInstance,
    _qubit: u64,
    _theta: f64,
    _phi: f64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn rzz_gate_fn(
    handle: RuntimeInstance,
    _qubit0: u64,
    _qubit1: u64,
    _theta: f64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn rz_gate_fn(handle: RuntimeInstance, _qubit: u64, _theta: f64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn rpp_gate_fn(
    handle: RuntimeInstance,
    _qubit0: u64,
    _qubit1: u64,
    _theta: f64,
    _phi: f64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn measure_fn(
    handle: RuntimeInstance,
    _qubit: u64,
    _result_id: *mut u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn measure_leaked_fn(
    handle: RuntimeInstance,
    _qubit: u64,
    _result_id: *mut u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn reset_fn(handle: RuntimeInstance, _qubit: u64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn force_result_fn(handle: RuntimeInstance, _result_id: u64) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn get_bool_result_fn(
    handle: RuntimeInstance,
    _id: u64,
    _result: *mut i8,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn get_u64_result_fn(
    handle: RuntimeInstance,
    _id: u64,
    _result: *mut u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn set_bool_result_fn(
    handle: RuntimeInstance,
    _result_id: u64,
    _result: bool,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn set_u64_result_fn(
    handle: RuntimeInstance,
    _result_id: u64,
    _result: u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn increment_future_refcount_fn(
    handle: RuntimeInstance,
    _result_id: u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn decrement_future_refcount_fn(
    handle: RuntimeInstance,
    _result_id: u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn custom_call_fn(
    handle: RuntimeInstance,
    _tag: u64,
    _data: *const ffi::c_void,
    _data_len: usize,
    _result: *mut u64,
) -> Errno {
    unsafe { check_access(handle, false) }
}
unsafe extern "C" fn simulate_delay_fn(handle: RuntimeInstance, _delay_ns: u64) -> Errno {
    unsafe { check_access(handle, false) }
}

#[test]
fn foreign_calls_use_shared_or_exclusive_access() {
    let interface = Arc::new(RuntimePluginInterface {
        _lib: libloading::os::unix::Library::this().into(),
        init_fn,
        exit_fn: Some(exit_fn),
        get_next_operations_fn,
        shot_start_fn,
        shot_end_fn,
        get_metrics_fn: Some(get_metrics_fn),
        qalloc_fn,
        qfree_fn,
        local_barrier_fn,
        global_barrier_fn,
        rxy_gate_fn,
        rzz_gate_fn,
        rz_gate_fn,
        rpp_gate_fn,
        measure_fn,
        measure_leaked_fn,
        reset_fn,
        force_result_fn,
        get_bool_result_fn,
        get_u64_result_fn,
        set_bool_result_fn,
        set_u64_result_fn,
        increment_future_refcount_fn,
        decrement_future_refcount_fn,
        custom_call_fn: Some(custom_call_fn),
        simulate_delay_fn: Some(simulate_delay_fn),
    });
    let mut runtime = Box::new(RuntimePlugin {
        interface,
        instance: std::ptr::null(),
        retrieval: Mutex::new(()),
        access: RwLock::new(()),
    });
    runtime.instance = (&raw const runtime.access).cast();
    let runtime = &*runtime;
    runtime.shot_start(0, 0).unwrap();
    runtime.qalloc().unwrap();
    runtime.qfree(0).unwrap();
    runtime.rxy_gate(0, 0.0, 0.0).unwrap();
    runtime.rzz_gate(0, 1, 0.0).unwrap();
    runtime.rz_gate(0, 0.0).unwrap();
    runtime.rpp_gate(0, 1, 0.0, 0.0).unwrap();
    runtime.measure(0).unwrap();
    runtime.measure_leaked(0).unwrap();
    runtime.reset(0).unwrap();
    runtime.force_result(0).unwrap();
    runtime.get_bool_result(0).unwrap();
    runtime.get_u64_result(0).unwrap();
    runtime.set_bool_result(0, true).unwrap();
    runtime.set_u64_result(0, 1).unwrap();
    runtime.increment_future_refcount(0).unwrap();
    runtime.decrement_future_refcount(0).unwrap();
    runtime.local_barrier(&[0], 0).unwrap();
    runtime.global_barrier(0).unwrap();
    runtime.custom_call(0, &[]).unwrap();
    runtime.simulate_delay(0).unwrap();
    runtime.get_next_operations().unwrap();
    runtime.shot_end().unwrap();
    runtime.get_metric(0).unwrap();
    runtime.exit().unwrap();
}
