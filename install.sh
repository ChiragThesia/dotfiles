#!/usr/bin/env bash
# One-command bootstrap: curl -fsSL https://raw.githubusercontent.com/chiragthesia/dotfiles/main/install.sh | sh
#
# Installs chezmoi itself (if missing), then hands off to chezmoi init --apply,
# which does everything else (Homebrew if missing, brew bundle, herdr, Claude
# Code settings/plugins -- see run_once_* scripts in this repo).
set -euo pipefail

BIN_DIR="$HOME/.local/bin"

if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
fi

CHEZMOI="$(command -v chezmoi || echo "$BIN_DIR/chezmoi")"
exec "$CHEZMOI" init --apply chiragthesia/dotfiles
