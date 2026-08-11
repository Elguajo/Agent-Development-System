#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
host_name="$(hostname -s 2>/dev/null || hostname)"
base_config="$repo_dir/config/codex/base.toml"
machine_config="$repo_dir/machines/$host_name/codex/config.toml"
source_config="$base_config"
source_serena_config="$repo_dir/serena/serena_config.yml"
target_dir="$HOME/.codex"
target_config="$target_dir/config.toml"
serena_target_dir="$HOME/.serena"
serena_target_config="$serena_target_dir/serena_config.yml"
adopt_existing=false

case "${1:-}" in
  "") ;;
  --adopt) adopt_existing=true ;;
  *)
    echo "Usage: $0 [--adopt]" >&2
    exit 2
    ;;
esac

if [[ -f "$repo_dir/secrets.local.env" ]]; then
  # shellcheck disable=SC1091
  source "$repo_dir/secrets.local.env"
fi

if [[ -f "$machine_config" ]]; then
  source_config="$machine_config"
  echo "Using machine-specific Codex config: $machine_config"
elif [[ -f "$target_config" && "$adopt_existing" == true ]]; then
  "$repo_dir/backup.sh"
  source_config="$machine_config"
  echo "Adopted existing Codex config into ignored host-local override: $machine_config"
elif [[ -f "$target_config" ]]; then
  echo "Refusing to replace existing $target_config without a host-local override." >&2
  echo "Run '$repo_dir/backup.sh' first, or rerun with --adopt." >&2
  exit 1
fi

if [[ ! -f "$source_config" ]]; then
  echo "Missing source config: $source_config" >&2
  exit 1
fi

mkdir -p "$target_dir"

if [[ -f "$target_config" ]]; then
  backup="$target_config.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$target_config" "$backup"
  echo "Backed up existing config to $backup"
fi

tmp_config="$(mktemp)"
cp "$source_config" "$tmp_config"

if [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
  perl -0pi -e 's/__CONTEXT7_API_KEY__/$ENV{CONTEXT7_API_KEY}/g' "$tmp_config"
fi

perl -0pi -e 's{__HOME__}{$ENV{HOME}}g' "$tmp_config"

mv "$tmp_config" "$target_config"
chmod 600 "$target_config"

echo "Installed Codex config to $target_config"

if [[ -f "$source_serena_config" ]]; then
  mkdir -p "$serena_target_dir"

  if [[ -f "$serena_target_config" ]]; then
    backup="$serena_target_config.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$serena_target_config" "$backup"
    echo "Backed up existing Serena config to $backup"

    if grep -q '^web_dashboard:' "$serena_target_config"; then
      perl -0pi -e 's/^web_dashboard:.*$/web_dashboard: true/m' "$serena_target_config"
    else
      printf "\nweb_dashboard: true\n" >> "$serena_target_config"
    fi

    if grep -q '^web_dashboard_open_on_launch:' "$serena_target_config"; then
      perl -0pi -e 's/^web_dashboard_open_on_launch:.*$/web_dashboard_open_on_launch: false/m' "$serena_target_config"
    else
      printf "web_dashboard_open_on_launch: false\n" >> "$serena_target_config"
    fi

    chmod 600 "$serena_target_config"
    echo "Patched Serena dashboard settings in $serena_target_config"
  else
    cp "$source_serena_config" "$serena_target_config"
    chmod 600 "$serena_target_config"
    echo "Installed Serena config to $serena_target_config"
  fi
fi
