//! cargo run -p selene-toolchain --example build -- /path/to/_dist ./program
use selene_toolchain::{Bitcode, Store, Toolchain};

fn main() -> selene_toolchain::Result<()> {
    let mut args = std::env::args_os().skip(1);
    let root = args.next().expect("Pass the packaged _dist directory");
    let output = args.next().expect("Pass an output filename");
    let toolchain = Toolchain::from_directory(root)?;
    let module = Bitcode::from_bytes(b"define i32 @main() { ret i32 0 }".to_vec());
    let object = toolchain.compile(module).plan()?;
    let plan = toolchain.link_executable().object(object).plan()?;
    let result = Store::default_location()?.build(&plan)?;
    result.artifact.copy_to(output)?;
    println!("{}: cached={}", result.key, result.cache_hit);
    Ok(())
}
