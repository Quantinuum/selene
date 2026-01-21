import datetime
from pathlib import Path

import yaml
from qir_qis import qir_ll_to_bc, get_entry_attributes
from selene_sim import Quest
from selene_sim.build import build

RESOURCE_DIR = Path(__file__).parent / "resources"
QIR_RESOURCE_DIR = RESOURCE_DIR / "qir"


def test_adaptive_cond_loop(snapshot):
    ll_file = QIR_RESOURCE_DIR / "adaptive_cond_loop.ll"
    ll_text = ll_file.read_text()
    # generate bitcode
    bc_bytes = qir_ll_to_bc(ll_file.read_text())
    # make a temp file to store the bitcode
    import tempfile

    bc_file = tempfile.NamedTemporaryFile(suffix=".bc", delete=False)
    with open(bc_file.name, "wb") as f:
        f.write(bc_bytes)

    # get entry attributes
    attrs = get_entry_attributes(bc_bytes)
    assert "required_num_qubits" in attrs
    n_qubits = int(attrs["required_num_qubits"])

    results = {}
    for name, input_program in [
        ("ll_file", ll_file),
        ("ll_text", ll_text),
        ("bc_bytes", bc_bytes),
        ("bc_file", Path(bc_file.name)),
    ]:
        runner = build(input_program, "no_results")
        results[name] = list(
            runner.run(
                Quest(),
                n_qubits=n_qubits,
                timeout=datetime.timedelta(seconds=1),
                random_seed=78129,
            )
        )
    # all results should be the same
    snapshot.assert_match(yaml.dump(results), "adaptive_cond_loop_results.yaml")
    for result in list(results.values())[1:]:
        assert result == list(results.values())[0]
