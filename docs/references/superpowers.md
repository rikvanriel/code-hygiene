# obra/superpowers — source inspiration

## TL;DR

Parent repo of many agentic workflow patterns — brainstorming, plan writing, TDD, debugging, subagent dispatch — that inspired Hermes `plan`, `systematic-debugging`, `test-driven-development` and code-hygiene's `self-review-gate` + `socratic-spec` + `plan-iteration-gate`.

## Provides

- Plan mode: write markdown plan to `.hermes/plans/` (our `obra-derived` → `.hermes/plans/`), get human sign-off before impl. See `plan` skill.
- TDD: RED-GREEN-REFACTOR — tests before code.
- Systematic debugging: 4-phase root cause before fix.
- Subagent dispatch patterns.

## License

Apache-2.0 (origin of some content, now MIT in this repo where we re-derive generically).

## Use with

Any repo that adopts code-hygiene workflow — Phase 0-2 directly map.

## Install / wiring

Not vendored here — use upstream repo `obra/superpowers` in Claude Code context, or adopt patterns via our generic skills. When our repo runs on Hermes, our `plan` skill covers same ground.

## When not to use

- If project has own planning format that conflicts — map instead of overriding.
- When single-step trivial fix — skips pre-plan per `project-discovery`.

## Link

- https://github.com/obra/superpowers
