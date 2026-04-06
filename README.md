# Agent Factory

A portable agent system for AI-assisted development. A hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear for project management. Works on Cursor, Claude Code, and Antigravity.

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children for finer-grained context and better output quality. Two agent models coexist -- choose based on project complexity:

**Unified model** (fewer files, broader context per file):
- **APPLICATION-AGENT** -- code + test in one file
- **PLATFORM-AGENT** -- infra + deploy + specialist knowledge in one file

**Split model** (more files, narrower scope per file):
- **CODE-AGENT** -- source code knowledge
- **TEST-AGENT** -- testing strategy and conventions
- **INFRA-AGENT** -- infrastructure as code, secrets, CI/CD
- **DEPLOY-AGENT** -- environment promotion, rollback, release tracking

**Shared across both models**:
- **MASTER-AGENT** -- single root entry point, orchestrates the full hierarchy
- **SUB-MASTER** -- intermediate orchestrator for a domain, service, or module
- **ROADMAP** -- owns all Linear card rules, backlog, dependency tracking
- **EXPERT-AGENT** -- shared specialist knowledge (e.g. AWS, Terraform, Docker)
- **DOCKERFILE-AGENT** -- specialized platform agent for container patterns

```
MASTER
  +-- ROADMAP
  +-- APPLICATION-AGENT (full) -- code + test
  |     +-- APPLICATION-AGENT (auth) -- scoped sub-agent
  +-- PLATFORM-AGENT (full) -- infra + deploy + AWS
  +-- SUB-MASTER: Frontend
        +-- CODE-AGENT (ui-components)
        +-- TEST-AGENT (ui-components)
        +-- INFRA-AGENT (cdn)
```

## How it works

The AI reads the agent files for context when you ask questions or work on tasks. When you ask about a Linear card, the AI fetches it directly via MCP. When you ask about code, it reads the relevant agent first for structure, then looks at the repo. The roadmap agent holds card rules and priorities.

`.factory-state.json` holds workspace metadata, the agent tree, and Linear integration details. The AI reads it to know which agents and projects exist.

## Workspace layout

Clone this repo once per workspace. It becomes the workspace root. Clone the project repositories inside it under `repos/` (gitignored).

```
~/projects/my-workspace/              <-- agent-industry clone (workspace root)
  templates/                          <-- agent templates
  agent/                              <-- generated per workspace
    shared/                           <-- shared expert agents
  repos/                              <-- project repos (gitignored)
    my-app/
  VERSION
```

## Linear integration

Each workspace maps to a Linear team and project. The roadmap agent stores the team and project IDs. Cards are created with both `teamId` and `projectId`.

The roadmap agent is the single source of truth for all Linear card rules:

- **Card structure** -- opening paragraph, acceptance criteria (`*` bullets), todo checkboxes (`- [ ]`)
- **Formatting** -- bold headings (not `#`), inline code for paths and env vars, no emojis, no filler
- **Tone** -- short direct sentences, operator perspective for AC, implementer perspective for todos
- **MCP usage** -- `create_issue` to create, `issue` to fetch by identifier (never `search_issues`), `update_issue` with UUID
- **Confidentiality** -- never mention agent files, paths, or internal structure in card content

## Project structure

```
templates/                           -- agent templates (source of truth)
  APPLICATION-AGENT-TEMPLATE.md      -- unified code + test
  PLATFORM-AGENT-TEMPLATE.md        -- unified infra + deploy + specialist
  SUB-MASTER-AGENT-TEMPLATE.md      -- orchestrator
  DOCKERFILE-AGENT.md               -- container patterns and security
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
    factory-state.json.example
    mcp.json.example
agent/                               -- generated per workspace (gitignored in template)
repos/                               -- project repos cloned here (gitignored)
.factory-state.json                  -- workspace state (gitignored in template)
VERSION                              -- local version anchor
CLAUDE.md                            -- Claude Code project context
AGENTS.md                            -- Antigravity/universal project context
.gitignore
```

## Version management

Agent-industry tracks its version through a `VERSION` file at the root and a corresponding Linear card per workspace titled `agent-industry-version`.

## Prerequisites

Two MCP servers must be configured:

**Linear MCP** -- roadmap sync, card management, version tracking. Needs a Linear API key from your team.

**Context7 MCP** -- up-to-date library documentation. Agents use this instead of relying on training data.

### MCP setup by IDE

**Cursor** -- add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@mkusaka/mcp-server-linear"],
      "env": { "LINEAR_API_KEY": "YOUR_KEY" }
    },
    "context7": {
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

**Claude Code** -- add to `.mcp.json` at project root (gitignored):

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@mkusaka/mcp-server-linear"],
      "env": { "LINEAR_API_KEY": "YOUR_KEY" }
    },
    "context7": {
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

Enable MCP servers in `~/.claude/settings.json`:

```json
{
  "enableAllProjectMcpServers": true
}
```

**Antigravity** -- add both MCP servers via Agent Manager > MCP Settings. Use the same packages as above.

## Setting up a new workspace

```bash
git clone <agent-industry-url> ~/projects/my-workspace
cd ~/projects/my-workspace
mkdir -p repos
git clone <project-repo-url> repos/my-app
```

Then:

1. Open `~/projects/my-workspace` as the workspace root in your IDE
2. Create a Linear project for the workspace in your team
3. Configure the Linear and Context7 MCP servers (see setup above)
4. Ask the AI to initialize the workspace, or use the scaffolding procedures in `.cursor/procedures/`

## Migrating from older versions

Workspaces created with earlier versions (v1/v2/v3) auto-migrate when scaffolding is run. Individual agent files are preserved as legacy nodes in the tree. You can regenerate them at any time using the unified or split agent options.

## Credits

Author: Clement VEROVE <verove.clement@gmail.com>
