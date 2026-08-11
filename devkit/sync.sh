#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command="${1:-help}"

case "$command" in
  doctor)
    shift || true
    "$repo_dir/doctor.sh" "$@"
    ;;
  install)
    shift || true
    "$repo_dir/install.sh" "$@"
    ;;
  auth)
    shift || true
    "$repo_dir/scripts/auth.sh" "$@"
    ;;
  bootstrap)
    shift || true
    "$repo_dir/bootstrap.sh" "$@"
    ;;
  backup)
    shift || true
    "$repo_dir/backup.sh" "$@"
    ;;
  snapshot)
    shift || true
    "$repo_dir/scripts/snapshot.sh" "$@"
    ;;
  export)
    shift || true
    "$repo_dir/scripts/export.sh" "$@"
    ;;
  mcp-doctor)
    shift || true
    "$repo_dir/mcp/doctor.sh" "$@"
    ;;
  mcp)
    shift || true
    "$repo_dir/mcp/manage.sh" "$@"
    ;;
  gstack)
    shift || true
    "$repo_dir/gstack/manage.sh" "$@"
    ;;
  guard)
    shift || true
    "$repo_dir/scripts/secret-guard.sh" "$repo_dir" "$@"
    ;;
  test)
    shift || true
    "$repo_dir/scripts/test.sh" "$@"
    ;;
  help|-h|--help)
    cat <<'HELP'
Usage: ./sync.sh <command>

Commands:
  doctor   Check required tools and local machine readiness.
  install  Install Codex and Serena settings onto this machine.
  auth     Start interactive GitHub CLI login when needed.
  bootstrap Bootstrap a new development machine with selected profiles.
  backup   Refresh the ignored host-local Codex override after sanitizing it.
  snapshot Collect a safe inventory of this development machine.
  export   Build a safe portable .tar.gz archive with checksum.
  mcp      List, enable, or diagnose opt-in portable MCP profiles.
  mcp-doctor Check dependencies declared by the portable Codex configuration.
  gstack   Install, update, or inspect the opt-in pinned Gstack integration.
  guard    Run the secret guard against this repo.
  test     Run local validation checks.
HELP
    ;;
  *)
    echo "Unknown command: $command" >&2
    echo "Run ./sync.sh help for usage." >&2
    exit 1
    ;;
esac
