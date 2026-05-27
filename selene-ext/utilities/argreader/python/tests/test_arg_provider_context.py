import pytest
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parents[1] / "selene_argreader_plugin"))
from provider import ArgProvider


def test_arg_provider_forbids_nested_contexts():
    outer = ArgProvider()
    outer.set_constant_args(input_u64=1)
    inner = ArgProvider()
    inner.set_constant_args(input_u64=2)

    with outer:
        with pytest.raises(RuntimeError, match="already set"):
            with inner:
                pass


def test_arg_provider_forbids_reentry():
    provider = ArgProvider()
    provider.set_constant_args(input_u64=1)

    with provider:
        with pytest.raises(RuntimeError, match="already active"):
            provider.__enter__()
