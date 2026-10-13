import subprocess
import sys
import textwrap
from pathlib import Path

import pytest


@pytest.mark.parametrize("missing", [("hugr",), ("qir_qis",), ("hugr", "qir_qis")])
def test_interfaces_without_optional_toolchains(missing):
    # Start before Selene imports so cached modules cannot hide import failures.
    script = textwrap.dedent(
        """
        import importlib.abc
        import importlib.util
        import sys
        from pathlib import Path

        resource_dir = Path(sys.argv[1])
        missing = set(sys.argv[2:])
        if 'hugr' in missing:
            missing.add('selene_hugr_qis_compiler')
        original_find_spec = importlib.util.find_spec

        def find_spec(name, *args, **kwargs):
            if name.split('.')[0] in missing:
                return None
            return original_find_spec(name, *args, **kwargs)

        class BlockOptionalImports(importlib.abc.MetaPathFinder):
            def find_spec(self, fullname, path=None, target=None):
                if fullname.split('.')[0] in missing:
                    raise ModuleNotFoundError(fullname, name=fullname)

        importlib.util.find_spec = find_spec
        sys.meta_path.insert(0, BlockOptionalImports())

        import selene_sim
        from selene_core.build_utils import BuildPlanner
        from selene_core.build_utils.builtins import register_builtins
        from selene_core.build_utils.builtins.helios import HeliosLLVMIRStringKind
        from selene_helios_qis_plugin import HeliosInterface
        from selene_sol_qis_plugin import SolInterface

        for platform, interface in (
            ('helios', HeliosInterface()), ('sol', SolInterface())
        ):
            planner = BuildPlanner()
            register_builtins(planner)
            interface.register_build_steps(planner)
            hugr_kinds = [
                kind for kind in planner.step_graph
                if kind.__module__.endswith('.hugr')
            ]
            assert bool(hugr_kinds) == (find_spec('hugr') is not None)
            source = 'declare void @setup()\\n'
            source += 'define void @qmain() { call void @setup() ret void }'
            assert planner.identify_kind(source) is HeliosLLVMIRStringKind

            program = resource_dir / platform / 'add_3_11-any.ll'
            runner = selene_sim.build(program, interface=interface)
            assert list(runner.run(selene_sim.Quest(), n_qubits=10)) == [('answer', 14)]

        assert not any(name.split('.')[0] in missing for name in sys.modules)
        """
    )
    result = subprocess.run(
        [
            sys.executable,
            "-c",
            script,
            str(Path(__file__).parent / "resources/qis"),
            *missing,
        ],
        capture_output=True,
        text=True,
        timeout=60,
    )
    assert result.returncode == 0, result.stdout + result.stderr
