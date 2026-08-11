#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$repo_dir/sync.sh" ]]; then
  echo "restore.sh must be run from an extracted Agents DevKits archive." >&2
  exit 1
fi

echo "This restore uses the extracted archive at:"
echo "  $repo_dir"
echo
echo "It will run the same bootstrap/install flow as the Git repo version."
echo "Secrets are not included in the archive."
echo

if [[ ! -f "$repo_dir/secrets.local.env" ]]; then
  cp "$repo_dir/secrets.example.env" "$repo_dir/secrets.local.env"
  echo "Created secrets.local.env from secrets.example.env."
  echo "Edit it before continuing if you want Context7 or other local secrets installed."
fi

"$repo_dir/sync.sh" bootstrap "$@"
