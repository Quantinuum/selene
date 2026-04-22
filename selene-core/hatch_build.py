import json
from hatchling.builders.hooks.plugin.interface import BuildHookInterface
from pathlib import Path


class SeleneCoreBuildHook(BuildHookInterface):
    def initialize(self, version: str, build_data: dict) -> None:
        # Generate and write the Trace JSON schema into _dist
        # as selene_core isn't yet available we need to import selene_core/trace.py manually
        import importlib.util

        trace_module_path = Path("python/selene_core/trace.py")
        spec = importlib.util.spec_from_file_location(
            "selene_core.trace", trace_module_path
        )
        if spec is None or spec.loader is None:
            raise RuntimeError(
                f"Unable to load module spec for selene_core.trace from {trace_module_path}"
            )
        trace_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(trace_module)
        schema_path = Path(
            "python/selene_core/_dist/share/selene-core/schemas/trace.json"
        )
        schema_path.parent.mkdir(parents=True, exist_ok=True)
        schema_path.write_text(
            json.dumps(trace_module.Trace.model_json_schema(), indent=2)
        )

        artifacts = []
        dist_dir = Path("python/selene_core/_dist")
        for artifact in dist_dir.rglob("*"):
            if artifact.is_file():
                artifacts.append(str(artifact.as_posix()))

        self.app.display_info("Found artifacts:")
        for a in artifacts:
            self.app.display_info(f"    {a}")

        build_data["artifacts"] += artifacts
