//! C-ABI exports for the *reader* side of the shared-memory FIFO transport.
//!
//! These functions are called from Python (via `ctypes`) by the process that
//! runs `run_shots`. That process creates the segment, hands its OS id to the
//! spawned writer (through the `shmem:<os_id>` output-stream URI), reads result
//! bytes out of the FIFO, and finally destroys the segment.
//!
//! The FIFO handle is exposed to C as an opaque `void *`; internally it is a
//! boxed [`ShmemFifo`].

use crate::ffi_interface::{BoolResult, U64Result, VoidResult};
use selene_core::shmem_fifo::ShmemFifo;
use std::ffi::c_void;

/// Error code returned when a null FIFO handle is passed.
const ERR_NULL_HANDLE: u32 = 200001;

/// Create a shared-memory FIFO with the given data-region capacity in bytes.
///
/// Returns an opaque handle pointer on success, or a null pointer on failure.
/// The returned handle owns the segment and must be released with
/// `selene_shmem_destroy`, which also unlinks the underlying segment.
#[unsafe(no_mangle)]
pub extern "C" fn selene_shmem_create(capacity: u64) -> *mut c_void {
    match ShmemFifo::create(capacity as usize) {
        Ok(fifo) => Box::into_raw(Box::new(fifo)) as *mut c_void,
        Err(_) => std::ptr::null_mut(),
    }
}

/// Copy the FIFO's OS id (UTF-8, not null-terminated) into `out_ptr`, writing at
/// most `out_max_len` bytes. Returns the full length of the OS id in the
/// `value` field; if this exceeds `out_max_len` the buffer was too small and the
/// caller should retry with a larger buffer.
///
/// # Safety
/// `handle` must be a valid handle from `selene_shmem_create` and `out_ptr` must
/// be valid for writes of `out_max_len` bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_shmem_get_os_id(
    handle: *mut c_void,
    out_ptr: *mut u8,
    out_max_len: u64,
) -> U64Result {
    if handle.is_null() {
        return U64Result::err(ERR_NULL_HANDLE);
    }
    let fifo = unsafe { &*(handle as *const ShmemFifo) };
    let id = fifo.os_id().as_bytes();
    let to_copy = id.len().min(out_max_len as usize);
    if to_copy > 0 && !out_ptr.is_null() {
        unsafe {
            std::ptr::copy_nonoverlapping(id.as_ptr(), out_ptr, to_copy);
        }
    }
    U64Result::ok(id.len() as u64)
}

/// Read up to `out_max_len` bytes currently available in the FIFO into
/// `out_ptr`, without blocking. Returns the number of bytes read in `value`
/// (which may be zero if the FIFO is currently empty).
///
/// # Safety
/// `handle` must be a valid handle from `selene_shmem_create` and `out_ptr` must
/// be valid for writes of `out_max_len` bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_shmem_read(
    handle: *mut c_void,
    out_ptr: *mut u8,
    out_max_len: u64,
) -> U64Result {
    if handle.is_null() {
        return U64Result::err(ERR_NULL_HANDLE);
    }
    let fifo = unsafe { &*(handle as *const ShmemFifo) };
    let buf = unsafe { std::slice::from_raw_parts_mut(out_ptr, out_max_len as usize) };
    let n = fifo.read(buf);
    U64Result::ok(n as u64)
}

/// Return whether the writer side has closed the FIFO.
///
/// # Safety
/// `handle` must be a valid handle from `selene_shmem_create`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_shmem_writer_closed(handle: *mut c_void) -> BoolResult {
    if handle.is_null() {
        return BoolResult::err(ERR_NULL_HANDLE);
    }
    let fifo = unsafe { &*(handle as *const ShmemFifo) };
    BoolResult::ok(fifo.is_writer_closed())
}

/// Destroy a FIFO handle previously returned by `selene_shmem_create`. The
/// underlying shared-memory segment is unlinked.
///
/// # Safety
/// `handle` must have been returned by `selene_shmem_create` and not already
/// destroyed.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn selene_shmem_destroy(handle: *mut c_void) -> VoidResult {
    if handle.is_null() {
        return VoidResult::err(ERR_NULL_HANDLE);
    }
    // Reclaim and drop the boxed FIFO; dropping an owner unlinks the segment.
    let _ = unsafe { Box::from_raw(handle as *mut ShmemFifo) };
    VoidResult::ok()
}
