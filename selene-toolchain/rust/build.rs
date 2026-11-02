use sha2::{Digest, Sha256};
use std::{
    env, fs,
    io::Read,
    path::{Path, PathBuf},
    process::Command,
};

fn output(command: &mut Command) -> String {
    let result = command
        .output()
        .unwrap_or_else(|error| panic!("Cannot run {command:?}: {error}"));
    assert!(
        result.status.success(),
        "{command:?} failed: {}",
        String::from_utf8_lossy(&result.stderr)
    );
    String::from_utf8(result.stdout)
        .expect("Toolchain configuration must be UTF-8")
        .trim()
        .into()
}

// Inside cibuildwheel, absolute symlinks in a Nix prefix still name the host's
// /nix/store. Resolve those under /host before using llvm-config's paths.
fn resolve(path: &Path) -> PathBuf {
    let mut path = path.to_path_buf();
    for _ in 0..64 {
        if let Ok(target) = fs::read_link(&path) {
            path = if target.is_absolute() {
                if path.starts_with("/host") {
                    Path::new("/host").join(target.strip_prefix("/").unwrap())
                } else {
                    target
                }
            } else {
                path.parent().unwrap().join(target)
            };
        } else if !path.exists()
            && path.is_absolute()
            && Path::new("/host")
                .join(path.strip_prefix("/").unwrap())
                .exists()
        {
            path = Path::new("/host").join(path.strip_prefix("/").unwrap());
        } else {
            return path;
        }
    }
    panic!("Too many symlinks while resolving {}", path.display());
}

fn hash_file(hash: &mut Sha256, path: &Path) {
    println!("cargo:rerun-if-changed={}", path.display());
    let mut file = fs::File::open(path)
        .unwrap_or_else(|error| panic!("Cannot read {}: {error}", path.display()));
    hash.update(file.metadata().unwrap().len().to_le_bytes());
    let mut bytes = [0; 65536];
    loop {
        let count = file.read(&mut bytes).unwrap();
        if count == 0 {
            break;
        }
        hash.update(&bytes[..count]);
    }
}

fn main() {
    for variable in ["SELENE_TOOLCHAIN_LLVM_PREFIX", "HUGRENV_PATH"] {
        println!("cargo:rerun-if-env-changed={variable}");
    }
    let prefix = env::var_os("SELENE_TOOLCHAIN_LLVM_PREFIX")
        .or_else(|| env::var_os("HUGRENV_PATH"))
        .map(PathBuf::from)
        .expect("Set SELENE_TOOLCHAIN_LLVM_PREFIX to an LLVM 21/LLD development prefix, or set HUGRENV_PATH");
    let os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    assert!(
        matches!(os.as_str(), "linux" | "macos" | "windows"),
        "Unsupported platform: {os}"
    );
    if os == "windows" {
        assert_eq!(
            env::var("CARGO_CFG_TARGET_ENV").unwrap(),
            "gnu",
            "Windows LLVM builds require the MinGW Rust target (x86_64-pc-windows-gnu)"
        );
    }
    let config = resolve(&prefix.join("bin").join(if cfg!(windows) {
        "llvm-config.exe"
    } else {
        "llvm-config"
    }));
    assert!(
        config.is_file(),
        "Missing {}. Supply a development installation containing LLVM and LLD",
        config.display()
    );
    println!("cargo:rerun-if-changed={}", config.display());
    let query = |args: &[&str]| output(Command::new(&config).args(args));
    let version = query(&["--version"]);
    assert!(
        version.starts_with("21."),
        "This bridge requires LLVM 21; found {version}"
    );
    let libdir = resolve(Path::new(&query(&["--libdir"])));
    let include = resolve(Path::new(&query(&["--includedir"])));
    for directory in ["llvm", "llvm-c", "lld"] {
        println!(
            "cargo:rerun-if-changed={}",
            include.join(directory).display()
        );
    }
    assert!(
        include.join("lld/Common/Driver.h").is_file(),
        "LLD development headers are missing from {}",
        include.display()
    );
    let mut compiler = cc::Build::new();
    compiler
        .cpp(true)
        .cpp_link_stdlib(None)
        .opt_level(1)
        .flag("-isystem")
        .flag(include.to_str().expect("LLVM include path must be UTF-8"))
        .file("native/backend.cpp");
    for flag in shlex::split(&query(&["--cxxflags"])).expect("Invalid LLVM C++ flags") {
        if !flag.starts_with("-I") {
            compiler.flag(flag);
        }
    }
    compiler
        .flag_if_supported("-fvisibility=hidden")
        .flag_if_supported("-fvisibility-inlines-hidden");
    if os == "windows" {
        assert!(
            compiler.get_compiler().is_like_gnu(),
            "Use a MinGW C++ compiler matching the LLVM installation"
        );
    }
    compiler.compile("selene_llvm_bridge");
    let archive = PathBuf::from(env::var_os("OUT_DIR").unwrap()).join("libselene_llvm_bridge.a");
    let mut backend = Sha256::new();
    hash_file(&mut backend, &archive);
    backend.update(version.as_bytes());
    println!("cargo:rustc-link-search=native={}", libdir.display());
    let lld: &[&str] = match os.as_str() {
        "windows" => &["lldMinGW", "lldCOFF", "lldCommon"],
        "macos" => &["lldMachO", "lldCommon"],
        _ => &["lldELF", "lldCommon"],
    };
    let llvm = query(&["--link-static", "--libs", "all"]);
    let libraries = shlex::split(&llvm).expect("Invalid LLVM library flags");
    for name in lld.iter().copied().chain(
        libraries
            .iter()
            .map(|flag| flag.strip_prefix("-l").expect("Expected LLVM -l flags")),
    ) {
        let path = libdir.join(format!("lib{name}.a"));
        assert!(
            path.is_file(),
            "Missing LLVM/LLD static library: {}",
            path.display()
        );
        hash_file(&mut backend, &path);
        // Keep LLVM archives outside the rlib instead of copying hundreds of
        // megabytes into every intermediate Rust artifact. The final link
        // uses this build's explicit native search directory.
        println!("cargo:rustc-link-lib=static:-bundle={name}");
    }
    if os == "linux" {
        let tool = compiler.get_compiler();
        let standard = resolve(Path::new(&output(
            tool.to_command().arg("-print-file-name=libstdc++.a"),
        )));
        assert!(
            standard.is_file(),
            "The C++ compiler must provide libstdc++.a"
        );
        hash_file(&mut backend, &standard);
        println!(
            "cargo:rustc-link-search=native={}",
            standard.parent().unwrap().display()
        );
        println!("cargo:rustc-link-lib=static:-bundle=stdc++");
        println!("cargo:rustc-cdylib-link-arg=-Wl,--exclude-libs,ALL");
        println!("cargo:rustc-cdylib-link-arg=-Wl,-Bsymbolic");
    } else {
        println!(
            "cargo:rustc-link-lib={}",
            if os == "macos" { "c++" } else { "stdc++" }
        );
    }
    let system = query(&["--link-static", "--system-libs"]);
    let flags = shlex::split(&system).expect("Invalid LLVM system library flags");
    let mut flags = flags.iter();
    while let Some(flag) = flags.next() {
        if let Some(name) = flag.strip_prefix("-l") {
            println!("cargo:rustc-link-lib={name}");
        } else if let Some(path) = flag.strip_prefix("-L") {
            println!(
                "cargo:rustc-link-search=native={}",
                resolve(Path::new(path)).display()
            );
        } else if flag == "-framework" {
            println!(
                "cargo:rustc-link-lib=framework={}",
                flags.next().expect("Missing framework name")
            );
        } else {
            panic!("Unsupported LLVM system link flag: {flag}");
        }
    }
    println!(
        "cargo:rustc-env=SELENE_TOOLCHAIN_BACKEND={:x}",
        backend.finalize()
    );
    let mut implementation = Sha256::new();
    let mut sources = fs::read_dir("src")
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .collect::<Vec<_>>();
    sources.extend([
        PathBuf::from("build.rs"),
        PathBuf::from("Cargo.toml"),
        PathBuf::from("native/backend.cpp"),
    ]);
    if Path::new("../../Cargo.lock").exists() {
        sources.push(PathBuf::from("../../Cargo.lock"));
    }
    sources.sort();
    for file in sources {
        hash_file(&mut implementation, &file);
    }
    println!(
        "cargo:rustc-env=SELENE_TOOLCHAIN_IMPLEMENTATION={:x}",
        implementation.finalize()
    );
    #[cfg(feature = "python")]
    pyo3_build_config::add_extension_module_link_args();
}
