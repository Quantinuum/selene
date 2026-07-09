from pathlib import Path
import pytest
import os

from selene_sim import build
from selene_sim.backends import Coinflip
from selene_sim.exceptions import SelenePanicError
from selene_envreader_plugin import EnvReaderPlugin


def test_env_reader(monkeypatch):
    llvm_file = Path(__file__).parent / "resources/envreader_example.ll"
    instance = build(llvm_file, utilities=[EnvReaderPlugin()])

    # clear any conflicting values from the environment
    for key in ("BOOL_ENV_VAR", "UINT_ENV_VAR", "INT_ENV_VAR", "FLOAT_ENV_VAR"):
        monkeypatch.delenv(key, raising=False)

    # If we don't provide arguments, the provider will panic on entry:
    with pytest.raises(
        SelenePanicError, match="Environment variable '[^']*' not found"
    ):
        result = list(
            list(r)
            for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
        )

    monkeypatch.setenv("BOOL_ENV_VAR", "true")
    monkeypatch.setenv("UINT_ENV_VAR", "4")
    monkeypatch.setenv("INT_ENV_VAR", "2")
    monkeypatch.setenv("FLOAT_ENV_VAR", "0.025")
    result = list(
        dict(r) for r in instance.run_shots(n_qubits=1, n_shots=1, simulator=Coinflip())
    )[0]
    assert result["input_bool"]
    assert result["input_uint"] == 4
    assert result["input_int"] == 2
    assert result["input_float"] == 0.025


def test_env_reader_per_process(monkeypatch):
    """
    If different environment variables should be available to different processes
    when n_processes > 1, they can be provided globally by prefixing the process
    index to the variable name. Before the process is launched, the environment
    variable will be available to the corresponding selene process without the prefix.
    """

    llvm_file = Path(__file__).parent / "resources/envreader_example.ll"
    instance = build(llvm_file, utilities=[EnvReaderPlugin()])

    monkeypatch.setenv("SELENE_PROCESS_0_BOOL_ENV_VAR", "true")
    monkeypatch.setenv("SELENE_PROCESS_0_UINT_ENV_VAR", "4")
    monkeypatch.setenv("SELENE_PROCESS_0_INT_ENV_VAR", "2")
    monkeypatch.setenv("SELENE_PROCESS_0_FLOAT_ENV_VAR", "0.025")
    monkeypatch.setenv("SELENE_PROCESS_1_BOOL_ENV_VAR", "false")
    monkeypatch.setenv("SELENE_PROCESS_1_UINT_ENV_VAR", "9")
    monkeypatch.setenv("SELENE_PROCESS_1_INT_ENV_VAR", "-5")
    monkeypatch.setenv("SELENE_PROCESS_1_FLOAT_ENV_VAR", "-0.025")
    monkeypatch.setenv("SELENE_PROCESS_2_BOOL_ENV_VAR", "1")
    monkeypatch.setenv("SELENE_PROCESS_2_UINT_ENV_VAR", "0")
    monkeypatch.setenv("SELENE_PROCESS_2_INT_ENV_VAR", "0")
    monkeypatch.setenv("SELENE_PROCESS_2_FLOAT_ENV_VAR", "-1")

    results = list(
        dict(r)
        for r in instance.run_shots(
            n_qubits=1, n_shots=3, simulator=Coinflip(), n_processes=3
        )
    )
    assert results[0]["input_bool"]
    assert results[0]["input_uint"] == 4
    assert results[0]["input_int"] == 2
    assert results[0]["input_float"] == 0.025
    assert not results[1]["input_bool"]
    assert results[1]["input_uint"] == 9
    assert results[1]["input_int"] == -5
    assert results[1]["input_float"] == -0.025
    assert results[2]["input_bool"]
    assert results[2]["input_uint"] == 0
    assert results[2]["input_int"] == 0
    assert results[2]["input_float"] == -1.0
