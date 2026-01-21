# Claude Code Configuration

Safe, selective management of Claude Code settings using dotfiles.

## What's Managed

✅ **Shared across machines** (symlinked from dotfiles):
- `CLAUDE.md` - Global development guidelines
- `agents/` - Custom subagents
- `skills/` - Custom skills

🔒 **Machine-specific** (managed locally):
- `settings.json` - Environment-specific config (AWS profiles, etc.)
- All runtime data (cache, history, sessions, etc.)

## Setup

1. **Install Claude Code** (if not already installed):
   ```bash
   npm install -g @anthropics/claude-cli
   # or use the native installer (recommended)
   ```

2. **Run the setup script**:
   ```bash
   cd ~/Source/dotfiles/claude-code
   ./setup-claude-config.sh
   ```

3. **Configure machine-specific settings** (optional):
   ```bash
   # Edit local settings for this machine
   vim ~/.claude/settings.json
   ```

4. **Verify setup**:
   ```bash
   claude doctor
   ls -la ~/.claude/
   ```

## Directory Structure

```
~/.claude/
├── CLAUDE.md          # 🔗 symlinked from dotfiles
├── agents/            # 🔗 symlinked from dotfiles
├── skills/            # 🔗 symlinked from dotfiles
├── settings.json      # 🔒 local machine config
├── cache/             # 🔒 runtime data
├── history.jsonl      # 🔒 runtime data
└── ...                # 🔒 other runtime data
```

## Adding Agents/Skills

Add new files to the dotfiles directories:

```bash
# Add a new agent
vim claude-code/.claude/agents/researcher.md

# Add a new skill
vim claude-code/.claude/skills/deploy.md

# Re-run setup if needed
./setup-claude-config.sh
```

Changes will be available across all machines on next `git pull` + setup.

## Safety Features

- ✅ Only safe, shareable files are symlinked
- ✅ Sensitive config stays local to each machine
- ✅ Runtime data never touches git
- ✅ Script is idempotent and safe to re-run
- ✅ Backs up existing files before symlinking