---
description: Global development guidelines and context
---

# Development Standards

## Code Quality
- Run tests before committing
- Use descriptive commit messages following conventional commits
- Ensure code passes linting and type checking
- Review changes before pushing

## Security Best Practices
- Never commit secrets, API keys, or credentials
- Use environment variables for sensitive configuration
- Review .env files are properly gitignored
- Rotate credentials regularly

## Git Workflow
- Use feature branches for development
- Keep commits atomic and well-described
- Squash commits when merging to main
- *NEVER* make co-author or attribution to AI tools in commit messages

## Project Setup Standards
- Initialize projects with proper .gitignore
- Set up CI/CD pipelines early
- Document setup instructions in README
- Use consistent dependency management (package-lock.json, requirements.txt, etc.)

## AWS & Cloud
- Always use AWS SSO for authentication
- Use least-privilege IAM policies
- Tag resources appropriately for cost tracking
- Use environment-specific configurations
