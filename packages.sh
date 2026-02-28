#!/usr/bin/env bash
# Package name mappings for Linux
# Brewfile is the source of truth - this file maps names that differ per platform

# =============================================================================
# Package name translation
# =============================================================================

# Translate brew package name to platform-specific name
get_linux_name() {
    local brew_name="$1"
    local pm="$2"  # apt, dnf, pacman

    case "$pm" in
        apt)
            case "$brew_name" in
                fd)      echo "fd-find" ;;
                node)    echo "nodejs" ;;
                python)  echo "python3" ;;
                go)      echo "golang-go" ;;
                *)       echo "$brew_name" ;;
            esac
            ;;
        dnf)
            case "$brew_name" in
                fd)      echo "fd-find" ;;
                node)    echo "nodejs" ;;
                python)  echo "python3" ;;
                go)      echo "golang" ;;
                *)       echo "$brew_name" ;;
            esac
            ;;
        pacman)
            case "$brew_name" in
                gh)         echo "github-cli" ;;
                node)       echo "nodejs" ;;
                git-delta)  echo "git-delta" ;;
                *)          echo "$brew_name" ;;
            esac
            ;;
        *)
            echo "$brew_name"
            ;;
    esac
}

# Check if package needs manual installation (not in standard repos)
is_manual() {
    local brew_name="$1"
    local pm="$2"

    case "$pm" in
        apt)
            case "$brew_name" in
                neovim|fd|lazygit|eza|git-delta|fnm|uv) return 0 ;;
                *) return 1 ;;
            esac
            ;;
        dnf)
            case "$brew_name" in
                neovim|fd|lazygit|eza|git-delta|fnm|uv) return 0 ;;
                *) return 1 ;;
            esac
            ;;
        pacman)
            case "$brew_name" in
                fnm|uv) return 0 ;;  # Install via script for consistency
                *) return 1 ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}

# Extra packages needed on Linux (not in Brewfile)
get_extra_packages() {
    local pm="$1"

    case "$pm" in
        apt)    echo "build-essential python3-pip npm unzip" ;;
        dnf)    echo "gcc make python3-pip unzip" ;;
        pacman) echo "base-devel python-pip npm unzip" ;;
    esac
}

# =============================================================================
# Main function: Parse Brewfile and return packages for a platform
# =============================================================================

get_packages_from_brewfile() {
    local pm="$1"
    local brewfile="$2"

    # Parse brew "package" lines from Brewfile
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        # Match: brew "package" or brew 'package'
        if [[ "$line" =~ ^brew[[:space:]]+[\"\']([^\"\']+)[\"\'] ]]; then
            local brew_name="${BASH_REMATCH[1]}"

            # Skip if manual install required
            if is_manual "$brew_name" "$pm"; then
                continue
            fi

            # Translate and output
            get_linux_name "$brew_name" "$pm"
        fi
    done < "$brewfile"

    # Add extra packages for this platform
    get_extra_packages "$pm"
}
