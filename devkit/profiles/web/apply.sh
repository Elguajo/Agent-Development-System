#!/usr/bin/env bash
set -euo pipefail

if command -v corepack >/dev/null 2>&1; then
  corepack enable
  corepack prepare pnpm@latest --activate
else
  echo "corepack is not available; install Node.js first." >&2
  exit 1
fi
