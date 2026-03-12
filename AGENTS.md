# Agent Industry

Portable agent system for AI-assisted development. Scaffolds a hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear. Logically linked concerns are unified: code + test live in a single application agent, infra + deploy + specialist knowledge live in a single platform agent.

## Entry Point

`/mayday` is the only command. It presents a menu for all operations: initialize workspace, create agents (application, platform, sub-masters), sync roadmap, create Linear cards, check version.

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children. The MASTER-AGENT is the root. SUB-MASTER agents orchestrate subtrees for domains, services, or modules. Leaf agents are grouped by category:

- **application** -- unified code + test: source code knowledge AND testing strategy in one file. Can spawn scoped sub-agents (e.g. auth, payments) for tighter context and better code quality.
- **platform** -- unified infra + deploy + specialist: infrastructure, deployment procedures, AND cloud provider expertise in one file. Can spawn scoped sub-agents (e.g. AWS-only, K8s-only) for focused provider knowledge.
- **planning** (roadmap) -- Linear integration, backlog, dependency tracking
- **orchestration** (master, sub-master) -- routing and delegation, no implementation

## Project Structure

This repo is cloned once per workspace. It IS the workspace root. Project repos are cloned into `repos/` (gitignored).

```
.cursor/commands/mayday.md           -- the single slash command (source of truth)
.cursor/procedures/                  -- procedure files (not exposed as commands)
.claude/commands/mayday.md           -- delegates to .cursor/commands/
.agent/
  workflows/mayday.md                -- delegates to .cursor/commands/
  rules/agent-system.md              -- always-on behavioral rules
templates/                           -- agent templates (source of truth)
templates/mcp.json.example           -- MCP config template (committed)
templates/factory-state.json.example -- state file schema reference (v4)
repos/                               -- project repos (gitignored)
agent/<workspace-slug>/              -- generated per workspace (committed), hierarchical tree
.factory-state.json                  -- persisted workspace state (gitignored, created by init)
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

`VERSION` file is the local anchor. A Linear card titled `agent-industry-version` in each workspace's group is the remote anchor. `/mayday` option 7 compares them.

## MCP Servers

A template lives at `templates/mcp.json.example` (committed). The live config is `.cursor/mcp.json` (gitignored). On first run, `/mayday` copies the template, asks for the Linear API key, and writes the config. After that, restart MCP servers and re-run `/mayday`.

- **Linear** (required) -- roadmap sync, card management, version tracking (`LINEAR_API_KEY`)
- **Context7** (recommended) -- up-to-date library documentation, required for agent creation
