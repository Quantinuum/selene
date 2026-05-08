use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-env-changed=SELENE_HELIOS_QIS_LIB_DIR");

    let lib_dir = env::var_os("SELENE_HELIOS_QIS_LIB_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(default_helios_lib_dir);
    if !lib_dir.exists() {
        panic!(
            "Helios interface runtime directory not found: {}. Build the Helios QIS interface first or set SELENE_HELIOS_QIS_LIB_DIR.",
            lib_dir.display()
        );
    }

    println!("cargo:rustc-link-search=native={}", lib_dir.display());
    println!("cargo:rustc-link-lib=dylib=helios_selene_interface_runtime");
}

fn default_helios_lib_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../interfaces/helios_qis/python/selene_helios_qis_plugin/_dist/lib")
}
