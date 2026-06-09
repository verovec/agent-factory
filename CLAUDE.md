# Agent Industry

Portable agent system for AI-assisted development. Hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear. Supports unified agents (application, platform) and split agents (code, test, infra, deploy), plus shared expert agents.

## How to work in this workspace

Each workspace has an agent tree under `agent/`. The MASTER-AGENT is the root. Leaf agents are either unified (application, platform) or split (code, test, infra, deploy). SUB-MASTER agents orchestrate subtrees. Shared expert agents live at `agent/shared/`.

When the user asks about a topic, read the relevant agents. When they ask about a Linear card, fetch it directly. When they ask about code, read the application or code agent for context first, then look at the repo.

### Answering questions

- **Linear cards**: Fetch by identifier using the `issue` MCP tool (e.g. INF-19). Never use `search_issues`.
- **Workspace context**: Read the MASTER-AGENT, then drill into the relevant leaf agent (application, platform, code, infra, test, deploy).
- **Roadmap**: Read the ROADMAP agent for card rules, dependency graph, and priorities.
- **Shared experts**: When a domain agent has a `refs` field, also read the referenced expert agents from `agent/shared/`.
- **Codebase**: Project code is in `stack/`. Read the application or code agent first to understand structure before diving in.
- **Infrastructure**: Read the platform or infra agent for deployment topology, cloud providers, and IaC details.

### Creating or updating Linear cards

Always read the roadmap agent first -- it contains the card rules. Follow them exactly.

- Use `create_issue` with both `teamId` and `projectId` from `.factory-state.json`
- Use `update_issue` with the issue UUID
- Use `update_issue_state` to change card state
- Never mention agent files or paths in card content

### Workspace lookup

`.factory-state.json` holds workspace metadata:
- `org_name`, `org_name_slug` -- identity
- `linear_team`, `linear_team_id` -- the Linear team
- `linear_project` -- the workspace's Linear project
- `stack` -- the project monorepo subfolders
- `shared_agents` -- array of shared expert agents
- `tree` -- recursive agent tree with paths to each agent file

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children.

- **application** -- unified code + test in one file
- **platform** -- unified infra + deploy + specialist in one file
- **code**, **test**, **infra**, **deploy** -- split agents for narrower scope
- **expert** -- shared specialist knowledge (e.g. AWS, Terraform, Docker)
- **planning** (roadmap) -- Linear integration, backlog, dependency tracking
- **orchestration** (master, sub-master) -- routing and delegation, no implementation

## Project Structure

```
templates/                           -- agent templates (source of truth)
  APPLICATION-AGENT-TEMPLATE.md      -- unified code + test
  PLATFORM-AGENT-TEMPLATE.md        -- unified infra + deploy + specialist
  SUB-MASTER-AGENT-TEMPLATE.md      -- orchestrator
  DOCKERFILE-AGENT.md               -- specialized platform agent
  domain/                            -- split agent templates
  shared/                            -- expert agent template
  config/                            -- mcp.json.example, factory-state.json.example
agent/                               -- generated per workspace
  shared/                            -- shared expert agents
stack/                               -- project code (committed)
.factory-state.json                  -- workspace state
VERSION                              -- local version anchor
```

## Rules

- Never use emojis
- No unnecessary documentation files or verbose comments
- Only modify files explicitly requested
- Linear card rules live in the roadmap agent -- always read it before creating or updating cards
- Never mention agent files or paths in Linear card content
- Fetch Linear tickets by identifier using `issue` tool, never `search_issues`

## Version Tracking

`VERSION` file is the local anchor. A Linear card titled `agent-industry-version` in the workspace's project is the remote anchor.

## MCP Servers

- **Linear** (required) -- roadmap sync, card management, version tracking (`LINEAR_API_KEY`)
- **Context7** (recommended) -- up-to-date library documentation, required for agent creation

Live config: `.cursor/mcp.json` (gitignored). Template: `templates/config/mcp.json.example`.
