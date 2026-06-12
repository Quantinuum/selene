use crate::*;
use approx::assert_ulps_eq;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::SimulatorInterface;
use std::sync::Arc;

fn measure(simulator: &mut CoinflipSimulator, qubit_id: u64) -> anyhow::Result<bool> {
    let results =
        simulator.handle_operations(BatchOperation::simulator(vec![Operation::Measure {
            qubit_id,
            result_id: 0,
        }]))?;
    assert!(results.u64_results.is_empty() && results.bool_results.len() == 1);
    Ok(results.bool_results[0].value)
}
#[test]
fn bias_test() {
    let factory = Arc::new(CoinflipSimulatorFactory);
    let mut always_one = factory
        .clone()
        .init(10000, &["plugin", "--bias=1"])
        .unwrap();
    let mut always_zero = factory
        .clone()
        .init(10000, &["plugin", "--bias=0"])
        .unwrap();
    let mut fifty_fifty = factory
        .clone()
        .init(10000, &["plugin", "--bias=0.5"])
        .unwrap();
    let mut fifty_fifty_alt = factory
        .clone()
        .init(10000, &["plugin", "--bias=0.5"])
        .unwrap();
    let mut thirty_seventy = factory
        .clone()
        .init(10000, &["plugin", "--bias=0.3"])
        .unwrap();

    always_one.shot_start(0, 0).unwrap();
    always_zero.shot_start(0, 0).unwrap();
    fifty_fifty.shot_start(0, 0).unwrap();
    fifty_fifty_alt.shot_start(1, 1).unwrap();
    thirty_seventy.shot_start(0, 0).unwrap();

    let mut always_one_trues = 0;
    let mut always_zero_trues = 0;
    let mut fifty_fifty_trues = 0;
    let mut fifty_fifty_alt_trues = 0;
    let mut thirty_seventy_trues = 0;
    for _ in 0..10000 {
        always_one_trues += measure(always_one.as_mut(), 0).unwrap() as u64;
        always_zero_trues += measure(always_zero.as_mut(), 0).unwrap() as u64;
        fifty_fifty_trues += measure(fifty_fifty.as_mut(), 0).unwrap() as u64;
        fifty_fifty_alt_trues += measure(fifty_fifty_alt.as_mut(), 0).unwrap() as u64;
        thirty_seventy_trues += measure(thirty_seventy.as_mut(), 0).unwrap() as u64;
    }
    // Out of bounds check
    assert!(measure(always_one.as_mut(), 10000).is_err());

    assert_eq!(always_one.total_flips, 10000);
    assert_eq!(always_zero.total_flips, 10000);
    assert_eq!(fifty_fifty.total_flips, 10000);
    assert_eq!(fifty_fifty_alt.total_flips, 10000);
    assert_eq!(thirty_seventy.total_flips, 10000);

    assert_eq!(always_one.true_flips, always_one_trues);
    assert_eq!(always_zero.true_flips, always_zero_trues);
    assert_eq!(fifty_fifty.true_flips, fifty_fifty_trues);
    assert_eq!(fifty_fifty_alt.true_flips, fifty_fifty_alt_trues);
    assert_eq!(thirty_seventy.true_flips, thirty_seventy_trues);

    assert_eq!(always_one.true_flips, 10000);
    assert_eq!(always_zero.true_flips, 0);
    // Aiming for cross-platform reproducibility, we want to fail tests
    // if the values don't reproduce local results:
    assert_eq!(fifty_fifty_trues, 4999);
    assert_eq!(fifty_fifty_alt_trues, 5002);
    assert_eq!(thirty_seventy_trues, 2986);

    assert_eq!(always_one.get_observed_bias(), 1.0);
    assert_eq!(always_zero.get_observed_bias(), 0.0);
    assert_ulps_eq!(fifty_fifty.get_observed_bias(), 0.5, epsilon = 0.01);
    assert_ulps_eq!(fifty_fifty_alt.get_observed_bias(), 0.5, epsilon = 0.01);
    assert_ulps_eq!(thirty_seventy.get_observed_bias(), 0.3, epsilon = 0.01);
}
