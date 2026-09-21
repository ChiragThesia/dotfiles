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

# A couple of the files this repo manages are ones a machine is likely to
# already have its own real version of. `chezmoi init --apply` below would
# overwrite them on first run, with no prompt and no backup, so pre-seed the
# keep-local markers .chezmoiignore reads and let an existing file win.
# A clean machine has neither file, so nothing is seeded and it gets the lot.
KEEP_DIR="$HOME/.config/chezmoi/keep-local"

keep_existing() {
  # $1 = marker name, $2 = the file it protects
  [ -e "$2" ] || return 0
  mkdir -p "$KEEP_DIR"
  [ -e "$KEEP_DIR/$1" ] && return 0
  : > "$KEEP_DIR/$1"
  echo "install: $2 already exists -- keeping yours, not overwriting it."
  echo "         To take this repo's copy instead: rm $KEEP_DIR/$1 && chezmoi apply"
}

keep_existing claude-md "$HOME/.claude/CLAUDE.md"
keep_existing worktrunk "$HOME/.config/worktrunk/config.toml"

exec "$CHEZMOI" init --apply chiragthesia/dotfiles
