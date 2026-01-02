# ~/.zshrc - Zsh configuration

# ============================================================================
# Environment
# ============================================================================

# Homebrew (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Node (npm global)
export PATH="$HOME/.npm-global/bin:$PATH"

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# ============================================================================
# History
# ============================================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command before executing from history

# ============================================================================
# Options
# ============================================================================

setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push directories onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
setopt CORRECT                # Command correction
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# ============================================================================
# Completion
# ============================================================================

autoload -Uz compinit
compinit -C

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================================
# Key bindings
# ============================================================================

bindkey -e                      # Emacs key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ============================================================================
# Aliases
# ============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ls replacements
if command -v eza &> /dev/null; then
    alias ls="eza"
    alias ll="eza -la"
    alias la="eza -a"
    alias lt="eza --tree --level=2"
else
    alias ll="ls -la"
    alias la="ls -a"
fi

# Git
alias g="git"
alias gs="git status"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"
alias lg="lazygit"

# Editor
alias v="nvim"
alias vim="nvim"

# Better defaults
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias mkdir="mkdir -p"

# Tools
if command -v bat &> /dev/null; then
    alias cat="bat --paging=never"
fi

# ============================================================================
# FZF
# ============================================================================

if command -v fzf &> /dev/null; then
    # Use fd for fzf if available
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

    # Source fzf keybindings
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# ============================================================================
# Prompt
# ============================================================================

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b)%f '

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%F{green}❯%f '

# ============================================================================
# Local config (not tracked in git)
# ============================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
