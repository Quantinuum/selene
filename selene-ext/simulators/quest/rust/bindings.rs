#![allow(unused)]

use std::os::raw::{c_char, c_double, c_void};

unsafe extern "C" {
    pub fn selene_quest_last_error() -> *const c_char;
    pub fn selene_quest_clear_error();

    pub fn selene_quest_create(num_qubits: u32, out: *mut *mut c_void) -> bool;
    pub fn selene_quest_destroy(sim: *mut c_void);

    pub fn selene_quest_init_zero_state(sim: *mut c_void) -> bool;
    pub fn selene_quest_apply_rotate_z(sim: *mut c_void, q: u32, theta: c_double) -> bool;
    pub fn selene_quest_apply_pauli_x(sim: *mut c_void, q: u32) -> bool;
    pub fn selene_quest_apply_matrix1(
        sim: *mut c_void,
        q: u32,
        real: *const c_double,
        imag: *const c_double,
    ) -> bool;
    pub fn selene_quest_apply_matrix2(
        sim: *mut c_void,
        q0: u32,
        q1: u32,
        real: *const c_double,
        imag: *const c_double,
    ) -> bool;
    pub fn selene_quest_apply_diag_matrix2(
        sim: *mut c_void,
        q0: u32,
        q1: u32,
        real: *const c_double,
        imag: *const c_double,
    ) -> bool;
    pub fn selene_quest_prob_of_outcome(
        sim: *mut c_void,
        q: u32,
        outcome: bool,
        out: *mut c_double,
    ) -> bool;
    pub fn selene_quest_collapse_to_outcome(
        sim: *mut c_void,
        q: u32,
        outcome: bool,
        probability: *mut c_double,
    ) -> bool;
    pub fn selene_quest_get_amp(
        sim: *const c_void,
        index: u64,
        real: *mut c_double,
        imag: *mut c_double,
    ) -> bool;
}
