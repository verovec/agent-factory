# Agent Industry

Portable agent system for AI-assisted development. Scaffolds scoped knowledge files (code, infrastructure, deploy, roadmap) orchestrated by a master agent, backed by Linear.

## Entry Point

`/mayday` is the only command. It presents a menu for all operations: initialize customer, create agents, sync roadmap, create Linear cards, check version.

## Project Structure

This repo is cloned once per customer. It IS the workspace root. Customer repos are cloned into `repos/` (gitignored).

```
.cursor/commands/mayday.md           -- the single slash command (source of truth)
.cursor/procedures/                  -- procedure files (not exposed as commands)
.claude/commands/mayday.md           -- delegates to .cursor/commands/
.agent/
  workflows/mayday.md                -- delegates to .cursor/commands/
  rules/agent-system.md              -- always-on behavioral rules
templates/                           -- agent templates (source of truth)
templates/mcp.json.example           -- MCP config template (committed)
repos/                               -- customer repos (gitignored)
agent/<customer-slug>/               -- generated per-customer (committed)
.factory-state.json                  -- persisted customer state (gitignored, created by init)
VERSION                              -- local version anchor
```

## Rules

- Never use emojis
- No unnecessary documentation files or verbose comments
- Only modify files explicitly requested
- Linear card rules live in the roadmap agent -- always read it before creating or updating cards
- Never mention agent files or paths in Linear card content
- Fetch Linear tickets by identifier using `issue` tool, never `search_issues`
- After deployment/infra tasks, check git branch for Linear ticket identifier and suggest updating it

## Version Tracking

`VERSION` file is the local anchor. A Linear card titled `agent-industry-version` in each customer's group is the remote anchor. `/mayday` option 7 compares them.

## MCP Servers

A template lives at `templates/mcp.json.example` (committed). The live config is `.cursor/mcp.json` (gitignored). On first run, `/mayday` copies the template, asks for the Linear API key, and writes the config. After that, restart MCP servers and re-run `/mayday`.

- **Linear** (required) -- roadmap sync, card management, version tracking (`LINEAR_API_KEY`)
- **Context7** (recommended) -- up-to-date library documentation, required for code/infra agent creation
