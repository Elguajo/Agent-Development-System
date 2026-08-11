#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host_name="$(hostname -s 2>/dev/null || hostname)"
default_config="$repo_dir/config/codex/base.toml"
host_config="$repo_dir/machines/$host_name/codex/config.toml"
[[ -f "$host_config" ]] && default_config="$host_config"
config_file="${CODEX_CONFIG_FILE:-$default_config}"
failures=0

ok() {
  printf "ok   %s\n" "$1"
}

warn() {
  printf "warn %s\n" "$1"
}

miss() {
  printf "miss %s\n" "$1"
  failures=$((failures + 1))
}

has_config() {
  local server="$1"
  rg -q "^\[mcp_servers\\.$server\]" "$config_file"
}

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    ok "$command_name: $(command -v "$command_name")"
  else
    miss "$command_name command"
  fi
}

check_path() {
  local label="$1"
  local path="$2"

  path="${path/__HOME__/$HOME}"

  if [[ -e "$path" ]]; then
    ok "$label: $path"
  else
    warn "$label missing: $path"
  fi
}

check_executable() {
  local label="$1"
  local path="$2"

  path="${path/__HOME__/$HOME}"

  if [[ -x "$path" ]]; then
    ok "$label: $path"
  else
    warn "$label missing or not executable: $path"
  fi
}

if [[ ! -f "$config_file" ]]; then
  miss "Codex config not found: $config_file"
  exit 1
fi

echo "MCP doctor source: $config_file"

needs_npx=false
for server in sequential-thinking duckduckgo-search context7 playwright memory shadcn; do
  if has_config "$server"; then
    needs_npx=true
  fi
done

if [[ "$needs_npx" == true ]]; then
  check_command npx
fi

if has_config serena; then
  check_command uvx
fi

if has_config context7; then
  if rg -q '__CONTEXT7_API_KEY__' "$config_file"; then
    warn "context7 key is a placeholder in tracked config; install.sh replaces it when CONTEXT7_API_KEY is set"
  elif [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
    ok "CONTEXT7_API_KEY environment variable is set"
  else
    warn "CONTEXT7_API_KEY is not set in this shell"
  fi
fi

if has_config chrome_devtools; then
  warn "chrome_devtools expects an external MCP endpoint at http://localhost:3000/mcp"
fi

if has_config pencil; then
  check_executable "Pencil MCP server" "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64"
fi

if has_config node_repl; then
  check_executable "Codex node_repl" "/Applications/Codex.app/Contents/Resources/cua_node/bin/node_repl"
  check_executable "Codex bundled node" "/Applications/Codex.app/Contents/Resources/cua_node/bin/node"
  check_executable "Codex CLI" "/Applications/Codex.app/Contents/Resources/codex"
  check_path "Codex home" "__HOME__/.codex"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "MCP doctor found $failures missing requirement(s)"
  exit 1
fi

echo "MCP doctor passed"
