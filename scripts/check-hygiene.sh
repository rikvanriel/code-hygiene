#!/usr/bin/env bash
# check-hygiene.sh — dogfood self-check matching the skills this repo teaches.
#
# Usage:
#   ./scripts/check-hygiene.sh [rev]       # run every gate (adds commit-msg gate if rev given)
#   ./scripts/check-hygiene.sh --selftest  # prove every gate can actually FAIL
#
# Design note: each gate is a function returning 0 (pass) or 1 (fail) and printing
# its own hits. --selftest copies the repo to a temp tree, plants one violation per
# gate, and asserts the real script exits non-zero for each. A gate that has never
# been observed failing is an unverified gate: an earlier version of the leak scan
# used a regex look-around the engine did not support, errored out on every run, and
# reported PASS forever.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Placeholder tokens that make a path a legitimate example rather than a leak.
PLACEHOLDER_RE='example-user|example\.invalid|<[A-Za-z_-]+>|\$\{|\$[A-Za-z_]|TODO'
# Absolute local paths require a boundary, while paths after a public URL host
# must not be mistaken for local files.
# Keep the Windows form separate because its drive prefix is not slash-bound.
PATH_RE='(^|[^[:alnum:]_.:/~-])/([A-Za-z0-9_.-]+/)+[A-Za-z0-9_.-]+|(^|[^[:alnum:]_.:/~-])[A-Za-z0-9]:\\\\[^[:space:]`)>]+'

check_frontmatter() {           # $1 = root
  local f bad=0
  for f in "$1"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    head -n 12 "$f" | grep -q "^name:"        || { echo "FAIL: $f missing name:"; bad=1; }
    head -n 12 "$f" | grep -q "^description:" || { echo "FAIL: $f missing description:"; bad=1; }
    head -n 12 "$f" | grep -q "^license: MIT" || echo "WARN: $f not MIT"
  done
  return $bad
}

check_private_refs() {          # $1 = root
  local hits
  hits="$(scan_private_refs "$1/skills" "$1/docs" "$1/templates" "$1/scripts")"
  [ -n "$hits" ] || return 0
  echo "$hits" | head -n 20
  echo "FAIL: real-looking private absolute path without placeholder marker"
  return 1
}

scan_private_refs() {           # $1 = dir or file list
  # Canonical system paths in shell examples (`/dev/null`, `/usr/bin`, ...)
  # are not private checkout paths. Keep the filter here rather than baking
  # machine-specific roots into PATH_RE.
  grep -rnE "$PATH_RE" "$@" 2>/dev/null \
    | grep -vE '/(bin|dev|etc|lib|proc|run|sbin|sys|usr|var)/' \
    | grep -vE "$PLACEHOLDER_RE"
}

check_generic_wording() {       # $1 = root
  local hits
  hits="$1/skills $1/docs/generic-principles.md"
  local found
  found="$(scan_kernel_terms $hits)"
  [ -n "$found" ] || return 0
  echo "$found" | head -n 20
  echo "FAIL: project-specific enforcement wording in the generic core"
  return 1
}

scan_kernel_terms() {           # $@ = paths
  grep -rnEi '(must|requires|always)[^.]{0,40}(checkpatch\.pl|KASAN splat|vmlinux|Fixes: [0-9a-f]{12})' \
    "$@" 2>/dev/null
}

declared_ids() {                # $1 = file
  { grep -oE '<!--[[:space:]]*GC-[0-9]+[[:space:]]*-->' "$1" | grep -oE 'GC-[0-9]+'
    grep -oE '^#+[[:space:]]+GC-[0-9]+' "$1" | grep -oE 'GC-[0-9]+'
  } 2>/dev/null | sort -u
}

check_id_declarations() {       # $1 = root
  local f id prev out=""
  for f in "$1"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    for id in $(declared_ids "$f"); do
      prev="$(grep -rlE "(<!--[[:space:]]*$id[[:space:]]*-->|^#+[[:space:]]+$id([^0-9]|\$))" \
        "$1"/skills/*/SKILL.md 2>/dev/null | grep -v "^$f\$" | tr '\n' ' ')"
      [ -n "$prev" ] && out="$out$id declared in $(basename "$(dirname "$f")") and also in: $(echo $prev | sed "s|$1/skills/||g; s|/SKILL.md||g")
"
    done
  done
  out="$(echo "$out" | grep -v '^$' | sort -u)"
  [ -n "$out" ] || return 0
  echo "$out"
  echo "FAIL: same rule ID declared in more than one skill"
  return 1
}

check_contributor_notes() {     # $1 = root
  local rc=0 f n
  for f in "$1/AGENTS.md"; do
    [ -f "$f" ] || { echo "FAIL: $f missing"; rc=1; continue; }
    grep -q "materially better way" "$f" || { echo "FAIL: $f missing gate (b)"; rc=1; }
    grep -q "important missing"     "$f" || { echo "FAIL: $f missing gate (c)"; rc=1; }
  done
  if [ -x "$1/scripts/build-template.py" ]; then
    ( cd "$1" && ./scripts/build-template.py --profile full 2>/dev/null | grep -q "important missing" ) \
      || { echo "FAIL: build-template.py output lost a gate - fix the generator"; rc=1; }
    ( cd "$1" && ./scripts/build-template.py --profile full 2>/dev/null | grep -q "materially better way" ) \
      || { echo "FAIL: build-template.py output lost a gate - fix the generator"; rc=1; }
  fi
  for f in "$1/CLAUDE.md"; do
    [ -f "$f" ] || { echo "FAIL: $f missing"; rc=1; continue; }
    grep -q "AGENTS.md" "$f" || { echo "FAIL: $f does not point to AGENTS.md"; rc=1; }
    n="$(wc -l < "$f")"
    [ "$n" -le 60 ] || { echo "FAIL: $f is $n lines — a second copy, not a shim"; rc=1; }
  done
  return $rc
}

check_no_budget_claims() {      # $1 = root
  local hits
  hits="$(cd "$1" && grep -nE '([0-9]+[[:space:]]*w[[:space:]]*~[[:space:]]*[0-9]+|[0-9]+(\.[0-9]+)?k[[:space:]]*tok|[0-9]+[[:space:]]*words?[[:space:]]*~)' \
    README.md AGENTS.md CONTRIBUTING.md 2>/dev/null | grep -vE 'phases\.py' || true)"
  [ -n "$hits" ] || return 0
  echo "$hits"
  echo "FAIL: entry doc states a load budget — read it from phases.py instead"
  return 1
}

check_commit_message() {        # $1 = rev
  local msg
  msg="$(git -C "$REPO" log -1 --pretty=%B "$1" 2>/dev/null || true)"
  [ -n "$msg" ] || return 0
  local hits
  hits="$(echo "$msg" | grep -nE "$PATH_RE" | grep -vE "$PLACEHOLDER_RE")"
  [ -n "$hits" ] || return 0
  echo "$hits"
  echo "FAIL: private absolute path in commit message"
  return 1
}

# --- self-test: copy the repo, plant one violation per gate, assert a real FAIL ---

selftest() {
  local tmp rc=0 base
  tmp="$(mktemp -d)"
  base="$tmp/repo"

  fresh() {                       # fresh copy of the repo without VCS metadata
    rm -rf "$base"; mkdir -p "$base"
    cp -r "$REPO/." "$base/"
    rm -rf "$base/.git"
  }
  runs_fail() {                   # $1 = label; asserts the script exits non-zero
    if (cd "$base" && bash scripts/check-hygiene.sh >/dev/null 2>&1); then
      echo "  FAIL planted $1 was NOT detected"; rc=1
    else
      echo "  ok   planted $1 detected"
    fi
  }

  fresh
  if (cd "$base" && bash scripts/check-hygiene.sh >/dev/null 2>&1); then
    echo "  ok   clean copy passes"
  else
    echo "  FAIL clean copy does not pass — gates are over-strict"; rc=1
  fi

  fresh
  printf '\nSee /private/realleakuser/secret-tree for the report.\n' >> "$base/skills/llm-tells/SKILL.md"
  runs_fail "private path"

  fresh
  printf '\nSee https://example.org/docs/reference for public documentation.\n' >> "$base/skills/llm-tells/SKILL.md"
  if (cd "$base" && bash scripts/check-hygiene.sh >/dev/null 2>&1); then
    echo "  ok   URL paths not flagged as local files"
  else
    echo "  FAIL URL path wrongly flagged"; rc=1
  fi

  fresh
  printf '\n### GC-10 — planted duplicate\n\ntext\n' >> "$base/skills/comment-quality/SKILL.md"
  runs_fail "duplicate rule ID"

  fresh
  printf '\nFull load is 8901w ~15158 tok.\n' >> "$base/README.md"
  runs_fail "hardcoded load budget"

  fresh
  printf 'no pointer to the canonical file here\n' > "$base/CLAUDE.md"
  runs_fail "broken CLAUDE shim"

  fresh
  printf '\nSTALE COPY\n' >> "$base/skills/catalog/references/index.md"
  runs_fail "stale skill-local reference"

  fresh
  printf 'See /home/example-user/x and /data/<private> and TODO later.\n' >> "$base/skills/llm-tells/SKILL.md"
  if (cd "$base" && bash scripts/check-hygiene.sh >/dev/null 2>&1); then
    echo "  ok   placeholders not flagged (no false positive)"
  else
    echo "  FAIL placeholder text wrongly flagged"; rc=1
  fi

  rm -rf "$tmp"
  return $rc
}

if [ "${1:-}" = "--selftest" ]; then
  echo "## check-hygiene --selftest"
  echo "### every gate must be able to fail"
  if selftest; then
    echo "PASS: each gate fails on a planted violation and passes a clean tree"
    echo ""; echo "check-hygiene: OK"; exit 0
  else
    echo ""; echo "check-hygiene: FAIL (self-test)"; exit 1
  fi
fi

TARGET="${1:-}"
echo "## check-hygiene ${TARGET:-working tree}"
cd "$REPO"
fail=0

echo "### SKILL.md frontmatter"
check_frontmatter "$REPO" && echo "PASS: frontmatter name/description present" || fail=1

echo "### Private-reference scan (placeholders allowed)"
check_private_refs "$REPO" && echo "PASS: paths use placeholder form only" || fail=1

echo "### Generic-core terminology check"
check_generic_wording "$REPO" && echo "PASS: core wording stays project-generic" || fail=1

echo "### Rule ID declarations unique per skill (cross-references allowed)"
check_id_declarations "$REPO" && echo "PASS: every rule ID declared once (cross-references excluded)" || fail=1

echo "### Contributor-note consistency (AGENTS canonical, CLAUDE shim, generator fresh)"
check_contributor_notes "$REPO" && echo "PASS: AGENTS carries the 4Q gates; CLAUDE points back and stays short; generator output carries the gates" || fail=1

echo "### No hardcoded load budgets in entry docs (phases.py is the source)"
check_no_budget_claims "$REPO" && echo "PASS: budgets come from phases.py, entry docs carry none" || fail=1

echo "### Skill-local references fresh (generated from docs/)"
"$REPO/scripts/sync-skill-refs.py" --check && echo "PASS: skill references/ match docs/" || fail=1

if [ -n "$TARGET" ]; then
  echo "### Commit message classes ($TARGET)"
  check_commit_message "$TARGET" && echo "PASS: commit message has no private path" || fail=1
fi

echo ""
if [ "$fail" -ne 0 ]; then
  echo "check-hygiene: FAIL"; exit 1
else
  echo "check-hygiene: OK"
fi
