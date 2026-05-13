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
    println!("cargo:rustc-link-lib=dylib=base_qis_selene_interface_logging_off");
    println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN/../../../selene_base_qis_plugin/_dist/lib")
}

fn default_base_lib_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../interfaces/base_qis/python/selene_base_qis_plugin/_dist/lib")
}
