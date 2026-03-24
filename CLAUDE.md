# Agent Industry

Portable agent system for AI-assisted development. Hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear. Unified agents: application (code + test) and platform (infra + deploy + cloud specialist).

## How to work in this workspace

Each workspace has an agent tree under `agent/`. The MASTER-AGENT is the root. Leaf agents are either application (code + test) or platform (infra + deploy + specialist). SUB-MASTER agents orchestrate subtrees for domains, services, or modules.

When the user asks about a topic, read the relevant agents. When they ask about a Linear card, fetch it directly. When they ask about code, read the application agent for context first, then look at the repo.

### Answering questions

- **Linear cards**: Fetch by identifier using the `issue` MCP tool (e.g. INF-19). Never use `search_issues`.
- **Workspace context**: Read the MASTER-AGENT, then drill into the relevant leaf agent (application or platform).
- **Roadmap**: Read the ROADMAP agent for card rules, dependency graph, and priorities.
- **Codebase**: Project repos are in `repos/`. Read the application agent first to understand structure before diving in.
- **Infrastructure**: Read the platform agent for deployment topology, cloud providers, and IaC details.

### Creating or updating Linear cards

Always read the roadmap agent first -- it contains the card rules. Follow them exactly.

- Use `create_issue` with both `teamId` and `projectId` from `.factory-state.json`
- Use `update_issue` with the issue UUID
- Use `update_issue_state` to change card state
- Never mention agent files or paths in card content

### Workspace lookup

`.factory-state.json` holds workspace metadata:
- `workspace_name`, `workspace_slug` -- identity
- `linear_team`, `linear_team_id` -- the Linear team
- `linear_project`, `linear_project_id` -- the workspace's Linear project
- `repos` -- array of repo names
- `tree` -- recursive agent tree with paths to each agent file

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children.

- **application** -- unified code + test: source code knowledge AND testing strategy in one file
- **platform** -- unified infra + deploy + specialist: infrastructure, deployment, AND cloud provider expertise in one file
- **planning** (roadmap) -- Linear integration, backlog, dependency tracking
- **orchestration** (master, sub-master) -- routing and delegation, no implementation

## Project Structure

```
templates/                           -- agent templates (source of truth)
  APPLICATION-AGENT-TEMPLATE.md
  PLATFORM-AGENT-TEMPLATE.md
  MASTER-AGENT-TEMPLATE.md
  SUB-MASTER-AGENT-TEMPLATE.md
  ROADMAP-TEMPLATE.md
  mcp.json.example
  factory-state.json.example
agent/                               -- generated per workspace (committed)
repos/                               -- project repos (gitignored)
.factory-state.json                  -- workspace state (gitignored)
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

`VERSION` file is the local anchor. A Linear card titled `agent-industry-version` in the workspace's group is the remote anchor.

## MCP Servers

- **Linear** (required) -- roadmap sync, card management, version tracking (`LINEAR_API_KEY`)
- **Context7** (recommended) -- up-to-date library documentation, required for agent creation

Live config: `.mcp.json` (gitignored). Template: `templates/mcp.json.example`.
