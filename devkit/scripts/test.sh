#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> shell syntax"
find "$repo_dir" -type f -name '*.sh' -not -path '*/.git/*' -print0 | xargs -0 bash -n

echo "==> secret guard"
"$repo_dir/scripts/secret-guard.sh" "$repo_dir"

echo "==> portable Codex config parses"
python3 - "$repo_dir/config/codex/base.toml" <<'PY'
import tomllib
from pathlib import Path
import sys

tomllib.loads(Path(sys.argv[1]).read_text())
print("portable config parsed")
PY

echo "==> MCP doctor"
"$repo_dir/mcp/doctor.sh"

echo "==> bootstrap dry-run defaults"
"$repo_dir/bootstrap.sh" --dry-run --yes >/tmp/agents-devkits-bootstrap-default.log
grep -q 'scripts/auth.sh' /tmp/agents-devkits-bootstrap-default.log

echo "==> bootstrap dry-run all profiles"
"$repo_dir/bootstrap.sh" --dry-run --yes --all >/tmp/agents-devkits-bootstrap-all.log

echo "==> bootstrap rejects unknown profile"
if "$repo_dir/bootstrap.sh" --dry-run --profile does-not-exist >/tmp/agents-devkits-bootstrap-invalid.log 2>&1; then
  echo "Expected unknown profile to fail" >&2
  exit 1
fi

echo "==> Gstack command is opt-in and reports an absent installation"
gstack_home="$(mktemp -d)"
if HOME="$gstack_home" "$repo_dir/sync.sh" gstack status >/tmp/agents-devkits-gstack-status.log 2>&1; then
  echo "Expected an absent Gstack installation to be reported" >&2
  exit 1
fi
grep -q 'Gstack is not installed' /tmp/agents-devkits-gstack-status.log
rmdir "$gstack_home"

echo "==> install uses portable baseline in an isolated home"
tmp_home="$(mktemp -d)"
tmp_repo=""
managed_home=""
cleanup() {
  [[ -z "$tmp_repo" ]] || rm -rf "$tmp_repo"
  [[ -z "$managed_home" ]] || rm -rf "$managed_home"
  rm -rf "$tmp_home"
}
trap cleanup EXIT
HOME="$tmp_home" "$repo_dir/install.sh" >/tmp/agents-devkits-install.log
cmp "$repo_dir/config/codex/base.toml" "$tmp_home/.codex/config.toml"
test -f "$tmp_home/.serena/serena_config.yml"

echo "==> snapshot dry run through temp repo copy"
tmp_repo="$(mktemp -d)"
cp -R "$repo_dir"/. "$tmp_repo"/
"$tmp_repo/sync.sh" snapshot >/tmp/agents-devkits-snapshot.log
test -f "$tmp_repo/snapshots/current/brew-formulae.txt"
test -f "$tmp_repo/snapshots/current/git-config.safe.txt"

echo "==> install refuses an unadopted existing configuration"
managed_home="$(mktemp -d)"
mkdir -p "$managed_home/.codex"
printf '[features]\njs_repl = true\n' > "$managed_home/.codex/config.toml"
if HOME="$managed_home" "$tmp_repo/install.sh" >/tmp/agents-devkits-install-refusal.log 2>&1; then
  echo "Expected install to require adoption for an existing config" >&2
  exit 1
fi
grep -q 'js_repl = true' "$managed_home/.codex/config.toml"

echo "==> install adopts an existing configuration"
HOME="$managed_home" "$tmp_repo/install.sh" --adopt >/tmp/agents-devkits-install-adopt.log
grep -q 'js_repl = true' "$managed_home/.codex/config.toml"

echo "==> MCP profiles are opt-in and installed into the host override"
HOME="$managed_home" "$tmp_repo/sync.sh" mcp enable playwright context7 >/tmp/agents-devkits-mcp-enable.log
grep -q '^\[mcp_servers.playwright\]' "$managed_home/.codex/config.toml"
grep -q '^\[mcp_servers.context7\]' "$managed_home/.codex/config.toml"

echo "==> export script syntax"
bash -n "$repo_dir/scripts/export.sh" "$repo_dir/restore.sh"

echo "tests passed"
