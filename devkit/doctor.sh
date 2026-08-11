#!/usr/bin/env bash
set -euo pipefail

failures=0

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf "ok   %s: %s\n" "$name" "$(command -v "$name")"
  else
    printf "miss %s\n" "$name"
    failures=$((failures + 1))
  fi
}

check_command git
check_command gh
check_command node
check_command npm
check_command npx
check_command rg
check_command uvx

if command -v brew >/dev/null 2>&1; then
  printf "ok   brew: %s\n" "$(command -v brew)"
else
  echo "warn brew is not installed; Brewfile cannot be applied automatically"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    echo "ok   gh auth"
  else
    echo "miss gh auth"
    failures=$((failures + 1))
  fi
fi

if [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
  echo "ok   CONTEXT7_API_KEY"
else
  echo "warn CONTEXT7_API_KEY is not set; install.sh will keep the placeholder"
fi

if [[ -d "/Applications/Codex.app" ]]; then
  echo "ok   Codex.app"
else
  echo "warn /Applications/Codex.app is missing"
fi

if [[ -x "/Applications/Codex.app/Contents/Resources/codex" ]]; then
  echo "ok   bundled Codex CLI"
else
  echo "warn bundled Codex CLI path is missing"
fi

if [[ -x "$HOME/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient" ]]; then
  echo "ok   Codex Computer Use notifier"
else
  echo "warn Codex Computer Use notifier path is missing"
fi

if [[ -f "$HOME/.codex/config.toml" ]]; then
  if rg -n "__CONTEXT7_API_KEY__|__HOME__" "$HOME/.codex/config.toml" >/dev/null 2>&1; then
    echo "warn installed Codex config still contains placeholders"
  else
    echo "ok   installed Codex config has no known placeholders"
  fi
else
  echo "warn $HOME/.codex/config.toml is not installed yet"
fi

"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/mcp/doctor.sh"

if [[ "$failures" -gt 0 ]]; then
  echo "doctor found $failures missing requirement(s)"
  exit 1
fi

echo "doctor passed"
