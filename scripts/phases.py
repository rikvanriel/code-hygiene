#!/usr/bin/env python3
"""
phases.py — print exact cat commands + token budgets for code-hygiene workflow.

Generic version of kernel-style's phases.py: shows 6-phase cumulative load
with token estimates (chars//4 heuristic). Source of truth for load order,
nothing executes beyond listing.

Usage:
  ./scripts/phases.py --phase 0..5
  ./scripts/phases.py --phase 3 --profile minimal|full
"""

import argparse
import pathlib

REPO = pathlib.Path(__file__).resolve().parent.parent

HOT_PHASES = {
    0: ["skills/project-discovery/SKILL.md", "docs/references/index.md"],
    1: ["skills/socratic-spec/SKILL.md"],
    2: ["skills/plan-iteration-gate/SKILL.md", "skills/self-review-gate/SKILL.md"],
    3: ["skills/code-structure/SKILL.md", "skills/comment-quality/SKILL.md",
        "skills/factual-integrity/SKILL.md", "docs/generic-principles.md"],
    4: ["skills/self-review-gate/SKILL.md", "skills/llm-tells/SKILL.md"],
    5: ["skills/changelog-quality/SKILL.md", "skills/upstream-hygiene/SKILL.md",
        "skills/catalog/SKILL.md"],
}

PHASE_NAMES = {
    0: "Phase 0 — project discovery (Step 0)",
    1: "Phase 1 — socratic spec (divergent, closes Open Qs)",
    2: "Phase 2 — plan iteration (convergent, observable signal per step)",
    3: "Phase 3 — draft code (always hot from here)",
    4: "Phase 4 — review before commit (mandatory)",
    5: "Phase 5 — changelog / PR description (mandatory when drafting message)",
}

def wc(path):
    try:
        t = (REPO / path).read_text(errors="replace")
        return len(t.split()), len(t) // 4
    except FileNotFoundError:
        return 0, 0

def main():
    ap = argparse.ArgumentParser(description="code-hygiene phases helper")
    ap.add_argument("--phase", type=int, required=True, choices=list(HOT_PHASES.keys()),
                    help="target phase")
    ap.add_argument("--profile", choices=["minimal", "full"], default="minimal",
                    help="minimal=exact phase set, full=cumulative up to phase")
    args = ap.parse_args()

    if args.profile == "full":
        phases_sorted = sorted(HOT_PHASES.keys())
        files = []
        seen = set()
        for p in phases_sorted:
            if p <= args.phase:
                for f in HOT_PHASES[p]:
                    if f not in seen:
                        files.append(f)
                        seen.add(f)
    else:
        files = HOT_PHASES[args.phase][:]

    total_w = total_tok = 0
    print(f"# {PHASE_NAMES[args.phase]} — profile {args.profile}")
    for f in files:
        w, tok = wc(f)
        total_w += w
        total_tok += tok
        exists = (REPO / f).exists()
        mark = "" if exists else " MISSING"
        print(f"  HOT   {f:50s} {w:4d}w ~{tok:4d}tok{mark}")
    print(f"\n  Total: {total_w}w ~{total_tok}tok")
    print(f"\n  Load command (hot): cat {' '.join(files)}")
    print("\n  Cumulative model: nothing unloads until task end per README.")
    if args.phase == 0:
        print("\n  On-demand: SOCRATIC spec questions bank in skills/socratic-spec/SKILL.md")
    if args.phase == 5:
        print("\n  Runnable: ./scripts/check-hygiene.sh HEAD (after commit)")

if __name__ == "__main__":
    main()
