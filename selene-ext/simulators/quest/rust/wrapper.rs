use crate::bindings;
use anyhow::{Result, anyhow};
use std::ffi::CStr;

pub struct QuestBackend {
    ptr: *mut std::ffi::c_void,
}

impl QuestBackend {
    pub fn new(num_qubits: u32) -> Result<Self> {
        let mut ptr = std::ptr::null_mut();
        check(unsafe { bindings::selene_quest_create(num_qubits, &mut ptr) })?;
        if ptr.is_null() {
            return Err(anyhow!("QuEST returned a null simulator handle"));
        }
        Ok(Self { ptr })
    }

    pub fn init_zero_state(&mut self) -> Result<()> {
        check(unsafe { bindings::selene_quest_init_zero_state(self.ptr) })
    }

    pub fn rotate_z(&mut self, q: u32, theta: f64) -> Result<()> {
        check(unsafe { bindings::selene_quest_apply_rotate_z(self.ptr, q, theta) })
    }

    pub fn pauli_x(&mut self, q: u32) -> Result<()> {
        check(unsafe { bindings::selene_quest_apply_pauli_x(self.ptr, q) })
    }

    pub fn matrix1(&mut self, q: u32, real: &[f64; 4], imag: &[f64; 4]) -> Result<()> {
        check(unsafe {
            bindings::selene_quest_apply_matrix1(self.ptr, q, real.as_ptr(), imag.as_ptr())
        })
    }

    pub fn matrix2(&mut self, q0: u32, q1: u32, real: &[f64; 16], imag: &[f64; 16]) -> Result<()> {
        check(unsafe {
            bindings::selene_quest_apply_matrix2(self.ptr, q0, q1, real.as_ptr(), imag.as_ptr())
        })
    }

    pub fn diag_matrix2(
        &mut self,
        q0: u32,
        q1: u32,
        real: &[f64; 4],
        imag: &[f64; 4],
    ) -> Result<()> {
        check(unsafe {
            bindings::selene_quest_apply_diag_matrix2(
                self.ptr,
                q0,
                q1,
                real.as_ptr(),
                imag.as_ptr(),
            )
        })
    }

    pub fn prob_of_outcome(&mut self, q: u32, outcome: bool) -> Result<f64> {
        let mut probability = 0.0;
        check(unsafe {
            bindings::selene_quest_prob_of_outcome(self.ptr, q, outcome, &mut probability)
        })?;
        Ok(probability)
    }

    pub fn collapse_to_outcome(&mut self, q: u32, outcome: bool) -> Result<f64> {
        let mut probability = 0.0;
        check(unsafe {
            bindings::selene_quest_collapse_to_outcome(self.ptr, q, outcome, &mut probability)
        })?;
        Ok(probability)
    }

    pub fn amp(&self, index: u64) -> Result<(f64, f64)> {
        let mut real = 0.0;
        let mut imag = 0.0;
        check(unsafe { bindings::selene_quest_get_amp(self.ptr, index, &mut real, &mut imag) })?;
        Ok((real, imag))
    }
}

impl Drop for QuestBackend {
    fn drop(&mut self) {
        unsafe { bindings::selene_quest_destroy(self.ptr) };
    }
}

fn check(ok: bool) -> Result<()> {
    if ok {
        return Ok(());
    }
    let message = unsafe {
        let ptr = bindings::selene_quest_last_error();
        if ptr.is_null() {
            "unknown QuEST error".to_string()
        } else {
            CStr::from_ptr(ptr).to_string_lossy().into_owned()
        }
    };
    Err(anyhow!(message))
}
