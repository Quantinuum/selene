// Check that the export helper and inline adapter both let two calls enter
// the runtime at once. The barrier inside custom_call requires that overlap.
use anyhow::Result;
use selene_core::runtime::{
    BatchOperation, Runtime, RuntimeInterface, RuntimeInterfaceFactory,
    plugin::{RuntimeInstanceV2 as RuntimeInstance, RuntimePluginDescriptorV2},
};
use selene_core::utils::MetricValue;
use std::sync::{
    Arc, Barrier,
    atomic::{AtomicU64, Ordering},
};

struct ConcurrentRuntime {
    next: AtomicU64,
    refs: AtomicU64,
    overlap: Barrier,
}

impl Default for ConcurrentRuntime {
    fn default() -> Self {
        Self {
            next: AtomicU64::new(0),
            refs: AtomicU64::new(1),
            overlap: Barrier::new(2),
        }
    }
}

impl RuntimeInterface for ConcurrentRuntime {
    fn exit(&self) -> Result<()> {
        Ok(())
    }
    fn shot_start(&self, _: u64, _: u64) -> Result<()> {
        Ok(())
    }
    fn shot_end(&self) -> Result<()> {
        Ok(())
    }
    fn get_metric(&self, _: u8) -> Result<Option<(String, MetricValue)>> {
        Ok(None)
    }
    fn get_next_operations(&self) -> Result<Option<BatchOperation>> {
        Ok(None)
    }
    fn qalloc(&self) -> Result<u64> {
        Ok(self.next.fetch_add(1, Ordering::Relaxed))
    }
    fn qfree(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn measure(&self, _: u64) -> Result<u64> {
        self.qalloc()
    }
    fn measure_leaked(&self, _: u64) -> Result<u64> {
        self.qalloc()
    }
    fn reset(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn force_result(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn get_bool_result(&self, _: u64) -> Result<Option<bool>> {
        Ok(Some(true))
    }
    fn get_u64_result(&self, _: u64) -> Result<Option<u64>> {
        Ok(Some(self.refs.load(Ordering::Relaxed)))
    }
    fn set_bool_result(&self, _: u64, _: bool) -> Result<()> {
        Ok(())
    }
    fn set_u64_result(&self, _: u64, _: u64) -> Result<()> {
        Ok(())
    }
    fn increment_future_refcount(&self, _: u64) -> Result<()> {
        self.refs.fetch_add(1, Ordering::Relaxed);
        Ok(())
    }
    fn decrement_future_refcount(&self, _: u64) -> Result<()> {
        self.refs.fetch_sub(1, Ordering::Relaxed);
        Ok(())
    }
    fn local_barrier(&self, _: &[u64], _: u64) -> Result<()> {
        Ok(())
    }
    fn global_barrier(&self, _: u64) -> Result<()> {
        Ok(())
    }
    fn custom_call(&self, _: u64, _: &[u8]) -> Result<u64> {
        // Both calls must reach this barrier before either can return.
        // If the adapter holds one lock across every call, the first caller
        // waits here forever because the second cannot enter.
        self.overlap.wait();
        Ok(0)
    }
}

#[derive(Default)]
struct Factory;
impl RuntimeInterfaceFactory for Factory {
    type Interface = ConcurrentRuntime;
    fn init(
        self: Arc<Self>,
        _: u64,
        _: selene_core::time::Instant,
        _: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        Ok(Box::default())
    }
}
selene_core::export_runtime_plugin!(crate::Factory);

#[test]
fn inline_adapter_permits_parallel_entry() {
    let runtime = Runtime::from_boxed(Box::<ConcurrentRuntime>::default());
    runtime.shot_start(0, 0).unwrap();
    std::thread::scope(|scope| {
        let runtime = &runtime;
        let workers: Vec<_> = (0..2)
            .map(|_| {
                scope.spawn(move || {
                    runtime.custom_call(0, &[]).unwrap();
                    (0..100)
                        .map(|_| {
                            runtime.increment_future_refcount(0).unwrap();
                            runtime.qalloc().unwrap()
                        })
                        .collect::<Vec<_>>()
                })
            })
            .collect();
        let ids: std::collections::HashSet<_> = workers
            .into_iter()
            .flat_map(|w| w.join().unwrap())
            .collect();
        assert_eq!(ids.len(), 200);
    });
    assert_eq!(runtime.get_u64_result(0).unwrap(), Some(201));
    runtime.shot_end().unwrap();
    runtime.exit().unwrap();
}

struct Exported {
    instance: RuntimeInstance,
    descriptor: &'static RuntimePluginDescriptorV2,
}
// SAFETY: the test keeps the helper-created instance alive until its scoped
// workers have joined. Its runtime implements Send + Sync, and workers only
// call shared operational methods. Cleanup happens after the workers finish.
unsafe impl Sync for Exported {}

impl Exported {
    fn run(&self) -> Vec<u64> {
        let d = self.descriptor;
        let mut output = 0;
        let data = [];
        unsafe {
            assert_eq!(
                d.custom_call_fn.unwrap()(self.instance, 0, data.as_ptr(), 0, &mut output),
                0
            );
            (0..100)
                .map(|_| {
                    assert_eq!((d.increment_future_refcount_fn)(self.instance, 0), 0);
                    assert_eq!((d.qalloc_fn)(self.instance, &mut output), 0);
                    output
                })
                .collect()
        }
    }
}

#[test]
fn export_helper_permits_parallel_entry() {
    let descriptor = unsafe { &*_plugin::selene_runtime_get_plugin_descriptor_v2() };
    let mut instance = std::ptr::null();
    let args = [];
    unsafe {
        assert_eq!(
            (descriptor.init_fn)(&mut instance, 1, 0, 0, args.as_ptr()),
            0
        );
    }
    let runtime = Exported {
        instance,
        descriptor,
    };
    std::thread::scope(|scope| {
        let first = scope.spawn(|| runtime.run());
        let second = scope.spawn(|| runtime.run());
        let ids: std::collections::HashSet<_> = first
            .join()
            .unwrap()
            .into_iter()
            .chain(second.join().unwrap())
            .collect();
        assert_eq!(ids.len(), 200);
    });
    unsafe {
        let mut refs = 0;
        assert_eq!((descriptor.get_u64_result_fn)(instance, 0, &mut refs), 0);
        assert_eq!(refs, 201);
    }
    std::thread::scope(|scope| {
        let runtime = &runtime;
        for _ in 0..2 {
            scope.spawn(move || {
                for _ in 0..100 {
                    unsafe {
                        assert_eq!(
                            (runtime.descriptor.decrement_future_refcount_fn)(runtime.instance, 0),
                            0
                        );
                    }
                }
            });
        }
    });
    unsafe {
        let mut refs = 0;
        assert_eq!((descriptor.get_u64_result_fn)(instance, 0, &mut refs), 0);
        assert_eq!(refs, 1);
        assert_eq!(descriptor.exit_fn.unwrap()(instance), 0);
        // The helper leaves its allocation alive after exit so later calls can
        // report errors. Here we know it is a Box<ConcurrentRuntime> and all
        // workers have finished, so we can free it ourselves.
        drop(Box::from_raw(
            instance.cast_mut().cast::<ConcurrentRuntime>(),
        ));
    }
}
