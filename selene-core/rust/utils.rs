use core::{cell::RefCell, ffi, fmt};
use std::ffi::CString;

use anyhow::bail;

use crate::runtime::plugin::Errno;

thread_local! {
    static LAST_ERROR: RefCell<Option<String>> = const { RefCell::new(None) };
}

pub fn set_last_error(message: impl Into<String>) {
    LAST_ERROR.with(|last_error| {
        *last_error.borrow_mut() = Some(message.into());
    });
}

fn clear_last_error() {
    LAST_ERROR.with(|last_error| {
        *last_error.borrow_mut() = None;
    });
}

/// Write the last plugin error captured by Selene's Rust helper ABI.
///
/// `written` is set to the number of UTF-8 bytes in the message, excluding any
/// trailing NUL. If `output` is non-null, up to `output_len` bytes are copied
/// into it. The function returns -1 only when `written` is null or the provided
/// output buffer is too small.
///
/// # Safety
///
/// If `output` is non-null it must be valid for writes of `output_len` bytes.
/// `written` must be valid for one `usize` write.
pub unsafe extern "C" fn last_error_message(
    output: *mut ffi::c_char,
    output_len: usize,
    written: *mut usize,
) -> Errno {
    if written.is_null() {
        return -1;
    }
    let message = LAST_ERROR.with(|last_error| last_error.borrow().clone().unwrap_or_default());
    let bytes = message.as_bytes();
    unsafe {
        *written = bytes.len();
    }
    if output.is_null() {
        return 0;
    }
    if output_len < bytes.len() {
        return -1;
    }
    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), output as *mut u8, bytes.len());
    }
    0
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct SeleneStr {
    pub ptr: *const ffi::c_char, // UTF-8 bytes
    pub len: u64,                // byte length
}
#[inline]
pub fn selene_str_to_bytes(s: SeleneStr) -> &'static [u8] {
    unsafe { std::slice::from_raw_parts(s.ptr as *const u8, s.len as usize) }
}

/// Represents different types of metric values.
pub enum MetricValue {
    Bool(bool),
    I64(i64),
    U64(u64),
    F64(f64),
}

impl MetricValue {
    /// Writes the raw representation of the metric value to the provided pointers.
    ///
    /// # Arguments
    ///
    /// * `tag` - A reference to a string slice representing the tag.
    /// * `tag_ptr` - A mutable pointer to a C character array where the tag will be written.
    /// * `datatype_ptr` - A mutable pointer to a u8 where the datatype will be written.
    /// * `data_ptr` - A mutable pointer to a u64 where the data will be written.
    ///
    /// # Safety
    ///
    /// All pointers passed to `write_raw` must be valid and mutable.
    pub unsafe fn write_raw(
        &self,
        tag: String,
        tag_ptr: *mut ffi::c_char,
        datatype_ptr: *mut u8,
        data_ptr: *mut u64,
    ) {
        let tag_bytes = tag.as_bytes();
        unsafe {
            std::ptr::copy_nonoverlapping(tag_bytes.as_ptr(), tag_ptr as *mut u8, tag_bytes.len());
            *tag_ptr.add(tag_bytes.len()) = 0;
        }
        let datatype = match self {
            MetricValue::Bool(_) => 0,
            MetricValue::I64(_) => 1,
            MetricValue::U64(_) => 2,
            MetricValue::F64(_) => 3,
        };
        unsafe { *datatype_ptr = datatype };
        match self {
            MetricValue::Bool(b) => {
                let data_ptr = data_ptr as *mut u8;
                unsafe { *data_ptr = *b as u8 };
            }
            MetricValue::I64(i) => {
                let data_ptr = data_ptr as *mut i64;
                unsafe { *data_ptr = *i };
            }
            MetricValue::U64(u) => {
                unsafe { *data_ptr = *u };
            }
            MetricValue::F64(f) => {
                let data_ptr = data_ptr as *mut f64;
                unsafe { *data_ptr = *f };
            }
        }
    }
}

/// Converts C-style arguments to Rust strings.
///
/// # Arguments
///
/// * `argc` - The number of arguments.
/// * `argv` - A pointer to the arguments.
///
/// # Returns
///
/// Returns an iterator over the converted strings.
///
/// # Safety
///
/// `slice::from_raw_parts(argv, argc)` must be safe. Each element of that slice
/// must point to a null terminated utf8 string.
pub unsafe fn convert_cargs_to_strings(
    argc: u32,
    argv: *const *const ffi::c_char,
) -> impl Iterator<Item = String> {
    (0..argc).map(move |i| {
        let c_str = unsafe { *argv.offset(i as isize) };
        unsafe { std::ffi::CStr::from_ptr(c_str) }
            .to_string_lossy()
            .into_owned()
    })
}

/// Converts Rust strings to C-style arguments and passes them to a closure.
///
/// # Arguments
///
/// * `args` - A slice of strings to convert.
/// * `go` - A closure that takes the number of arguments and a pointer to the arguments.
///
/// # Returns
///
/// Returns the result of the closure.
pub fn with_strings_to_cargs<T>(
    args: &[impl AsRef<str>],
    mut go: impl FnMut(u32, *const *const ffi::c_char) -> T,
) -> T {
    let args_cstrings: Vec<CString> = args
        .iter()
        .map(|s| CString::new(s.as_ref().as_bytes()).expect("CString::new failed"))
        .collect();
    let mut args_c_ptrs: Vec<*const ffi::c_char> =
        args_cstrings.iter().map(|cs| cs.as_ptr()).collect();
    args_c_ptrs.push(std::ptr::null());
    let argc = args.len() as u32;
    let argv = args_c_ptrs.as_ptr();
    go(argc, argv)
}

/// Checks the given errno and returns a result.
///
/// # Arguments
///
/// * `errno` - The errno to check.
/// * `mk_err` - A closure that creates an error of type `E`.
///
/// # Returns
///
/// Returns `Ok(())` if `errno` is 0, otherwise returns `Err` with the error created by `mk_err`.
pub fn check_errno<E>(errno: Errno, mut mk_err: impl FnMut() -> E) -> Result<(), E> {
    if errno != 0 { Err(mk_err()) } else { Ok(()) }
}

/// Converts a ~Result~ to an errno value.
///
/// # Arguments
///
/// * `msg` - Retained for call-site context; user-facing errors come from `r`.
/// * `r` - The result to convert.
///
/// # Returns
///
/// Returns `0` if the result is `Ok`. Otherwise, stores the error chain for
/// the plugin's `last_error` callback and returns `-1`.
pub fn result_to_errno<E: fmt::Display>(_msg: impl AsRef<str>, r: Result<(), E>) -> Errno {
    let Err(e) = r else {
        clear_last_error();
        return 0;
    };

    set_last_error(format!("{e:#}"));
    -1
}
/// Converts a ~Result~ of ~errno~ to an errno value. If the
/// result has an errno already, that value is used. However,
/// if the result itself is an Err, -1 is used.
///
/// This is useful for functions that have successful errno
/// values that are non-zero, such as writing metrics.
///
/// # Arguments
///
/// * `msg` - Retained for call-site context; user-facing errors come from `r`.
/// * `r` - The result to convert.
///
/// # Returns
///
/// Returns `n` if the result is `Ok(n)`.
/// Returnns `-1` if the result is Err
pub fn result_of_errno_to_errno<E: fmt::Display>(
    _msg: impl AsRef<str>,
    r: Result<Errno, E>,
) -> Errno {
    match r {
        Ok(n) => {
            clear_last_error();
            n
        }
        Err(e) => {
            set_last_error(format!("{e:#}"));
            -1
        }
    }
}

pub fn read_raw_metric(
    mut get_metric: impl FnMut(*mut ffi::c_char, *mut u8, *mut u64) -> Errno,
) -> anyhow::Result<Option<(String, MetricValue)>> {
    let mut tag = [0 as ffi::c_char; 256];
    let mut data_type: u8 = 0;
    let mut data: u64 = 0;
    // FFI, outparams, memory pointer passing - this is all unavoidably unsafe.
    //
    // # Safety
    //
    // The plugin is responsible for writing into the memory pointed to by the outparams,
    // and if it were to write beyond that memory it could cause a problem. The user is
    // responsible for verifying and trusting a plugin being run, just as they should
    // any library or program.
    unsafe {
        let result = get_metric(
            tag.as_mut_ptr(),
            &mut data_type as *mut u8,
            &mut data as *mut u64,
        );
        if result != 0 {
            return Ok(None);
        }
        if tag[255] != 0 {
            bail!("Plugin provided a tag string that is too long: The limit is 255 characters.");
        }
        let tag_cstr = std::ffi::CStr::from_ptr(tag.as_ptr());
        let tag_str = tag_cstr.to_str().unwrap().to_string();
        let metric = match data_type {
            0 => MetricValue::Bool(data != 0),
            1 => {
                let value = *(&data as *const u64 as *const i64);
                MetricValue::I64(value)
            }
            2 => MetricValue::U64(data),
            3 => {
                let value = *(&data as *const u64 as *const f64);
                MetricValue::F64(value)
            }

            n => bail!("Unknown data type received: {}, with tag '{}'", n, tag_str),
        };
        Ok(Some((tag_str, metric)))
    }
}
