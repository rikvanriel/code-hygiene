---
name: evidence-discipline
description: "Use when measuring, benchmarking, or validating anything — proves the instrument, the sample, and the artifact."
version: 1.0.0
author: code-hygiene contributors
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [measurement, benchmark, metric, evidence, validation]
    related_skills: [factual-integrity, self-review-gate, pre-commit-check, systematic-debugging]
---

# Evidence Discipline

Capability: turns a number into a defensible one — the instrument is validated, the sample is representative, the conditions are stated, and the artifact you deliver is the artifact you verified. A number that fails any of these is not evidence, it is an impression.

Companion to `factual-integrity`: that skill forbids inventing a value; this one says what makes a measured value trustworthy enough to report.

## Trigger

Any time you measure, benchmark, profile, sample, or compare: performance work, tuning a threshold, validating a fix, reporting a metric in a changelog or PR description.

## Rules

### GC-60 — Validate the instrument before trusting its numbers

Calibrate the metric against a signal whose ground truth you control (a known input, a synthetic case with a known answer, two independent measurements of one quantity). An unvalidated metric manufactures confident wrong answers: it can be wrong in sign, scale, or ordering and still look plausible. Say in the report how the instrument was validated; if it was not, say that too.

### GC-61 — A metric must be able to fail, and you must say where

Before running a measurement, state the value at which the result must FAIL and the value at which it must PASS. Then check that it actually discriminates. A metric that has never been observed failing is unverified. A metric that responds smoothly and monotonically to a parameter, with no optimum or knee, is usually measuring a side effect of the change rather than its effect.

### GC-62 — One reading is an anecdote

Re-measure the same configuration across several samples or windows before making any claim at that granularity, and report the spread. A single reading of a noisy metric is not a result; re-running the same configuration has repeatedly produced different values. Quote the number of samples with the number.

### GC-63 — Never average over a heterogeneous population

Stratify: report per class, per regime, per input shape, per cache state. One global average hides the case that matters (the contended run, the slow input class, the cold cache) and is the number that will be quoted back wrongly. If a stratum is too small to report, say so rather than pooling it.

### GC-64 — Compare only under identical configuration

A value measured under one configuration cannot be compared with one measured under another — the difference you report would be the configuration, not the change. Hold every other condition fixed, change exactly one factor per arm, and clear the state carried between arms (warm cache, loaded index, retained cgroup, previous run's data). If two factors moved, report the comparison as inconclusive rather than attributing the delta to one of them. Verify a result under one environment before carrying it to another: a number does not transfer across a model, host, or parameter change.

### GC-65 — State every number's conditions, units, origin, and window

A number means nothing without its units, its reference origin (what zero is, which end a value measures from) and the window or workload it came from. A fraction with no stated denominator, a percentage with no base, and a latency with no percentile are all unreportable. If the value comes from a sampled or animated signal, say what was sampled and over what extent — a property that must hold across a whole artifact is verified at points spread across it, not at one convenient slice.

### GC-66 — A truncated or interrupted run is not a measurement

If a run was killed, timed out, or its output clipped, its result is a lower bound at best and must not be reported as a value. Check the run completed by its own completion signal, not by the process exiting. An interrupted measurement is missing data: report it as missing, do not interpolate.

### GC-67 — Validate against an expected band; refuse to persist a weak value

Check a measured value against the range it could plausibly take. An out-of-band reading is an error to investigate, not a result to record — a value outside the physical or logical range usually means the instrument, the units, or the parsing is wrong. If the value cannot be established to the acceptance threshold, do not persist it: store nothing (or a TODO) rather than a weak number that later reads as fact.

### GC-68 — Verify the artifact you actually deliver

Superseded runs keep writing into the same output, and a corrected artifact lands beside the broken one it replaced, so "the file I sent" is a claim to verify, not to assume: hash or otherwise identify the delivered artifact and check it is the one you measured. After fixing an upstream step, re-validate every downstream stage instead of assuming it still holds — a stage that was correct against the old input is unverified against the new one.

### GC-69 — Put a no-change control in every comparison

A run that changes nothing shows what the reading looks like when nothing is wrong. Without it you cannot tell your effect from the metric's own noise or drift, and a comparison can produce a confident delta from noise alone. If the control moves, the metric is broken and every reading from it is noise.

### GC-70 — Instrument rather than guess

When a component is opaque, make it observable — log its real input, output and environment — instead of reasoning about what it probably did. Prove a path end-to-end with a known input (a value whose correct result you know) before forming a theory about it, and keep that probe as a regression test: it separates "the path does what I asked" from "the path does something else", which no amount of reading the code settles.

### GC-71 — Keep the evidence bounded and durable

Never pull an unbounded output into your working context: filter to counts, ranges, and the anomalous tail before reading. Write findings to durable storage as they are produced — intermediate results, probe outputs and the numbers behind a claim — because the context is not a store, and a claim whose evidence existed only in a context that has since been compressed is unverifiable. Each result should be persisted when produced, not batched at the end, and a re-run should skip units already completed.

### GC-72 — Model-produced evidence is a draft until verified

When a model (or a pipeline containing one) produces the evidence, verify it claim by claim against the primary source, re-derive any list it produced by querying the data, and set an explicit abort threshold for when its output is not good enough to use. Keep the gathering step deterministic and let the model only summarize. A list of "everything that X" must come from a query plus its count, never from a model's or your own remembered subset. Record the dead ends as you go: a ruled-out avenue with where it was confirmed is the most valuable note in the report, and it is lost if it is only batched at the end.

## Verification

```bash
# Does every reported number carry conditions, units and a sample size?
git log -1 --pretty=%B | grep -nE "[0-9]+(ms|%|MB/s|ops/s)" || echo "no numbers to justify"
# Was the delivered artifact the one measured? (compare identity, not timestamps)
sha256sum out/*.bin 2>/dev/null | head -n 5
# Was the run complete, or truncated? (completion marker, not process exit)
grep -c "DONE" run.log 2>/dev/null || echo "no completion marker -> report as missing"
```

## Anti-patterns

| Bad | Good |
|-----|------|
| "Cutoff 2 Hz is better" from one run | "Cutoff 0.5 Hz: 8.3 ± 0.4 over 6 windows; 3.18 Hz: 8.6 ± 0.5 — same plateau, chose lower" |
| "Average latency improved 12%" | Per-class table; the contended class reported separately |
| Number quoted from an earlier configuration | Re-measured on the current configuration, conditions stated |
| Comparison with two variables changed | One factor per arm, other conditions stated as held |
| "Too noisy to tell" from a single reading | Repeat, report spread, or report the comparison as inconclusive |
| Value from a run killed by timeout | Reported as missing, with the timeout named |

## Related

- `factual-integrity` GC-01..GC-09 — never invent a value; this skill covers values you did measure.
- `pre-commit-check` — gates before a push, including whether claims have evidence behind them.
- `self-review-gate` — Gate 1 (a) asks for the failure mode; here asks whether the number could be wrong.
- `systematic-debugging` — reproduce and verify a fix; the known-input probe lives there too.
