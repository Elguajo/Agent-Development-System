#!/usr/bin/env bash
set -euo pipefail

git_name="$(git config --global user.name || true)"
git_email="$(git config --global user.email || true)"

cat <<STEPS

Manual steps still required:

1. GitHub CLI auth:
   Bootstrap runs ./sync.sh auth automatically.
   If it failed or was skipped, rerun: ./sync.sh auth

2. Configure Git identity if missing:
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"

   Current user.name: ${git_name:-<not set>}
   Current user.email: ${git_email:-<not set>}

3. Add or import SSH keys:
   ssh-keygen -t ed25519 -C "you@example.com"
   gh ssh-key add ~/.ssh/id_ed25519.pub

4. Install any GUI apps manually if this machine needs them.

5. Restart Codex after installing Codex settings.

STEPS
