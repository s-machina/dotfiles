#!/usr/bin/env bash
# Common setup for all platforms
#
# Expected environment variables (set by platform scripts):
#   EXTRA_STOW_PACKAGES - space-separated list of additional stow packages

info "Running common setup..."

# Base stow packages (all platforms)
STOW_PACKAGES=(shell neovim tmux git)

# Add platform-specific packages
if [[ -n "$EXTRA_STOW_PACKAGES" ]]; then
    # shellcheck disable=SC2206
    STOW_PACKAGES+=($EXTRA_STOW_PACKAGES)
fi

info "Creating symlinks with stow..."
cd "$DOTFILES_DIR"

for package in "${STOW_PACKAGES[@]}"; do
    if [[ -d "$package" ]]; then
        info "  Stowing $package..."
        stow -v --adopt --target="$HOME" "$package" 2>&1 | grep -v "^LINK:" || true
    fi
done

# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
    info "Setting zsh as default shell..."
    if command -v zsh &> /dev/null; then
        chsh -s "$(which zsh)" || info "  Could not change shell automatically. Run: chsh -s \$(which zsh)"
    fi
fi

# Install npm global packages
if ! command -v claude &> /dev/null; then
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Set up Claude Code configuration if it was installed and config exists
if command -v claude &> /dev/null && [[ -f "$DOTFILES_DIR/claude-code/setup-claude-config.sh" ]]; then
    info "Setting up Claude Code configuration..."
    "$DOTFILES_DIR/claude-code/setup-claude-config.sh"
fi

success "Common setup complete"
