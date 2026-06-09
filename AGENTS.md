# Agent Industry

Portable agent system for AI-assisted development. Scaffolds a hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear. Supports both unified agents (application, platform) and split agents (code, test, infra, deploy), plus shared expert agents for cross-cutting specialist knowledge.

## Entry Point

`/mayday` is the only command. It presents a menu for all operations: initialize workspace, create agents (application, platform, code, test, infra, deploy, expert, sub-masters), sync roadmap, create Linear cards, check version.

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children. The MASTER-AGENT is the root. SUB-MASTER agents orchestrate subtrees for domains, services, or modules.

Two agent models coexist:

**Unified agents** (fewer files, broader context per file):
- **application** -- code + test in one file
- **platform** -- infra + deploy + specialist knowledge in one file

**Split agents** (more files, narrower scope per file):
- **code** -- source code knowledge only
- **test** -- testing strategy only
- **infra** -- infrastructure only
- **deploy** -- deployment procedures only

**Shared expert agents** live at `agent/shared/` and provide specialist knowledge on a technology or platform (e.g. AWS, Docker, Terraform). Domain agents can reference experts via a `refs` field.

Other agent types:
- **planning** (roadmap) -- Linear integration, backlog, dependency tracking
- **orchestration** (master, sub-master) -- routing and delegation, no implementation

## Project Structure

This repo is cloned once per project. It IS the project repo. Project code lives in `stack/` (backend/, frontend/, terraform/, docs/) and is committed.

```
.cursor/commands/mayday.md           -- the single slash command (source of truth)
.cursor/procedures/                  -- procedure files (not exposed as commands)
.claude/commands/mayday.md           -- delegates to .cursor/commands/
.agent/
  workflows/mayday.md                -- delegates to .cursor/commands/
  rules/agent-system.md              -- always-on behavioral rules
templates/                           -- agent templates (source of truth)
  APPLICATION-AGENT-TEMPLATE.md      -- unified code + test
  PLATFORM-AGENT-TEMPLATE.md        -- unified infra + deploy + specialist
  SUB-MASTER-AGENT-TEMPLATE.md      -- orchestrator (unified model)
  DOCKERFILE-AGENT.md               -- specialized platform agent
  domain/                            -- split agent templates
    MASTER-AGENT-TEMPLATE.md
    CODE-AGENT-TEMPLATE.md
    TEST-AGENT-TEMPLATE.md
    INFRA-AGENT-TEMPLATE.md
    DEPLOY-AGENT-TEMPLATE.md
    ROADMAP-TEMPLATE.md
    SUB-MASTER-AGENT-TEMPLATE.md
  shared/                            -- expert agent template
    EXPERT-AGENT-TEMPLATE.md
  config/                            -- configuration templates
    mcp.json.example
    factory-state.json.example
stack/                               -- project code (committed)
agent/<workspace-slug>/              -- generated per workspace (gitignored in template)
agent/shared/                        -- shared expert agents
.factory-state.json                  -- workspace state (gitignored in template)
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

`VERSION` file is the local anchor. A Linear card titled `agent-industry-version` in the workspace's project is the remote anchor. `/mayday` option `version` compares them.

## MCP Servers

A template lives at `templates/config/mcp.json.example` (committed). The live config is `.cursor/mcp.json` (gitignored). On first run, `/mayday` copies the template, asks for the Linear API key, and writes the config. After that, restart MCP servers and re-run `/mayday`.

- **Linear** (required) -- roadmap sync, card management, version tracking (`LINEAR_API_KEY`)
- **Context7** (recommended) -- up-to-date library documentation, required for agent creation
