#![cfg(unix)]

use std::{
    io::Write,
    path::PathBuf,
    process::{Command, Stdio},
};

fn check_header(language: &str, standard: &str, source: &str) {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mut compiler = Command::new(if language == "c" { "cc" } else { "c++" })
        .args(["-x", language, standard, "-Wall", "-Wextra", "-Werror"])
        .arg("-I")
        .arg(root.join("c/include"))
        .args(["-fsyntax-only", "-"])
        .stdin(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    compiler
        .stdin
        .take()
        .unwrap()
        .write_all(source.as_bytes())
        .unwrap();
    let output = compiler.wait_with_output().unwrap();
    assert!(
        output.status.success(),
        "{language}: {source}\n{}",
        String::from_utf8_lossy(&output.stderr)
    );
}

#[test]
fn current_and_versioned_headers_work_alone_and_together() {
    let mut headers = [
        "core_types.h",
        "operations.h",
        "runtime.h",
        "runtime/v0_3.h",
        "runtime/v0_4.h",
        "simulator.h",
        "simulator/v0_1.h",
        "error_model.h",
        "error_model/v0_3.h",
    ];
    for (language, standard, assertion) in [
        ("c", "-std=c17", "_Static_assert"),
        ("c++", "-std=c++20", "static_assert"),
    ] {
        // A plugin should be able to include just the header for its contract.
        // A host needs several contracts at once, so we also check both include
        // orders. The current API constants mustn't depend on which came first.
        for header in headers {
            check_header(language, standard, &format!("#include <selene/{header}>\n"));
        }
        for _ in 0..2 {
            let mut source = headers
                .iter()
                .map(|header| format!("#include <selene/{header}>\n"))
                .collect::<String>();
            for (name, version) in [
                ("RUNTIME_CURRENT", 0x400),
                ("RUNTIME_V0_4", 0x400),
                ("RUNTIME_V0_3", 0x300),
                ("SIMULATOR_CURRENT", 0x101),
                ("SIMULATOR_V0_1", 0x101),
                ("ERROR_MODEL_CURRENT", 0x300),
                ("ERROR_MODEL_V0_3", 0x300),
            ] {
                source.push_str(&format!(
                    "{assertion}(SELENE_{name}_API_VERSION == {version}, \"{name}\");\n"
                ));
            }
            check_header(language, standard, &source);
            headers.reverse();
        }
    }
}
