#!/usr/bin/env bash
# macOS-specific setup

info "Setting up macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure Homebrew is in PATH (also sets HOMEBREW_PREFIX)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Update Homebrew
info "Updating Homebrew..."
brew update

# Install packages from Brewfile
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Remove quarantine attribute from Ghostty (Gatekeeper blocks cask-installed apps)
if [[ -d /Applications/Ghostty.app ]]; then
    xattr -cr /Applications/Ghostty.app
fi

# Install fzf key bindings
if [[ -f "$HOMEBREW_PREFIX/opt/fzf/install" ]]; then
    "$HOMEBREW_PREFIX/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# Set extra stow packages for common.sh
export EXTRA_STOW_PACKAGES="ghostty macos"

success "macOS package installation complete"
