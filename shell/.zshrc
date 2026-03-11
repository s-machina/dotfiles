# ~/.zshrc - Zsh configuration

# ============================================================================
# Dotfiles directory (written by bootstrap.sh)
# ============================================================================

[[ -f "$HOME/.config/dotfiles/env" ]] && source "$HOME/.config/dotfiles/env"

# ============================================================================
# Environment
# ============================================================================

# Homebrew (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# SSH Agent - reuse existing or start new
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    # Check for existing agent
    if [[ -f ~/.ssh/agent.env ]]; then
        source ~/.ssh/agent.env > /dev/null
    fi
    # Start new agent if not running
    if ! ssh-add -l &> /dev/null; then
        eval "$(ssh-agent -s)" > /dev/null
        echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AUTH_SOCK;" > ~/.ssh/agent.env
        echo "SSH_AGENT_PID=$SSH_AGENT_PID; export SSH_AGENT_PID;" >> ~/.ssh/agent.env
    fi
fi

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# fnm (Fast Node Manager)
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# Node (npm global) - fallback if not using fnm
export PATH="$HOME/.npm-global/bin:$PATH"

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# SSH session detection
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    SSH_SESSION=1
fi

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

# uv (Python version/venv manager)
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

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
alias vi="nvim"
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

# OSC52 clipboard - pipe stdin to local clipboard over SSH
clip() {
    local data
    data=$(base64 | tr -d '\n')
    printf '\e]52;c;%s\a' "$data"
}

# Terminal recovery - reset all modes that apps like neovim leave behind
_terminal_reset() {
    stty sane 2>/dev/null
    printf '\e[0m' 2>/dev/null        # reset text attributes
    printf '\e[?25h' 2>/dev/null       # show cursor
    printf '\e[?47l' 2>/dev/null       # exit alternate screen (legacy)
    printf '\e[?1049l' 2>/dev/null     # exit alternate screen (xterm)
    printf '\e(B' 2>/dev/null          # reset charset to ASCII
    printf '\e[?1l' 2>/dev/null        # reset cursor keys to normal mode
    printf '\e[?1000l' 2>/dev/null     # disable mouse click tracking
    printf '\e[?1002l' 2>/dev/null     # disable mouse button tracking
    printf '\e[?1003l' 2>/dev/null     # disable mouse all-motion tracking
    printf '\e[?1006l' 2>/dev/null     # disable SGR mouse mode
    printf '\e[?2004l' 2>/dev/null     # disable bracketed paste
    printf '\e[r' 2>/dev/null          # reset scroll region
    printf '\e>' 2>/dev/null           # reset numeric keypad mode
    printf '\e[?7h' 2>/dev/null        # re-enable line wrapping
}
alias ft="_terminal_reset"

# Wrap ssh to auto-reset terminal after disconnect
ssh() {
    command ssh "$@"
    local ret=$?
    _terminal_reset
    return $ret
}

# Theme switching (macOS)
if [[ -n "$DOTFILES_DIR" ]] && [[ -x "$DOTFILES_DIR/themes/switch-theme.sh" ]]; then
    alias theme="$DOTFILES_DIR/themes/switch-theme.sh"
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
[[ -n "$SSH_SESSION" ]] && PROMPT='%F{yellow}%n@%m%f '"$PROMPT"

# ============================================================================
# Tmux Session Management
# ============================================================================

# Path to tmux session management script
TMUX_SESSION_SCRIPT="$DOTFILES_DIR/scripts/tmux-session.sh"

# Aliases for tmux session management
if [[ -x "$TMUX_SESSION_SCRIPT" ]]; then
    alias tm="$TMUX_SESSION_SCRIPT"                    # Quick session connect/create
    alias tms="$TMUX_SESSION_SCRIPT --select"          # Interactive session selection
    alias tml="$TMUX_SESSION_SCRIPT --list"            # List sessions
    alias tm3="$TMUX_SESSION_SCRIPT --three-split"     # Create with three-split layout
fi

# Function to create a new tmux session with three-split layout
tm3s() {
    local session_name="${1:-dev}"
    if [[ -x "$TMUX_SESSION_SCRIPT" ]]; then
        "$TMUX_SESSION_SCRIPT" --new --three-split "$session_name"
    else
        echo "Tmux session script not found at: $TMUX_SESSION_SCRIPT"
    fi
}

# Function for smart tmux attachment (for SSH sessions)
tmux_auto_attach() {
    # Only auto-attach if:
    # 1. We're in an SSH session
    # 2. We're not already in a tmux session
    # 3. This is an interactive shell
    # 4. The tmux session script exists
    if [[ -n "$SSH_SESSION" ]] && [[ -z "$TMUX" ]] && [[ $- == *i* ]] && [[ -x "$TMUX_SESSION_SCRIPT" ]]; then
        echo "🚀 Welcome to your remote development environment!"
        echo "📋 Available tmux sessions:"

        # Show existing sessions if any
        if tmux list-sessions &>/dev/null; then
            tmux list-sessions -F "   #{session_name} (#{session_windows} windows)"
        else
            echo "   (no existing sessions)"
        fi

        echo ""
        echo "💡 Quick commands:"
        echo "   tm           - Connect to/create default session"
        echo "   tm <name>    - Connect to/create named session"
        echo "   tm3 <name>   - Create session with 3-split layout"
        echo "   tms          - Interactive session selector"
        echo ""

        # Ask if user wants to connect to a session
        read -t 10 -k 1 "auto_connect?Auto-connect to default session? (y/N, 10s timeout): "
        echo ""

        if [[ "$auto_connect" =~ ^[Yy]$ ]]; then
            "$TMUX_SESSION_SCRIPT"
        else
            echo "Use 'tm' command when ready to start tmux session."
        fi
    fi
}

# Call auto-attach function when shell starts
tmux_auto_attach

# ============================================================================
# Local config (not tracked in git)
# ============================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
