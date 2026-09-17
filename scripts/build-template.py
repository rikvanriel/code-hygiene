#!/usr/bin/env python3
"""Generate adopter template from root AGENTS.md."""
import argparse
import re
import sys
from pathlib import Path
REPO = Path(__file__).resolve().parent.parent
ROOT_AGENTS = REPO / "AGENTS.md"
ROOT_CLAUDE = REPO / "CLAUDE.md"
TPL_AGENTS = REPO / "templates" / "AGENTS.md"
TPL_CLAUDE = REPO / "templates" / "CLAUDE.md"

def strip_repo_paths(text):
    text = re.sub(r"`skills/[a-z-]+/SKILL\.md`", "`<notes-dir>/<topic>.md`", text)
    text = re.sub(r"`docs/references/[a-z-]+\.md`", "`docs/references/<topic>.md`", text)
    text = re.sub(r"`scripts/[a-z-]+\.(sh|py)", r"`scripts/<check>.\1", text)
    return text


def token_table():
    try:
        from phases import PHASES, estimate
    except ImportError:
        return None
    rows = []
    for name in PHASES:
        files = PHASES[name]["files"]
        total = sum(estimate(REPO / f) for f in files)
        rows.append((name, total))
    return rows

def build(profile, with_refs):
    src = ROOT_AGENTS.read_text()
    body = strip_repo_paths(src)
    lines = body.splitlines()
    out = []
    out.append("# AGENTS.md template — generated, do not hand-edit")
    out.append("")
    out.append("Generated from code-hygiene root AGENTS.md by")
    out.append("`scripts/build-template.py --profile %s%s`." % (profile, " --with " + ",".join(with_refs) if with_refs else ""))
    out.append("Regenerate rather than editing: `./scripts/build-template.py --profile %s`" % profile)
    out.append("")
    skip = False
    for ln in lines:
        if ln.startswith("# AGENTS.md"):
            continue
        if profile == "minimal" and ln.startswith("## Distribution"):
            skip = True
            continue
        if skip and ln.startswith("## "):
            skip = False
        if skip:
            continue
        out.append(ln)
    out.append("")
    out.append("## Load budgets (computed, not hardcoded)")
    out.append("")
    out.append("Run the phase helper in the code-hygiene checkout for current numbers:")
    out.append("")
    out.append("```bash")
    out.append("./scripts/phases.py --phase 0")
    out.append("./scripts/phases.py --phase 5 --profile full")
    out.append("```")
    for ref in with_refs:
        sec = REFERENCED_SECTIONS.get(ref)
        if sec:
            out.append("")
            out.append(sec)
    out.append("")
    return "\n".join(out) + "\n"

REFERENCED_SECTIONS = {
    "memory": """## Working memory (optional, via referenced software)

Record durable decisions as facts so later sessions stay consistent
without re-deriving them. Keep each memory provider behind a probe:
only the configured provider's section loads.

- lemmalog (local-first): assert line-protocol facts
  `subject --relation[confidence]--> object`, one per line; query with
  `lemmalog_context` for budget-aware retrieval, `lemmalog_query` for
  exact bindings. See `docs/references/lemmalog.md`.
- Provider-neutral rule: memories hold decisions and constraints, never
  secrets. Re-check a memory's claim against the current diff before
  acting on it, the same as any other unverified prose.""",
    "search": """## Code search (optional, via referenced software)

Ground claims in the current tree before asserting them. Keep each
search provider behind a probe: only the configured provider loads.

- zoekt (local index): `mcp__zoekt__search` for content,
  `mcp__zoekt__search_symbols` for definitions, `mcp__zoekt__file_content`
  to read a hit. Verify a symbol's call sites rather than asserting them.
- semcode (semantic index over the same tree): `call_tool` for
  cross-reference queries the local index cannot answer.
  See `docs/references/code-search.md`.
- Provider-neutral rule: paste the matching lines (file plus line range)
  into the change record instead of paraphrasing them.""",
}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--profile", choices=["minimal", "full"], default="full")
    ap.add_argument("--with", dest="with_refs", default="",
                    help="comma list: memory,search")
    ap.add_argument("--write", action="store_true",
                    help="write generated output to templates/ (local use only;"
                    " templates/ is git-ignored, so there is no --check mode:"
                    " freshness is verified by check-hygiene.sh, which greps"
                    " the generator's stdout for the 4Q gates)")
    args = ap.parse_args()
    with_refs = [w for w in args.with_refs.split(",") if w in REFERENCED_SECTIONS]
    if args.with_refs and not with_refs:
        ap.error("--with accepts: memory,search")

    agents = build(args.profile, with_refs)
    claude = (
        "# CLAUDE.md — see AGENTS.md template\n"
        "\n"
        "Canonical template lives in `templates/AGENTS.md`. This file is a thin shim\n"
        "for Claude Code — same pattern as root CLAUDE.md pointing to root AGENTS.md.\n"
        "\n"
        "```bash\n"
        "./scripts/build-template.py --profile %s%s  # regenerate this template\n" % (args.profile, " --with " + ",".join(with_refs) if with_refs else "")
        + "```\n"
    )

    if args.write:
        TPL_AGENTS.parent.mkdir(parents=True, exist_ok=True)
        TPL_AGENTS.write_text(agents)
        TPL_CLAUDE.write_text(claude)
        print("wrote templates/AGENTS.md + templates/CLAUDE.md")
        return 0

    sys.stdout.write(agents)
    return 0


if __name__ == "__main__":
    sys.exit(main())
