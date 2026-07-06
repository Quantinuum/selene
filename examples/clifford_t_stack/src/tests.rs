use selene_core::error_model::ErrorModelInterface;
use selene_core::runtime::RuntimeInterface;
use selene_core::simulator::SimulatorInterface;

use crate::{
    CliffordTErrorModel, CliffordTInterface, CliffordTRuntime, CliffordTTraceSimulator,
    clifford_t_gateset, gateset_names,
};

#[test]
fn gateset_negotiation_is_explicit_at_each_layer() {
    let interface_gateset = clifford_t_gateset();
    let mut runtime = CliffordTRuntime::new(2, selene_core::time::Instant::from(0));
    let runtime_gateset = runtime.negotiate_gateset(&interface_gateset).unwrap();
    let mut error_model = CliffordTErrorModel::deterministic();
    let error_model_gateset = error_model.negotiate_gateset(&runtime_gateset).unwrap();
    let mut simulator = CliffordTTraceSimulator::new(2);
    let simulator_gateset = simulator.negotiate_gateset(&error_model_gateset).unwrap();

    let names = vec!["H", "S", "Sdg", "T", "Tdg", "X", "CNOT"];
    assert_eq!(gateset_names(&interface_gateset), names);
    assert_eq!(gateset_names(&runtime_gateset), names);
    assert_eq!(gateset_names(&error_model_gateset), names);
    assert_eq!(gateset_names(&simulator_gateset), names);
}

#[test]
fn interface_runtime_error_model_and_simulator_work_together() {
    let mut runtime = CliffordTRuntime::new(2, selene_core::time::Instant::from(0));
    let mut error_model = CliffordTErrorModel::deterministic();
    let mut simulator = CliffordTTraceSimulator::new(2);

    let runtime_gateset = runtime.negotiate_gateset(&clifford_t_gateset()).unwrap();
    let error_model_gateset = error_model.negotiate_gateset(&runtime_gateset).unwrap();
    simulator.negotiate_gateset(&error_model_gateset).unwrap();

    runtime.shot_start(0, 0).unwrap();
    error_model.shot_start(0, 0).unwrap();
    simulator.shot_start(0, 0).unwrap();

    assert_eq!(runtime.qalloc().unwrap(), 0);
    assert_eq!(runtime.qalloc().unwrap(), 1);
    let (m0, m1) = {
        let mut interface = CliffordTInterface::new(&mut runtime);
        interface.h(0).unwrap();
        interface.t(0).unwrap();
        interface.cnot(0, 1).unwrap();
        let m0 = interface.measure(0).unwrap();
        let m1 = interface.measure(1).unwrap();
        (m0, m1)
    };

    runtime.global_barrier(0).unwrap();
    while let Some(batch) = runtime.get_next_operations().unwrap() {
        let results = error_model
            .handle_operations(batch, &mut simulator)
            .unwrap();
        for result in results.bool_results {
            runtime
                .set_bool_result(result.result_id, result.value)
                .unwrap();
        }
    }

    assert_eq!(runtime.get_bool_result(m0).unwrap(), Some(false));
    assert_eq!(runtime.get_bool_result(m1).unwrap(), Some(false));

    simulator.shot_end().unwrap();
    error_model.shot_end().unwrap();
    runtime.shot_end().unwrap();

    assert_eq!(
        simulator
            .trace()
            .iter()
            .map(|entry| entry.0.as_str())
            .collect::<Vec<_>>(),
        vec![
            "H q0",
            "X q0",
            "T q0",
            "X q0",
            "CNOT q0 q1",
            "MEASURE q0 -> false",
            "MEASURE q1 -> false",
        ]
    );
    assert_eq!(error_model.injected_x(), 2);
    assert_eq!(simulator.gates_seen(), 5);
    assert_eq!(simulator.measurements(), 2);
}
