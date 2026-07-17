//! Standalone microbenchmark that measures the raw bandwidth of Selene's
//! results-stream transports (`tcp` and `shmem`) in isolation, without any
//! QIR/simulator overhead.
//!
//! The benchmark mirrors Selene's real multi-process design: one process (the
//! *reader*, analogous to the Python process that calls `run_shots`) creates
//! and owns the transport endpoint, then spawns a second, independent OS
//! process (the *writer*, analogous to the spawned `selene` executable) which
//! connects to (TCP) or opens (shmem) that endpoint and streams data across
//! it. Both sides reuse the exact primitives and wire protocol used in
//! production:
//! - `shmem`: [`selene_core::shmem_fifo::ShmemFifo`] / `ShmemWriter`, exactly
//!   as used by `ShmemStream` (Python) and `ffi_shmem.rs` / the writer opened
//!   in `selene-sim/rust/selene_instance/configuration.rs`.
//! - `tcp`: a loopback `TcpListener`/`TcpStream`, with the writer sending the
//!   same 24-byte `(offset, increment, count)` `u64` registration header that
//!   the real spawned `selene` process sends before streaming results.

use selene_core::shmem_fifo::{ShmemFifo, ShmemWriter};
use std::io::{Read, Write};
use std::net::{Shutdown, TcpListener, TcpStream};
use std::path::Path;
use std::process::{Child, Command};
use std::time::{Duration, Instant};
use thiserror::Error;

/// Length, in bytes, of the shot-configuration registration header a real
/// writer sends after connecting over TCP (three little-endian `u64`s:
/// offset, increment, count). The benchmark writer sends the same number of
/// bytes (zeroed) purely to keep the wire protocol identical to production.
pub const TCP_HEADER_LEN: usize = 24;

#[derive(Debug, Error)]
pub enum BenchError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("shared memory error: {0}")]
    Shmem(#[from] selene_core::shmem_fifo::ShmemFifoError),
    #[error("invalid transport URI: {0}")]
    InvalidUri(String),
    #[error("data integrity check failed at byte offset {0}")]
    VerifyMismatch(u64),
}

pub type Result<T> = std::result::Result<T, BenchError>;

/// The transport under test.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Transport {
    Tcp,
    Shmem,
}

impl Transport {
    pub fn name(&self) -> &'static str {
        match self {
            Transport::Tcp => "tcp",
            Transport::Shmem => "shmem",
        }
    }
}

impl std::str::FromStr for Transport {
    type Err = String;
    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "tcp" => Ok(Transport::Tcp),
            "shmem" => Ok(Transport::Shmem),
            other => Err(format!(
                "unknown transport '{other}', expected 'tcp' or 'shmem'"
            )),
        }
    }
}

/// A parsed output-stream URI, mirroring the schemes understood by
/// `Configuration::get_output_writer` in `selene-sim`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Uri {
    Tcp { host: String, port: u16 },
    Shmem { os_id: String },
}

impl Uri {
    pub fn tcp(host: &str, port: u16) -> String {
        format!("tcp://{host}:{port}")
    }

    pub fn shmem(os_id: &str) -> String {
        format!("shmem:{os_id}")
    }

    pub fn parse(uri: &str) -> Result<Uri> {
        if let Some(os_id) = uri.strip_prefix("shmem:") {
            return Ok(Uri::Shmem {
                os_id: os_id.to_string(),
            });
        }
        let url = url::Url::parse(uri).map_err(|e| BenchError::InvalidUri(e.to_string()))?;
        if url.scheme() != "tcp" {
            return Err(BenchError::InvalidUri(format!(
                "unsupported scheme '{}'",
                url.scheme()
            )));
        }
        let host = url
            .host_str()
            .ok_or_else(|| BenchError::InvalidUri("missing host".to_string()))?
            .to_string();
        let port = url
            .port()
            .ok_or_else(|| BenchError::InvalidUri("missing port".to_string()))?;
        Ok(Uri::Tcp { host, port })
    }
}

/// Fill `buf` with a deterministic repeating byte ramp, continuing the
/// sequence from `start_pos` (the absolute stream position of `buf[0]`). This
/// lets the reader verify data integrity without any side-channel: it just
/// needs to know how many bytes it has read so far.
pub fn fill_ramp(buf: &mut [u8], start_pos: u64) {
    for (i, b) in buf.iter_mut().enumerate() {
        *b = ((start_pos.wrapping_add(i as u64)) % 256) as u8;
    }
}

/// Verify that `buf` matches the byte ramp starting at absolute stream
/// position `start_pos`. Returns the absolute position of the first mismatch,
/// if any.
pub fn verify_ramp(buf: &[u8], start_pos: u64) -> Option<u64> {
    for (i, &b) in buf.iter().enumerate() {
        let expected = ((start_pos.wrapping_add(i as u64)) % 256) as u8;
        if b != expected {
            return Some(start_pos + i as u64);
        }
    }
    None
}

/// The outcome of a single reader/writer trial.
#[derive(Debug, Clone)]
pub struct TrialResult {
    pub bytes: u64,
    pub elapsed: Duration,
}

impl TrialResult {
    pub fn mib_per_sec(&self) -> f64 {
        let secs = self.elapsed.as_secs_f64();
        if secs <= 0.0 {
            return f64::INFINITY;
        }
        (self.bytes as f64) / (1024.0 * 1024.0) / secs
    }
}

/// Basic descriptive statistics over a set of sample values.
#[derive(Debug, Clone, Copy)]
pub struct Stats {
    pub min: f64,
    pub median: f64,
    pub mean: f64,
    pub stdev: f64,
}

/// Compute [`Stats`] over a slice of samples. Panics if `values` is empty.
pub fn stats(values: &[f64]) -> Stats {
    assert!(!values.is_empty(), "stats() requires at least one sample");
    let mut sorted: Vec<f64> = values.to_vec();
    sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let n = sorted.len();
    let min = sorted[0];
    let median = if n % 2 == 1 {
        sorted[n / 2]
    } else {
        (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0
    };
    let mean = sorted.iter().sum::<f64>() / n as f64;
    let stdev = if n > 1 {
        let variance = sorted.iter().map(|v| (v - mean).powi(2)).sum::<f64>() / (n - 1) as f64;
        variance.sqrt()
    } else {
        0.0
    };
    Stats {
        min,
        median,
        mean,
        stdev,
    }
}

/// Spawn the writer role as a fresh, independent OS process, mirroring how the
/// Python `run_shots` parent spawns the `selene` executable and hands it the
/// output-stream URI.
fn spawn_writer(
    exe_path: &Path,
    uri: &str,
    total_bytes: u64,
    chunk_size: usize,
) -> std::io::Result<Child> {
    Command::new(exe_path)
        .arg("--writer-role")
        .arg(uri)
        .arg("--total-bytes")
        .arg(total_bytes.to_string())
        .arg("--chunk-size")
        .arg(chunk_size.to_string())
        .spawn()
}

/// Run the writer role: connect/open the given transport URI and stream
/// `total_bytes` across it in `chunk_size`-sized writes of the byte ramp.
/// This is invoked in the spawned child process.
pub fn run_writer(uri: &str, total_bytes: u64, chunk_size: usize) -> Result<()> {
    match Uri::parse(uri)? {
        Uri::Tcp { host, port } => {
            let mut stream = TcpStream::connect((host.as_str(), port))?;
            // Match the real writer's handshake: a zeroed shot-configuration
            // header of the same length, since the bench doesn't have real
            // shot metadata to send.
            stream.write_all(&[0u8; TCP_HEADER_LEN])?;
            write_ramp_loop(&mut stream, total_bytes, chunk_size)?;
            stream.flush()?;
            stream.shutdown(Shutdown::Write).ok();
        }
        Uri::Shmem { os_id } => {
            let mut writer = ShmemWriter::open(&os_id)?;
            write_ramp_loop(&mut writer, total_bytes, chunk_size)?;
            // Dropping `writer` marks the FIFO closed, signaling the reader.
        }
    }
    Ok(())
}

fn write_ramp_loop<W: Write>(w: &mut W, total_bytes: u64, chunk_size: usize) -> Result<()> {
    let mut buf = vec![0u8; chunk_size.max(1)];
    let mut written: u64 = 0;
    while written < total_bytes {
        let remaining = (total_bytes - written) as usize;
        let this_chunk = remaining.min(buf.len());
        fill_ramp(&mut buf[..this_chunk], written);
        w.write_all(&buf[..this_chunk])?;
        written += this_chunk as u64;
    }
    Ok(())
}

/// Run a single reader/writer trial over TCP: bind a loopback listener, spawn
/// a writer child process, accept its connection, and read until EOF while
/// timing and (optionally) verifying the stream.
pub fn run_tcp_trial(
    exe_path: &Path,
    total_bytes: u64,
    chunk_size: usize,
    verify: bool,
) -> Result<TrialResult> {
    let listener = TcpListener::bind("127.0.0.1:0")?;
    let port = listener.local_addr()?.port();
    let uri = Uri::tcp("127.0.0.1", port);

    let mut child = spawn_writer(exe_path, &uri, total_bytes, chunk_size)?;

    let (mut stream, _addr) = listener.accept()?;
    let mut header = [0u8; TCP_HEADER_LEN];
    stream.read_exact(&mut header)?;

    let start = Instant::now();
    let mut buf = vec![0u8; chunk_size.max(1)];
    let mut position: u64 = 0;
    loop {
        let n = stream.read(&mut buf)?;
        if n == 0 {
            break;
        }
        if verify && let Some(bad) = verify_ramp(&buf[..n], position) {
            return Err(BenchError::VerifyMismatch(bad));
        }
        position += n as u64;
    }
    let elapsed = start.elapsed();

    child.wait()?;

    Ok(TrialResult {
        bytes: position,
        elapsed,
    })
}

/// Run a single reader/writer trial over shmem: create the FIFO segment,
/// spawn a writer child process, and poll for data until the writer closes
/// and the FIFO is drained, timing and (optionally) verifying the stream.
pub fn run_shmem_trial(
    exe_path: &Path,
    total_bytes: u64,
    chunk_size: usize,
    shmem_capacity: usize,
    verify: bool,
) -> Result<TrialResult> {
    let fifo = ShmemFifo::create(shmem_capacity)?;
    let uri = Uri::shmem(fifo.os_id());

    let mut child = spawn_writer(exe_path, &uri, total_bytes, chunk_size)?;

    let start = Instant::now();
    let mut buf = vec![0u8; chunk_size.max(1)];
    let mut position: u64 = 0;
    loop {
        let n = fifo.read(&mut buf);
        if n > 0 {
            if verify && let Some(bad) = verify_ramp(&buf[..n], position) {
                return Err(BenchError::VerifyMismatch(bad));
            }
            position += n as u64;
            continue;
        }
        // No data currently available.
        if fifo.is_writer_closed() && fifo.available() == 0 {
            break;
        }
    }
    let elapsed = start.elapsed();

    child.wait()?;

    Ok(TrialResult {
        bytes: position,
        elapsed,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ramp_round_trips() {
        let mut buf = [0u8; 1024];
        fill_ramp(&mut buf, 250);
        assert_eq!(verify_ramp(&buf, 250), None);
    }

    #[test]
    fn ramp_detects_mismatch() {
        let mut buf = [0u8; 16];
        fill_ramp(&mut buf, 0);
        buf[5] ^= 0xFF;
        assert_eq!(verify_ramp(&buf, 0), Some(5));
    }

    #[test]
    fn ramp_continues_across_chunks() {
        // Verify that filling in two separate chunks starting from the
        // correct absolute position produces a value stream identical to
        // filling it all at once.
        let mut whole = [0u8; 300];
        fill_ramp(&mut whole, 0);

        let mut a = [0u8; 100];
        fill_ramp(&mut a, 0);
        let mut b = [0u8; 200];
        fill_ramp(&mut b, 100);

        assert_eq!(&whole[..100], &a[..]);
        assert_eq!(&whole[100..], &b[..]);
    }

    #[test]
    fn stats_basic() {
        let s = stats(&[1.0, 2.0, 3.0, 4.0, 5.0]);
        assert_eq!(s.min, 1.0);
        assert_eq!(s.median, 3.0);
        assert_eq!(s.mean, 3.0);
        assert!((s.stdev - 1.5811388).abs() < 1e-5);
    }

    #[test]
    fn stats_single_sample() {
        let s = stats(&[42.0]);
        assert_eq!(s.min, 42.0);
        assert_eq!(s.median, 42.0);
        assert_eq!(s.mean, 42.0);
        assert_eq!(s.stdev, 0.0);
    }

    #[test]
    fn stats_even_count_median_averages() {
        let s = stats(&[1.0, 2.0, 3.0, 4.0]);
        assert_eq!(s.median, 2.5);
    }

    #[test]
    fn uri_tcp_round_trips() {
        let uri = Uri::tcp("127.0.0.1", 4242);
        assert_eq!(uri, "tcp://127.0.0.1:4242");
        assert_eq!(
            Uri::parse(&uri).unwrap(),
            Uri::Tcp {
                host: "127.0.0.1".to_string(),
                port: 4242
            }
        );
    }

    #[test]
    fn uri_shmem_round_trips() {
        let uri = Uri::shmem("/some_os_id");
        assert_eq!(uri, "shmem:/some_os_id");
        assert_eq!(
            Uri::parse(&uri).unwrap(),
            Uri::Shmem {
                os_id: "/some_os_id".to_string()
            }
        );
    }

    #[test]
    fn uri_parse_rejects_unknown_scheme() {
        assert!(Uri::parse("file:///tmp/foo").is_err());
    }

    #[test]
    fn transport_from_str() {
        assert_eq!("tcp".parse::<Transport>().unwrap(), Transport::Tcp);
        assert_eq!("shmem".parse::<Transport>().unwrap(), Transport::Shmem);
        assert!("bogus".parse::<Transport>().is_err());
    }
}
