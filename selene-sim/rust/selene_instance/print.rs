use super::SeleneInstance;
use anyhow::Result;
use selene_core::encoder::{OutputStream, StreamWritable};

pub fn print_directly_to_stream<T: StreamWritable>(
    out_encoder: &mut OutputStream,
    time_cursor: u64,
    tag: &str,
    value: T,
) -> Result<()> {
    // In some cases, e.g. the compiled user program, the exit namespace is already
    // encoded in the provided message. In others, e.g. runtime panics from components,
    // we need to prepend it.
    out_encoder.begin_message(time_cursor)?;
    out_encoder.write(tag)?;
    out_encoder.write(value)?;
    out_encoder.end_message()?;
    Ok(())
}

impl SeleneInstance {
    /// Write a tagged boolean variable to the result stream.
    pub fn print<T: StreamWritable>(&mut self, tag: &str, value: T) -> Result<()> {
        print_directly_to_stream(&mut self.out_encoder, self.time_cursor, tag, value)
    }
    fn emit_debug_trace(&mut self) -> Result<()> {
        // Capture the backtrace at the point of the panic and include it in the output stream.
        // This can be used by the frontend to provide more context about where a panic occurred,
        // which is especially useful for panics originating from compiled user code, where the
        // source of the panic may not be immediately obvious.
        let mut status = Ok(());
        backtrace::trace(|frame| {
            let ip = frame.ip() as u64;
            if ip != 0 {
                let pc = ip - 1;
                let base = frame.module_base_address().map(|p| p as u64).unwrap_or(0);
                let address = pc - base;
                if let Err(e) = self.print("DEBUG:BACKTRACE", address) {
                    status = Err(anyhow::anyhow!("Failed to emit debug trace: {:?}", e));
                    return false;
                }
            }
            true
        });
        status
        /*
            backtrace::resolve_frame(frame, |symbol| {
                let Some(filename) = symbol.filename().map(|f| f.display().to_string()) else {
                    return;
                };
                let Some(name) = symbol.name().map(|f| f.to_string()) else {
                    return;
                };
                if name == "qmain" {
                    // libraries, which can be noisy and not helpful for debugging user code.
                    done = true;
                }
                let Some(line) = symbol.lineno() else {
                    return;
                };
                let Some(col) = symbol.colno() else {
                    return;
                };
                let tag = format!("DEBUG:TRACE:{filename}#{line}#{col}#{name}");
                if let Err(e) = self.print(&tag, 0u64) {
                    status = Err(anyhow::anyhow!("Failed to emit debug trace: {:?}", e));
                }
            });
            status.is_ok() && !done
        });
        status
        */
    }
    pub fn print_panic(&mut self, message: &str, error_code: u32) -> Result<()> {
        if error_code >= 1000 {
            // For full panics (that prevent further shots), we emit a debug backtrace.
            self.emit_debug_trace()?;
        }

        // In some cases, e.g. the compiled user program, the exit namespace is already
        // encoded in the provided message. In others, e.g. runtime panics from components,
        // we need to prepend it.
        let tag = if message.starts_with("EXIT:INT:") {
            message.to_string()
        } else {
            format!("EXIT:INT:{}", message)
        };
        self.print(&tag, error_code as u64)
    }
    pub fn print_exit(&mut self, message: &str, error_code: u32) -> Result<()> {
        // At present, we handle exits in the same way as panics - the code
        // is used to communicate the semantics. This is a placeholder incase
        // we want to differentiate them in the future.
        self.print_panic(message, error_code)
    }
    pub fn fallible_print_panic(&mut self, message: &str, error_code: u32) {
        if self.print_panic(message, error_code).is_err() {
            // If printing the panic fails, there's not much we can do
            // to communicate the issue to the frontend, so we log it to stderr.
            eprintln!("Panic #{error_code}: {message}");
        }
    }
    pub fn print_shot_start(&mut self) -> Result<()> {
        self.print("SELENE:SHOT_START", self.shot_number)
    }
    pub fn print_shot_end(&mut self) -> Result<()> {
        self.print("SELENE:SHOT_END", self.shot_number)
    }
    pub fn flush_output(&mut self) -> Result<()> {
        self.out_encoder
            .flush()
            .map_err(|e| anyhow::anyhow!("Failed to flush output stream: {:?}", e))
    }
}
