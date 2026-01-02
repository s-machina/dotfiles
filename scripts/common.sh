#!/usr/bin/env bash
# Common setup for all platforms

info "Running common setup..."

# Stow packages to create symlinks
STOW_PACKAGES=(shell neovim tmux git)

info "Creating symlinks with stow..."
cd "$DOTFILES_DIR"

for package in "${STOW_PACKAGES[@]}"; do
    if [[ -d "$package" ]]; then
        info "  Stowing $package..."
        # Use --adopt to handle existing files, then restore from git
        stow -v --target="$HOME" "$package" 2>&1 | grep -v "^LINK:" || true
    fi
done

# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
    info "Setting zsh as default shell..."
    if command -v zsh &> /dev/null; then
        chsh -s "$(which zsh)" || info "  Could not change shell automatically. Run: chsh -s \$(which zsh)"
    fi
fi

# Install fzf key bindings if available
if command -v fzf &> /dev/null; then
    if [[ -f /opt/homebrew/opt/fzf/install ]]; then
        /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    elif [[ -f /usr/local/opt/fzf/install ]]; then
        /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi
fi

success "Common setup complete"
