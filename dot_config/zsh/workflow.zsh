# Tools
export BAT_THEME="TwoDark"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --cycle'

if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# Aliases
alias ls="eza"
alias ll="eza -la"
alias tree="eza --tree"
alias cat="bat"
