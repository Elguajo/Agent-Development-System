#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"

if [[ ! -d "$root" ]]; then
  echo "Secret guard target is not a directory: $root" >&2
  exit 1
fi

patterns=(
  'ctx7sk-[A-Za-z0-9_-]+'
  'gho_[A-Za-z0-9_]+'
  'ghp_[A-Za-z0-9_]+'
  'github_pat_[A-Za-z0-9_]+'
  'sk-[A-Za-z0-9_-]{20,}'
  'Bearer[[:space:]]+[A-Za-z0-9._-]+'
  'password[[:space:]]*=[[:space:]]*"[^"]+"'
  'token[[:space:]]*=[[:space:]]*"[^"]+"'
  'secret[[:space:]]*=[[:space:]]*"[^"]+"'
)

if ! command -v rg >/dev/null 2>&1; then
  echo "Secret guard requires ripgrep (rg)" >&2
  exit 1
fi

found=0
for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!.git/**' --glob '!secrets.local.env' --glob '!*.backup.*' "$pattern" "$root"; then
    found=1
  fi
done

if [[ "$found" -ne 0 ]]; then
  echo "Secret guard found possible secrets. Remove or sanitize them before committing." >&2
  exit 1
fi

echo "Secret guard passed"
