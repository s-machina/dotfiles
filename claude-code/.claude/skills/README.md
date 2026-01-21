# Custom Skills

This directory contains custom Claude Code skills that can be invoked with slash commands.

Add new skills as markdown files with YAML frontmatter. Each skill should:

1. Have a descriptive filename (e.g., `deploy-app.md`)
2. Include YAML frontmatter with metadata
3. Provide step-by-step instructions
4. Handle error cases appropriately

## Example Skill Structure

```markdown
---
name: example-skill
description: Brief description of what this skill does
usage: /example [arguments]
---

# Skill Instructions

Clear step-by-step instructions for what this skill should do...

## Arguments

- `arg1`: Description of first argument
- `arg2`: Description of second argument (optional)

## Error Handling

How to handle common error scenarios...

## Examples

Show example usage patterns...
```

## Skill Usage

Skills can be invoked using:
```bash
claude /example arg1 arg2
```

Or by typing `/example` in a Claude Code session.