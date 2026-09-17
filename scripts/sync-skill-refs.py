#!/usr/bin/env python3
"""Sync skill-local references/ from docs/ — generated, do not hand-edit.

Some skills link reference entries (docs/references/*.md,
docs/generic-principles.md). Installed skills resolve plain relative
links against their own directory, so each linking skill carries its own
references/ copy. This script regenerates those copies from the docs/
canonical source; check-hygiene.sh fails when a copy is stale.

Usage:
  ./scripts/sync-skill-refs.py --check   # fail if any copy differs
  ./scripts/sync-skill-refs.py --write   # regenerate copies
"""
import argparse
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# skill -> docs/ files it needs locally
MAP = {
    "catalog": [
        "docs/references/index.md",
        "docs/generic-principles.md",
    ],
    "changelog-quality": [
        "docs/references/conventional-commits.md",
        "docs/generic-principles.md",
    ],
    "code-structure": [
        "docs/references/kernel-style-as-example.md",
    ],
}

HEADER = "<!-- generated from {src} by scripts/sync-skill-refs.py — do not hand-edit -->\n"


def sync(write: bool) -> int:
    problems = []
    for skill, srcs in MAP.items():
        destdir = REPO / "skills" / skill / "references"
        for src in srcs:
            body = (REPO / src).read_text()
            out = HEADER.format(src=src) + body
            dest = destdir / Path(src).name
            if write:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(out)
            elif not dest.is_file() or dest.read_text() != out:
                problems.append(f"{dest} differs from {src}")
    if problems and not write:
        for p in problems:
            print("FAIL: " + p)
        print("Regenerate: ./scripts/sync-skill-refs.py --write")
        return 1
    print("wrote skill references/" if write else "PASS: skill references/ match docs/")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    if args.check == args.write:
        ap.error("pass exactly one of --check / --write")
    return sync(write=args.write)


if __name__ == "__main__":
    sys.exit(main())
