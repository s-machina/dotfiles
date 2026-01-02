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

    # fd is named fdfind on Debian/Ubuntu
    if ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    # bat is named batcat on Debian/Ubuntu
    if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi
}

# Install tools not in standard repos
install_manual_packages() {
    local pm="$1"

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
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
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
