# CLAUDE.md — see AGENTS.md

Canonical contributor workflow lives in `AGENTS.md` — same file Claude Code, Codex, Cursor, Copilot discover.

Quick start for Claude Code:

```bash
./scripts/phases.py --phase 0              # ~1.3k tok
./scripts/phases.py --phase 5 --profile full
cat skills/catalog/SKILL.md                # picker — 2-3 Qs → tailored list
./scripts/install.sh --list
```

Phase 0 discovery → Phase 1 socratic-spec (one Q/turn, 0 blocking Qs) → Phase 2 plan-iteration-gate 4Q (a) wrong (b) better way (c) missing (d) boundaries + 4 human-escalation triggers only → Phase 3 code-structure/comment-quality/factual-integrity → Phase 4 self-review-gate 4Q+cut + llm-tells → Phase 5 changelog-quality/upstream-hygiene.

All rules generic, positive framing (says what it IS), placeholder example.invalid / example-user, no private paths.
