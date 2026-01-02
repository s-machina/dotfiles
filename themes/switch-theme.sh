#!/usr/bin/env bash
# Switches theme across all apps based on macOS appearance
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Detect macOS appearance (returns "Dark" if dark mode, empty if light)
get_appearance() {
    defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"
}

# Get the appropriate theme based on appearance
get_current_theme() {
    if [[ "$(get_appearance)" == "Dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Update Ghostty config
update_ghostty() {
    local mode="$1"
    local theme_name
    local ghostty_config="$HOME/.config/ghostty/config"

    if [[ "$mode" == "dark" ]]; then
        theme_name="$THEME_DARK"
    else
        theme_name="$THEME_LIGHT"
    fi

    # Create ghostty config dir if needed
    mkdir -p "$(dirname "$ghostty_config")"

    # Update or create the theme line in ghostty config
    if [[ -f "$ghostty_config" ]]; then
        if grep -q "^theme = " "$ghostty_config"; then
            sed -i '' "s/^theme = .*/theme = $theme_name/" "$ghostty_config"
        else
            echo "theme = $theme_name" >> "$ghostty_config"
        fi
    else
        echo "theme = $theme_name" > "$ghostty_config"
    fi

    # Ghostty auto-reloads config on change
}

# Update tmux (write current theme to a file tmux can source)
update_tmux() {
    local mode="$1"
    local tmux_theme_file="$HOME/.config/tmux/current-theme.conf"

    mkdir -p "$(dirname "$tmux_theme_file")"

    if [[ "$mode" == "dark" ]]; then
        cat > "$tmux_theme_file" << 'EOF'
# Dark theme (TokyoNight Storm)
set -g status-style 'bg=#1f2335 fg=#c0caf5'
set -g pane-border-style 'fg=#3b4261'
set -g pane-active-border-style 'fg=#7aa2f7'
set -g window-status-current-format '#[fg=#7aa2f7,bold] #I:#W '
set -g window-status-format '#[fg=#565f89] #I:#W '
set -g status-left '#[fg=#7aa2f7,bold] #S #[fg=#3b4261]│ '
set -g status-right '#[fg=#3b4261]│ #[fg=#9ece6a]%H:%M #[fg=#3b4261]│ #[fg=#bb9af7]%d %b'
EOF
    else
        cat > "$tmux_theme_file" << 'EOF'
# Light theme (TokyoNight Day)
set -g status-style 'bg=#e1e2e7 fg=#3760bf'
set -g pane-border-style 'fg=#a8aecb'
set -g pane-active-border-style 'fg=#2e7de9'
set -g window-status-current-format '#[fg=#2e7de9,bold] #I:#W '
set -g window-status-format '#[fg=#6172b0] #I:#W '
set -g status-left '#[fg=#2e7de9,bold] #S #[fg=#a8aecb]│ '
set -g status-right '#[fg=#a8aecb]│ #[fg=#587539]%H:%M #[fg=#a8aecb]│ #[fg=#9854f1]%d %b'
EOF
    fi

    # Reload tmux if running
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null; then
        tmux source-file "$tmux_theme_file" 2>/dev/null || true
    fi
}

# Write current mode to a file that Neovim can watch
update_nvim_signal() {
    local mode="$1"
    local signal_file="$HOME/.config/nvim/.theme-mode"

    mkdir -p "$(dirname "$signal_file")"
    echo "$mode" > "$signal_file"

    # Send USR1 signal to all nvim processes to trigger theme reload
    pkill -USR1 nvim 2>/dev/null || true
}

# Main
main() {
    local mode
    mode=$(get_current_theme)

    echo "Switching to $mode mode..."

    update_ghostty "$mode"
    update_tmux "$mode"
    update_nvim_signal "$mode"

    echo "Theme switched to $mode"
}

main "$@"
