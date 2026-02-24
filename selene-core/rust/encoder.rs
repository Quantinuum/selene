use std::io::Write;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum OutputStreamError {
    #[error("IO Error: {0}")]
    IoError(std::io::Error),
    #[error("Empty arrays are not allowed")]
    EmptyArrayError, // A zero-length array of non-string primatives is handled as a single
    // element.
    #[error("Array size {0} exceeds maximum size")]
    OversizeArrayError(usize),
    #[error("String size {0} exceeds maximum size")]
    OversizeStringError(usize),
    #[error("Tag pointer is null")]
    NullTagError,
    #[error("String contains null byte: {0:?}")]
    CorruptedStringError(Box<[u8]>),
    #[error("{0}")]
    OtherError(String),
}

pub trait StreamWritable {
    const TYPE_REPR: u16;
    fn write<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        stream
            .write_all(&Self::TYPE_REPR.to_le_bytes())
            .map_err(OutputStreamError::IoError)?;
        stream
            .write_all(&self.get_length()?.to_le_bytes())
            .map_err(OutputStreamError::IoError)?;
        self.write_impl(stream)
    }
    fn get_length(&self) -> Result<u16, OutputStreamError>;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError>;
}
impl StreamWritable for &str {
    const TYPE_REPR: u16 = 3;
    fn get_length(&self) -> Result<u16, OutputStreamError> {
        if self.len() > u16::MAX as usize {
            return Err(OutputStreamError::OversizeStringError(self.len()));
        }
        Ok(self.len() as u16)
    }
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        if self.contains('\0') {
            return Err(OutputStreamError::CorruptedStringError(
                self.as_bytes().into(),
            ));
        }
        stream
            .write_all(self.as_bytes())
            .map_err(OutputStreamError::IoError)
    }
}
pub trait StreamWritableSingle {
    const TYPE_REPR: u16;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError>;
}
impl<T: StreamWritableSingle> StreamWritable for T {
    const TYPE_REPR: u16 = T::TYPE_REPR;
    fn get_length(&self) -> Result<u16, OutputStreamError> {
        // by default, we're writing a single value.
        // The encoding we use defines a length of 0 as a single non-array value.
        Ok(0)
    }
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        self.write_impl(stream)
    }
}
impl<T: StreamWritableSingle> StreamWritable for &[T] {
    const TYPE_REPR: u16 = T::TYPE_REPR;
    fn get_length(&self) -> Result<u16, OutputStreamError> {
        if self.is_empty() {
            return Err(OutputStreamError::EmptyArrayError);
        }
        if self.len() > u16::MAX as usize {
            return Err(OutputStreamError::OversizeArrayError(self.len()));
        }
        Ok(self.len() as u16)
    }
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        for item in self.iter() {
            item.write_impl(stream)?;
        }
        Ok(())
    }
}
impl StreamWritableSingle for bool {
    const TYPE_REPR: u16 = 4;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        let byte = if *self { 1u8 } else { 0u8 };
        stream
            .write_all(&[byte])
            .map_err(OutputStreamError::IoError)
    }
}
impl StreamWritableSingle for u64 {
    const TYPE_REPR: u16 = 1;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        stream
            .write_all(&self.to_le_bytes())
            .map_err(OutputStreamError::IoError)
    }
}
impl StreamWritableSingle for i64 {
    const TYPE_REPR: u16 = 5;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        stream
            .write_all(&self.to_le_bytes())
            .map_err(OutputStreamError::IoError)
    }
}
impl StreamWritableSingle for f64 {
    const TYPE_REPR: u16 = 2;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        stream
            .write_all(&self.to_le_bytes())
            .map_err(OutputStreamError::IoError)
    }
}
impl StreamWritableSingle for u8 {
    const TYPE_REPR: u16 = 9116;
    fn write_impl<W: Write>(&self, stream: &mut W) -> Result<(), OutputStreamError> {
        stream
            .write_all(&self.to_le_bytes())
            .map_err(OutputStreamError::IoError)
    }
}

pub struct InternalBuffer {
    buffer: Vec<u8>,
    last_read_index: usize,
}
impl Default for InternalBuffer {
    fn default() -> Self {
        InternalBuffer {
            buffer: Vec::with_capacity(1024 * 64),
            last_read_index: 0,
        }
    }
}
impl Write for InternalBuffer {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.buffer.extend_from_slice(buf);
        Ok(buf.len())
    }
    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}
impl InternalBuffer {
    fn try_read(&mut self, length: usize) -> Result<&[u8], OutputStreamError> {
        let max_len = self.buffer.len() - self.last_read_index;
        let length = length.min(max_len);
        let data = &self.buffer[self.last_read_index..self.last_read_index + length];
        self.last_read_index += length;
        Ok(data)
    }
}

pub enum OutputWriter {
    Internal(InternalBuffer),
    Stdout(std::io::Stdout),
    Stderr(std::io::Stderr),
    File(std::fs::File),
    Tcp(std::net::TcpStream),
}
impl Write for OutputWriter {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        match self {
            OutputWriter::Internal(internal) => internal.write(buf),
            OutputWriter::Stdout(stdout) => stdout.write(buf),
            OutputWriter::Stderr(stderr) => stderr.write(buf),
            OutputWriter::File(file) => file.write(buf),
            OutputWriter::Tcp(tcp) => tcp.write(buf),
        }
    }
    fn flush(&mut self) -> std::io::Result<()> {
        match self {
            OutputWriter::Internal(internal) => internal.flush(),
            OutputWriter::Stdout(stdout) => stdout.flush(),
            OutputWriter::Stderr(stderr) => stderr.flush(),
            OutputWriter::File(file) => file.flush(),
            OutputWriter::Tcp(tcp) => tcp.flush(),
        }
    }
}

pub struct OutputStream {
    writer: OutputWriter,
    bytes_written: usize,
}
impl OutputStream {
    pub fn new(writer: OutputWriter) -> Self {
        OutputStream {
            writer,
            bytes_written: 0,
        }
    }
    pub fn get_bytes_written(&self) -> usize {
        self.bytes_written
    }
    fn write_impl(&mut self, value: &[u8]) -> Result<(), OutputStreamError> {
        self.writer
            .write_all(value)
            .map_err(OutputStreamError::IoError)
    }
    pub fn flush(&mut self) -> Result<(), OutputStreamError> {
        self.writer.flush().map_err(OutputStreamError::IoError)
    }
    pub fn try_read(&mut self, length: usize) -> Result<&[u8], OutputStreamError> {
        match &mut self.writer {
            OutputWriter::Internal(internal) => internal.try_read(length),
            _ => Err(OutputStreamError::OtherError(
                "Read operations are not supported for external writers".to_string(),
            )),
        }
    }

    pub fn begin_message(&mut self, time_cursor: u64) -> Result<(), OutputStreamError> {
        self.write_impl(&time_cursor.to_le_bytes())
    }
    pub fn end_message(&mut self) -> Result<(), OutputStreamError> {
        self.write_impl(&0u16.to_le_bytes())?;
        self.write_impl(&0u16.to_le_bytes())
    }
    pub fn end_of_stream(&mut self) -> Result<(), OutputStreamError> {
        self.write_impl(&u64::MAX.to_le_bytes())
    }
    // Single element writers
    pub fn write<T: StreamWritable>(&mut self, value: T) -> Result<(), OutputStreamError> {
        value.write(&mut self.writer)
    }
}
impl Drop for OutputStream {
    fn drop(&mut self) {
        if let Err(e) = self.end_of_stream() {
            eprintln!("Error closing output encoder: {}", e);
        }
        if let Err(e) = self.flush() {
            eprintln!("Error flushing output encoder: {}", e);
        }
    }
}
