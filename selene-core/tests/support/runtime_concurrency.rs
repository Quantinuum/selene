use selene_core::runtime::{Operation, RuntimeInterface};
use std::{
    collections::HashSet,
    sync::{Barrier, mpsc},
    thread,
};

/// Multiple producers force both kinds of measurement while one consumer drains.
/// Channels/barriers establish progress without relying on sleeps or polling.
pub fn exercise(runtime: &dyn RuntimeInterface) {
    const PRODUCERS: usize = 4;
    const ROUNDS: usize = 16;
    let barrier = Barrier::new(PRODUCERS);
    let (tx, rx) = mpsc::channel();
    thread::scope(|scope| {
        let mut producers = Vec::new();
        for _ in 0..PRODUCERS {
            let tx = tx.clone();
            let barrier = &barrier;
            producers.push(scope.spawn(move || {
                let qubit = runtime.qalloc().unwrap();
                assert_ne!(qubit, u64::MAX);
                barrier.wait();
                let mut ids = Vec::new();
                for round in 0..ROUNDS {
                    runtime.rxy_gate(qubit, 0.5, 0.25).unwrap();
                    let id = if round % 2 == 0 {
                        runtime.measure(qubit).unwrap()
                    } else {
                        runtime.measure_leaked(qubit).unwrap()
                    };
                    runtime.increment_future_refcount(id).unwrap();
                    runtime.force_result(id).unwrap();
                    tx.send(id).unwrap();
                    // Readers may observe either pending or published values.
                    if let Some(value) = runtime.get_u64_result(id).unwrap() {
                        assert_eq!(value, id + 10);
                    }
                    runtime.decrement_future_refcount(id).unwrap();
                    ids.push(id);
                }
                ids
            }));
        }
        drop(tx);
        let mut seen = HashSet::new();
        for requested in rx {
            while let Some(batch) = runtime.get_next_operations().unwrap() {
                for op in batch.iter_ops() {
                    if let Operation::Measure { result_id, .. }
                    | Operation::MeasureLeaked { result_id, .. } = op
                    {
                        assert!(seen.insert(*result_id), "measurement dispatched twice");
                        // Reforcing after dispatch must succeed without needing the
                        // measurement to remain in the queue.
                        runtime.force_result(*result_id).unwrap();
                        runtime.set_u64_result(*result_id, *result_id + 10).unwrap();
                    }
                }
            }
            assert_eq!(
                runtime.get_u64_result(requested).unwrap(),
                Some(requested + 10)
            );
        }
        let ids: Vec<_> = producers
            .into_iter()
            .flat_map(|p| p.join().unwrap())
            .collect();
        assert_eq!(seen.len(), PRODUCERS * ROUNDS);
        assert_eq!(ids.iter().copied().collect::<HashSet<_>>(), seen);
        for id in ids {
            assert_eq!(runtime.get_u64_result(id).unwrap(), Some(id + 10));
            runtime.force_result(id).unwrap();
            runtime.decrement_future_refcount(id).unwrap();
        }
        assert!(runtime.get_next_operations().unwrap().is_none());
    });
}
