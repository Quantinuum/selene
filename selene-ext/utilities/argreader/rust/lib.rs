use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::collections::BTreeMap;
use std::{fs, io};

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
    let tag: u64 = 0xA363EADE3;
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
        log_utility_call(tag, data.as_ptr(), data.len() as u64);
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
    unsafe {
        let slice = std::slice::from_raw_parts(key_ptr, 255);
        let Some(nul_pos) = slice.iter().position(|&c| c == 0) else {
            selene_panic(
                "Runtime argument names must be null-terminated and at most 255 bytes long"
                    .to_string(),
            );
        };
        let Ok(key) = std::str::from_utf8(&slice[..nul_pos]) else {
            selene_panic("Runtime argument names must be valid UTF-8".to_string());
        };
        key.to_string()
    }
}

unsafe fn value_helper(key: *const u8) -> InputRecord {
    let key = get_key(key);
    if INPUTS.with(|cell| cell.borrow().is_none()) {
        init();
    }
    INPUTS.with(|cell| {
        let binding = cell.borrow();
        let current_shot = unsafe { get_current_shot() };
        let shot_inputs = binding.as_ref().unwrap().get_inputs_for_shot(current_shot);
        if shot_inputs.is_none() {
            selene_panic(format!(
                "No runtime arguments provided for shot {current_shot} (0-indexed)"
            ));
        }
        if let Some(record) = shot_inputs.unwrap().records.get(&key) {
            log(&key, record);
            record.clone()
        } else {
            selene_panic(format!("Missing runtime argument '{}'", key));
        }
    })
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_u64(key_ptr: *const u8) -> u64 {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::U64(value) => value,
        InputRecord::I64(value) => {
            if value < 0 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has a negative value ({}), which cannot be converted to an unsigned integer",
                    key, value
                ));
            }
            value as u64
        }
        InputRecord::F64(value) => {
            if value < 0.0 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has a negative floating point value ({}), which cannot be converted to an unsigned integer",
                    key, value
                ));
            }
            if value.fract() != 0.0 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has a non-integral floating point value {}, which cannot be converted to an unsigned integer",
                    key, value
                ));
            }
            value as u64
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects an unsigned integer, but received the non-integer value {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_i64(key_ptr: *const u8) -> i64 {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::I64(value) => value,
        InputRecord::U64(value) => {
            if value > i64::MAX as u64 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has an unsigned value {}, exceeding the maximum value of a signed integer",
                    key, value
                ));
            }
            value as i64
        }
        InputRecord::F64(value) => {
            if value.fract() != 0.0 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has the non-integral floating point value {}, which cannot be converted to an integer",
                    key, value
                ));
            }
            if value < i64::MIN as f64 || value > i64::MAX as f64 {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' has the floating point value {}, which exceeds signed integer bounds",
                    key, value
                ));
            }
            value as i64
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' is not an integer: {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_bool(key_ptr: *const u8) -> bool {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::Bool(value) => value,
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects a boolean value, but received the non-boolean value {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_f64(key_ptr: *const u8) -> f64 {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::F64(value) => value,
        InputRecord::U64(value) => value as f64,
        InputRecord::I64(value) => value as f64,
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' is not a floating point number: {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_u64_array(key_ptr: *const u8, out_ptr: *mut u64, len: u64) {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::U64Array(values) => {
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} unsigned integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::I64Array(values) => {
            if values.iter().any(|&v| v < 0) {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains negative int values ({:?}), and thus cannot be converted to an unsigned int array",
                    key, values
                ));
            }
            let u64_values: Vec<u64> = values.into_iter().map(|v| v as u64).collect();
            if u64_values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} unsigned integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    u64_values,
                    u64_values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(u64_values.as_ptr(), out_ptr, u64_values.len());
            }
        }
        InputRecord::F64Array(values) => {
            if values.iter().any(|&v| v < 0.0) {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains negative floating point values, and thus cannot be converted to an unsigned int array",
                    key
                ));
            }
            if values.iter().any(|&v| v.fract() != 0.0) {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains non-integral floating point values, and thus cannot be converted to an unsigned int array",
                    key
                ));
            }
            let u64_values: Vec<u64> = values.into_iter().map(|v| v as u64).collect();
            if u64_values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} unsigned integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    u64_values,
                    u64_values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(u64_values.as_ptr(), out_ptr, u64_values.len());
            }
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} integers, but received the value {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_i64_array(key_ptr: *const u8, out_ptr: *mut i64, len: u64) {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::I64Array(values) => {
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        InputRecord::U64Array(values) => {
            if values.iter().any(|&v| v > i64::MAX as u64) {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains unsigned int values which exceed the max value of signed ints ({:?}), and thus cannot be converted to an int array",
                    key, values
                ));
            }
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
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
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains non-integral floating point numbers ({:?}), and thus cannot be converted to an int array",
                    key, values
                ));
            }
            if values
                .iter()
                .any(|&v| v < i64::MIN as f64 || v > i64::MAX as f64)
            {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' contains floating point values which exceed signed integer bounds ({:?})), which cannot be converted to an int array",
                    key, values
                ));
            }
            let i64_values: Vec<i64> = values.clone().into_iter().map(|v| v as i64).collect();
            if i64_values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} integers, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
                    i64_values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(i64_values.as_ptr(), out_ptr, i64_values.len());
            }
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} integers, but received the value {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_f64_array(key_ptr: *const u8, out_ptr: *mut f64, len: u64) {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::F64Array(values) => {
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} floats, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
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
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} floats, but was provided an array {:?} of length {}",
                    key,
                    len,
                    values,
                    f64_values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(f64_values.as_ptr(), out_ptr, f64_values.len());
            }
        }
        InputRecord::I64Array(values) => {
            let f64_values: Vec<f64> = values.clone().into_iter().map(|v| v as f64).collect();
            if f64_values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects an array of {} floats, but was provided an array {:?} of length {}",
                    key,
                    len,
                    f64_values,
                    f64_values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(f64_values.as_ptr(), out_ptr, f64_values.len());
            }
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects an array of {len} floating point values, but received the value {value:?}"
            ));
        }
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn argreader_get_bool_array(
    key_ptr: *const u8,
    out_ptr: *mut bool,
    len: u64,
) {
    match unsafe { value_helper(key_ptr) } {
        InputRecord::BoolArray(values) => {
            if values.len() != len as usize {
                let key = get_key(key_ptr);
                selene_panic(format!(
                    "Runtime argument '{}' expects a boolean array of length {}, but received an array {:?} of length {}",
                    key,
                    len,
                    values,
                    values.len()
                ));
            }
            unsafe {
                std::ptr::copy_nonoverlapping(values.as_ptr(), out_ptr, values.len());
            }
        }
        value => {
            let key = get_key(key_ptr);
            selene_panic(format!(
                "Runtime argument '{key}' expects a boolean array of length {len}, but received the value {value:?}"
            ));
        }
    }
}
