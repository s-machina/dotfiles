#!/usr/bin/env bash
# Central theme configuration
#
# Set themes using Ghostty naming (capitals and spaces).
# Neovim names are derived automatically (lowercase, spaces → dashes)

# Theme names (Ghostty style)
THEME_LIGHT="TokyoNight Day"
THEME_DARK="TokyoNight Storm"

# Derive Neovim colorscheme names (lowercase, spaces to dashes)
to_nvim_theme() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

NVIM_THEME_LIGHT=$(to_nvim_theme "$THEME_LIGHT")
NVIM_THEME_DARK=$(to_nvim_theme "$THEME_DARK")

export THEME_LIGHT THEME_DARK NVIM_THEME_LIGHT NVIM_THEME_DARK
