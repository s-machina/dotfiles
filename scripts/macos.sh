#!/usr/bin/env bash
# macOS-specific setup

info "Setting up macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Update Homebrew
info "Updating Homebrew..."
brew update

# Install packages from Brewfile
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

success "macOS setup complete"
