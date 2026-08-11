#!/usr/bin/env bash
set -euo pipefail

adopt_existing=false

case "${1:-}" in
  "") ;;
  --adopt) adopt_existing=true ;;
  *)
    echo "Usage: $0 [--adopt]" >&2
    exit 2
    ;;
esac

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source_root="$repo_root/skills"
backup_root="${HOME}/.agent-skills-backups/$(date +%Y%m%d-%H%M%S)"

for target_root in "${HOME}/.codex/skills" "${HOME}/.claude/skills"; do
  runtime="$(basename "$(dirname "$target_root")")"
  mkdir -p "$target_root"

  for source_skill in "$source_root"/*; do
    [[ -d "$source_skill" && -f "$source_skill/SKILL.md" ]] || continue

    skill_name="$(basename "$source_skill")"
    target_skill="$target_root/$skill_name"

    if [[ -L "$target_skill" && "$(readlink "$target_skill")" == "$source_skill" ]]; then
      echo "Already linked: $runtime/$skill_name"
      continue
    fi

    if [[ -e "$target_skill" || -L "$target_skill" ]]; then
      if [[ "$adopt_existing" != true ]]; then
        echo "Skipped existing skill: $target_skill (run with --adopt to replace it safely)" >&2
        continue
      fi

      backup_skill="$backup_root/$runtime/$skill_name"
      mkdir -p "$(dirname "$backup_skill")"
      mv "$target_skill" "$backup_skill"
      echo "Backed up: $target_skill -> $backup_skill"
    fi

    ln -s "$source_skill" "$target_skill"
    echo "Linked: $runtime/$skill_name"
  done
done
