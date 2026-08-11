#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required for GitHub auth." >&2
  echo "Install it with: brew install gh" >&2
  exit 1
fi

if gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is already authenticated."
  gh auth status
  exit 0
fi

echo "GitHub CLI is not authenticated."
echo "Starting interactive GitHub login. Follow the prompts in this terminal/browser."

if [[ ! -t 0 ]]; then
  echo "Cannot start interactive login because stdin is not a TTY." >&2
  echo "Run manually: gh auth login --hostname github.com --git-protocol https --web" >&2
  exit 1
fi

gh auth login --hostname github.com --git-protocol https --web

echo "Verifying GitHub auth..."
gh auth status
