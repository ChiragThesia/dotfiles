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

## For Claude Code sessions working on this repo — follow exactly, in order

These are the actual commands verified to work while building this repo. Do not
improvise alternatives to the flagged steps; each one exists because the obvious
approach failed during testing.

### Pulling / applying (any machine that is NOT the machine this repo was authored on)

1. First time on a machine: `brew install chezmoi && chezmoi init --apply chiragthesia/dotfiles`.
2. Updating a machine already set up this way: `chezmoi update` (equivalent to
   `cd "$(chezmoi source-path)" && git pull --autostash && chezmoi apply` — either form is fine).
3. **STOP before running either command if `hostname` / the user confirms this is the
   machine the repo was originally built on.** The source tree deliberately diverges
   from that machine's real config in several places (SN-specific hooks stripped,
   etc.) — applying there reverts real, intentional customization on that machine.
   If genuinely unsure which machine this is, ask the user before running `apply`.
4. Never run `chezmoi apply`/`chezmoi diff` with no arguments as a way to "check what
   would happen" without reading the diff first — always `chezmoi diff` and actually
   read it before the first real `apply` on any machine you haven't applied to before.

### Pushing changes (adding/editing anything in this repo)

1. Work in the chezmoi source dir: `cd "$(chezmoi source-path)"` (or wherever this
   repo is checked out if not managed via `chezmoi`).
2. Adding a new dotfile from a real path on disk: `chezmoi add <path>` — it names the
   file correctly (`dot_` / `executable_` prefixes) automatically. Don't hand-name
   files unless you're creating one that has no real counterpart on disk yet.
3. **If you touched any `*.sh.tmpl` script**, render and syntax-check it before
   committing — do not skip this:
   ```bash
   chezmoi execute-template < path/to/script.sh.tmpl | bash -n /dev/stdin && echo OK
   ```
4. **Run a secret scan over the whole tree before every commit, no exceptions:**
   ```bash
   rg -i 'password|secret|INTERNAL_INSTANCES|api[_-]?key|token.*:.*[A-Za-z0-9]{20}' "$(chezmoi source-path)" --glob '!.git'
   ```
   Any real hit (not a git commit hash, not prose mentioning the word "token") means
   **stop and do not commit** until it's resolved. This is the single most important
   rule in this file.
5. **Never read a real `~/.claude/settings.json` (or any other file known to carry
   live credentials) into this repo, not even temporarily.** If a settings change is
   needed, hand-edit `claude-settings-patch.json` directly — it is a hand-authored
   literal, deliberately never derived from the real file. Same principle for any
   future file that might carry secrets on some machine: author a clean version from
   scratch, don't copy-then-strip.
6. Review before committing: `git add -A && git status --short` — confirm nothing
   unexpected is staged.
7. Commit, then push. **`git push` alone will hang** on this machine waiting on a
   macOS Keychain dialog that a non-interactive agent session cannot approve — use
   this instead, every time:
   ```bash
   TOKEN=$(gh auth token --hostname github.com)
   git -c credential.helper= -c "http.https://github.com/.extraheader=Authorization: basic $(printf 'x-access-token:%s' "$TOKEN" | base64)" push
   ```
   Requires `gh auth login` (github.com, not an enterprise host) to already be done
   on whatever machine is running this. If that push command itself fails, do not
   fall back to plain `git push` and wait — report the failure instead of hanging.

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
- **zsh** (`~/.config/zsh/workflow.zsh`) — oh-my-zsh (installed + activated here,
  `robbyrussell` theme, 4 community plugins), a stale-worktree cwd guard, tool env
  vars (bat/fzf), worktrunk's shell integration (`wt switch` needs this to actually
  `cd` the shell — easy to miss, it's not optional), guarded `tv`/`atuin`/`zoxide`
  inits, and a handful of generic aliases (`cr`/`c`/`cc` for Claude Code, `copypath`,
  `gtask`). Wired into `~/.zshrc` via one idempotent appended `source` line, not by
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
GitHub login), the `project-b`/`acme`/`cc-marketplace` plugin marketplaces, the
`now/homebrew-devtools` tap, the `gh-dash` alias (hardcodes `code.internal.invalid`), the
500-line `ai-search()` function and `fastzboot`/`gll-snapshot()` (INTERNAL build
tooling). Also `terminal-browser` and its `alt+b` herdr binding — broken by an
unresolved upstream bug
([zenbu-labs/terminal-browser#97](https://github.com/zenbu-labs/terminal-browser/issues/97));
add it back once that's fixed.

Also excluded, not SN-specific but not generically useful either: `oktafy()`/
`workondw()` (tied to a "a-previous-employer" job/project context, reference undefined env
vars), iTerm2-specific bits (`_iterm2_tab_color`, iTerm2 shell integration — this
whole setup is Ghostty-primary), and the `claude-usage`/`claude-worktree` aliases
(point at `~/.claude/scripts/*.sh` that were never verified to still exist or work —
add them back yourself if they do). `asdf` was dropped from the oh-my-zsh plugin
list for the same reason nvm/pnpm/IntelliJ's PATH entries were left un-installed —
outside this repo's stated scope (their inert PATH lines are still here; the plugin
would not be).

## Security note

`~/.claude/settings.json`'s merged patch (`claude-settings-patch.json` in this repo)
is hand-authored from scratch, not copied from any real settings file — the machine
this was built on has a live credential in that file's `env.INTERNAL_INSTANCES`, which is
why it's never read into this repo at all, not even temporarily.
