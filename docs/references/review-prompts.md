# Reference: masoncl/review-prompts and slash-command distribution

## TL;DR

Pattern for distributing AI review as slash-commands `/kreview /kseries /kslop` — file list in `.github/`, each prompt runs self-review on diff. Inspiration for peer-review Gates and how to ship skills as repo-native commands.

## Provides

- **Slash-command as skill transport:** store prompt docs in `.muse/commands/` or GitHub Copilot custom commands — agent loads on `/command` invocation with diff context.
- **Profile routing:** `exemplars-routing.md` tiny routing file (~315w) picks profile before loading full corpus — token saver ~5k tok per gate.
- **Automated second pass with high bar:** `/kslop` cluster requirement + neighbor comparison + hard cap 3 findings phrased as questions not flat deletions.

## License

MIT per review-prompts repo.

## Use with

`self-review-gate`, `change-splitting`, `pre-commit-check`. Adapt pattern: store code-hygiene gates in `templates/` + `.github/` slash-command aliases that cat core skills.

## Install / wiring

```bash
# example .github/muse/instructions.md referencing core
cat docs/references/index.md > .github/copilot-instructions.md
# optional .claude/commands/review.md that runs: cat skills/self-review-gate/SKILL.md
```

## When not to use

When project already has extensive review bot — layer, don't duplicate. Avoid slash-command spam that inflates PR.

## Link

https://github.com/masoncl/review-prompts
https://github.com/cline/cline (slash commands)
