#!/usr/bin/env bash
# check-hygiene.sh — dogfood self-check matching skills we teach.
# Usage: ./scripts/check-hygiene.sh [HEAD]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

TARGET="${1:-HEAD}"

echo "## check-hygiene $TARGET"
fail=0

# 1. SKILL.md frontmatter valid
echo "### SKILL.md frontmatter"
bad=0
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  head -n 20 "$f" | grep -q "^name:" || { echo "FAIL: $f missing name:"; bad=1; fail=1; }
  head -n 20 "$f" | grep -q "^description:" || { echo "FAIL: $f missing description:"; bad=1; fail=1; }
  head -n 20 "$f" | grep -q "^license: MIT" || echo "WARN: $f not MIT"
done
[ $bad -eq 0 ] && echo "PASS: frontmatter name/description present"

# 2. Upstream-hygiene: no real private absolute refs in docs/skills — allow escaped examples
# We allow example tokens: example-user, example.invalid, <user>, <org>
# Fail only on bare /home/<non-example> or /data/ without example marker on same line
echo "### Upstream hygiene class check (real leaks only)"
if rg -n "^[^#]* /home/(?!example-user|\\$|\\{|<)[a-z0-9]" skills/ docs/ --hidden 2>/dev/null | grep -v "example" | head -n 20; then
  echo "FAIL: looks like real /home/ ref without example marker"
  fail=1
else
  echo "PASS: no real private absolute refs in skills/docs"
fi

# 3. Kernel-free core — allow generic references like "checkpatch-like" or "Fixes:" when marked as project-specific
# Fail only on kernel-specific enforcement language
echo "### Kernel-free core check"
if rg -U "This (code|patch|commit) (must|requires) (checkpatch|Fixes:|KASAN|kasan)" skills/ docs/generic-principles.md 2>/dev/null | head -n 20; then
  echo "FAIL: kernel-specific enforcement leaked into generic core"
  fail=1
else
  echo "PASS: core kernel-free (generic mentions allowed)"
fi

echo ""
if [ $fail -ne 0 ]; then
  echo "check-hygiene: FAIL ($fail issues)"
  exit 1
else
  echo "check-hygiene: OK"
fi
