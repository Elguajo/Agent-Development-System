#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host_name="$(hostname -s 2>/dev/null || hostname)"
base_config="$repo_dir/config/codex/base.toml"
host_config="$repo_dir/machines/$host_name/codex/config.toml"
profiles_dir="$repo_dir/config/mcp"
active_config="$HOME/.codex/config.toml"

usage() {
  cat <<'HELP'
Usage: ./devkit.sh mcp <command> [server...]

Commands:
  list                 List portable MCP profiles and enabled servers.
  enable <server...>   Add selected profiles to the ignored host config and install it.
  doctor               Check dependencies for the active host configuration.

Portable profiles:
  context7, memory, playwright, sequential-thinking

MCP profiles are opt-in. Credentials stay in secrets.local.env or the shell.
HELP
}

ensure_host_config() {
  if [[ -f "$host_config" ]]; then
    return
  fi

  if [[ -f "$active_config" ]]; then
    "$repo_dir/backup.sh"
  else
    mkdir -p "$(dirname "$host_config")"
    cp "$base_config" "$host_config"
    chmod 600 "$host_config"
  fi
}

validate_toml() {
  python3 - "$host_config" <<'PY'
import sys
import tomllib
from pathlib import Path

tomllib.loads(Path(sys.argv[1]).read_text())
PY
}

list_profiles() {
  local profile name state
  for profile in "$profiles_dir"/*.toml; do
    name="$(basename "$profile" .toml)"
    state="disabled"
    if [[ -f "$host_config" ]] && rg -q "^\[mcp_servers\.$name\]" "$host_config"; then
      state="enabled"
    fi
    printf '%-22s %s\n' "$name" "$state"
  done
}

enable_profiles() {
  if [[ "$#" -eq 0 ]]; then
    echo "Specify at least one MCP profile." >&2
    usage >&2
    exit 2
  fi

  ensure_host_config

  local name profile
  for name in "$@"; do
    profile="$profiles_dir/$name.toml"
    if [[ ! -f "$profile" ]]; then
      echo "Unknown portable MCP profile: $name" >&2
      echo "Run './devkit.sh mcp list' to see available profiles." >&2
      exit 2
    fi
    if rg -q "^\[mcp_servers\.$name\]" "$host_config"; then
      echo "Already enabled: $name"
      continue
    fi
    printf '\n' >> "$host_config"
    cat "$profile" >> "$host_config"
    echo "Enabled: $name"
  done

  validate_toml
  "$repo_dir/install.sh"
}

command="${1:-help}"
shift || true

case "$command" in
  list) list_profiles ;;
  enable) enable_profiles "$@" ;;
  doctor) "$repo_dir/mcp/doctor.sh" "$@" ;;
  help|-h|--help) usage ;;
  *)
    echo "Unknown MCP command: $command" >&2
    usage >&2
    exit 2
    ;;
esac
