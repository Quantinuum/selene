fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    // Integration fixtures use cc outside a build script, where TARGET is absent.
    println!(
        "cargo:rustc-env=SELENE_CORE_TARGET={}",
        std::env::var("TARGET").unwrap()
    );
}
