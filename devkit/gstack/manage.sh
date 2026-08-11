#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$repo_dir/config/external-tools/gstack.conf"
install_dir="$HOME/.gstack/repos/gstack"
command="${1:-help}"

usage() {
  cat <<'HELP'
Usage: ./devkit.sh gstack <command>

Commands:
  install  Install the pinned Gstack revision for Codex.
  update   Move an existing Gstack installation to this DevKit's pinned revision.
  status   Show the installed and pinned Gstack revisions.

Gstack is installed separately at ~/.gstack/repos/gstack. Its Codex skills are
registered under ~/.codex/skills with gstack-prefixed names. Neither command
enables Gstack's optional hooks or automatic updates.
HELP
}

read_config_value() {
  local key="$1"
  sed -n "s/^${key}=//p" "$config_file" | tail -n 1
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    return 1
  fi
}

load_config() {
  if [[ ! -f "$config_file" ]]; then
    echo "Missing Gstack configuration: $config_file" >&2
    exit 1
  fi

  gstack_remote="$(read_config_value remote)"
  gstack_revision="$(read_config_value revision)"

  if [[ ! "$gstack_remote" =~ ^https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+\.git$ ]]; then
    echo "Invalid Gstack remote in $config_file" >&2
    exit 1
  fi

  if [[ ! "$gstack_revision" =~ ^[0-9a-f]{40}$ ]]; then
    echo "Invalid Gstack revision in $config_file; expected a full Git commit SHA." >&2
    exit 1
  fi
}

ensure_managed_checkout() {
  if [[ -e "$install_dir" && ! -d "$install_dir/.git" ]]; then
    echo "Refusing to use $install_dir: it is not a Gstack Git checkout managed by DevKit." >&2
    exit 1
  fi

  if [[ -d "$install_dir/.git" ]]; then
    local existing_remote
    existing_remote="$(git -C "$install_dir" remote get-url origin 2>/dev/null || true)"
    if [[ "$existing_remote" != "$gstack_remote" ]]; then
      echo "Refusing to use $install_dir: origin is $existing_remote, expected $gstack_remote." >&2
      exit 1
    fi
    return
  fi

  mkdir -p "$(dirname "$install_dir")"
  git init --quiet "$install_dir"
  git -C "$install_dir" remote add origin "$gstack_remote"
}

checkout_pinned_revision() {
  if ! git -C "$install_dir" diff --quiet || ! git -C "$install_dir" diff --cached --quiet; then
    echo "Refusing to update Gstack because $install_dir has tracked local changes." >&2
    echo "Commit, discard, or move those changes before running this command again." >&2
    exit 1
  fi

  git -C "$install_dir" fetch --depth 1 origin "$gstack_revision"
  git -C "$install_dir" checkout --detach --quiet FETCH_HEAD

  local installed_revision
  installed_revision="$(git -C "$install_dir" rev-parse HEAD)"
  if [[ "$installed_revision" != "$gstack_revision" ]]; then
    echo "Gstack checkout verification failed: expected $gstack_revision, got $installed_revision." >&2
    exit 1
  fi
}

run_upstream_setup() {
  if [[ ! -x "$install_dir/setup" ]]; then
    echo "Pinned Gstack checkout has no executable setup script: $install_dir/setup" >&2
    exit 1
  fi

  require_command bun

  # Gstack's coreutils installation and Claude hooks are optional. Keep both
  # outside this opt-in DevKit integration so the command has a narrow scope.
  GSTACK_SKIP_COREUTILS=1 \
    GSTACK_PLAN_TUNE_HOOKS=no \
    "$install_dir/setup" --host codex --prefix --no-plan-tune-hooks
}

show_status() {
  echo "Pinned Gstack revision: $gstack_revision"
  echo "Installation path: $install_dir"

  if [[ ! -d "$install_dir/.git" ]]; then
    echo "Gstack is not installed. Run './devkit.sh gstack install'."
    return 1
  fi

  local installed_revision
  installed_revision="$(git -C "$install_dir" rev-parse HEAD 2>/dev/null || true)"
  if [[ -z "$installed_revision" ]]; then
    echo "Gstack checkout is invalid; run './devkit.sh gstack update'." >&2
    return 1
  fi

  echo "Installed Gstack revision: $installed_revision"
  if [[ "$installed_revision" == "$gstack_revision" ]]; then
    echo "Revision status: pinned revision installed"
  else
    echo "Revision status: differs from this DevKit pin; run './devkit.sh gstack update'."
    return 1
  fi

  if [[ -f "$HOME/.codex/skills/gstack/SKILL.md" ]]; then
    echo "Codex registration: present"
  else
    echo "Codex registration: missing; run './devkit.sh gstack install'."
    return 1
  fi
}

load_config

case "$command" in
  install)
    require_command git
    ensure_managed_checkout
    checkout_pinned_revision
    run_upstream_setup
    show_status
    ;;
  update)
    require_command git
    if [[ ! -d "$install_dir/.git" ]]; then
      echo "Gstack is not installed. Run './devkit.sh gstack install' first." >&2
      exit 1
    fi
    ensure_managed_checkout
    checkout_pinned_revision
    run_upstream_setup
    show_status
    ;;
  status)
    require_command git
    show_status
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown Gstack command: $command" >&2
    usage >&2
    exit 1
    ;;
esac
