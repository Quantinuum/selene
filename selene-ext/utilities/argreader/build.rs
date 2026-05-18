use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-env-changed=SELENE_BASE_QIS_LIB_DIR");

    let lib_dir = env::var_os("SELENE_BASE_QIS_LIB_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(default_base_lib_dir);
    if !lib_dir.exists() {
        panic!(
            "Helios interface runtime directory not found: {}. Build the Helios QIS interface first or set SELENE_BASE_QIS_LIB_DIR.",
            lib_dir.display()
        );
    }

    println!("cargo:rustc-link-search=native={}", lib_dir.display());
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    let target_env = env::var("CARGO_CFG_TARGET_ENV").unwrap_or_default();
    if target_os == "windows" && target_env == "gnu" {
        let import_lib = lib_dir.join("libbase_qis_selene_interface_logging_off.dll.a");
        if !import_lib.exists() {
            panic!(
                "Base QIS import library not found: {}",
                import_lib.display()
            );
        }
        // MinGW link order matters for import libraries. Cargo places native
        // rustc-link-lib entries before Rust objects for cdylibs, so pass the
        // import library as a final linker argument instead.
        println!("cargo:rustc-link-arg={}", import_lib.display());
    } else {
        println!("cargo:rustc-link-lib=dylib=base_qis_selene_interface_logging_off");
    }

    match target_os.as_str() {
        "linux" => {
            println!(
                "cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN/../../../selene_base_qis_plugin/_dist/lib"
            );
        }
        "macos" => {
            println!(
                "cargo:rustc-link-arg=-Wl,-rpath,@loader_path/../../../selene_base_qis_plugin/_dist/lib"
            );
        }
        _ => {}
    }
}

fn default_base_lib_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../interfaces/base_qis/python/selene_base_qis_plugin/_dist/lib")
}
