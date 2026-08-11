#!/usr/bin/env bash
set -euo pipefail

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global core.editor "code --wait"
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictstyle zdiff3

touch "$HOME/.zshrc"

if ! grep -q 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# Prompt\n' >> "$HOME/.zshrc"
  printf 'eval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
fi

if ! grep -q 'zoxide init zsh' "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# Smarter cd\n' >> "$HOME/.zshrc"
  printf 'eval "$(zoxide init zsh)"\n' >> "$HOME/.zshrc"
fi

if ! grep -q 'direnv hook zsh' "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# Per-project env\n' >> "$HOME/.zshrc"
  printf 'eval "$(direnv hook zsh)"\n' >> "$HOME/.zshrc"
fi
