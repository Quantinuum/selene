//! Integration tests that spawn the real compiled `selene-transport-bench`
//! binary as a subprocess (exactly as it would be spawned by a user), rather
//! than calling library functions in-process. This exercises the full
//! multi-process orchestration path: the invoked binary itself spawns a
//! second child process (the writer role) and streams data across the
//! transport under test.

use std::process::Command;

fn bin_path() -> &'static str {
    env!("CARGO_BIN_EXE_selene-transport-bench")
}

#[test]
fn tcp_transfer_succeeds_with_verification() {
    let output = Command::new(bin_path())
        .args([
            "--transport",
            "tcp",
            "--total-bytes",
            "65536",
            "--chunk-size",
            "4096",
            "--trials",
            "1",
            "--verify",
            "true",
        ])
        .output()
        .expect("failed to run selene-transport-bench");
    assert!(
        output.status.success(),
        "stdout: {}\nstderr: {}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("== tcp"), "unexpected stdout: {stdout}");
    assert!(
        stdout.contains("65536 bytes"),
        "unexpected stdout: {stdout}"
    );
}

#[test]
fn shmem_transfer_succeeds_with_wraparound() {
    // Force the ring buffer to wrap several times: capacity is much smaller
    // than the total bytes transferred.
    let output = Command::new(bin_path())
        .args([
            "--transport",
            "shmem",
            "--total-bytes",
            "65536",
            "--chunk-size",
            "1024",
            "--shmem-capacity",
            "4096",
            "--trials",
            "1",
            "--verify",
            "true",
        ])
        .output()
        .expect("failed to run selene-transport-bench");
    assert!(
        output.status.success(),
        "stdout: {}\nstderr: {}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("== shmem"), "unexpected stdout: {stdout}");
    assert!(
        stdout.contains("65536 bytes"),
        "unexpected stdout: {stdout}"
    );
}

#[test]
fn both_transports_run_in_a_single_invocation() {
    let output = Command::new(bin_path())
        .args([
            "--transport",
            "both",
            "--total-bytes",
            "16384",
            "--chunk-size",
            "2048",
            "--trials",
            "1",
        ])
        .output()
        .expect("failed to run selene-transport-bench");
    assert!(
        output.status.success(),
        "stdout: {}\nstderr: {}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("== tcp"), "unexpected stdout: {stdout}");
    assert!(stdout.contains("== shmem"), "unexpected stdout: {stdout}");
}

#[test]
fn invalid_transport_is_rejected() {
    let output = Command::new(bin_path())
        .args(["--transport", "bogus", "--trials", "1"])
        .output()
        .expect("failed to run selene-transport-bench");
    assert!(
        !output.status.success(),
        "expected failure for invalid transport"
    );
}
