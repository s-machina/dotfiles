#!/bin/bash
# Claude Code configuration setup with selective symlinking
# Only manages shared files, leaves sensitive config (settings.json) local

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SOURCE_DIR="$DOTFILES_DIR/.claude"

echo "Setting up Claude Code configuration..."
echo "Source: $SOURCE_DIR"
echo "Target: $CLAUDE_DIR"

# Ensure ~/.claude directory exists
mkdir -p "$CLAUDE_DIR"

# Files/directories to symlink from dotfiles
MANAGED_ITEMS=(
    "CLAUDE.md"
    "agents"
    "skills"
)

# Function to create symlink safely
create_symlink() {
    local item="$1"
    local source="$SOURCE_DIR/$item"
    local target="$CLAUDE_DIR/$item"

    if [ ! -e "$source" ]; then
        echo "⚠️  Source doesn't exist: $source"
        return 1
    fi

    # Remove existing symlink or file if it exists
    if [ -L "$target" ]; then
        echo "🔄 Replacing existing symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        echo "🔄 Backing up existing file: $target -> $target.backup"
        mv "$target" "$target.backup"
    fi

    # Create the symlink
    ln -s "$source" "$target"
    echo "✅ Linked: $item"
}

# Create symlinks for managed items
for item in "${MANAGED_ITEMS[@]}"; do
    create_symlink "$item"
done

echo ""
echo "🎉 Claude Code configuration setup complete!"
echo ""
echo "📁 Managed files (symlinked from dotfiles):"
for item in "${MANAGED_ITEMS[@]}"; do
    echo "   ~/.claude/$item -> $SOURCE_DIR/$item"
done
echo ""
echo "🔒 Local files (manage separately on each machine):"
echo "   ~/.claude/settings.json"
echo "   ~/.claude/cache/"
echo "   ~/.claude/history.jsonl"
echo "   (and other runtime data)"
echo ""
echo "💡 Run 'claude doctor' to verify your configuration"