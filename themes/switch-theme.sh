#!/usr/bin/env bash
# Switches theme for apps that don't auto-detect macOS appearance
# - Ghostty: handled natively via theme = light:x,dark:y
# - Neovim: handled by auto-dark-mode.nvim plugin
# - Tmux: needs manual update (this script)
# - Delta (git diff): needs manual update (this script)
set -euo pipefail

# Detect macOS appearance
get_appearance() {
    defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"
}

# Update tmux theme
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

# Update delta (git diff) theme
update_delta() {
    local mode="$1"
    local delta_theme_file="$HOME/.config/delta/theme.gitconfig"

    mkdir -p "$(dirname "$delta_theme_file")"

    if [[ "$mode" == "dark" ]]; then
        cat > "$delta_theme_file" << 'EOF'
# Dark theme (TokyoNight Storm)
[delta]
    syntax-theme = tokyonight_storm
    light = false
EOF
    else
        cat > "$delta_theme_file" << 'EOF'
# Light theme (TokyoNight Day)
[delta]
    syntax-theme = tokyonight_day
    light = true
EOF
    fi
}

# Main
main() {
    local mode
    if [[ "$(get_appearance)" == "Dark" ]]; then
        mode="dark"
    else
        mode="light"
    fi

    echo "Switching to $mode mode..."
    update_tmux "$mode"
    update_delta "$mode"
    echo "Theme switched to $mode"
}

main "$@"
