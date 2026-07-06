use super::builtin::{PhasedX, PhasedXX, QuantinuumGate, RZ, ZZPhase};
use crate::gatewire::{Angle, DynamicGateSet, GateSet, Qubit};
use crate::runtime::Operation;

crate::define_gateset! {
    enum ExampleGateSet {
        RZ(RZ),
        PhasedX(PhasedX),
        PhasedXX(PhasedXX),
    }
}

#[test]
fn typed_roundtrip() {
    let set = GateSet::<ExampleGateSet>::new().unwrap();
    let gate = ExampleGateSet::PhasedXX(PhasedXX {
        q0: Qubit(0),
        q1: Qubit(1),
        theta: Angle(0.25),
        phi: Angle(1.25),
    });
    let bytes = set.serialize_gate(&gate).unwrap();
    let decoded = set.try_deserialize(&bytes).unwrap().unwrap();
    assert_eq!(decoded, gate);
}

#[test]
fn dynamic_gateset_roundtrip() {
    let set = GateSet::<ExampleGateSet>::new().unwrap();
    let bytes = set.serialize_gateset();
    let dynamic = DynamicGateSet::deserialize(&bytes).unwrap();
    assert!(dynamic.contains(RZ::semantic_id()));
    assert_eq!(dynamic.len(), 3);
}

#[test]
fn dynamic_gateset_subset_and_superset_use_semantic_ids() {
    let all = DynamicGateSet::from_declarations([
        RZ::declaration(),
        PhasedX::declaration(),
        ZZPhase::declaration(),
    ])
    .unwrap();
    let subset =
        DynamicGateSet::from_declarations([RZ::declaration(), PhasedX::declaration()]).unwrap();
    let unsupported = DynamicGateSet::from_declarations([PhasedXX::declaration()]).unwrap();

    assert!(subset.is_subset_of(&all));
    assert!(all.is_superset_of(&subset));
    assert!(!all.is_subset_of(&subset));
    assert_eq!(
        subset
            .first_unsupported_by(&all)
            .map(|decl| decl.name.as_str()),
        None
    );
    assert_eq!(
        unsupported
            .first_unsupported_by(&all)
            .map(|decl| decl.name.as_str()),
        Some("PhasedXX")
    );
}

#[test]
fn dynamic_gateset_union_ignores_identical_duplicates() {
    let union = super::builtin::HeliosGateSet::dynamic()
        .union(&super::builtin::SolGateSet::dynamic())
        .unwrap();

    assert!(union.contains(RZ::semantic_id()));
    assert!(union.contains(PhasedX::semantic_id()));
    assert!(union.contains(ZZPhase::semantic_id()));
    assert!(union.contains(PhasedXX::semantic_id()));
    assert_eq!(union.len(), 4);
    assert_eq!(union, super::builtin::QuantinuumGateSet::dynamic());
}

#[test]
fn helios_gateset_is_compatible_with_quantinuum_accepting_plugins() {
    let incoming = super::builtin::HeliosGateSet::dynamic();
    let accepted = super::builtin::QuantinuumGateSet::dynamic();

    assert!(incoming.is_subset_of(&accepted));
    assert_eq!(incoming.first_unsupported_by(&accepted), None);
}

#[test]
fn builtin_gate_view_decodes_to_plain_fields() {
    let op = Operation::phased_xx(1, 2, 0.25, 0.75).unwrap();

    assert_eq!(
        op.as_gate_view::<QuantinuumGate>().unwrap(),
        Some(QuantinuumGate::PhasedXX {
            qubit_id_1: 1,
            qubit_id_2: 2,
            theta: 0.25,
            phi: 0.75,
        })
    );
}
