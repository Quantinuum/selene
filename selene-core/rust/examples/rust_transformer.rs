use gatewire::builtin::{PhasedXX, PhasedX, RZ, ZZPhase};
use gatewire::{Angle, GateError, GateSet, Qubit, TryDecode};

#[derive(Clone, Debug, PartialEq, gatewire::GateSet)]
enum InputGate {
    RZ(RZ),
    PhasedX(PhasedX),
    PhasedXX(PhasedXX),
}

#[derive(Clone, Debug, PartialEq, gatewire::GateSet)]
enum OutputGate {
    RZ(RZ),
    PhasedX(PhasedX),
    ZZPhase(ZZPhase),
}

fn transform(gate: InputGate) -> OutputGate {
    match gate {
        InputGate::RZ(g) => OutputGate::RZ(g),
        InputGate::PhasedX(g) => OutputGate::PhasedX(g),
        InputGate::PhasedXX(g) => {
            // Just an example, this isn't real
            OutputGate::ZZPhase(ZZPhase { q0: g.q0, q1: g.q1, theta: g.theta + g.phi})
        }
    }
}

fn main() -> Result<(), GateError> {
    let input_set = GateSet::<InputGate>::new()?;
    let output_set = GateSet::<OutputGate>::new()?;

    let incoming = InputGate::PhasedXX(PhasedXX {
        q0: Qubit(0),
        q1: Qubit(1),
        theta: Angle(0.25),
        phi: Angle(1.25),
    });

    let incoming_wire = input_set.serialize_gate(&incoming)?;

    let decoded = match input_set.decode(&incoming_wire)? {
        TryDecode::Decoded(gate) => gate,
        TryDecode::Unknown(_) => return Err(GateError::UnknownGate),
    };

    let outgoing = transform(decoded);
    let outgoing_wire = output_set.serialize_gate(&outgoing)?;
    let roundtrip = output_set
        .try_deserialize(&outgoing_wire)?
        .ok_or(GateError::UnknownGate)?;

    println!("input:  {incoming:?}");
    println!("output: {roundtrip:?}");
    println!("wire bytes: {} -> {}", incoming_wire.len(), outgoing_wire.len());

    Ok(())
}
