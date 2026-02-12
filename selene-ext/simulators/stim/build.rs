fn main() {
    // If running Clippy, skip building Stim.
    if std::env::var("CLIPPY_ARGS").is_ok() {
        println!("cargo:warning=Skipping external C build in Clippy mode");
        return;
    }

    println!("cargo:rerun-if-changed=c_interface");
    let dst = cmake::Config::new("c_interface").build();
    println!(
        "cargo:rustc-link-search=native={}",
        dst.join("lib").display()
    );
    println!("cargo:rustc-link-lib=static=selene_stim_c_interface");

    let target_triple = std::env::var("TARGET").unwrap();
    if target_triple.contains("linux-gnu") {
        println!("cargo:rustc-link-lib=stdc++");
    } else if target_triple.contains("apple-darwin") {
        println!("cargo:rustc-link-lib=c++");
    }
}
