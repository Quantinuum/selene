use serde::{Deserialize, Serialize};

/// When logging via selene's log_utility_call function,
/// we pass this identifying tag so we can recognise the
/// call in the selene trace and handle it appropriately.
const ENVREADER_LOGGING_TAG: u64 = 0xE91113EADE130746;

unsafe extern "C" {
    // this is imported from selene at link time.
    // note that we can't use panic() -> this conflicts with libSystem on Darwin,
    // and cargo really wants to link it in while this is compiling.
    //
    // Instead we use panic_str, an exposed function for registering a panic with
    // the selene result stream based on a C string rather than a CL string.
    fn panic_str(error_code: u32, message: *const std::ffi::c_char) -> !;
    fn log_utility_call(tag: u64, data_ptr: *const u8, data_len: u64);
}

fn selene_panic(message: String) -> ! {
    // Convert the message to a C string
    let message = message.into_bytes();
    let message = std::ffi::CString::new(message).unwrap();
    // Issue the panic
    // print just in case the panic_str fails to make it through to
    // the results stream.
    eprintln!("EnvReader: Panic: {}", message.to_string_lossy());
    unsafe { panic_str(60001, message.as_ptr()) }
}


#[derive(Serialize, Deserialize, Debug)]
struct LogEntry<ValueType: Serialize> {
    key: String,
    string_value: String,
    typed_value: ValueType,
}


fn log<ValueType: Serialize>(key: String, string_value: String, typed_value: ValueType) {
    let entry = LogEntry::<ValueType> {
        key,
        string_value,
        typed_value,
    };
    // serde encode it
    let yaml = serde_yml::to_string(&entry).unwrap_or_else(|e| {
        selene_panic(format!(
            "Failed to serialize log entry for key '{}': {}",
            entry.key, e
        ));
    });
    let data = yaml.into_bytes();
    unsafe {
        log_utility_call(ENVREADER_LOGGING_TAG, data.as_ptr(), data.len() as u64);
    }
}

fn decode_string(name_ptr: *const u8) -> String {
    // As with result() calls and panic() calls, the format of the key starts with
    // byte providing the length of the string that follows.
    unsafe {
        if name_ptr.is_null() {
            selene_panic("Received null pointer for environment variable name".to_string());
        }
        let length = *name_ptr;
        let string_start = name_ptr.add(1);
        let slice = std::slice::from_raw_parts(string_start, length as usize);
        let Ok(key) = std::str::from_utf8(slice) else {
            selene_panic("Environment variable names must be valid UTF-8".to_string());
        };
        key.to_string()
    }
}


fn get_env_var(name: &String) -> String {
    std::env::var(name)
        .unwrap_or_else(|_| {
            selene_panic(format!("Environment variable '{name}' not found"));
        })
}

/// Get a boolean environment variable given a CL-string name.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn envreader_get_bool(name_ptr: *const u8) -> bool {
    let name = decode_string(name_ptr);
    let value = get_env_var(&name);
    let result = match value.to_lowercase().as_str() {
        "true" | "1" => true,
        "false" | "0" => false,
        _ => selene_panic(format!(
            "Environment variable '{value}' is not a valid boolean value (expected 'true', 'false', '1', or '0')"
        )),
    };
    log(name, value, result);
    result
}

/// Get a u64 environment variable given a CL-string name.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn envreader_get_u64(name_ptr: *const u8) -> u64 {
    let name = decode_string(name_ptr);
    let value = get_env_var(&name);
    let result = value.parse::<u64>().unwrap_or_else(|_| {
        selene_panic(format!(
            "Environment variable '{value}' is not a valid unsigned integer"
        ));
    });
    log(name, value, result);
    result
}

/// Get an i64 environment variable given a CL-string name.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn envreader_get_i64(name_ptr: *const u8) -> i64 {
    let name = decode_string(name_ptr);
    let value = get_env_var(&name);
    let result = value.parse::<i64>().unwrap_or_else(|_| {
        selene_panic(format!(
            "Environment variable '{value}' is not a valid signed integer"
        ));
    });
    log(name, value, result);
    result
}

/// Get an f64 environment variable given a CL-string name.
///
/// # Safety
/// The provided pointer must point to a valid CL string, with the char
/// at the pointer providing the length of the UTF-8 string that follows it.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn envreader_get_f64(name_ptr: *const u8) -> f64 {
    let name = decode_string(name_ptr);
    let value = get_env_var(&name);
    let result = value.parse::<f64>().unwrap_or_else(|_| {
        selene_panic(format!(
            "Environment variable '{value}' is not a valid floating-point number"
        ));
    });
    log(name, value, result);
    result
}
