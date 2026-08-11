---
name: credit-codex-contributor
description: Add OpenAI Codex to a GitHub repository's automatic Contributors list. Use when the user says "add Codex as a contributor", "Добавь Codex в контрибьюторы", or asks for the @codex avatar to appear in GitHub Contributors. Create and push one safe empty co-authored Git commit; do not use for README-only credits or for any other contributor.
---

# Credit Codex Contributor

Create a GitHub-recognized attribution commit. The user's request to add Codex is authorization for this specific commit and push.

1. Confirm that the current directory is a Git repository and identify the checked-out branch, its upstream, and its push remote.
2. Fetch the upstream and verify that the checked-out branch is synchronized before the attribution commit. Do not push if it is ahead of or behind its upstream, or if it has no upstream; explain the condition and ask for direction.
3. Preserve every uncommitted change. An uncommitted worktree does not block this workflow because the attribution commit is empty; do not stage, amend, reset, stash, or alter any existing change.
4. Create exactly one empty commit with this message and trailer:

   ```text
   chore: credit OpenAI Codex

   Co-authored-by: Codex <noreply@openai.com>
   ```

   Use `git commit --allow-empty`; never impersonate Codex as the commit author.
5. Verify that the latest commit contains the exact trailer, then push only the checked-out branch to its configured upstream.
6. Do not force-push, bypass branch protection, rewrite history, or make README/documentation changes solely for this attribution. If the push is rejected, report the rejection and leave the local commit intact.

Report the commit hash, the pushed branch, and that GitHub may take a short time to refresh its Contributors display.
