//! Program printing and exit requests. The runtime orders these calls, while
//! the host keeps the encoder and writes through the supplied output sink.
use crate::encoder::Record;
use anyhow::{Result, anyhow, ensure};
use std::ffi::c_void;

/// A UTF-8 string borrowed for one call. data may be null when length is zero.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct OutputString {
    pub data: *const std::ffi::c_char,
    pub length: u64,
}
impl OutputString {
    fn new(value: &str) -> Self {
        Self {
            data: value.as_ptr().cast(),
            length: value.len() as u64,
        }
    }
    unsafe fn read(&self) -> Result<String> {
        Ok(
            std::str::from_utf8(unsafe { read_slice(self.data.cast::<u8>(), self.length)? })?
                .to_owned(),
        )
    }
}
pub(super) unsafe fn read_slice<'a, T>(data: *const T, length: u64) -> Result<&'a [T]> {
    let length = usize::try_from(length)?;
    ensure!(
        length <= isize::MAX as usize / size_of::<T>(),
        "Output buffer is too large"
    );
    if length == 0 {
        return Ok(&[]);
    }
    ensure!(!data.is_null(), "Null output buffer");
    Ok(unsafe { std::slice::from_raw_parts(data, length) })
}

/// The native C type used by an output value's data pointer.
#[repr(u32)]
#[derive(Clone, Copy)]
pub enum OutputDatatype {
    Bool = 0,
    I64 = 1,
    U64 = 2,
    F64 = 3,
    String = 4,
}

/// One typed value. datatype is an OutputDatatype value. data points to a
/// native C array: bool, int64_t, uint64_t, double or UTF-8 bytes, respectively.
/// Scalars have length 1 and is_array false. Text has is_array false and length
/// bytes. Empty numeric arrays cannot be represented by the output encoding.
/// All buffers are borrowed for the duration of the call.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct OutputValue {
    pub datatype: u32,
    pub is_array: bool,
    pub data: *const c_void,
    pub length: u64,
}

/// Print one tagged value. Copy the tag and value before returning if the
/// runtime queues the request. There is no timestamp in a program request.
#[repr(C)]
pub struct PrintRequestRaw {
    pub struct_size: u64,
    pub tag: OutputString,
    pub value: OutputValue,
}

/// Exit codes carry the existing distinction between normal exits and panics.
/// Backtrace entries are captured on the calling program thread. Copy all
/// borrowed buffers before returning. No callback may longjmp or unwind.
#[repr(C)]
pub struct ExitRequestRaw {
    pub struct_size: u64,
    pub error_code: u32,
    pub message: OutputString,
    pub backtrace: *const PrintRequestRaw,
    pub backtrace_length: u64,
}

#[derive(Clone, Debug, PartialEq)]
pub enum PrintValue {
    Bool(bool),
    I64(i64),
    U64(u64),
    F64(f64),
    BoolArray(Vec<bool>),
    I64Array(Vec<i64>),
    U64Array(Vec<u64>),
    F64Array(Vec<f64>),
    String(String),
}
macro_rules! values {
    ($(($ty:ty, $single:ident, $array:ident)),* $(,)?) => { $(
        impl From<$ty> for PrintValue {
            fn from(value: $ty) -> Self { Self::$single(value) }
        }
        impl From<&[$ty]> for PrintValue {
            fn from(value: &[$ty]) -> Self { Self::$array(value.to_vec()) }
        }
        impl From<Vec<$ty>> for PrintValue {
            fn from(value: Vec<$ty>) -> Self { Self::$array(value) }
        }
    )*};
}
values!(
    (bool, Bool, BoolArray),
    (i64, I64, I64Array),
    (u64, U64, U64Array),
    (f64, F64, F64Array)
);
impl From<&str> for PrintValue {
    fn from(value: &str) -> Self {
        Self::String(value.to_owned())
    }
}
impl From<String> for PrintValue {
    fn from(value: String) -> Self {
        Self::String(value)
    }
}
impl PrintValue {
    fn raw(&self) -> OutputValue {
        fn scalar<T>(datatype: u32, value: &T) -> OutputValue {
            OutputValue {
                datatype,
                is_array: false,
                data: (value as *const T).cast(),
                length: 1,
            }
        }
        fn array<T>(datatype: u32, values: &[T]) -> OutputValue {
            OutputValue {
                datatype,
                is_array: true,
                data: values.as_ptr().cast(),
                length: values.len() as u64,
            }
        }
        match self {
            Self::Bool(v) => scalar(0, v),
            Self::I64(v) => scalar(1, v),
            Self::U64(v) => scalar(2, v),
            Self::F64(v) => scalar(3, v),
            Self::BoolArray(v) => array(0, v),
            Self::I64Array(v) => array(1, v),
            Self::U64Array(v) => array(2, v),
            Self::F64Array(v) => array(3, v),
            Self::String(v) => OutputValue {
                datatype: 4,
                is_array: false,
                data: v.as_ptr().cast(),
                length: v.len() as u64,
            },
        }
    }
    unsafe fn read(value: &OutputValue) -> Result<Self> {
        if value.datatype == 4 {
            ensure!(!value.is_array, "Arrays of strings are unsupported");
            return Ok(Self::String(unsafe {
                OutputString {
                    data: value.data.cast(),
                    length: value.length,
                }
                .read()?
            }));
        }
        ensure!(
            value.is_array || value.length == 1,
            "Scalar output must have length one"
        );
        macro_rules! read {
            ($ty:ty, $single:ident, $array:ident) => {{
                let values = unsafe { read_slice(value.data.cast::<$ty>(), value.length)? };
                if value.is_array {
                    Self::$array(values.to_vec())
                } else {
                    Self::$single(values[0])
                }
            }};
        }
        Ok(match value.datatype {
            0 => read!(bool, Bool, BoolArray),
            1 => read!(i64, I64, I64Array),
            2 => read!(u64, U64, U64Array),
            3 => read!(f64, F64, F64Array),
            _ => return Err(anyhow!("Unknown output datatype")),
        })
    }
}

/// An owned print request, suitable for placing on a runtime's work queue.
#[derive(Clone, Debug, PartialEq)]
pub struct PrintRequest {
    pub tag: String,
    pub value: PrintValue,
}
impl PrintRequest {
    pub fn new(tag: impl Into<String>, value: impl Into<PrintValue>) -> Self {
        Self {
            tag: tag.into(),
            value: value.into(),
        }
    }
    pub fn as_raw(&self) -> PrintRequestRaw {
        PrintRequestRaw {
            struct_size: size_of::<PrintRequestRaw>() as u64,
            tag: OutputString::new(&self.tag),
            value: self.value.raw(),
        }
    }
    /// Copy a C request into an owned Rust request.
    ///
    /// # Safety
    /// All pointers must describe live, aligned buffers of the advertised types.
    pub unsafe fn from_raw(request: *const PrintRequestRaw) -> Result<Self> {
        ensure!(!request.is_null(), "Null print request");
        ensure!(
            unsafe { (*request).struct_size } >= size_of::<PrintRequestRaw>() as u64,
            "Undersized print request"
        );
        let request = unsafe { &*request };
        Ok(Self {
            tag: unsafe { request.tag.read()? },
            value: unsafe { PrintValue::read(&request.value)? },
        })
    }
    pub fn record(&self, timestamp: u64) -> Result<Record> {
        let record = Record::new(timestamp, &self.tag)?;
        Ok(match &self.value {
            PrintValue::Bool(v) => record.add_entry(*v)?,
            PrintValue::I64(v) => record.add_entry(*v)?,
            PrintValue::U64(v) => record.add_entry(*v)?,
            PrintValue::F64(v) => record.add_entry(*v)?,
            PrintValue::BoolArray(v) => record.add_entry(v.as_slice())?,
            PrintValue::I64Array(v) => record.add_entry(v.as_slice())?,
            PrintValue::U64Array(v) => record.add_entry(v.as_slice())?,
            PrintValue::F64Array(v) => record.add_entry(v.as_slice())?,
            PrintValue::String(v) => record.add_entry(v.as_str())?,
        })
    }
}

#[derive(Clone, Debug)]
pub struct ExitRequest {
    pub error_code: u32,
    pub message: String,
    pub backtrace: Vec<PrintRequest>,
}
impl ExitRequest {
    /// Copy the request and all backtrace entries.
    ///
    /// # Safety
    /// All pointers must describe live buffers of their advertised types.
    pub unsafe fn from_raw(request: *const ExitRequestRaw) -> Result<Self> {
        ensure!(!request.is_null(), "Null exit request");
        ensure!(
            unsafe { (*request).struct_size } >= size_of::<ExitRequestRaw>() as u64,
            "Undersized exit request"
        );
        let request = unsafe { &*request };
        let frames = unsafe { read_slice(request.backtrace, request.backtrace_length)? };
        Ok(Self {
            error_code: request.error_code,
            message: unsafe { request.message.read()? },
            backtrace: frames
                .iter()
                .map(|frame| unsafe { PrintRequest::from_raw(frame) })
                .collect::<Result<_>>()?,
        })
    }
    pub fn with_raw<T>(&self, call: impl FnOnce(&ExitRequestRaw) -> T) -> T {
        let backtrace = self
            .backtrace
            .iter()
            .map(PrintRequest::as_raw)
            .collect::<Vec<_>>();
        call(&ExitRequestRaw {
            struct_size: size_of::<ExitRequestRaw>() as u64,
            error_code: self.error_code,
            message: OutputString::new(&self.message),
            backtrace: backtrace.as_ptr(),
            backtrace_length: backtrace.len() as u64,
        })
    }
    pub fn records(&self) -> Vec<PrintRequest> {
        let tag = if self.message.starts_with("EXIT:INT:") {
            self.message.clone()
        } else {
            format!("EXIT:INT:{}", self.message)
        };
        let mut records = vec![PrintRequest::new(tag, u64::from(self.error_code))];
        records.extend(self.backtrace.clone());
        records
    }
}

/// A host-owned printer. The handle remains borrowed until shot_end returns,
/// including after program exit. write_fn writes the group without interleaving
/// another group and returns zero on success. All arguments are borrowed only
/// during the call. It must be thread safe and must not re-enter the runtime.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct OutputSinkHandle {
    pub context: *mut c_void,
    /// Write count records at timestamp nanoseconds. Buffers are borrowed for
    /// this call. A failed write is an execution failure, rather than a reason
    /// to retry the records and potentially duplicate output.
    pub write_fn: Option<
        unsafe extern "C" fn(
            context: *mut c_void,
            timestamp: u64,
            records: *const PrintRequestRaw,
            count: u64,
        ) -> i32,
    >,
    /// Flush the output transport before returning. Both sink functions are
    /// required; neither may unwind, retain buffers or call the runtime.
    pub flush_fn: Option<unsafe extern "C" fn(context: *mut c_void) -> i32>,
}
// The sink's C contract requires synchronised access to its host-owned state.
unsafe impl Send for OutputSinkHandle {}
unsafe impl Sync for OutputSinkHandle {}
impl OutputSinkHandle {
    /// Flush a borrowed C printer.
    ///
    /// # Safety
    /// The sink's context and function must remain live until this call returns.
    pub unsafe fn flush(&self) -> Result<()> {
        let flush = self
            .flush_fn
            .ok_or_else(|| anyhow!("Missing output sink flush"))?;
        crate::utils::check_errno(unsafe { flush(self.context) }, || {
            anyhow!("Output sink flush failed")
        })
    }

    /// Write owned records through a borrowed C printer.
    ///
    /// # Safety
    /// The sink's context and function must remain live until this call returns.
    pub unsafe fn print(&self, timestamp: u64, records: &[PrintRequest]) -> Result<()> {
        let raw = records.iter().map(PrintRequest::as_raw).collect::<Vec<_>>();
        let write = self
            .write_fn
            .ok_or_else(|| anyhow!("Missing output sink writer"))?;
        crate::utils::check_errno(
            unsafe { write(self.context, timestamp, raw.as_ptr(), raw.len() as u64) },
            || anyhow!("Output sink failed"),
        )
    }
}
