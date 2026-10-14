fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    // The tests compile C plugins with cc, but Cargo only sets TARGET for build
    // scripts. Save it here so those tests can choose the same compiler target.
    println!(
        "cargo:rustc-env=SELENE_CORE_TARGET={}",
        std::env::var("TARGET").unwrap()
    );
}
