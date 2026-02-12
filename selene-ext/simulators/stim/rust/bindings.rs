#![allow(unused)]
use std::os::raw::{c_char, c_uint, c_ulonglong, c_void};
unsafe extern "C" {
    pub fn stim_tableausimulator_min_create(
        numQubits: c_uint,
        randomSeed: c_ulonglong,
    ) -> *mut c_void;
    pub fn stim_tableausimulator_min_destroy(rawptr: *mut c_void);
    pub fn stim_tableausimulator_min_do_X(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_Y(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_Z(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_H_XZ(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_X(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_Y(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_Z(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_X_DAG(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_Y_DAG(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_Z_DAG(rawptr: *mut c_void, q: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_XX(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_YY(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_ZZ(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_XX_DAG(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_YY_DAG(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_SQRT_ZZ_DAG(rawptr: *mut c_void, q0: c_uint, q1: c_uint);
    pub fn stim_tableausimulator_min_do_ZCX(rawptr: *mut c_void, qc: c_uint, qt: c_uint);
    pub fn stim_tableausimulator_min_do_ZCY(rawptr: *mut c_void, qc: c_uint, qt: c_uint);
    pub fn stim_tableausimulator_min_do_ZCZ(rawptr: *mut c_void, qc: c_uint, qt: c_uint);
    pub fn stim_tableausimulator_min_do_MZ(rawptr: *mut c_void, q: c_uint) -> bool;
    pub fn stim_tableausimulator_min_do_POSTSELECT_Z(
        rawptr: *mut c_void,
        q: c_uint,
        target_value: bool,
    ) -> bool;
    pub fn stim_tableausimulator_min_get_stabilizers(rawptr: *mut c_void, write: *mut *mut c_char);
    pub fn stim_tableausimulator_min_free_stabilizers(written: *mut c_char);
}
