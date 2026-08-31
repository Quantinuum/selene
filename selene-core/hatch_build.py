import shutil
from hatchling.builders.hooks.plugin.interface import BuildHookInterface
from pathlib import Path


class SeleneCoreBuildHook(BuildHookInterface):
    def initialize(self, version: str, build_data: dict) -> None:
        # _dist is ignored and may contain artifacts from an older local build.
        # Recreate it so a wheel is determined solely by the current sources.
        dist_dir = Path("python/selene_core/_dist")
        if dist_dir.exists():
            shutil.rmtree(dist_dir)

        # The public trace schema is owned by the language-neutral
        # selene-protocol package. Keep distributing it with selene-core for users
        # of the legacy selene_core.trace import path.
        schema_path = Path(
            "python/selene_core/_dist/share/selene-core/schemas/trace.json"
        )
        schema_path.parent.mkdir(parents=True, exist_ok=True)
        schema_source = Path("trace_schema/trace.json")
        if not schema_source.exists():
            schema_source = Path("../selene-protocol/schemas/trace/0.1.0.schema.json")
        shutil.copy2(schema_source, schema_path)

        shutil.copytree(Path("c/include"), dist_dir / "include")

        artifacts = []
        for artifact in dist_dir.rglob("*"):
            if artifact.is_file():
                artifacts.append(str(artifact.as_posix()))

        self.app.display_info("Found artifacts:")
        for a in artifacts:
            self.app.display_info(f"    {a}")

        build_data["artifacts"] += artifacts
