# selene-transport-bench

A standalone microbenchmark that measures the raw bandwidth of Selene's
results-stream transports — `tcp` and `shmem` — in isolation, without any
QIR/simulator overhead.

## Why

Selene's `run_shots` (see `selene_sim.instance`) streams shot results from a
spawned `selene` process back to the calling Python process over one of two
transports, selected via `transport="tcp"` (the default) or `transport="shmem"`:

- **tcp**: a loopback TCP socket. Supports multiple concurrent writer
  processes (`n_processes > 1`).
- **shmem**: a fixed-size, single-writer/single-reader lock-free ring buffer
  over a shared-memory segment (`selene_core::shmem_fifo`). Faster in
  principle, but restricted to a single writer process.

This tool answers "how much raw bandwidth does each transport actually
deliver?", independent of everything else `run_shots` does (compiling QIR,
running the simulator, parsing/dispatching tagged results, etc).

## How it mirrors Selene's multi-process design

Just like `run_shots`, the benchmark uses two independent OS processes:

- The **reader** (the process you invoke) creates and owns the transport
  endpoint — a `TcpListener` for `tcp`, or a `ShmemFifo` segment for `shmem` —
  exactly as the Python process calling `run_shots` does.
- The reader then spawns a **second, independent process** (a fresh copy of
  this same binary, run with a hidden `--writer-role` flag) and hands it the
  resulting output-stream URI (`tcp://host:port` or `shmem:<os_id>`), just as
  `run_shots` passes the URI to the spawned `selene` executable.
- The writer child process connects to (`tcp`) or opens (`shmem`) that URI
  using the exact same code paths and wire protocol as production (including
  the 24-byte offset/increment/count registration header sent over TCP), and
  streams a deterministic byte ramp across it in fixed-size chunks.
- The reader times the transfer from the point the connection/segment is
  ready until the writer signals it is done (TCP: socket EOF; shmem: the
  writer-closed flag observed with the FIFO fully drained), and reports
  bandwidth in MiB/s. It also verifies the received bytes against the
  expected ramp so a slow or corrupted transfer both get flagged.

## Usage

```sh
cargo run --release -p selene-transport-bench -- \
  --transport both \
  --total-bytes $((256 * 1024 * 1024)) \
  --chunk-size 65536 \
  --shmem-capacity $((1024 * 1024)) \
  --trials 5
```

Flags:

- `--transport tcp|shmem|both` (default `both`)
- `--total-bytes <n>` — bytes streamed per trial (default 256 MiB)
- `--chunk-size <n>` — size of each write/read call (default 64 KiB)
- `--shmem-capacity <n>` — shmem ring buffer capacity, ignored for `tcp`
  (default 1 MiB, matching `run_shots`' default)
- `--trials <n>` — number of trials per transport (default 5)
- `--verify true|false` — verify the byte ramp on the reader side (default
  `true`)

Always build with `--release` for representative numbers — a debug build
will be dominated by the transport's own overhead rather than the code being
tested.

Output is a small per-trial report plus min/median/mean/stdev across trials,
per transport, so `tcp` and `shmem` can be compared directly.

## Notes

- Reported bandwidth excludes process-spawn and connection/handshake latency;
  it measures only the steady-state transfer from "reader ready" to "writer
  done". This makes the two transports directly comparable on a bytes/sec
  basis, even though spawning and connecting is itself part of Selene's
  real-world overhead.
- `--total-bytes` smaller than `--shmem-capacity` never wraps the shmem ring
  buffer; use a capacity smaller than `--total-bytes` to exercise
  backpressure/wraparound behavior (see the integration tests for an example).
