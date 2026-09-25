#![cfg(unix)]

use rstest::{fixture, rstest};
use selene_core::{
    runtime::{Operation, Runtime, RuntimeInterface},
    utils::MetricValue,
};
use std::{
    path::PathBuf,
    sync::atomic::{AtomicUsize, Ordering},
};

struct PluginFixture {
    directory: PathBuf,
    library: PathBuf,
}
#[fixture]
fn plugin(#[default(&[])] defines: &[&str]) -> PluginFixture {
    static NEXT: AtomicUsize = AtomicUsize::new(0);
    let directory = std::env::temp_dir().join(format!(
        "selene-runtime-{}-{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    ));
    std::fs::create_dir(&directory).unwrap();
    let library = directory.join(format!("plugin.{}", std::env::consts::DLL_EXTENSION));
    let fixture = PluginFixture { directory, library };
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mut build = cc::Build::new();
    build
        .host(env!("SELENE_CORE_TARGET"))
        .target(env!("SELENE_CORE_TARGET"))
        .out_dir(&fixture.directory)
        .opt_level(1)
        .debug(false)
        .cargo_metadata(false)
        .std("c11")
        .pic(true)
        .extra_warnings(false)
        .warnings_into_errors(true)
        .flag("-Wno-unused-function")
        .include(root.join("c/include"))
        .file(root.join("tests/support/runtime_v1.c"))
        .file(root.join("tests/support/runtime_v2.c"));
    for define in defines {
        let (name, value) = define
            .split_once('=')
            .map_or((*define, None), |(name, value)| (name, Some(value)));
        build.define(name, value);
    }
    // cc compiles the objects; use its selected compiler driver to link the
    // shared plugin because cc's compile() produces static archives only.
    let objects = build
        .try_compile_intermediates()
        .expect("compile plugin fixture");
    let output = build
        .get_compiler()
        .to_command()
        .arg(if cfg!(target_os = "macos") {
            "-dynamiclib"
        } else {
            "-shared"
        })
        .args(objects)
        .arg("-o")
        .arg(&fixture.library)
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    fixture
}

impl PluginFixture {
    fn runtime(&self, args: &[&str]) -> anyhow::Result<Runtime> {
        Runtime::load_from_file(&self.library, 16, Default::default(), args)
    }
}
impl Drop for PluginFixture {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.directory);
    }
}

#[rstest]
#[case::accessor(&[])]
#[case::data_symbol(&["DATA_SYMBOL"])]
fn legacy_calls_stay_on_the_initializing_thread_and_results_make_progress(
    #[case] _defines: &[&str],
    #[with(_defines)] plugin: PluginFixture,
) {
    let observer = unsafe { libloading::Library::new(&plugin.library).unwrap() };
    let exits = unsafe {
        observer
            .get::<unsafe extern "C" fn() -> u32>(b"test_exit_count")
            .unwrap()
    };
    let runtime = plugin.runtime(&[]).unwrap();
    runtime.shot_start(0, 123).unwrap();
    let mut allocations = std::thread::scope(|scope| {
        let workers: Vec<_> = (0..8)
            .map(|_| {
                let runtime = &runtime;
                scope.spawn(move || {
                    (0..50)
                        .map(|_| runtime.qalloc().unwrap())
                        .collect::<Vec<_>>()
                })
            })
            .collect();
        workers
            .into_iter()
            .flat_map(|w| w.join().unwrap())
            .collect::<Vec<_>>()
    });
    allocations.sort_unstable();
    assert_eq!(allocations, (0..400).collect::<Vec<_>>());
    let (tag, value) = runtime.get_metric(0).unwrap().unwrap();
    assert_eq!(tag, "allocations");
    assert!(matches!(value, MetricValue::U64(400)));
    assert!(runtime.get_metric(1).unwrap().is_none());
    runtime.local_barrier(&[3, 4], 0).unwrap();
    assert_eq!(runtime.custom_call(10, &[1, 2, 3]).unwrap(), 16);
    runtime.simulate_delay(10).unwrap();
    runtime.rxy_gate(0, 0.1, 0.2).unwrap();
    runtime.rzz_gate(0, 1, 0.1).unwrap();
    runtime.rz_gate(0, 0.1).unwrap();
    runtime.rpp_gate(0, 1, 0.1, 0.2).unwrap();
    runtime.reset(0).unwrap();
    let result = runtime.measure(0).unwrap();
    assert_eq!(runtime.measure_leaked(0).unwrap(), result);
    runtime.increment_future_refcount(result).unwrap();
    assert_eq!(runtime.get_bool_result(result).unwrap(), None);
    assert_eq!(runtime.get_u64_result(result).unwrap(), None);
    assert!(runtime.get_next_operations().unwrap().is_none());
    runtime.force_result(result).unwrap();
    // The simulator consumer runs separately from the submitting thread.
    std::thread::scope(|scope| {
        scope
            .spawn(|| {
                let first = runtime.get_next_operations().unwrap().unwrap();
                assert!(matches!(
                    first.iter_ops().next(),
                    Some(Operation::Reset { qubit_id: 0 })
                ));
                assert_eq!(u64::from(first.runtime_source().unwrap().start()), 10);
                let second = runtime.get_next_operations().unwrap().unwrap();
                assert!(matches!(
                    second.iter_ops().next(),
                    Some(Operation::Measure { result_id: 42, .. })
                ));
                assert!(runtime.get_next_operations().unwrap().is_none());
                runtime.set_bool_result(result, true).unwrap();
                runtime.set_u64_result(result, 123).unwrap();
            })
            .join()
            .unwrap()
    });
    assert_eq!(runtime.get_bool_result(result).unwrap(), Some(true));
    assert_eq!(runtime.get_u64_result(result).unwrap(), Some(123));
    runtime.decrement_future_refcount(result).unwrap();
    runtime.qfree(0).unwrap();
    runtime.global_barrier(0).unwrap();
    runtime.shot_end().unwrap();
    runtime.exit().unwrap();
    assert!(runtime.qalloc().is_err());
    assert!(runtime.exit().is_err());
    drop(runtime);
    assert_eq!(unsafe { exits() }, 1);
    drop(plugin.runtime(&[]).unwrap()); // Drop must also clean up on the owning thread.
    assert_eq!(unsafe { exits() }, 2);
    assert!(plugin.runtime(&["fail"]).is_err());
    assert_eq!(unsafe { exits() }, 2);
}

#[rstest]
fn legacy_optional_calls_and_patch_versions(
    #[with(&["NO_OPTIONALS", "API_VERSION=0x301"])] plugin: PluginFixture,
) {
    let runtime = plugin.runtime(&[]).unwrap();
    assert!(runtime.custom_call(0, &[]).is_err());
    assert!(runtime.simulate_delay(1).is_err());
}

#[rstest]
#[case::null(&["BAD_V2=1"], "null")]
#[case::undersized(&["BAD_V2=2"], "too small")]
#[case::wrong_version(&["BAD_V2=3"], "minor version")]
fn advertised_invalid_v2_is_not_hidden_by_legacy_fallback(
    #[case] _defines: &[&str],
    #[case] message: &str,
    #[with(_defines)] plugin: PluginFixture,
) {
    let error = plugin.runtime(&[]).err().expect("invalid v2 must fail");
    assert!(error.to_string().contains(message), "{error}");
}

#[rstest]
fn unsupported_legacy_contract_is_rejected(#[with(&["API_VERSION=0x400"])] plugin: PluginFixture) {
    assert!(
        plugin
            .runtime(&[])
            .err()
            .unwrap()
            .to_string()
            .contains("minor version")
    );
}

#[rstest]
#[case::accessor(&["WITH_V2"])]
#[case::data_symbol(&["WITH_V2", "DATA_SYMBOL"])]
fn concurrent_descriptor_is_preferred_when_both_are_exported(
    #[case] _defines: &[&str],
    #[with(_defines)] plugin: PluginFixture,
) {
    let runtime = plugin.runtime(&[]).unwrap();
    assert_eq!(runtime.qalloc().unwrap(), 999);
    runtime.exit().unwrap();
}
