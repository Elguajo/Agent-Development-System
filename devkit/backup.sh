#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_config="$HOME/.codex/config.toml"
host_name="$(hostname -s 2>/dev/null || hostname)"
target_config="$repo_dir/machines/$host_name/codex/config.toml"

if [[ ! -f "$source_config" ]]; then
  echo "Missing Codex config: $source_config" >&2
  exit 1
fi

staging_dir="$(mktemp -d)"
staging_config="$staging_dir/config.toml"
cleanup() {
  rm -rf "$staging_dir"
}
trap cleanup EXIT

cp "$source_config" "$staging_config"

perl -0pi -e 's/ctx7sk-[A-Za-z0-9_-]+/__CONTEXT7_API_KEY__/g' "$staging_config"
perl -0pi -e 's/gho_[A-Za-z0-9_]+/__GITHUB_TOKEN__/g' "$staging_config"
perl -0pi -e 's/ghp_[A-Za-z0-9_]+/__GITHUB_TOKEN__/g' "$staging_config"
perl -0pi -e 's/github_pat_[A-Za-z0-9_]+/__GITHUB_TOKEN__/g' "$staging_config"
HOME_PATH="$HOME" perl -0pi -e 's{\Q$ENV{HOME_PATH}\E}{__HOME__}g' "$staging_config"

"$repo_dir/scripts/secret-guard.sh" "$staging_dir"

mkdir -p "$(dirname "$target_config")"
cp "$staging_config" "$target_config"
chmod 600 "$target_config"

echo "Updated sanitized host-local Codex config at $target_config"
echo "This override is ignored by Git and is intentionally excluded from public exports."
