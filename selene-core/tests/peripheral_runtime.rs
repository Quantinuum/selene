#![cfg(unix)]

use selene_core::runtime::pipeline::Runtime;
use std::{
    path::PathBuf,
    process::Command,
    sync::atomic::{AtomicU64, Ordering},
};

struct PluginDirectory(PathBuf);
impl Drop for PluginDirectory {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

fn rejected_plugin(defines: &[&str], expected: &str) {
    static NEXT: AtomicU64 = AtomicU64::new(0);
    let directory = PluginDirectory(std::env::temp_dir().join(format!(
        "selene-peripheral-descriptor-{}-{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    )));
    std::fs::create_dir_all(&directory.0).unwrap();
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let library = directory
        .0
        .join(format!("runtime.{}", std::env::consts::DLL_EXTENSION));
    let mut compiler = Command::new("cc");
    compiler.args(["-std=c17", "-fPIC", "-Wall", "-Wextra"]);
    compiler.arg(if cfg!(target_os = "macos") {
        "-dynamiclib"
    } else {
        "-shared"
    });
    for define in defines {
        compiler.arg(format!("-D{define}"));
    }
    let compiled = compiler
        .arg("-I")
        .arg(root.join("c/include"))
        .arg(root.join("tests/support/peripheral_runtime.c"))
        .arg("-o")
        .arg(&library)
        .output()
        .unwrap();
    assert!(
        compiled.status.success(),
        "{}",
        String::from_utf8_lossy(&compiled.stderr)
    );
    let error = match Runtime::load_from_file(&library, 1, 0.into(), &[] as &[&str]) {
        Ok(_) => panic!("Malformed peripheral runtime was accepted"),
        Err(error) => format!("{error:#}"),
    };
    assert!(error.contains(expected), "{error}");
}

#[test]
fn invalid_v2_descriptors_do_not_fall_back_to_legacy() {
    rejected_plugin(
        &["TEST_VERSION=0x500"],
        "Unsupported peripheral runtime API version",
    );
    rejected_plugin(&["TEST_SIZE=16"], "Runtime v2");
    rejected_plugin(&["TEST_NULL"], "Runtime v2");
    rejected_plugin(&[], "Runtime v2 requires destroy_fn");
}
