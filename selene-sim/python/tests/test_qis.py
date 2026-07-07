import pytest
from pathlib import Path

import yaml
from selene_core import symbolize_qis_call_sites
from selene_core.build_utils.utils import invoke_zig
from selene_core.trace import EventRecord, GateEvent, SimulatorSource, Trace
from selene_sim.event_hooks import CircuitExtractor, MetricStore, MultiEventHook
from selene_sim.event_hooks.instruction_log import GateInstruction, Source
from selene_sim import Quest, SoftRZRuntime
from selene_sim.build import build
from selene_sim.exceptions import SeleneStartupError
from selene_base_qis_plugin import LogLevel
from selene_helios_qis_plugin import HeliosInterface
from selene_sol_qis_plugin import SolInterface

RESOURCE_DIR = Path(__file__).parent / "resources"
QIS_RESOURCE_DIR = RESOURCE_DIR / "qis"


def _macho_section_address(path: Path, section_name: str) -> int:
    from filebytes.mach_o import MachO

    binary = MachO(str(path))
    if binary.isFat:
        binary = binary.fatArches[0]
    for command in binary.loadCommands:
        if not hasattr(command, "sections"):
            continue
        for section in command.sections:
            if section.name == section_name:
                return int(section.header.addr)
    raise AssertionError(f"section {section_name} not found in {path}")


def _pe_section_rva(path: Path, section_name: str) -> int:
    from filebytes.pe import PE

    binary = PE(str(path))
    for section in binary.sections:
        if section.name == section_name:
            return int(section.header.VirtualAddress)
    raise AssertionError(f"section {section_name} not found in {path}")


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis(snapshot, program_name: str):
    filename = f"{program_name}-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    sol_file = QIS_RESOURCE_DIR / "sol" / filename
    assert helios_file.exists()
    assert sol_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())
    sol_build = build(sol_file, interface=SolInterface())

    helios_results = helios_build.run_shots(
        Quest(), n_qubits=10, n_shots=100, random_seed=1024
    )

    sol_results = sol_build.run_shots(
        Quest(), n_qubits=10, n_shots=100, random_seed=1024
    )

    results = {
        "helios": list(list(shot) for shot in helios_results),
        "sol": list(list(shot) for shot in sol_results),
    }

    assert results["helios"] == results["sol"]

    snapshot.assert_match(yaml.dump(results), f"{program_name}.yaml")


@pytest.mark.parametrize(
    "program_name",
    [
        "add_3_11",
    ],
)
def test_qis_circuit_log(snapshot, program_name: str):
    filename = f"{program_name}-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    sol_file = QIS_RESOURCE_DIR / "sol" / filename
    assert helios_file.exists()
    assert sol_file.exists()

    helios_build = build(helios_file, interface=HeliosInterface())
    sol_build = build(sol_file, interface=SolInterface())

    helios_circuit_extractor = CircuitExtractor()
    sol_circuit_extractor = CircuitExtractor()

    helios_results = helios_build.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=helios_circuit_extractor,
    )

    sol_results = sol_build.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=sol_circuit_extractor,
    )

    # trigger shot consumption
    list(list(shot) for shot in helios_results)
    list(list(shot) for shot in sol_results)

    circuits = {
        "helios": repr(helios_circuit_extractor.shots[0].get_user_circuit()),
        "sol": repr(sol_circuit_extractor.shots[0].get_user_circuit()),
    }

    snapshot.assert_match(yaml.dump(circuits), f"{program_name}_circuits.yaml")


@pytest.mark.parametrize(
    ("interface", "qis_file"),
    [
        (
            HeliosInterface(log_level=LogLevel.DIAGNOSTIC),
            QIS_RESOURCE_DIR / "helios" / "add_3_11-any.ll",
        ),
        (
            SolInterface(log_level=LogLevel.DIAGNOSTIC),
            QIS_RESOURCE_DIR / "sol" / "add_3_11-any.ll",
        ),
    ],
)
def test_qis_diagnostic_log_records_gate_call_site_metadata_in_trace(
    interface, qis_file: Path
):
    runner = build(qis_file, interface=interface)
    circuit_extractor = CircuitExtractor()

    results = runner.run_shots(
        Quest(),
        n_qubits=10,
        n_shots=1,
        random_seed=1024,
        event_hook=circuit_extractor,
    )
    list(list(shot) for shot in results)

    shot_instructions = circuit_extractor.shots[0]
    user_gate_instructions = [
        instruction
        for instruction in shot_instructions
        if instruction.source is Source.USER
        and isinstance(instruction.operation, GateInstruction)
    ]
    assert user_gate_instructions

    for instruction in user_gate_instructions:
        metadata = instruction.operation.metadata()
        assert metadata["qis.symbolization"] == "return-address-v1"
        assert metadata["qis.call_site.return_address"] > 0
        if "qis.call_site.module_offset" in metadata:
            assert metadata["qis.call_site.module_offset"] > 0
        if "qis.call_site.module" in metadata:
            assert metadata["qis.call_site.module"]

    trace = shot_instructions.get_trace()
    traced_sources = {
        record.source.kind
        for record in trace.events
        if isinstance(record.event, GateEvent)
        and record.event.metadata.get("qis.symbolization") == "return-address-v1"
        and record.event.metadata.get("qis.call_site.return_address", 0) > 0
    }
    assert traced_sources >= {"UserProgram", "Runtime", "ErrorModel", "Simulator"}


def test_qis_diagnostic_trace_pass_symbolizes_simulator_gate_call_site(tmp_path):
    source_lines = [
        "#include <stdint.h>",
        "extern void setup(uint64_t);",
        "extern uint64_t teardown(void);",
        "extern uint64_t ___qalloc(void);",
        "extern void ___reset(uint64_t);",
        "extern void ___qfree(uint64_t);",
        "extern void ___rxy(uint64_t, double, double);",
        "",
        "__attribute__((noinline)) static void apply_named_gate(uint64_t q) {",
        "    ___rxy(q, 3.141592653589793, 0.0);",
        "}",
        "",
        "uint64_t qmain(uint64_t tc) {",
        "    setup(tc);",
        "    uint64_t q = ___qalloc();",
        "    ___reset(q);",
        "    apply_named_gate(q);",
        "    ___reset(q);",
        "    ___qfree(q);",
        "    return teardown();",
        "}",
    ]
    gate_call_line = source_lines.index("    ___rxy(q, 3.141592653589793, 0.0);") + 1
    source_path = tmp_path / "debug_qis.c"
    object_path = tmp_path / "debug_qis.o"
    source_path.write_text("\n".join(source_lines) + "\n")

    invoke_zig(
        "cc",
        "-g",
        "-O0",
        "-fno-omit-frame-pointer",
        "-c",
        source_path,
        "-o",
        object_path,
        cache_dir=tmp_path / "zig-cache",
    )

    runner = build(
        object_path,
        interface=HeliosInterface(log_level=LogLevel.DIAGNOSTIC),
        build_dir=tmp_path / "selene-build",
    )
    circuit_extractor = CircuitExtractor()
    results = runner.run_shots(
        Quest(),
        n_qubits=1,
        n_shots=1,
        random_seed=1024,
        event_hook=circuit_extractor,
    )
    list(list(shot) for shot in results)

    enriched_trace = symbolize_qis_call_sites(circuit_extractor.shots[0].get_trace())
    simulator_gate_events = [
        record.event
        for record in enriched_trace.events
        if isinstance(record.source, SimulatorSource)
        and isinstance(record.event, GateEvent)
        and record.event.gate_name == "PhasedX"
    ]

    assert simulator_gate_events
    debug_stack = simulator_gate_events[0].debug_stack
    assert debug_stack
    assert debug_stack[0].function == "apply_named_gate"
    assert Path(debug_stack[0].file).name == source_path.name
    assert debug_stack[0].line == gate_call_line
    assert "debug_stack" in simulator_gate_events[0].model_dump()


def test_qis_diagnostic_trace_pass_ignores_non_elf_modules(tmp_path):
    module_path = tmp_path / "program.exe"
    module_path.write_bytes(b"MZ")
    trace = Trace(
        events=[
            EventRecord(
                source=SimulatorSource(index=0, duration_ns=0),
                event=GateEvent(
                    gate_name="PhasedX",
                    metadata={
                        "qis.call_site.module": str(module_path),
                        "qis.call_site.module_offset": 1,
                        "qis.call_site.return_address": 1,
                    },
                ),
            )
        ]
    )

    enriched_trace = symbolize_qis_call_sites(trace)

    assert enriched_trace.events[0].event.debug_stack == []


@pytest.mark.parametrize(
    ("target", "output_name", "compile_flags", "module_offset"),
    [
        (
            "x86_64-macos.11.0-none",
            "debug_qis.o",
            ["-c", "-g"],
            lambda path: _macho_section_address(path, "__text"),
        ),
        (
            "x86_64-windows-gnu",
            "debug_qis.exe",
            ["-gdwarf-4"],
            lambda path: _pe_section_rva(path, ".text"),
        ),
    ],
)
def test_qis_diagnostic_trace_pass_symbolizes_non_elf_dwarf_containers(
    tmp_path, target, output_name, compile_flags, module_offset
):
    source_lines = [
        "__attribute__((noinline)) int marker(void) {",
        "    return 7;",
        "}",
        "int main(void) {",
        "    return marker();",
        "}",
    ]
    marker_line = source_lines.index("__attribute__((noinline)) int marker(void) {") + 1
    source_path = tmp_path / "debug_qis.c"
    module_path = tmp_path / output_name
    source_path.write_text("\n".join(source_lines) + "\n")

    invoke_zig(
        "cc",
        "-O0",
        *compile_flags,
        source_path,
        "-o",
        module_path,
        "-target",
        target,
        handle_triple=False,
        cache_dir=tmp_path / f"zig-cache-{output_name}",
    )

    trace = Trace(
        events=[
            EventRecord(
                source=SimulatorSource(index=0, duration_ns=0),
                event=GateEvent(
                    gate_name="PhasedX",
                    metadata={
                        "qis.call_site.module": str(module_path),
                        "qis.call_site.module_offset": module_offset(module_path),
                    },
                ),
            )
        ]
    )

    enriched_trace = symbolize_qis_call_sites(trace)
    debug_stack = enriched_trace.events[0].event.debug_stack

    assert debug_stack
    assert debug_stack[0].function == "marker"
    assert Path(debug_stack[0].file).name == source_path.name
    assert debug_stack[0].line == marker_line


def test_full_stack_gateset_handshake_rejects_unsupported_downstream_gate():
    sol_file = QIS_RESOURCE_DIR / "sol" / "add_3_11-any.ll"
    assert sol_file.exists()

    runner = build(sol_file, interface=SolInterface())

    with pytest.raises(SeleneStartupError) as exc_info:
        list(
            list(shot)
            for shot in runner.run_shots(
                Quest(),
                runtime=SoftRZRuntime(),
                n_qubits=10,
                n_shots=1,
                random_seed=1024,
            )
        )

    error = exc_info.value
    assert "SoftRZRuntime does not support gate PhasedXX" in error.message


def test_simulate_delay():
    filename = "simulate_delay-any.ll"
    helios_file = QIS_RESOURCE_DIR / "helios" / filename
    assert helios_file.exists()
    helios_build = build(helios_file, interface=HeliosInterface())
    helios_circuit_extractor = CircuitExtractor()
    metric_store = MetricStore()
    hook = MultiEventHook([helios_circuit_extractor, metric_store])

    helios_results = helios_build.run_shots(
        Quest(),
        n_qubits=2,
        n_shots=1,
        random_seed=1024,
        event_hook=hook,
    )

    results = {
        "helios": list(dict(shot) for shot in helios_results),
    }
    assert results["helios"][0]["qubit_0"] == 0
    assert results["helios"][0]["qubit_1"] == 0

    shot_metrics = metric_store.shots[0]
    # the QIS example adds a simulated delay of 123,450,000 ns, so we check that the metric store reflects this
    # in the total runtime (the default "simple" runtime doesn't add any time taken for operations)
    assert shot_metrics["post_runtime"]["total_duration_ns"] == 1_234_500_000, (
        f"Expected total_duration_ns to be 1,234,500,000 ns, but got {shot_metrics['post_runtime']['total_duration_ns']}"
    )

    optimiser_output = helios_circuit_extractor.shots[0].get_optimiser_output()

    assert optimiser_output == [
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "Reset", "qubit": 0},
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "Reset", "qubit": 1},
        {"op": "BatchStart", "start_time_ns": 0, "duration_ns": 0},
        {"op": "FutureRead", "qubit": 0},
        # simulated delay happens here, so we expect the next operations to be logged as starting at 1,234,500,000 ns
        {"op": "BatchStart", "start_time_ns": 1234500000, "duration_ns": 0},
        {"op": "FutureRead", "qubit": 1},
    ]

    all_output = list(helios_circuit_extractor.shots[0])
    all_output_serialised = []
    for item in all_output:
        if str(item.source) not in {"Source.USER", "Source.OPTIMISER"}:
            continue
        all_output_serialised.append(
            {"source": str(item.source), "operation": item.operation.to_dict()}
        )

    assert all_output_serialised == [
        {
            "operation": {
                "op": "QAlloc",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "QAlloc",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "Reset",
                "qubit": 1,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "MeasureRequest",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 0,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "QFree",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 0,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 1234500000,
                "op": "ClassicalDelay",
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "MeasureRequest",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "duration_ns": 0,
                "op": "BatchStart",
                "start_time_ns": 1234500000,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 1,
            },
            "source": "Source.OPTIMISER",
        },
        {
            "operation": {
                "op": "QFree",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
        {
            "operation": {
                "op": "FutureRead",
                "qubit": 1,
            },
            "source": "Source.USER",
        },
    ]
