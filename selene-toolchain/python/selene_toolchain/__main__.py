"""Small command-line entry point for managing the local build cache."""

import argparse
from . import Store


def main() -> None:
    parser = argparse.ArgumentParser(prog="python -m selene_toolchain")
    commands = parser.add_subparsers(dest="command", required=True)
    clean = commands.add_parser(
        "clean", help="Evict cached build records; keep captured libraries"
    )
    clean.add_argument("--store", help="Use a particular store directory")
    clean.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    store = Store(args.store)
    count = store.clean(dry_run=args.dry_run)
    print(
        f"{'Would remove' if args.dry_run else 'Removed'} {count} bytes of cached build records and temporary files"
    )


if __name__ == "__main__":
    main()
