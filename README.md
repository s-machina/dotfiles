# Dotfiles

Cross-platform dotfiles with automatic theme switching.

## What's Included

- **Zsh** - Shell configuration with aliases, history, and completions
- **Neovim** - LazyVim-based config with TokyoNight theme
- **Tmux** - Terminal multiplexer with vim-style navigation
- **Git** - Config with delta for diffs and useful aliases
- **Ghostty** - Terminal emulator config (macOS)

### Tools

- fzf, ripgrep, fd - Fast searching
- eza - Modern ls replacement
- bat - Syntax-highlighted cat
- lazygit - Git TUI
- fnm - Node version manager
- uv - Python package manager

## Installation

```bash
git clone https://github.com/s-machina/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will:

1. Install Homebrew (macOS) or use your system package manager (Linux)
2. Install all packages from the Brewfile
3. Symlink dotfiles using GNU Stow
4. Set up automatic theme switching (macOS)

## Platform Support

| Feature | macOS | Linux |
|---------|-------|-------|
| Package installation | Homebrew | apt/dnf/pacman |
| Theme switching | Auto | Manual |
| Ghostty config | Yes | No |

## Theme Switching (macOS)

Themes automatically sync with your system appearance:

- **Dark mode**: TokyoNight Storm
- **Light mode**: TokyoNight Day

This works across Neovim, Tmux, and Ghostty via a background daemon.

## Structure

```
dotfiles/
├── bootstrap.sh     # Main installer
├── Brewfile         # Package list
├── shell/           # Zsh config
├── neovim/          # Neovim config
├── tmux/            # Tmux config
├── git/             # Git config
├── ghostty/         # Ghostty config (macOS)
├── themes/          # Theme switching scripts
├── macos/           # macOS-specific files
└── scripts/         # Setup scripts
```

## Post-Install

- Edit `~/.gitconfig.local` for personal git settings (name, email)
- Restart your terminal or run `source ~/.zshrc`
