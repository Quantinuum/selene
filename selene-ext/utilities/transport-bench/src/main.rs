//! CLI entry point for the transport bandwidth microbenchmark. Run without
//! `--writer-role` to act as the reader/orchestrator (this is the normal user
//! entry point); the reader spawns a second copy of this same binary with
//! `--writer-role` set, which then behaves as the writer child process.

use clap::Parser;
use std::env;
use std::str::FromStr;
use transport_bench::{Transport, TrialResult, run_shmem_trial, run_tcp_trial, run_writer, stats};

/// Standalone microbenchmark comparing the bandwidth of Selene's `tcp` and
/// `shmem` results-stream transports in isolation, using the same
/// multi-process (reader creates the endpoint, writer child streams into it)
/// design as `run_shots`.
#[derive(Parser, Debug)]
#[command(name = "selene-transport-bench")]
struct Cli {
    /// Which transport(s) to benchmark.
    #[arg(long, default_value = "both")]
    transport: String,

    /// Total number of bytes to stream per trial.
    #[arg(long, default_value_t = 256 * 1024 * 1024)]
    total_bytes: u64,

    /// Size, in bytes, of each write/read call.
    #[arg(long, default_value_t = 64 * 1024)]
    chunk_size: usize,

    /// Capacity, in bytes, of the shmem ring buffer (ignored for tcp).
    #[arg(long, default_value_t = 1024 * 1024)]
    shmem_capacity: usize,

    /// Number of trials to run per transport.
    #[arg(long, default_value_t = 5)]
    trials: u32,

    /// Verify the received byte stream matches the expected deterministic
    /// ramp pattern.
    #[arg(long, default_value_t = true, action = clap::ArgAction::Set)]
    verify: bool,

    /// Internal: run as the writer child process against the given URI,
    /// rather than as the reader/orchestrator. Not intended for direct use.
    #[arg(long, hide = true)]
    writer_role: Option<String>,
}

fn main() {
    let cli = Cli::parse();

    if let Some(uri) = cli.writer_role.as_deref() {
        if let Err(e) = run_writer(uri, cli.total_bytes, cli.chunk_size) {
            eprintln!("writer error: {e}");
            std::process::exit(1);
        }
        return;
    }

    let transports: Vec<Transport> = match cli.transport.as_str() {
        "both" => vec![Transport::Tcp, Transport::Shmem],
        other => match Transport::from_str(other) {
            Ok(t) => vec![t],
            Err(e) => {
                eprintln!("error: {e}");
                std::process::exit(2);
            }
        },
    };

    let exe_path = env::current_exe().expect("failed to resolve current executable path");

    for transport in transports {
        println!(
            "\n== {} : total_bytes={} chunk_size={} trials={} ==",
            transport.name(),
            cli.total_bytes,
            cli.chunk_size,
            cli.trials
        );

        let mut results: Vec<TrialResult> = Vec::with_capacity(cli.trials as usize);
        for trial in 0..cli.trials {
            let result = match transport {
                Transport::Tcp => {
                    run_tcp_trial(&exe_path, cli.total_bytes, cli.chunk_size, cli.verify)
                }
                Transport::Shmem => run_shmem_trial(
                    &exe_path,
                    cli.total_bytes,
                    cli.chunk_size,
                    cli.shmem_capacity,
                    cli.verify,
                ),
            };
            match result {
                Ok(r) => {
                    println!(
                        "  trial {:>2}: {:>10.2} MiB/s ({} bytes in {:.4}s)",
                        trial + 1,
                        r.mib_per_sec(),
                        r.bytes,
                        r.elapsed.as_secs_f64()
                    );
                    results.push(r);
                }
                Err(e) => {
                    eprintln!("  trial {} FAILED: {e}", trial + 1);
                    std::process::exit(1);
                }
            }
        }

        let mib_per_sec: Vec<f64> = results.iter().map(TrialResult::mib_per_sec).collect();
        let s = stats(&mib_per_sec);
        println!(
            "  summary: min={:.2} MiB/s  median={:.2} MiB/s  mean={:.2} MiB/s  stdev={:.2} MiB/s",
            s.min, s.median, s.mean, s.stdev
        );
    }
}
