#!/usr/bin/env bash
set -euo pipefail

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.screencapture location -string "$HOME/Desktop"

killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
