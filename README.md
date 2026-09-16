# dotfiles

Personal herdr + Ghostty + nvim terminal workflow, managed with [chezmoi](https://chezmoi.io).
macOS only — Ghostty.app, Homebrew, and macOS's Option-key remapping are load-bearing
throughout this. Nothing here has been tried on Linux/Windows.

## Install

```bash
brew install chezmoi
chezmoi init --apply chiragthesia/dotfiles
```

That installs everything brew-installable (Ghostty, worktrunk, zoxide, fzf, fd, eza,
bat, lazygit, jq, bun), then herdr itself (not on Homebrew — its own installer),
wires herdr's worktrunk plugin, merges a curated set of Claude Code settings, and
installs the `caveman` and `claude-hud` Claude Code plugins fresh.

## Manual steps after the first apply

- **Reload or restart Ghostty once.** A handful of `keybind = ...=unbind` lines and
  the theme only take effect on a running Ghostty process after it re-reads its
  config (`Cmd+Shift+,` inside it, or quit and reopen).
- **Launch `nvim` once and wait.** lazy.nvim bootstraps itself and Mason installs
  language servers on first real launch — this can take a minute or two. Don't try
  to script this; a headless pre-warm attempt can leave Mason mid-install (hit this
  exact failure once while building this setup).
- Run `herdr config check` to confirm the config parsed; `wt --version` and
  `herdr --version` to confirm both installed.

## What's here

- **Ghostty** (`~/.config/ghostty/config`) — keybind unbinds so herdr/nvim can claim
  those chords instead of Ghostty's own native actions, Option-as-Alt, Tokyo Night
  theme, font/padding/cursor/scrollback.
- **herdr** (`~/.config/herdr/config.toml`) — full keybinding layout (backtick prefix,
  direct chords for tabs/panes/agents/workspaces), plus custom command bindings
  (lazygit popup, worktrunk plugin actions, pane swap, jump-to-finished-agent,
  move-pane-to-tab picker).
- **nvim** (`~/.config/nvim/`) — LazyVim-based, VS Code-ish explorer/preview
  behavior, Tokyo Night theme, diffview for merge conflict resolution,
  `lazy-lock.json` pinned so plugin versions match what was actually tested.
- **zsh** (`~/.config/zsh/workflow.zsh`) — tool env vars (bat/fzf) and eza/bat
  aliases. Wired into `~/.zshrc` via one idempotent appended `source` line, not by
  managing `.zshrc` directly — that file commonly already has real personal content
  on any machine this runs on.
- **worktrunk** (`~/.config/worktrunk/config.toml`) — sibling-directory worktree
  path (the tool's own default), and a `pre-switch` hook that fetches `origin`
  before every worktree creation so new branches never base off a stale local
  default branch.
- **herdr-move-pane-to-tab** (`~/bin/`) — fzf-picker script backing the
  move-pane-to-tab herdr binding.
- **Claude Code** — `~/.claude/CLAUDE.md` copied as-is; a curated subset of
  `~/.claude/settings.json` **merged** (not overwritten) into whatever's already
  there; `caveman` and `claude-hud` plugins installed fresh from their own
  marketplaces; herdr's own `claude` integration (agent lifecycle → herdr's sidebar);
  `claude-hud`'s own `config.json` (display/layout preferences, not just cache);
  `combat` (rationalist-skills toolkit, `combat:murphyjitsu` etc.) — not tracked by
  Claude Code's plugin system at all, so its content is cloned fresh from
  [dgriffith/combat-epistemology](https://github.com/dgriffith/combat-epistemology)
  on apply, with only its `.claude-plugin/plugin.json` manifest (which upstream
  doesn't ship) carried in this repo.

## Deliberately not here

Anything Acme-specific: the TICKETS/internal-mcp setup, the `project-a` pre-tool-use
hook, `gh-dash`/`wt-new-session`/`gh-dash-open-pr` (wired to SN repos and a specific
GitHub login), the `project-b`/`acme`/`cc-marketplace` plugin marketplaces. Also
`terminal-browser` and its `alt+b` herdr binding — broken by an unresolved upstream
bug ([zenbu-labs/terminal-browser#97](https://github.com/zenbu-labs/terminal-browser/issues/97));
add it back once that's fixed.

## Security note

`~/.claude/settings.json`'s merged patch (`claude-settings-patch.json` in this repo)
is hand-authored from scratch, not copied from any real settings file — the machine
this was built on has a live credential in that file's `env.INTERNAL_INSTANCES`, which is
why it's never read into this repo at all, not even temporarily.
