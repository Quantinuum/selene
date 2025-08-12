#![allow(dead_code)]

use crate::bindings;

pub struct TableauSimulatorMin {
    ptr: *mut std::ffi::c_void,
}
impl TableauSimulatorMin {
    pub fn new(num_qubits: u32, random_seed: u64) -> Self {
        Self {
            ptr: unsafe { bindings::stim_tableausimulator_min_create(num_qubits, random_seed) },
        }
    }
    pub fn x(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_X(self.ptr, q) }
    }
    pub fn y(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_Y(self.ptr, q) }
    }
    pub fn z(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_Z(self.ptr, q) }
    }
    pub fn h(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_H_XZ(self.ptr, q) }
    }
    pub fn sqrt_x(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_X(self.ptr, q) }
    }
    pub fn sqrt_y(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_Y(self.ptr, q) }
    }
    pub fn sqrt_z(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_Z(self.ptr, q) }
    }
    pub fn sqrt_x_dag(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_X_DAG(self.ptr, q) }
    }
    pub fn sqrt_y_dag(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_Y_DAG(self.ptr, q) }
    }
    pub fn sqrt_z_dag(&mut self, q: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_Z_DAG(self.ptr, q) }
    }
    pub fn sqrt_xx(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_XX(self.ptr, q0, q1) }
    }
    pub fn sqrt_yy(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_YY(self.ptr, q0, q1) }
    }
    pub fn sqrt_zz(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_ZZ(self.ptr, q0, q1) }
    }
    pub fn sqrt_xx_dag(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_XX_DAG(self.ptr, q0, q1) }
    }
    pub fn sqrt_yy_dag(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_YY_DAG(self.ptr, q0, q1) }
    }
    pub fn sqrt_zz_dag(&mut self, q0: u32, q1: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_SQRT_ZZ_DAG(self.ptr, q0, q1) }
    }
    pub fn h(&mut self, q: u32) {
        unsafe { bindings::cstim_TableauSimulator64_do_H_XZ(self.ptr, q) }
    }
    pub fn mz(&mut self, q: u32) -> bool {
        unsafe { bindings::stim_tableausimulator_min_do_MZ(self.ptr, q) }
    }
    pub fn cx(&mut self, q_control: u32, q_target: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_ZCX(self.ptr, q_control, q_target) }
    }
    pub fn cy(&mut self, q_control: u32, q_target: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_ZCY(self.ptr, q_control, q_target) }
    }
    pub fn cz(&mut self, q_control: u32, q_target: u32) {
        unsafe { bindings::stim_tableausimulator_min_do_ZCZ(self.ptr, q_control, q_target) }
    }
    pub fn postselect_z(&mut self, q: u32, target_value: bool) -> bool {
        unsafe { bindings::stim_tableausimulator_min_do_POSTSELECT_Z(self.ptr, q, target_value) }
    }
    pub fn get_stabilisers(&mut self) -> String {
        let mut stringptr = std::ptr::null_mut();
        unsafe { bindings::stim_tableausimulator_min_get_stabilizers(self.ptr, &mut stringptr) };
        let result: String = unsafe {
            if stringptr.is_null() {
                String::new()
            } else {
                std::ffi::CStr::from_ptr(stringptr)
                    .to_string_lossy()
                    .into_owned()
            }
        };
        unsafe { bindings::stim_tableausimulator_min_free_stabilizers(stringptr) };
        result
    }
}

impl Drop for TableauSimulatorMin {
    fn drop(&mut self) {
        unsafe { bindings::stim_tableausimulator_min_destroy(self.ptr) }
    }
}
