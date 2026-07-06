//! A fixed-size, single-writer/single-reader byte FIFO backed by a shared
//! memory segment.
//!
//! The FIFO is a lock-free SPSC (single-producer, single-consumer) ring buffer.
//! One process (the *reader*, typically the Python process that calls
//! `run_shots`) creates the segment and owns its lifetime, destroying it when
//! it is dropped. Another process (the *writer*, the spawned selene executable)
//! opens the existing segment by its OS id.
//!
//! # Layout
//!
//! ```text
//! offset 0  : capacity      u64        (bytes in the data region)
//! offset 8  : head          AtomicU64  (total bytes consumed by the reader)
//! offset 16 : tail          AtomicU64  (total bytes produced by the writer)
//! offset 24 : writer_closed AtomicU8   (0 = open, 1 = closed)
//! offset 64 : data          [u8; capacity] (ring buffer)
//! ```
//!
//! `head` and `tail` are monotonically increasing counters; the actual index
//! into the ring buffer is `counter % capacity`. Using ever-increasing counters
//! avoids the classic full/empty ambiguity of a wrap-around ring buffer.

use shared_memory::{Shmem, ShmemConf, ShmemError};
use std::sync::atomic::{AtomicU8, AtomicU64, Ordering};

/// Byte offset of the capacity field within the segment.
const OFF_CAPACITY: usize = 0;
/// Byte offset of the head counter within the segment.
const OFF_HEAD: usize = 8;
/// Byte offset of the tail counter within the segment.
const OFF_TAIL: usize = 16;
/// Byte offset of the writer-closed flag within the segment.
const OFF_WRITER_CLOSED: usize = 24;
/// Size of the header region, padded to a cache line so the data region starts
/// aligned and header fields do not share a cache line with the data.
const HEADER_SIZE: usize = 64;

/// Errors that can occur while operating on a shared-memory FIFO.
#[derive(Debug, thiserror::Error)]
pub enum ShmemFifoError {
    #[error("shared memory error: {0}")]
    Shmem(#[from] ShmemError),
    #[error("shared memory segment is too small: {size} bytes")]
    TooSmall { size: usize },
    #[error("requested capacity must be greater than zero")]
    ZeroCapacity,
}

/// A single-writer/single-reader byte FIFO over shared memory.
pub struct ShmemFifo {
    shmem: Shmem,
    capacity: usize,
}

// The FIFO is only ever driven from a single thread within a given process, so
// exposing it across threads is unnecessary; the shared-memory synchronisation
// is between processes via the atomic counters.

impl ShmemFifo {
    /// Create a new FIFO with the given data-region capacity (in bytes),
    /// generating a fresh OS id. The returned FIFO owns the segment and will
    /// unlink it when dropped.
    pub fn create(capacity: usize) -> Result<Self, ShmemFifoError> {
        if capacity == 0 {
            return Err(ShmemFifoError::ZeroCapacity);
        }
        let total = HEADER_SIZE + capacity;
        let shmem = ShmemConf::new().size(total).create()?;
        // POSIX shared memory is zero-initialised on creation, so head, tail
        // and writer_closed already start at zero.
        let fifo = ShmemFifo { shmem, capacity };
        // Publish the capacity so that the writer, which opens by id, can
        // discover the data-region size.
        fifo.capacity_atomic()
            .store(capacity as u64, Ordering::Release);
        Ok(fifo)
    }

    /// Open an existing FIFO by its OS id. The returned FIFO does not own the
    /// segment and will not unlink it when dropped.
    pub fn open(os_id: &str) -> Result<Self, ShmemFifoError> {
        let shmem = ShmemConf::new().os_id(os_id).open()?;
        if shmem.len() < HEADER_SIZE {
            return Err(ShmemFifoError::TooSmall { size: shmem.len() });
        }
        let mut fifo = ShmemFifo { shmem, capacity: 0 };
        let capacity = fifo.capacity_atomic().load(Ordering::Acquire) as usize;
        if capacity == 0 || HEADER_SIZE + capacity > fifo.shmem.len() {
            return Err(ShmemFifoError::TooSmall {
                size: fifo.shmem.len(),
            });
        }
        fifo.capacity = capacity;
        Ok(fifo)
    }

    /// The OS id of the underlying segment, used to construct the `shmem://`
    /// URI passed to the writer.
    pub fn os_id(&self) -> &str {
        self.shmem.get_os_id()
    }

    /// The capacity of the data region in bytes.
    pub fn capacity(&self) -> usize {
        self.capacity
    }

    /// Whether this handle owns the segment (i.e. it created it).
    pub fn is_owner(&self) -> bool {
        self.shmem.is_owner()
    }

    fn base_ptr(&self) -> *mut u8 {
        self.shmem.as_ptr()
    }

    fn capacity_atomic(&self) -> &AtomicU64 {
        // SAFETY: OFF_CAPACITY is within the mapped segment (>= HEADER_SIZE
        // bytes) and 8-byte aligned relative to the page-aligned base.
        unsafe { &*(self.base_ptr().add(OFF_CAPACITY) as *const AtomicU64) }
    }

    fn head_atomic(&self) -> &AtomicU64 {
        // SAFETY: see `capacity_atomic`; OFF_HEAD is aligned and in bounds.
        unsafe { &*(self.base_ptr().add(OFF_HEAD) as *const AtomicU64) }
    }

    fn tail_atomic(&self) -> &AtomicU64 {
        // SAFETY: see `capacity_atomic`; OFF_TAIL is aligned and in bounds.
        unsafe { &*(self.base_ptr().add(OFF_TAIL) as *const AtomicU64) }
    }

    fn writer_closed_atomic(&self) -> &AtomicU8 {
        // SAFETY: see `capacity_atomic`; OFF_WRITER_CLOSED is in bounds.
        unsafe { &*(self.base_ptr().add(OFF_WRITER_CLOSED) as *const AtomicU8) }
    }

    fn data_ptr(&self) -> *mut u8 {
        // SAFETY: the data region begins at HEADER_SIZE and spans `capacity`
        // bytes, all within the mapped segment.
        unsafe { self.base_ptr().add(HEADER_SIZE) }
    }

    /// Number of bytes currently available to read.
    pub fn available(&self) -> usize {
        let head = self.head_atomic().load(Ordering::Acquire);
        let tail = self.tail_atomic().load(Ordering::Acquire);
        (tail - head) as usize
    }

    /// Number of bytes of free space currently available to write.
    pub fn free(&self) -> usize {
        self.capacity - self.available()
    }

    /// Mark the writer side as closed. Called by the writer when it is done.
    pub fn set_writer_closed(&self) {
        self.writer_closed_atomic().store(1, Ordering::Release);
    }

    /// Whether the writer side has been closed.
    pub fn is_writer_closed(&self) -> bool {
        self.writer_closed_atomic().load(Ordering::Acquire) != 0
    }

    /// Write as many bytes from `buf` as currently fit into the FIFO, without
    /// blocking. Returns the number of bytes written (may be zero if full).
    pub fn write(&self, buf: &[u8]) -> usize {
        let head = self.head_atomic().load(Ordering::Acquire);
        let tail = self.tail_atomic().load(Ordering::Acquire);
        let free = self.capacity - (tail - head) as usize;
        let to_write = free.min(buf.len());
        if to_write == 0 {
            return 0;
        }
        let start = (tail as usize) % self.capacity;
        let first = to_write.min(self.capacity - start);
        // SAFETY: the reader never touches the [start, start+to_write) region
        // (mod capacity) while these bytes are unpublished, because that space
        // is counted as free until we advance `tail` below.
        unsafe {
            std::ptr::copy_nonoverlapping(buf.as_ptr(), self.data_ptr().add(start), first);
            if to_write > first {
                std::ptr::copy_nonoverlapping(
                    buf.as_ptr().add(first),
                    self.data_ptr(),
                    to_write - first,
                );
            }
        }
        self.tail_atomic()
            .store(tail + to_write as u64, Ordering::Release);
        to_write
    }

    /// Read as many bytes as are currently available into `buf`, without
    /// blocking. Returns the number of bytes read (may be zero if empty).
    pub fn read(&self, buf: &mut [u8]) -> usize {
        let head = self.head_atomic().load(Ordering::Acquire);
        let tail = self.tail_atomic().load(Ordering::Acquire);
        let available = (tail - head) as usize;
        let to_read = available.min(buf.len());
        if to_read == 0 {
            return 0;
        }
        let start = (head as usize) % self.capacity;
        let first = to_read.min(self.capacity - start);
        // SAFETY: the writer never overwrites the [start, start+to_read) region
        // (mod capacity) while these bytes are unconsumed, because that space is
        // counted as used until we advance `head` below.
        unsafe {
            std::ptr::copy_nonoverlapping(self.data_ptr().add(start), buf.as_mut_ptr(), first);
            if to_read > first {
                std::ptr::copy_nonoverlapping(
                    self.data_ptr(),
                    buf.as_mut_ptr().add(first),
                    to_read - first,
                );
            }
        }
        self.head_atomic()
            .store(head + to_read as u64, Ordering::Release);
        to_read
    }
}

/// A blocking, `Write`-based adapter over a [`ShmemFifo`] for the writer side.
///
/// Writes block until all bytes have been placed into the FIFO, applying
/// backpressure when the ring buffer is full. While full, the writer spins
/// in-process with exponential backoff (using [`std::hint::spin_loop`]) rather
/// than yielding to the OS, doubling the spin count up to a cap and resetting
/// on progress. When the writer is dropped it marks the FIFO as closed so the
/// reader can detect the end of the stream even if no explicit end-of-stream
/// marker was written (for example after a crash).
pub struct ShmemWriter {
    fifo: ShmemFifo,
}

impl ShmemWriter {
    /// Wrap an opened FIFO for use as a blocking writer.
    pub fn new(fifo: ShmemFifo) -> Self {
        ShmemWriter { fifo }
    }

    /// Open an existing FIFO by OS id and wrap it as a writer.
    pub fn open(os_id: &str) -> Result<Self, ShmemFifoError> {
        Ok(ShmemWriter::new(ShmemFifo::open(os_id)?))
    }
}

impl std::io::Write for ShmemWriter {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        // Lower and upper bounds for the exponential backoff spin count.
        const MIN_SPINS: u32 = 1;
        const MAX_SPINS: u32 = 1 << 12;

        let mut written = 0;
        let mut spins = MIN_SPINS;
        while written < buf.len() {
            let n = self.fifo.write(&buf[written..]);
            if n == 0 {
                // FIFO is full. Busy-wait in-process with exponential backoff
                // until the reader frees space, avoiding an OS sleep.
                for _ in 0..spins {
                    std::hint::spin_loop();
                }
                spins = (spins << 1).min(MAX_SPINS);
                continue;
            }
            written += n;
            // Made progress; reset the backoff.
            spins = MIN_SPINS;
        }
        Ok(written)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

impl Drop for ShmemWriter {
    fn drop(&mut self) {
        self.fifo.set_writer_closed();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn round_trip_within_capacity() {
        let fifo = ShmemFifo::create(1024).unwrap();
        assert_eq!(fifo.capacity(), 1024);
        assert_eq!(fifo.available(), 0);
        assert_eq!(fifo.free(), 1024);

        let data = b"hello, shared memory FIFO";
        let written = fifo.write(data);
        assert_eq!(written, data.len());
        assert_eq!(fifo.available(), data.len());

        let mut out = vec![0u8; data.len()];
        let read = fifo.read(&mut out);
        assert_eq!(read, data.len());
        assert_eq!(&out, data);
        assert_eq!(fifo.available(), 0);
    }

    #[test]
    fn write_is_bounded_by_free_space() {
        let fifo = ShmemFifo::create(8).unwrap();
        let written = fifo.write(&[1u8; 16]);
        assert_eq!(written, 8, "should only write up to capacity");
        assert_eq!(fifo.free(), 0);
        assert_eq!(fifo.write(&[2u8; 4]), 0, "no space left");
    }

    #[test]
    fn read_is_bounded_by_available() {
        let fifo = ShmemFifo::create(16).unwrap();
        fifo.write(&[7u8; 4]);
        let mut out = vec![0u8; 10];
        let read = fifo.read(&mut out);
        assert_eq!(read, 4);
        assert_eq!(&out[..4], &[7u8; 4]);
        assert_eq!(fifo.read(&mut out), 0, "nothing left to read");
    }

    #[test]
    fn wraps_around_the_ring() {
        let cap = 8;
        let fifo = ShmemFifo::create(cap).unwrap();
        // Advance head/tail near the wrap boundary.
        fifo.write(&[0u8; 6]);
        let mut sink = vec![0u8; 6];
        assert_eq!(fifo.read(&mut sink), 6);
        // Now write a chunk that must wrap across the end of the ring.
        let data = [1u8, 2, 3, 4, 5];
        assert_eq!(fifo.write(&data), 5);
        let mut out = vec![0u8; 5];
        assert_eq!(fifo.read(&mut out), 5);
        assert_eq!(out, data);
    }

    #[test]
    fn writer_closed_flag_round_trips() {
        let fifo = ShmemFifo::create(16).unwrap();
        assert!(!fifo.is_writer_closed());
        fifo.set_writer_closed();
        assert!(fifo.is_writer_closed());
    }

    #[test]
    fn open_shares_the_same_segment() {
        let writer = ShmemFifo::create(64).unwrap();
        let os_id = writer.os_id().to_string();
        let reader = ShmemFifo::open(&os_id).unwrap();
        assert_eq!(reader.capacity(), 64);

        let msg = b"cross-handle";
        assert_eq!(writer.write(msg), msg.len());
        let mut out = vec![0u8; msg.len()];
        assert_eq!(reader.read(&mut out), msg.len());
        assert_eq!(&out, msg);
    }
}
