#!/usr/bin/env python3
"""Reject changes to JSON Schemas that already exist in a base revision."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path

SCHEMA_DIRECTORY = "selene-trace/schemas"
SCHEMA_SUFFIX = ".schema.json"


def run_git(repository: Path, *arguments: str) -> str:
    try:
        result = subprocess.run(
            ["git", *arguments],
            cwd=repository,
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip()
        message = f"git {' '.join(arguments)} failed"
        if detail:
            message = f"{message}: {detail}"
        raise SystemExit(message) from None
    return result.stdout


def find_repository() -> Path:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip()
        raise SystemExit(detail or "Not inside a Git repository") from None
    return Path(result.stdout.strip())


def schema_paths_at_revision(repository: Path, revision: str) -> set[str]:
    output = run_git(
        repository,
        "ls-tree",
        "-r",
        "--name-only",
        revision,
        "--",
        SCHEMA_DIRECTORY,
    )
    return {path for path in output.splitlines() if path.endswith(SCHEMA_SUFFIX)}


def schema_paths_in_index(repository: Path) -> set[str]:
    output = run_git(
        repository,
        "ls-files",
        "--cached",
        "--",
        SCHEMA_DIRECTORY,
    )
    return {path for path in output.splitlines() if path.endswith(SCHEMA_SUFFIX)}


def schema_changes(
    repository: Path, base_revision: str, head_revision: str | None
) -> list[str]:
    comparison = (
        ["diff", "--cached", "--name-status", "--find-renames", base_revision]
        if head_revision is None
        else [
            "diff",
            "--name-status",
            "--find-renames",
            base_revision,
            head_revision,
        ]
    )
    output = run_git(repository, *comparison, "--", SCHEMA_DIRECTORY)
    return output.splitlines()


def print_schema_list(heading: str, schemas: set[str]) -> None:
    print(f"{heading} ({len(schemas)}):")
    for schema in sorted(schemas):
        print(f"  - {schema}")


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base",
        required=True,
        help="revision containing the schemas that must remain unchanged",
    )
    comparison = parser.add_mutually_exclusive_group(required=True)
    comparison.add_argument("--head", help="revision to compare with the base")
    comparison.add_argument(
        "--staged",
        action="store_true",
        help="compare the Git index with the base revision",
    )
    return parser.parse_args()


def main() -> None:
    arguments = parse_arguments()
    repository = find_repository()
    base_schemas = schema_paths_at_revision(repository, arguments.base)
    head_schemas = (
        schema_paths_in_index(repository)
        if arguments.staged
        else schema_paths_at_revision(repository, arguments.head)
    )

    violations = []
    for change in schema_changes(repository, arguments.base, arguments.head):
        status, *paths = change.split("\t")
        if status != "A" and any(path.endswith(SCHEMA_SUFFIX) for path in paths):
            violations.append(change)

    if base_schemas:
        print_schema_list("Previously published schemas", base_schemas)
    else:
        print("No previously published schemas were found.")

    new_schemas = head_schemas - base_schemas
    if new_schemas:
        print_schema_list("New schemas", new_schemas)
    else:
        print("No new schemas were found.")

    if violations:
        details = "\n".join(f"  {violation}" for violation in violations)
        raise SystemExit(
            "Published JSON Schemas are immutable. Add a schema with a new "
            f"versioned filename instead of changing an existing one:\n{details}"
        )

    if base_schemas:
        print("All previously published schemas are unchanged.")
    print("Schema immutability check passed.")


if __name__ == "__main__":
    main()
