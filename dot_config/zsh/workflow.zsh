# guard: if cwd was deleted (stale worktree), fall back to home before
# anything else in this shell runs
[ -d "$(pwd 2>/dev/null)" ] || cd ~

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Personal tool managers/editors -- kept as guarded/inert entries rather than
# installed by this repo (nvm/pnpm/IntelliJ are outside its stated scope);
# each is a no-op if the tool in question isn't present.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[ -d "/Applications/IntelliJ IDEA.app" ] && export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

# oh-my-zsh (installed by run_once_after_02, KEEP_ZSHRC=yes so its own
# installer never touches this file -- activation lives here instead).
# The `omz` guard skips this block on a machine whose .zshrc already
# sources oh-my-zsh itself: a second source re-sets PROMPT to ZSH_THEME,
# which silently overrides a prompt (starship etc.) set earlier in .zshrc,
# and duplicates precmd hooks.
if [ -d "$HOME/.oh-my-zsh" ] && ! typeset -f omz >/dev/null 2>&1; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(
    git
    docker
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
  )
  source "$ZSH/oh-my-zsh.sh"
  autoload -Uz compinit && compinit
fi

# Tools
export BAT_THEME="TwoDark"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --cycle'

if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# worktrunk shell integration -- required for `wt switch` to actually cd
# the shell; without this it only prints the target directory.
command -v wt >/dev/null 2>&1 && eval "$(command wt config shell init zsh)"

# television — context-aware fuzzy picker (ctrl-t)
command -v tv >/dev/null 2>&1 && eval "$(tv init zsh)"

# atuin — shell history search (ctrl-r)
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# Aliases
alias ls="eza"
alias ll="eza -la"
alias tree="eza --tree"
alias cat="bat"
alias copypath='pwd | pbcopy'
alias gtask='task'

# Claude Code
alias cr="claude --resume"
alias c="claude"
alias cc="claude --continue"

export PATH="$HOME/go/bin:$PATH"
