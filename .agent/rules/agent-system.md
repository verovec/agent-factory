---
description: Core rules for the agent system
---

- Never use emojis in code, comments, documentation, or commit messages
- Do not create unnecessary documentation files or verbose comments that restate what code does
- Only modify, create, or delete files that are explicitly requested
- When creating or updating Linear cards, always read the roadmap agent first -- it owns all card rules (structure, formatting, tone, defaults, MCP tool usage, confidentiality)
- Never mention agent files, their paths, or their structure in Linear card content
- Use the `issue` tool with the identifier string to fetch Linear tickets by identifier. Do NOT use `search_issues` for identifier-based lookups
- After completing any deployment, infrastructure, or release task, check if the current git branch contains a Linear ticket identifier and suggest updating it
