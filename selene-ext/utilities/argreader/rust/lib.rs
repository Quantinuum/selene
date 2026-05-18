use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::collections::BTreeMap;
use std::{fs, io};

/// When logging via selene's log_utility_call function,
/// we pass this identifying tag so we can recognise the
/// call in the selene trace and handle it appropriately.
const ARGREADER_LOGGING_TAG: u64 = 0xA13613EADE130746;

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(untagged)]
enum InputRecord {
    Bool(bool),
    U64(u64),
    I64(i64),
    F64(f64),
    BoolArray(Vec<bool>),
    U64Array(Vec<u64>),
    I64Array(Vec<i64>),
    F64Array(Vec<f64>),
}

#[derive(Serialize, Deserialize, Clone)]
struct ShotInputs {
    shot_start_idx: u64,
    shot_end_idx: u64,
    records: BTreeMap<String, InputRecord>,
}

#[derive(Serialize, Deserialize)]
struct RunInputs {
    shot_inputs: Vec<ShotInputs>,
}

#[derive(Serialize, Deserialize, Debug)]
struct LogEntry {
    key: String,
    value: InputRecord,
}

impl RunInputs {
    pub fn get_inputs_for_shot(&self, shot_id: u64) -> Option<&ShotInputs> {
        self.shot_inputs
            .iter()
            .find(|shot| shot.shot_start_idx <= shot_id && shot.shot_end_idx > shot_id)
    }
}

thread_local! {
    pub static INPUTS: RefCell<Option<RunInputs>> = const{ RefCell::new(None) };
    pub static SHOT_INPUT_CACHE: RefCell<Option<(u64, ShotInputs)>> = const{ RefCell::new(None) };
}

unsafe extern "C" {
    // this is imported from selene at link time.
    // note that we can't use panic() -> this conflicts with libSystem on Darwin,
    // and cargo really wants to link it in while this is compiling.
    //
    // Instead we use panic_str, an exposed function for registering a panic with
    // the selene result stream based on a C string rather than a CL string.
    fn panic_str(error_code: u32, message: *const std::ffi::c_char) -> !;
    fn get_current_shot() -> u64;
    fn log_utility_call(tag: u64, data_ptr: *const u8, data_len: u64);
}

fn selene_panic(message: String) -> ! {
    // Convert the message to a C string
    let message = message.into_bytes();
    let message = std::ffi::CString::new(message).unwrap();
    // Issue the panic
    // print just in case the panic_str fails to make it through to
    // the results stream.
    eprintln!("ArgReader: Panic: {}", message.to_string_lossy());
    unsafe { panic_str(60001, message.as_ptr()) }
}
fn log(key: &str, value: &InputRecord) {
    let entry = LogEntry {
        key: key.to_string(),
        value: value.clone(),
    };
    // serde encode it
    let yaml = serde_yml::to_string(&entry).unwrap_or_else(|e| {
        selene_panic(format!(
            "Failed to serialize log entry for key '{}': {}",
            key, e
        ));
    });
    let data = yaml.into_bytes();
    unsafe {
        log_utility_call(ARGREADER_LOGGING_TAG, data.as_ptr(), data.len() as u64);
    }
}

fn init() {
    let filename = std::env::var("SELENE_ARGREADER_INPUT_FILE").unwrap_or_else(|_| {
        selene_panic("When using runtime arguments, use the ArgProvider context wrapper to provide arguments into the selene environment.".to_string());
    });
    let file = match fs::File::open(&filename) {
        Ok(f) => f,
        Err(e) => {
            selene_panic(format!("Failed to open file {filename}: {e}"));
        }
    };
    let reader = io::BufReader::new(file);
    let data: RunInputs = match serde_yml::from_reader(reader) {
        Ok(d) => d,
        Err(e) => {
            selene_panic(format!("Failed to parse YAML from file {filename}: {e}"));
        }
    };
    INPUTS.with(|cell| {
        *cell.borrow_mut() = Some(data);
    });
}

fn get_key(key_ptr: *const u8) -> String {
    // As with result() calls and panic() calls, the format of the key starts with
    // byte providing the length of the string that follows.
    unsafe {
        if key_ptr.is_null() {
            selene_panic("Received null pointer for runtime argument key".to_string());
        }
        let length = *key_ptr;
        let string_start = key_ptr.add(1);
        let slice = std::slice::from_raw_parts(string_start, length as usize);
        let Ok(key) = std::str::from_utf8(slice) else {
            selene_panic("Runtime argument names must be valid UTF-8".to_string());
        };
        key.to_string()
    }
}

unsafe fn value_helper(key: &String) -> InputRecord {
    if INPUTS.with(|cell| cell.borrow().is_none()) {
        init();
    }

    let current_shot = unsafe { get_current_shot() };

    // If we have cached inputs for the current shot, use them. Otherwise, look them up and cache
    // them.
    let shot_inputs = SHOT_INPUT_CACHE.with(|cache_cell| {
        let cached = cache_cell.borrow();

        if let Some((cached_shot, cached_inputs)) = cached.as_ref() && *cached_shot == current_shot {
            return cached_inputs.clone();
        }

        drop(cached);

        let shot_inputs = INPUTS.with(|cell| {
            let inputs = cell.borrow();

            inputs
                .as_ref()
                .expect("runtime inputs should be initialised")
                .get_inputs_for_shot(current_shot)
                .unwrap_or_else(|| {
                    selene_panic(format!(
                        "No runtime arguments provided for shot {current_shot} (0-indexed)"
                    ))
                })
                .clone()
        });

        *cache_cell.borrow_mut() = Some((current_shot, shot_inputs.clone()));

        shot_inputs
    });

    let record = shot_inputs.records.get(key).unwrap_or_else(|| {
        selene_panic(format!("Missing runtime argument '{key}'"))
    });

    log(key, record);

    record.clone()
}

/// Get a boolean runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_bool(key_ptr: *const u8) -> bool {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::Bool(value) => value,
        InputRecord::U64(value) => {
            if value == 0 {
                false
            } else if value == 1 {
                true
            } else {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean value, but received the unsigned integer {value} which is not 0 or 1",
                ));
            }
        }
        InputRecord::I64(value) => {
            if value == 0 {
                false
            } else if value == 1 {
                true
            } else {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean value, but received the integer {value} which is not 0 or 1",
                ));
            }
        }
        InputRecord::F64(value) => {
            if value == 0.0 {
                false
            } else if value == 1.0 {
                true
            } else {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean value, but received the float {value} which is not 0.0 or 1.0",
                ));
            }
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects a boolean value, but received the non-boolean value {value:?}"
            ));
        }
    }
}

/// Get a u64 runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_u64(key_ptr: *const u8) -> u64 {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::U64(value) => value,
        InputRecord::I64(value) => {
            if value < 0 {
                selene_panic(format!(
                    "Runtime argument '{key}' has a negative value ({value}), which cannot be converted to an unsigned integer",
                ));
            }
            value as u64
        }
        InputRecord::F64(value) => {
            if value < 0.0 {
                selene_panic(format!(
                    "Runtime argument '{key}' has a negative floating point value ({value}), which cannot be converted to an unsigned integer",
                ));
            }
            if value.fract() != 0.0 {
                selene_panic(format!(
                    "Runtime argument '{key}' has a non-integral floating point value {value}, which cannot be converted to an unsigned integer",
                ));
            }
            value as u64
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects an unsigned integer, but received the non-integer value {value:?}"
            ));
        }
    }
}

/// Get an i64 runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_i64(key_ptr: *const u8) -> i64 {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::I64(value) => value,
        InputRecord::U64(value) => {
            if value > i64::MAX as u64 {
                selene_panic(format!(
                    "Runtime argument '{key}' has an unsigned value {value}, exceeding the maximum value of a signed integer",
                ));
            }
            value as i64
        }
        InputRecord::F64(value) => {
            if value.fract() != 0.0 {
                selene_panic(format!(
                    "Runtime argument '{key}' has the non-integral floating point value {value}, which cannot be converted to an integer",
                ));
            }
            if value < i64::MIN as f64 || value > i64::MAX as f64 {
                selene_panic(format!(
                    "Runtime argument '{key}' has the floating point value {value}, which exceeds signed integer bounds",
                ));
            }
            value as i64
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' is not an integer: {value:?}"
            ));
        }
    }
}

/// Get an f64 runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_f64(key_ptr: *const u8) -> f64 {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::F64(value) => value,
        InputRecord::U64(value) => value as f64,
        InputRecord::I64(value) => value as f64,
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' is not a floating point number: {value:?}"
            ));
        }
    }
}

/// Get an u64-array runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided key_ptr must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
///
/// The provided out_ptr must point to a writable memory region large enough to
/// hold `len` contiguous u64 values, each represented in 8 bytes in native endian.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_u64_array(key_ptr: *const u8, out_ptr: *mut u64, len: u64) {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::U64Array(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} unsigned integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::I64Array(values) => {
            if values.iter().any(|&v| v < 0) {
                selene_panic(format!(
                    "Runtime argument '{key}' contains negative int values ({values:?}), and thus cannot be converted to an unsigned int array",
                ));
            }
            let u64_values: Vec<u64> = values.clone().into_iter().map(|v| v as u64).collect();
            if u64_values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} unsigned integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(u64_values.as_ptr(), out_ptr, u64_values.len());
            }
        }
        InputRecord::F64Array(values) => {
            if values.iter().any(|&v| v < 0.0) {
                selene_panic(format!(
                    "Runtime argument '{key}' contains negative floating point values ({values:?}), and thus cannot be converted to an unsigned int array",
                ));
            }
            if values.iter().any(|&v| v.fract() != 0.0) {
                selene_panic(format!(
                    "Runtime argument '{key}' contains non-integral floating point values ({values:?}), and thus cannot be converted to an unsigned int array",
                ));
            }
            let u64_values: Vec<u64> = values.clone().into_iter().map(|v| v as u64).collect();
            if u64_values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} unsigned integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(u64_values.as_ptr(), out_ptr, u64_values.len());
            }
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} integers, but received the value {value:?}"
            ));
        }
    }
}

/// Get an i64-array runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided key_ptr must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
///
/// The provided out_ptr must point to a writable memory region large enough to
/// hold `len` contiguous i64 values, each of which will be represented in 8
/// bytes in two's complement format, native endian.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_i64_array(key_ptr: *const u8, out_ptr: *mut i64, len: u64) {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::I64Array(values) => {
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::U64Array(values) => {
            if values.iter().any(|&v| v > i64::MAX as u64) {
                selene_panic(format!(
                    "Runtime argument '{key}' contains unsigned int values which exceed the max value of signed ints ({values:?}), and thus cannot be converted to an int array",
                ));
            }
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            let i64_values: Vec<i64> = values.into_iter().map(|v| v as i64).collect();
            unsafe {
                std::ptr::copy_nonoverlapping(i64_values.as_ptr(), out_ptr, i64_values.len());
            }
        }
        InputRecord::F64Array(values) => {
            if values.iter().any(|&v| v.fract() != 0.0) {
                selene_panic(format!(
                    "Runtime argument '{key}' contains non-integral floating point numbers ({values:?}), and thus cannot be converted to an int array",
                ));
            }
            if values
                .iter()
                .any(|&v| v < i64::MIN as f64 || v > i64::MAX as f64)
            {
                selene_panic(format!(
                    "Runtime argument '{key}' contains floating point values which exceed signed integer bounds ({values:?})), which cannot be converted to an int array",
                ));
            }
            let i64_values: Vec<i64> = values.clone().into_iter().map(|v| v as i64).collect();
            if i64_values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} integers, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(i64_values.as_ptr(), out_ptr, i64_values.len());
            }
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} integers, but received the value {value:?}"
            ));
        }
    }
}

/// Get an f64-array runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided key_ptr must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
///
/// The provided out_ptr must point to a writable memory region large enough to
/// hold `len` contiguous f64 values, each of which will be represented in 8 bytes
/// in IEEE 754 double-precision format, native endian.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_f64_array(key_ptr: *const u8, out_ptr: *mut f64, len: u64) {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::F64Array(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} floats, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::U64Array(values) => {
            let f64_values: Vec<f64> = values.clone().into_iter().map(|v| v as f64).collect();
            if f64_values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} floats, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(f64_values.as_ptr(), out_ptr, f64_values.len());
            }
        }
        InputRecord::I64Array(values) => {
            let f64_values: Vec<f64> = values.clone().into_iter().map(|v| v as f64).collect();
            if f64_values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects an array of {len} floats, but was provided an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(f64_values.as_ptr(), out_ptr, f64_values.len());
            }
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} floating point values, but received the value {value:?}"
            ));
        }
    }
}

/// Get an bool-array runtime argument for the current shot given a CL-string key.
///
/// # Safety
/// The provided key_ptr must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
///
/// The provided out_ptr must point to a writable memory region large enough to
/// hold `len` contiguous boolean values, each of which represented by a byte
/// with value 0 for false, 1 for true.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_bool_array(
    key_ptr: *const u8,
    out_ptr: *mut bool,
    len: u64,
) {
    let key = get_key(key_ptr);
    match unsafe { value_helper(&key) } {
        InputRecord::BoolArray(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array of length {len}, but received an array {values:?} of length {}",
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::I64Array(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array of length {len}, but received an array {values:?} of length {}",
                    values.len()
                ));
            }
            if values.iter().any(|&v| v != 0 && v != 1) {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array, but received the integer array {values:?} which contains non-boolean values",
                ));
            }
            let bool_values: Vec<bool> = values.into_iter().map(|v| v == 1).collect();
            unsafe {
                std::ptr::copy_nonoverlapping(bool_values.as_ptr(), out_ptr, bool_values.len());
            }
        }
        InputRecord::U64Array(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array of length {len}, but received an array {values:?} of length {}",
                    values.len()
                ));
            }
            if values.iter().any(|&v| v != 0 && v != 1) {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array, but received the unsigned integer array {values:?} which contains non-boolean values",
                ));
            }
            let bool_values: Vec<bool> = values.into_iter().map(|v| v == 1).collect();
            unsafe {
                std::ptr::copy_nonoverlapping(bool_values.as_ptr(), out_ptr, bool_values.len());
            }
        }
        InputRecord::F64Array(values) => {
            if values.len() != len as usize {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array of length {len}, but received an array {values:?} of length {}",
                    values.len()
                ));
            }
            if values.iter().any(|&v| v != 0.0 && v != 1.0) {
                selene_panic(format!(
                    "Runtime argument '{key}' expects a boolean array, but received the float array {values:?} which contains non-boolean values",
                ));
            }
            let bool_values: Vec<bool> = values.into_iter().map(|v| v == 1.0).collect();
            unsafe {
                std::ptr::copy_nonoverlapping(bool_values.as_ptr(), out_ptr, bool_values.len());
            }
        }
        value => {
            selene_panic(format!(
                "Runtime argument '{key}' expects a boolean array of length {len}, but received the value {value:?}"
            ));
        }
    }
}
