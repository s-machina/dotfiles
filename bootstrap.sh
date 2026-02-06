#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() {
    printf "\033[0;34m==>\033[0m %s\n" "$1"
}

success() {
    printf "\033[0;32m==>\033[0m %s\n" "$1"
}

error() {
    printf "\033[0;31mError:\033[0m %s\n" "$1" >&2
    exit 1
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      error "Unsupported operating system" ;;
    esac
}

main() {
    info "Starting dotfiles bootstrap..."

    local os
    os="$(detect_os)"
    info "Detected OS: $os"

    # Run OS-specific setup
    case "$os" in
        macos)
            source "$DOTFILES_DIR/scripts/macos.sh"
            ;;
        linux)
            source "$DOTFILES_DIR/scripts/linux.sh"
            ;;
    esac

    # Persist DOTFILES_DIR for shell config
    mkdir -p "$HOME/.config/dotfiles"
    echo "DOTFILES_DIR=\"$DOTFILES_DIR\"" > "$HOME/.config/dotfiles/env"

    # Run common setup (stow packages)
    source "$DOTFILES_DIR/scripts/common.sh"

    # Install bat themes for delta (git diff)
    if command -v bat &>/dev/null; then
        local bat_themes_dir="$HOME/.config/bat/themes"
        if [[ ! -f "$bat_themes_dir/tokyonight_storm.tmTheme" ]]; then
            info "Installing bat themes for delta..."
            mkdir -p "$bat_themes_dir"
            curl -sL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_storm.tmTheme" \
                -o "$bat_themes_dir/tokyonight_storm.tmTheme"
            curl -sL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_day.tmTheme" \
                -o "$bat_themes_dir/tokyonight_day.tmTheme"
            bat cache --build
            success "Bat themes installed"
        fi
    fi

    # Run OS-specific post-setup
    case "$os" in
        macos)
            # Set up theme switching
            if [[ -x "$DOTFILES_DIR/themes/switch-theme.sh" ]]; then
                info "Setting up theme based on system appearance..."
                "$DOTFILES_DIR/themes/switch-theme.sh"
            fi

            # Load the theme watcher launch agent
            if [[ -f "$HOME/Library/LaunchAgents/com.dotfiles.theme-watcher.plist" ]]; then
                info "Loading theme watcher agent..."
                launchctl unload "$HOME/Library/LaunchAgents/com.dotfiles.theme-watcher.plist" 2>/dev/null || true
                launchctl load "$HOME/Library/LaunchAgents/com.dotfiles.theme-watcher.plist"
            fi
            ;;
    esac

    success "Bootstrap complete!"
    echo ""
    echo "Next steps:"
    echo "  - Restart your shell or run: source ~/.zshrc"

    # Only suggest git config if not already set (check from ~ to avoid local repo config)
    if [[ -z "$(cd ~ && git config user.name)" ]] || [[ -z "$(cd ~ && git config user.email)" ]]; then
        echo "  - Configure git user: git config --global user.name 'Your Name'"
        echo "                        git config --global user.email 'you@example.com'"
    fi
}

main "$@"
