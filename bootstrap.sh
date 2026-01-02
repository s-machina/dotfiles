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

    # Run common setup (stow packages)
    source "$DOTFILES_DIR/scripts/common.sh"

    success "Bootstrap complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc"
    echo "  2. Open neovim to install plugins: nvim"
    echo "  3. Configure git user: git config --global user.name 'Your Name'"
    echo "                         git config --global user.email 'you@example.com'"
}

main "$@"
