#!/usr/bin/env python3
"""Validate JSON Schema $id URLs and optionally stage schemas for publishing."""

import argparse
import json
import shutil
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--destination",
        type=Path,
        help="copy validated schemas to this directory, preserving relative paths",
    )
    arguments = parser.parse_args()

    source = Path(__file__).resolve().parents[1] / "schemas"
    base_url = "https://quantinuum.github.io/selene/schemas/"
    schemas = sorted(source.rglob("*.schema.json"))

    if not schemas:
        raise SystemExit(f"No JSON Schemas found under {source}")

    for schema in schemas:
        relative_path = schema.relative_to(source)
        expected_id = base_url + relative_path.as_posix()
        document = json.loads(schema.read_text())

        if document.get("$id") != expected_id:
            raise SystemExit(
                f"{schema}: expected $id {expected_id!r}, found {document.get('$id')!r}"
            )

    if arguments.destination is not None:
        for schema in schemas:
            output = arguments.destination / schema.relative_to(source)
            output.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(schema, output)


if __name__ == "__main__":
    main()
