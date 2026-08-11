#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
skills_root="$repo_root/skills"

if [[ ! -d "$skills_root" ]]; then
  echo "Missing skills directory: $skills_root" >&2
  exit 1
fi

skill_count=0
for skill_dir in "$skills_root"/*; do
  [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue
  skill_count=$((skill_count + 1))
done

if [[ "$skill_count" -eq 0 ]]; then
  echo "No valid skills found in $skills_root" >&2
  exit 1
fi

"$repo_root/scripts/install.sh" "$@"

echo "Installed $skill_count skill(s). Restart Codex or Claude Code if they were already running."
