use selene_toolchain::{Artifact, ArtifactKind, Store, Toolchain};

#[test]
#[ignore = "Needs SELENE_TOOLCHAIN_ROOT pointing to a built runtime distribution"]
fn rust_can_build_and_execute_without_python() -> selene_toolchain::Result<()> {
    let toolchain = Toolchain::from_directory(
        std::env::var_os("SELENE_TOOLCHAIN_ROOT").expect("Set SELENE_TOOLCHAIN_ROOT"),
    )?;
    let directory = tempfile::tempdir()?;
    let store = Store::local(directory.path().join("store"))?;
    let module = Artifact::from_bytes(
        ArtifactKind::Bitcode,
        b"define i32 @main() { ret i32 0 }".to_vec(),
    );
    let object = toolchain.compile(module).plan()?;
    let first_object = store.build(&object)?;
    assert!(
        first_object.artifact.symbols(&toolchain)?["defined_symbols"]
            .as_array()
            .unwrap()
            .contains(&serde_json::json!("main"))
    );
    let plan = toolchain.link_executable().object(object).plan()?;
    assert!(!store.build(&plan)?.cache_hit);
    let result = store.build(&plan)?;
    assert!(result.cache_hit);
    let output = directory.path().join("program.exe");
    result.artifact.copy_to(&output)?;
    assert!(std::process::Command::new(output).status()?.success());
    Ok(())
}

#[test]
fn artifacts_capture_bytes_instead_of_reading_paths_later() -> selene_toolchain::Result<()> {
    let directory = tempfile::tempdir()?;
    let source = directory.path().join("input.ll");
    std::fs::write(&source, "first")?;
    let artifact = Artifact::from_path(ArtifactKind::Bitcode, &source)?;
    std::fs::write(&source, "second")?;
    assert_eq!(artifact.bytes(), b"first");
    assert_ne!(
        artifact.digest(),
        Artifact::from_path(ArtifactKind::Bitcode, source)?.digest()
    );
    Ok(())
}

#[test]
fn compilation_uses_linked_llvm_without_a_link_runtime() -> selene_toolchain::Result<()> {
    let toolchain = Toolchain::new()?;
    assert!(toolchain.version()?.starts_with("21."));
    let source =
        selene_toolchain::Bitcode::from_bytes(b"define i32 @main() { ret i32 0 }".to_vec());
    let plan = toolchain.compile(source).plan()?;
    let directory = tempfile::tempdir()?;
    let object = Store::local(directory.path())?.build(&plan)?.artifact;
    assert!(
        object.symbols(&toolchain)?["defined_symbols"]
            .as_array()
            .unwrap()
            .contains(&serde_json::json!("main"))
    );
    let error = toolchain
        .link_executable()
        .object(object)
        .plan()
        .unwrap_err();
    assert!(error.to_string().contains("runtime inputs"));
    Ok(())
}
