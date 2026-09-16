#!/usr/bin/env bash
# check-hygiene.sh — dogfood self-check matching the skills this repo teaches.
#
# Usage:
#   ./scripts/check-hygiene.sh [rev]       # frontmatter + leak scan (+ commit msg if rev given)
#   ./scripts/check-hygiene.sh --selftest  # prove the leak scan can actually fail
#
# The leak scan uses grep -E only (no ripgrep PCRE dependency, no look-around):
# an earlier version used rg look-ahead, which errored out on every run and
# silently reported PASS forever. --selftest exists so that failure mode cannot
# come back unnoticed.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

# Placeholder tokens that make a path a legitimate example, not a real leak.
PLACEHOLDER_RE='example-user|example\.invalid|<[A-Za-z_-]+>|\$\{|\$[A-Za-z_]|TODO'

# A real-looking private absolute path on a line with no placeholder marker.
scan_private_refs() {
  local root="$1"
  grep -rnE '(/home|/Users|/data|C:\\Users)/[A-Za-z0-9_.-]+' "$root" 2>/dev/null \
    | grep -vE "$PLACEHOLDER_RE" || true
}

# Kernel-specific enforcement language that must not live in the generic core.
scan_kernel_terms() {
  local root="$1"
  grep -rnEi '(must|requires|always)[^.]{0,40}(checkpatch\.pl|KASAN splat|vmlinux|Fixes: [0-9a-f]{12})' \
    "$root" 2>/dev/null || true
}

selftest() {
  local tmp rc=0
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/skills/planted" "$tmp/skills/clean"
  # Planted: a real home path with no placeholder.
  printf 'See /home/realleakuser/secret-tree for the report.\n' > "$tmp/skills/planted/SKILL.md"
  # Clean: placeholder form must NOT be flagged.
  printf 'See /home/example-user/x and /data/<private> instead.\n' > "$tmp/skills/clean/SKILL.md"
  if [ -n "$(scan_private_refs "$tmp/skills/planted")" ]; then
    echo "  ok   planted leak detected"
  else
    echo "  FAIL planted leak NOT detected — scan is a no-op"; rc=1
  fi
  if [ -z "$(scan_private_refs "$tmp/skills/clean")" ]; then
    echo "  ok   placeholder text not flagged"
  else
    echo "  FAIL placeholder text wrongly flagged (false positive)"; rc=1
  fi
  rm -rf "$tmp"
  return $rc
}

TARGET="${1:-}"
echo "## check-hygiene ${TARGET:-working tree}"

if [ "$TARGET" = "--selftest" ]; then
  echo "### scan self-test (proves the leak scan can fail)"
  if selftest; then
    echo "PASS: scan detects leaks and ignores placeholders"
    echo ""; echo "check-hygiene: OK"; exit 0
  else
    echo ""; echo "check-hygiene: FAIL (scan self-test)"; exit 1
  fi
fi

fail=0

echo "### SKILL.md frontmatter"
bad=0
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  head -n 12 "$f" | grep -q "^name:" || { echo "FAIL: $f missing name:"; bad=1; fail=1; }
  head -n 12 "$f" | grep -q "^description:" || { echo "FAIL: $f missing description:"; bad=1; fail=1; }
  head -n 12 "$f" | grep -q "^license: MIT" || { echo "WARN: $f not MIT"; }
done
[ $bad -eq 0 ] && echo "PASS: frontmatter name/description present"

echo "### Private-reference scan (placeholders allowed)"
leaks="$(scan_private_refs skills docs templates scripts)"
if [ -n "$leaks" ]; then
  echo "$leaks" | head -n 20
  echo "FAIL: real-looking private absolute path without placeholder marker"
  fail=1
else
  echo "PASS: paths use placeholder form only"
fi

echo "### Generic-core terminology check"
kernel_hits="$(scan_kernel_terms skills docs/generic-principles.md)"
if [ -n "$kernel_hits" ]; then
  echo "$kernel_hits" | head -n 20
  echo "FAIL: project-specific enforcement wording in the generic core"
  fail=1
else
  echo "PASS: core wording stays project-generic"
fi

echo "### Rule ID declarations unique per skill (cross-references allowed)"
# An ID is *declared* when it appears as an anchor (<!-- GC-N -->) or a heading
# (## GC-N — / ### GC-N —). Bare mentions elsewhere are cross-references and fine.
declared_ids() {
  grep -rhoE '(<!--[[:space:]]*GC-[0-9]+|<h[0-9]>|^#+[[:space:]]+GC-[0-9]+)' "$1" 2>/dev/null \
    | grep -oE 'GC-[0-9]+' | sort -u
}
dupes=""
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  # anchor form
  ids="$(grep -oE '<!--[[:space:]]*GC-[0-9]+[[:space:]]*-->' "$f" | grep -oE 'GC-[0-9]+')"
  # heading form
  ids="$ids
$(grep -oE '^#+[[:space:]]+GC-[0-9]+' "$f" | grep -oE 'GC-[0-9]+')"
  for id in $ids; do
    [ -n "$id" ] || continue
    prev="$(grep -rlE "(<!--[[:space:]]*$id[[:space:]]*-->|^#+[[:space:]]+$id([^0-9]|$))" skills/*/SKILL.md \
      | grep -v "^$f$" | tr '\n' ' ')"
    [ -n "$prev" ] && dupes="$dupes
$id declared in $f and also in: $prev"
  done
done
dupes="$(echo "$dupes" | grep -v '^$' | sort -u)"
if [ -n "$dupes" ]; then
  echo "$dupes"
  echo "FAIL: same rule ID declared in more than one skill"
  fail=1
else
  echo "PASS: every rule ID declared once (cross-references excluded)"
fi

echo "### Contributor-note consistency (AGENTS canonical, CLAUDE shim, templates)"
note_fail=0
for f in AGENTS.md templates/AGENTS.md; do
  [ -f "$f" ] || { echo "FAIL: $f missing"; note_fail=1; continue; }
  grep -q "materially better way" "$f" || { echo "FAIL: $f missing gate (b)"; note_fail=1; }
  grep -q "important missing" "$f" || { echo "FAIL: $f missing gate (c)"; note_fail=1; }
done
for f in CLAUDE.md templates/CLAUDE.md; do
  [ -f "$f" ] || { echo "FAIL: $f missing"; note_fail=1; continue; }
  grep -q "AGENTS.md" "$f" || { echo "FAIL: $f is not a shim (does not point to AGENTS.md)"; note_fail=1; }
  n="$(wc -l < "$f")"
  [ "$n" -le 60 ] || { echo "FAIL: $f is $n lines — looks like a second copy, not a shim"; note_fail=1; }
done
if [ $note_fail -eq 0 ]; then
  echo "PASS: both AGENTS carry the 4Q gates; both CLAUDE point back and stay short"
else
  fail=1
fi

if [ -n "$TARGET" ] && [ "$TARGET" != "HEAD~0" ]; then
  echo "### Commit message classes ($TARGET)"
  msg="$(git log -1 --pretty=%B "$TARGET" 2>/dev/null || true)"
  if [ -n "$msg" ]; then
    if echo "$msg" | grep -nE '(/home|/Users|/data|C:\\Users)/[A-Za-z0-9_.-]+' | grep -vE "$PLACEHOLDER_RE"; then
      echo "FAIL: private absolute path in commit message"; fail=1
    else
      echo "PASS: commit message has no private path"
    fi
  fi
fi

echo ""
if [ $fail -ne 0 ]; then
  echo "check-hygiene: FAIL ($fail issues)"; exit 1
else
  echo "check-hygiene: OK"
fi
