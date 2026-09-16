# ADR 0001 — Canonical AGENTS.md + shim CLAUDE.md

Date: 2026-09-16
Status: accepted

## Context

Agents discover contributor notes via different filenames:
- Claude Code reads CLAUDE.md / .claude/CLAUDE.md
- Codex/Cursor/Copilot/Aider/Cline/Amp/Google CLI read AGENTS.md
- Cursor also reads .cursor/rules, Copilot reads .github/muse-instructions.md

Maintaining full duplicated content in CLAUDE.md and AGENTS.md causes drift — e.g. templates/AGENTS.md was ...[truncated]