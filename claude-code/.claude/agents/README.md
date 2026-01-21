# Custom Agents

This directory contains custom Claude Code subagents that extend functionality.

Add new agents as markdown files with YAML frontmatter. Each agent should:

1. Have a descriptive filename (e.g., `security-scanner.md`)
2. Include YAML frontmatter with metadata
3. Provide clear instructions for the agent's purpose
4. Define what tools/capabilities it should use

## Example Agent Structure

```markdown
---
name: example-agent
description: Brief description of what this agent does
tools: [Bash, Read, Write]  # Optional: specific tools
---

# Agent Instructions

Clear instructions for what this agent should do...

## When to Use

Describe when this agent should be activated...

## Examples

Show example usage patterns...
```

## Agent Activation

Agents can be activated using:
```bash
claude --agent security-scanner "scan this project for vulnerabilities"
```

Or through the Task tool in conversations.