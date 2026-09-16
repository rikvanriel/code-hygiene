# Reference: CLAUDE.md, copilot-instructions, .cursorrules, AGENTS distribution

## TL;DR

Different agent homes discover same content via different filenames — Claude Code reads `CLAUDE.md`, Copilot reads `.github/muse-instructions.md`, Cursor reads `.muse/rules`, Codex/Aider read `AGENTS.md`. Code-hygiene provides canonical AGENTS.md + shim pattern to avoid drift.

## Provides

- **Canonical + shim:** One canonical file holds real rules, second file points. ADR 0001 documents decision.
- **Install probe:** `./scripts/install.sh --list` checks `~/.claude/skills`, `~/.hermes/skills`, `AGENTS.md`, `.cursor/rules`, `.github/` and prints detectable homes — confirmation gate required before copy.
- **Adapter per agent:** Claude `Skill({name})` invocation, Cursor `@file` reference, Copilot instruction block.

## License

MIT for adapters; vendor docs CC-BY where relevant.

## Use with

`project-discovery`, `catalog`, `upstream-hygiene`. When project already has one of these files, extend don't replace — discovery Step0 obeys existing.

## Install / wiring

```bash
./scripts/install.sh --list            # detect homes
./scripts/install.sh --install catalog --to ~/.claude/skills  # one skill
# or copy canonical
cp AGENTS.md /path/to/project/AGENTS.md
cp CLAUDE.md /path/to/project/CLAUDE.md  # shim
```

## When not to use

When project has extensive AGENTS.md already — merge via socratic-spec interview, ask human which sections to keep.

## Link

https://code.visualstudio.com/docs/copilot/copilot-customization
https://docs.cursor.com/context/rules-for-ai
https://github.com/sourcegraph/cody — similar instruction discovery
