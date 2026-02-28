#!/usr/bin/env bash
# Linux-specific setup - reads packages from Brewfile

info "Setting up Linux..."

# Source package mappings
source "$DOTFILES_DIR/packages.sh"

# Detect package manager
detect_pm() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        error "No supported package manager found (apt, dnf, or pacman)"
    fi
}

# Install packages from Brewfile
install_packages() {
    local pm="$1"

    info "Detected package manager: $pm"

    # Get packages from Brewfile, translated for this platform
    local packages
    packages=$(get_packages_from_brewfile "$pm" "$DOTFILES_DIR/Brewfile" | tr '\n' ' ')

    info "Installing packages: $packages"

    case "$pm" in
        apt)
            sudo apt update
            # shellcheck disable=SC2086
            sudo apt install -y $packages
            ;;
        dnf)
            # shellcheck disable=SC2086
            sudo dnf install -y $packages
            ;;
        pacman)
            sudo pacman -Sy
            # shellcheck disable=SC2086
            sudo pacman -S --noconfirm $packages
            ;;
    esac
}

# Fix symlinks for packages with different binary names (Debian/Ubuntu)
fix_symlinks() {
    if [[ "$(detect_pm)" != "apt" ]]; then
        return
    fi

    # bat is named batcat on Debian/Ubuntu
    if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi
}

# Install tools not in standard repos
install_manual_packages() {
    local pm="$1"

    # Neovim (distro versions are too old for LazyVim)
    local nvim_ver
    nvim_ver=$(nvim --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' || echo "0.0")
    if ! command -v nvim &> /dev/null || [[ "$(printf '%s\n' "0.10" "$nvim_ver" | sort -V | head -1)" != "0.10" ]]; then
        info "Installing Neovim from GitHub releases..."
        curl -Lo /tmp/nvim-linux-x86_64.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        mkdir -p "$HOME/.local"
        rm -rf "$HOME/.local/lib/nvim" "$HOME/.local/share/nvim/runtime"
        tar xf /tmp/nvim-linux-x86_64.tar.gz -C "$HOME/.local" --strip-components=1
        rm /tmp/nvim-linux-x86_64.tar.gz
        success "Neovim installed: $("$HOME/.local/bin/nvim" --version | head -1)"
    fi

    # GitHub CLI (apt/dnf need special repo)
    if ! command -v gh &> /dev/null; then
        case "$pm" in
            apt)
                info "Installing GitHub CLI..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                sudo apt install -y gh
                ;;
            dnf)
                sudo dnf install -y gh
                ;;
        esac
    fi

    # fd (distro versions are too old for snacks.nvim explorer, needs >= 8.4)
    local fd_ver
    fd_ver=$(fd --version 2>/dev/null | grep -oP '\d+\.\d+' || echo "0.0")
    if [[ "$pm" != "pacman" ]] && (! command -v fd &> /dev/null || [[ "$(printf '%s\n' "8.4" "$fd_ver" | sort -V | head -1)" != "8.4" ]]); then
        info "Installing fd from GitHub releases..."
        FD_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        case "$pm" in
            apt)
                curl -Lo /tmp/fd.deb "https://github.com/sharkdp/fd/releases/latest/download/fd_${FD_VERSION}_amd64.deb"
                sudo dpkg -i /tmp/fd.deb
                rm /tmp/fd.deb
                ;;
            dnf)
                curl -Lo /tmp/fd.rpm "https://github.com/sharkdp/fd/releases/latest/download/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.rpm"
                sudo rpm -i /tmp/fd.rpm
                rm /tmp/fd.rpm
                ;;
        esac
        success "fd installed: $(fd --version)"
    fi

    # lazygit
    if ! command -v lazygit &> /dev/null && [[ "$pm" != "pacman" ]]; then
        info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit /tmp/lazygit.tar.gz
    fi

    # eza
    if ! command -v eza &> /dev/null && [[ "$pm" != "pacman" ]]; then
        info "Installing eza..."
        case "$pm" in
            apt)
                curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
                tar xf /tmp/eza.tar.gz -C /tmp ./eza
                sudo install /tmp/eza /usr/local/bin
                rm /tmp/eza /tmp/eza.tar.gz
                ;;
            dnf)
                sudo dnf install -y eza
                ;;
        esac
    fi

    # delta
    if ! command -v delta &> /dev/null && [[ "$pm" != "pacman" ]]; then
        info "Installing delta..."
        DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        case "$pm" in
            apt)
                curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
                sudo dpkg -i /tmp/delta.deb
                rm /tmp/delta.deb
                ;;
            dnf)
                curl -Lo /tmp/delta.rpm "https://github.com/dandavison/delta/releases/latest/download/git-delta-${DELTA_VERSION}-x86_64.rpm"
                sudo rpm -i /tmp/delta.rpm
                rm /tmp/delta.rpm
                ;;
        esac
    fi

    # fnm (Fast Node Manager)
    if ! command -v fnm &> /dev/null; then
        info "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    fi

    # uv (Python version/venv manager)
    if ! command -v uv &> /dev/null; then
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

# Main
pm=$(detect_pm)
install_packages "$pm"
fix_symlinks
install_manual_packages "$pm"

# Set extra stow packages for common.sh (none for Linux currently)
export EXTRA_STOW_PACKAGES=""

success "Linux setup complete"
