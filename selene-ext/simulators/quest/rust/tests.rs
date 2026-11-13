use crate::QuestSimulatorFactory;
use selene_core::simulator::conformance_testing::run_basic_tests;
use std::sync::{Arc, Mutex};

// QuEST uses a process-global RNG; independent tests must not seed it concurrently.
static QUEST_TEST_LOCK: Mutex<()> = Mutex::new(());
#[test]
fn basic_conformance_test() {
    let _guard = QUEST_TEST_LOCK.lock().unwrap();
    let interface = Arc::new(QuestSimulatorFactory);
    let args = vec![];
    run_basic_tests(interface, args);
}

#[test]
fn exit_releases_state_and_rejects_later_callbacks() {
    let _guard = QUEST_TEST_LOCK.lock().unwrap();
    use selene_core::runtime::{BatchOperation, Operation};
    use selene_core::simulator::{SimulatorInterface, SimulatorInterfaceFactory};

    let mut simulator = Arc::new(QuestSimulatorFactory)
        .init(2, &[] as &[String])
        .unwrap();
    simulator.shot_start(0, 19).unwrap();
    simulator.shot_end().unwrap();
    simulator.exit().unwrap();
    assert!(simulator.state.is_none());
    assert!(simulator.exit().is_err());
    assert!(simulator.shot_start(1, 20).is_err());
    assert!(simulator.shot_end().is_err());
    assert!(
        simulator
            .handle_operations(BatchOperation::simulator(vec![]))
            .is_err()
    );
    for operation in [
        Operation::RXYGate {
            qubit_id: 0,
            theta: 0.2,
            phi: 0.3,
        },
        Operation::RZGate {
            qubit_id: 0,
            theta: 0.2,
        },
        Operation::RZZGate {
            qubit_id_1: 0,
            qubit_id_2: 1,
            theta: 0.2,
        },
        Operation::RPPGate {
            qubit_id_1: 0,
            qubit_id_2: 1,
            theta: 0.2,
            phi: 0.3,
        },
        Operation::Measure {
            qubit_id: 0,
            result_id: 0,
        },
        Operation::MeasureLeaked {
            qubit_id: 0,
            result_id: 0,
        },
        Operation::Reset { qubit_id: 0 },
    ] {
        assert!(
            simulator
                .handle_operations(BatchOperation::simulator(vec![operation]))
                .is_err()
        );
    }
    assert!(simulator.postselect(0, false).is_err());
    assert!(simulator.get_metric(0).is_err());
    // The exited check must happen before opening a file or accessing state.
    assert!(
        simulator
            .dump_state(std::path::Path::new(""), &[0])
            .unwrap_err()
            .to_string()
            .contains("exited")
    );
    // Explicit cleanup followed by Rust drop must not destroy the handles twice.
    drop(simulator);
}

#[test]
fn repeated_instances_support_explicit_exit_and_drop_cleanup() {
    let _guard = QUEST_TEST_LOCK.lock().unwrap();
    use selene_core::simulator::{SimulatorInterface, SimulatorInterfaceFactory};
    for explicit_exit in [false, true] {
        for shot in 0..16 {
            let mut simulator = Arc::new(QuestSimulatorFactory)
                .init(8, &[] as &[String])
                .unwrap();
            simulator.shot_start(shot, shot).unwrap();
            simulator.shot_end().unwrap();
            if explicit_exit {
                simulator.exit().unwrap();
            }
            drop(simulator);
        }
    }
}
