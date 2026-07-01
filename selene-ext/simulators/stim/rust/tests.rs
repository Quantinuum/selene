use crate::StimSimulatorFactory;
use selene_core::runtime::{BatchOperation, Operation};
use selene_core::simulator::conformance_testing::run_basic_tests;
use selene_core::simulator::{Simulator, SimulatorInterface};
use std::sync::Arc;

#[test]
fn basic_conformance_test() {
    let interface = Arc::new(StimSimulatorFactory);
    let args = vec!["".to_string(), "--angle-threshold=0.001".to_string()];
    run_basic_tests(interface, args);
}

#[test]
fn impossible_postselection_reports_simulator_detail() {
    let mut simulator = Simulator::new(
        Arc::new(StimSimulatorFactory),
        1,
        &["", "--angle-threshold=0.001"],
    )
    .unwrap();
    simulator
        .handle_operations(BatchOperation::simulator(vec![
            Operation::phased_x(0, std::f64::consts::PI, 0.0).unwrap(),
        ]))
        .unwrap();

    let error = simulator.postselect(0, false).unwrap_err();

    assert_eq!(
        error.to_string(),
        "Simulator (Stim): handle_operations failed: Postselection impossible.\n\
         Qubit 0 was asked to postselect to state |0>, but was in the perpendicular state |1>."
    );
}
