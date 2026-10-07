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

/// A record is built privately before any of its bytes reach the output stream.
pub struct Record {
    buffer: Vec<u8>,
    failed: bool,
}

impl Record {
    pub fn new(time_cursor: u64, tag: &str) -> Result<Self, OutputStreamError> {
        let mut record = Self {
            buffer: time_cursor.to_le_bytes().to_vec(),
            failed: false,
        };
        record.push(tag)?;
        Ok(record)
    }

    /// Add an entry, returning the builder so calls can be chained with `?`.
    pub fn add_entry<T: StreamWritable>(mut self, value: T) -> Result<Self, OutputStreamError> {
        self.push(value)?;
        Ok(self)
    }

    /// Append an entry when the record is being constructed in a loop.
    pub fn push<T: StreamWritable>(&mut self, value: T) -> Result<(), OutputStreamError> {
        if self.failed {
            return Err(OutputStreamError::OtherError(
                "Record construction previously failed".into(),
            ));
        }
        if let Err(error) = value.write(&mut self.buffer) {
            // Even if the caller ignores this error, we can't submit the record
            // because an entry may have been written only partially.
            self.failed = true;
            return Err(error);
        }
        Ok(())
    }
}

pub struct OutputStream {
    writer: OutputWriter,
    bytes_written: usize,
    failed: bool,
}
impl OutputStream {
    pub fn new(writer: OutputWriter) -> Self {
        OutputStream {
            writer,
            bytes_written: 0,
            failed: false,
        }
    }
    pub fn get_bytes_written(&self) -> usize {
        self.bytes_written
    }
    fn write_impl(&mut self, value: &[u8]) -> Result<(), OutputStreamError> {
        if self.failed {
            return Err(OutputStreamError::OtherError(
                "Output stream previously failed".into(),
            ));
        }
        if let Err(error) = self.writer.write_all(value) {
            // A transport failure may leave part of a record on the wire. We
            // mustn't append a panic or an end marker to that partial record.
            self.failed = true;
            return Err(OutputStreamError::IoError(error));
        }
        self.bytes_written += value.len();
        Ok(())
    }
    pub fn flush(&mut self) -> Result<(), OutputStreamError> {
        if let Err(error) = self.writer.flush() {
            self.failed = true;
            return Err(OutputStreamError::IoError(error));
        }
        Ok(())
    }
    pub fn try_read(&mut self, length: usize) -> Result<&[u8], OutputStreamError> {
        match &mut self.writer {
            OutputWriter::Internal(internal) => internal.try_read(length),
            _ => Err(OutputStreamError::OtherError(
                "Read operations are not supported for external writers".to_string(),
            )),
        }
    }

    pub fn add_record(&mut self, mut record: Record) -> Result<(), OutputStreamError> {
        if record.failed {
            return Err(OutputStreamError::OtherError(
                "Cannot submit a record whose construction failed".into(),
            ));
        }
        record.buffer.extend_from_slice(&[0; 4]);
        self.write_impl(&record.buffer)
    }
    pub fn end_of_stream(&mut self) -> Result<(), OutputStreamError> {
        self.write_impl(&u64::MAX.to_le_bytes())
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

#[cfg(test)]
mod tests {
    use super::*;

    fn stream() -> OutputStream {
        OutputStream::new(OutputWriter::Internal(InternalBuffer::default()))
    }

    #[test]
    fn complete_record_keeps_the_existing_wire_format() {
        let mut output = stream();
        let record = Record::new(7, "answer").unwrap().add_entry(42u64).unwrap();
        output.flush().unwrap();
        assert!(output.try_read(usize::MAX).unwrap().is_empty());
        output.add_record(record).unwrap();

        let mut expected = 7u64.to_le_bytes().to_vec();
        expected.extend_from_slice(&[3, 0, 6, 0]);
        expected.extend_from_slice(b"answer");
        expected.extend_from_slice(&[1, 0, 0, 0]);
        expected.extend_from_slice(&42u64.to_le_bytes());
        expected.extend_from_slice(&[0; 4]);
        assert_eq!(output.try_read(usize::MAX).unwrap(), expected);
    }

    fn rejected_entry<T: StreamWritable>(value: T) {
        let mut output = stream();
        output
            .add_record(Record::new(0, "before").unwrap().add_entry(1u64).unwrap())
            .unwrap();
        let before = output.try_read(usize::MAX).unwrap().to_vec();
        assert!(!before.is_empty());

        let mut record = Record::new(1, "INSTRUCTIONLOG").unwrap();
        record.push(9u64).unwrap();
        record.push(42u64).unwrap();
        assert!(record.push(value).is_err());
        // Ignoring the first error mustn't allow either more entries or a
        // submission that silently omits the rejected field.
        assert!(record.push(123u64).is_err());
        assert!(output.add_record(record).is_err());
        assert!(output.try_read(usize::MAX).unwrap().is_empty());

        output
            .add_record(
                Record::new(2, "panic")
                    .unwrap()
                    .add_entry(100001u64)
                    .unwrap(),
            )
            .unwrap();
        let mut expected = stream();
        expected
            .add_record(
                Record::new(2, "panic")
                    .unwrap()
                    .add_entry(100001u64)
                    .unwrap(),
            )
            .unwrap();
        assert_eq!(
            output.try_read(usize::MAX).unwrap(),
            expected.try_read(usize::MAX).unwrap()
        );
    }

    #[test]
    fn validation_failures_discard_the_whole_record() {
        rejected_entry(&[] as &[u8]);
        rejected_entry(vec![0u64; u16::MAX as usize + 1].as_slice());
        rejected_entry("x".repeat(u16::MAX as usize + 1).as_str());
        rejected_entry("embedded\0nul");
    }

    #[test]
    fn failed_tag_and_abandoned_builder_write_nothing() {
        let mut output = stream();
        assert!(Record::new(0, "bad\0tag").is_err());
        let record = Record::new(0, "abandoned")
            .unwrap()
            .add_entry(42u64)
            .unwrap();
        drop(record);
        output.end_of_stream().unwrap();
        assert_eq!(output.try_read(usize::MAX).unwrap(), u64::MAX.to_le_bytes());
    }

    #[test]
    fn transport_failure_prevents_further_records() {
        // Writing to a read-only file gives us an actual I/O error without
        // relying on a socket reset or a platform-specific device file.
        let file = std::fs::File::open(concat!(env!("CARGO_MANIFEST_DIR"), "/Cargo.toml")).unwrap();
        let mut output = OutputStream::new(OutputWriter::File(file));
        assert!(matches!(
            output.add_record(Record::new(0, "result").unwrap().add_entry(42u64).unwrap()),
            Err(OutputStreamError::IoError(_))
        ));
        // Replace the writer to observe whether the stream attempts any more
        // output. It can't know how much of the failed record was delivered.
        output.writer = OutputWriter::Internal(InternalBuffer::default());
        assert!(output.add_record(Record::new(0, "panic").unwrap()).is_err());
        assert!(output.end_of_stream().is_err());
        assert!(output.try_read(usize::MAX).unwrap().is_empty());
    }
}
