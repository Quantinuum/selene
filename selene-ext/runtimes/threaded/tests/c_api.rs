//! Compile the C example against the public headers and run it against our
//! exported descriptor. This tests both directions of the ABI: C calls the
//! runtime, and the runtime calls a C endpoint and host borrow callbacks.
#![cfg(target_os = "linux")]

#[test]
fn a_c_host_can_supply_its_own_endpoint() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../..");
    let source = root.join("selene-core/examples/runtime/c/endpoint.c");
    let includes = root.join("selene-core/c/include");
    let directory = std::env::temp_dir().join(format!("selene-c-endpoint-{}", std::process::id()));
    std::fs::create_dir_all(&directory).unwrap();
    let executable = directory.join("endpoint");
    let compiled = std::process::Command::new("cc")
        .args([
            "-std=c17",
            "-pedantic-errors",
            "-Wall",
            "-Wextra",
            "-Werror",
        ])
        .arg("-I")
        .arg(includes)
        .arg(source)
        .args(["-ldl", "-pthread", "-o"])
        .arg(&executable)
        .output()
        .unwrap();
    assert!(
        compiled.status.success(),
        "{}",
        String::from_utf8_lossy(&compiled.stderr)
    );
    let library = std::env::current_exe()
        .unwrap()
        .parent()
        .unwrap()
        .join("libselene_threaded_runtime.so");
    let scheduler = library
        .parent()
        .unwrap()
        .join("libselene_simple_runtime.so");
    let run = std::process::Command::new(executable)
        .arg(library)
        .arg(scheduler)
        .output()
        .unwrap();
    std::fs::remove_dir_all(directory).unwrap();
    assert!(
        run.status.success(),
        "{}",
        String::from_utf8_lossy(&run.stderr)
    );
}
