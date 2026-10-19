use super::super::backtrace::Module;
use super::SeleneInstance;
use anyhow::Result;
use selene_core::encoder::{OutputStream, Record, StreamWritable};
use selene_core::runtime::{
    RuntimeInstruction,
    output::{ExitRequest, PrintRequest, PrintRequestRaw, PrintValue},
};

pub fn print_directly_to_stream<T: StreamWritable>(
    out_encoder: &mut OutputStream,
    time_cursor: u64,
    tag: &str,
    value: T,
) -> Result<()> {
    // In some cases, e.g. the compiled user program, the exit namespace is already
    // encoded in the provided message. In others, e.g. runtime panics from components,
    // we need to prepend it.
    out_encoder.add_record(Record::new(time_cursor, tag)?.add_entry(value)?)?;
    Ok(())
}

impl SeleneInstance {
    /// Write a host record directly, without calling into the runtime.
    pub fn print<T: StreamWritable>(&self, tag: &str, value: T) -> Result<()> {
        print_directly_to_stream(&mut self.out_encoder.lock(), self.time_cursor(), tag, value)
    }
    pub fn print_program(&self, tag: &str, value: impl Into<PrintValue>) -> Result<()> {
        let request = PrintRequest::new(tag, value);
        // Reject values the encoder cannot represent before handing them to an
        // asynchronous runtime, while the caller can still receive the error.
        request.record(0)?;
        self.emulator
            .runtime
            .handle_instruction(RuntimeInstruction::Print { request })?
            .into_unit()
    }
    fn exit_request(message: &str, error_code: u32) -> ExitRequest {
        let mut request = ExitRequest {
            message: message.to_owned(),
            error_code,
            backtrace: Vec::new(),
        };
        if error_code >= 1000 {
            // We need the program caller's stack, before the runtime can move
            // the request to its execution thread.
            backtrace::trace(|frame| {
                let ip = frame.ip() as u64;
                if ip != 0
                    && let Some(module) = Module::from_program_counter(ip - 1)
                {
                    request.backtrace.push(PrintRequest::new(
                        format!("DEBUG:BACKTRACE:{}", module.path.display()),
                        module.address,
                    ));
                }
                true
            });
        }
        request
    }
    pub fn print_panic(&self, message: &str, error_code: u32) -> Result<()> {
        self.emulator
            .runtime
            .handle_instruction(RuntimeInstruction::Exit {
                request: Self::exit_request(message, error_code),
            })?
            .into_unit()
    }
    pub fn print_exit(&self, message: &str, error_code: u32) -> Result<()> {
        // Panic and exit have the same runtime behaviour. Their code ranges
        // tell the frontend whether the program failed or ended normally.
        self.print_panic(message, error_code)
    }
    pub fn fallible_print_panic(&self, message: &str, error_code: u32) {
        let request = Self::exit_request(message, error_code);
        if write_records(
            &mut self.out_encoder.lock(),
            self.time_cursor(),
            &request.records(),
        )
        .is_err()
        {
            // If printing the panic fails, there's not much we can do
            // to communicate the issue to the frontend, so we log it to stderr.
            eprintln!("Panic #{error_code}: {message}");
        }
    }
    pub fn print_shot_start(&self) -> Result<()> {
        self.print("SELENE:SHOT_START", self.shot_number)
    }
    pub fn print_shot_end(&self) -> Result<()> {
        self.print("SELENE:SHOT_END", self.shot_number)
    }
    pub fn flush_output(&self) -> Result<()> {
        self.out_encoder
            .lock()
            .flush()
            .map_err(|e| anyhow::anyhow!("Failed to flush output stream: {:?}", e))
    }
}

fn write_records(
    output: &mut OutputStream,
    timestamp: u64,
    requests: &[PrintRequest],
) -> Result<()> {
    let records = requests
        .iter()
        .map(|request| request.record(timestamp))
        .collect::<Result<Vec<_>>>()?;
    for record in records {
        output.add_record(record)?;
    }
    Ok(())
}

/// The runtime holds the Arc-backed encoder's address only during its shot.
/// The instance destroys the runtime before releasing that Arc.
pub(super) unsafe extern "C" fn write_output(
    context: *mut std::ffi::c_void,
    timestamp: u64,
    requests: *const PrintRequestRaw,
    length: u64,
) -> i32 {
    selene_core::runtime::callback_result(|| {
        anyhow::ensure!(
            length <= isize::MAX as u64 / size_of::<PrintRequestRaw>() as u64,
            "Too many print records"
        );
        let requests = if length == 0 {
            &[]
        } else {
            anyhow::ensure!(!requests.is_null(), "Null print records");
            unsafe { std::slice::from_raw_parts(requests, length as usize) }
        };
        let requests = requests
            .iter()
            .map(|request| unsafe { PrintRequest::from_raw(request) })
            .collect::<Result<Vec<_>>>()?;
        let encoder = unsafe { &*context.cast::<parking_lot::Mutex<OutputStream>>() };
        write_records(&mut encoder.lock(), timestamp, &requests)
    })
}

pub(super) unsafe extern "C" fn flush_output(context: *mut std::ffi::c_void) -> i32 {
    selene_core::runtime::callback_result(|| {
        let encoder = unsafe { &*context.cast::<parking_lot::Mutex<OutputStream>>() };
        encoder.lock().flush()?;
        Ok(())
    })
}
