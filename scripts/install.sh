#!/usr/bin/env bash
# install.sh — install code-hygiene skills into detected agent homes.
# No auto-install — requires --install <comma-list> and confirmation.
# Usage:
#   ./scripts/install.sh --list
#   ./scripts/install.sh --install upstream-hygiene,factual-integrity,...
#   ./scripts/install.sh --install all  (installs all generic core)
#   ./scripts/install.sh --agent AGENTS.md --install all  (single generic file target)

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO/skills"

detect() {
  echo "## Detected agent homes"
  for p in "$HOME/.claude/skills" "$HOME/.hermes/skills" "$HOME/.config/hermes/skills"; do
    if [ -d "$(dirname "$p")" ]; then
      echo " - $(dirname "$p") -> $p $([ -d "$p" ] && echo exists || echo will-create)"
    else
      echo " - $(dirname "$p") (not present)"
    fi
  done
  for p in ".cursor/rules" ".github" ; do
    [ -e "$p" ] && echo " - ./$p (repo-local)" || echo " - ./$p (not in repo, skip)"
  done
}

list_skills() {
  echo "## Available skills (from $SKILLS_DIR)"
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    name="$(basename "$d")"
    desc="$(head -n 15 "$d/SKILL.md" | grep -m1 'description:' | sed 's/.*description: *//' | tr -d '"' || echo)"
    echo " - $name — $desc"
  done
  echo ""
  echo "## References"
  if [ -d "$REPO/docs/references" ]; then
    ls "$REPO/docs/references" | sed 's/^/ - /'
  fi
}

install_skills() {
  local raw="$1"
  local agent="${2:-auto}"
  local list
  if [ "$raw" = "all" ]; then
    list="$(for d in "$SKILLS_DIR"/*/; do [ -f "$d/SKILL.md" ] && basename "$d"; done | tr '\n' ',' | sed 's/,$//')"
  else
    list="$raw"
  fi

  IFS=',' read -ra SKILLS <<< "$list"
  echo "## Will install skills: ${SKILLS[*]}"
  echo "## Agent target: $agent (auto = probe ~/.claude/skills + ~/.hermes/skills)"
  local targets=()
  if [ "$agent" = "auto" ]; then
    for base in "$HOME/.claude/skills" "$HOME/.hermes/skills"; do
      if [ -d "$(dirname "$base")" ] || [ -d "$base" ]; then
        targets+=("$base")
      fi
    done
    # generic fallback
    if [ ${#targets[@]} -eq 0 ]; then
      targets=("AGENTS.md")
    fi
  else
    targets=("$agent")
  fi

  echo "## Targets: ${targets[*]}"
  echo "## Preview (first file that would be written):"
  for s in "${SKILLS[@]}"; do
    src="$SKILLS_DIR/$s/SKILL.md"
    [ -f "$src" ] || { echo "  SKIP $s — not found at $src"; continue; }
    echo "  src=$src"
    for t in "${targets[@]}"; do
      if [[ "$t" == *.md ]]; then
        echo "    -> append to $t (generic AGENTS.md/copy-paste mode)"
      else
        echo "    -> $t/$s/SKILL.md"
      fi
    done
  done

  read -p "Proceed? (y/N) " -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  for s in "${SKILLS[@]}"; do
    src="$SKILLS_DIR/$s/SKILL.md"
    [ -f "$src" ] || continue
    for t in "${targets[@]}"; do
      if [[ "$t" == *.md ]]; then
        echo "## Appending $s to $t"
        cat "$src" >> "$t"
        echo -e "\n---\n" >> "$t"
      else
        dst="$t/$s/SKILL.md"
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "Installed $dst"
      fi
    done
  done
  echo "Done."
}

case "${1:-}" in
  --list|--ls) detect; echo ""; list_skills ;;
  --install) install_skills "${2:-}" "${4:-auto}" ;;
  *) echo "Usage: $0 --list | --install <comma-list|all> [--agent path]"; detect; echo ""; list_skills ;;
esac
