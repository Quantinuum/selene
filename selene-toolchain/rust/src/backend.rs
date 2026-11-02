use crate::{Error, Result};
use serde_json::Value;
use std::{
    ffi::{CString, c_char},
    slice,
};

#[repr(C)]
struct Buffer {
    data: *mut u8,
    length: usize,
    status: i32,
}
unsafe extern "C" {
    fn st_call(
        operation: *const c_char,
        data: *const u8,
        length: usize,
        options: *const c_char,
    ) -> Buffer;
    fn st_free(buffer: Buffer);
    fn st_abi_version() -> u32;
}

pub(crate) struct Backend {
    pub identity: String,
}
impl Backend {
    pub fn linked() -> Result<Self> {
        // SAFETY: Cargo compiles and links the C interface with this crate.
        if unsafe { st_abi_version() } != 1 {
            return Err(Error::Backend("Incompatible linked LLVM bridge ABI".into()));
        }
        Ok(Self {
            identity: env!("SELENE_TOOLCHAIN_BACKEND").into(),
        })
    }
    pub fn run(&self, operation: &str, data: &[u8], options: &Value) -> Result<Vec<u8>> {
        let op = CString::new(operation).map_err(|e| Error::Invalid(e.to_string()))?;
        let options = CString::new(serde_json::to_vec(options)?)
            .map_err(|e| Error::Invalid(e.to_string()))?;
        // SAFETY: Input buffers live throughout the call. Copy the output
        // before asking the same C++ allocator to free its memory.
        unsafe {
            let result = st_call(op.as_ptr(), data.as_ptr(), data.len(), options.as_ptr());
            if result.data.is_null() {
                return Err(Error::Backend("LLVM allocation failed".into()));
            }
            let bytes = slice::from_raw_parts(result.data, result.length).to_vec();
            let status = result.status;
            st_free(result);
            if status != 0 {
                return Err(Error::Operation {
                    operation: operation.into(),
                    diagnostics: String::from_utf8_lossy(&bytes).into_owned(),
                });
            }
            Ok(bytes)
        }
    }
}
