# Agent Factory

A portable agent system for AI-assisted development. A hierarchical tree of scoped knowledge files orchestrated by master and sub-master agents, backed by Linear for project management. Works on Cursor, Claude Code, and Antigravity.

## Architecture

Agents form a recursive tree with unlimited depth. Any agent can have children for finer-grained context and better output quality. Logically linked concerns are unified into single files:

- **MASTER-AGENT** -- single root entry point per workspace, orchestrates the full hierarchy
- **SUB-MASTER** -- intermediate orchestrator for a domain, service, or module (e.g., "Frontend", "API", "Payments")
- **APPLICATION-AGENT** -- unified code + test: source code knowledge AND testing strategy in one file
- **PLATFORM-AGENT** -- unified infra + deploy + specialist: infrastructure, deployment procedures, AND cloud provider expertise in one file
- **ROADMAP** -- lives at the root, owns all Linear card rules

```
MASTER
  +-- ROADMAP
  +-- APPLICATION-AGENT (full) -- code + test
  |     +-- APPLICATION-AGENT (auth) -- scoped sub-agent
  |     +-- APPLICATION-AGENT (payments) -- scoped sub-agent
  +-- PLATFORM-AGENT (full) -- infra + deploy + AWS + GCP + Azure
  |     +-- PLATFORM-AGENT (aws) -- AWS specialist sub-agent
  |     +-- PLATFORM-AGENT (gcp) -- GCP specialist sub-agent
  |     +-- PLATFORM-AGENT (azure) -- Azure specialist sub-agent
  +-- SUB-MASTER: Frontend
        +-- APPLICATION-AGENT (ui-components)
        +-- PLATFORM-AGENT (cdn)
```

The application agent knows the codebase and knows how to test it. The platform agent knows the infrastructure, knows how to deploy it, and has embedded specialist knowledge for the cloud providers in use. Sub-agents carry narrower slices of knowledge so each agent operates with only the context it needs.

## How it works

The AI reads the agent files for context when you ask questions or work on tasks. When you ask about a Linear card, the AI fetches it directly via MCP. When you ask about code, it reads the relevant application agent first for structure, then looks at the repo. The roadmap agent holds card rules and priorities.

`.factory-state.json` holds workspace metadata, the agent tree, and Linear integration details. The AI reads it to know which agents and projects exist.

## Workspace layout

Clone this repo once per workspace. It becomes the workspace root. Clone the project repositories inside it under `repos/` (gitignored).

```
~/projects/my-workspace/              <-- agent-industry clone (workspace root)
  templates/                          <-- agent templates
  agent/                              <-- generated per workspace (committed)
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
  MASTER-AGENT-TEMPLATE.md
  SUB-MASTER-AGENT-TEMPLATE.md
  APPLICATION-AGENT-TEMPLATE.md
  PLATFORM-AGENT-TEMPLATE.md
  ROADMAP-TEMPLATE.md
  factory-state.json.example
  mcp.json.example
agent/                               -- generated per workspace (committed)
repos/                               -- project repos cloned here (gitignored)
.factory-state.json                  -- workspace state (gitignored)
VERSION                              -- local version anchor
CLAUDE.md                            -- Claude Code project context
AGENTS.md                            -- Antigravity/universal project context
.gitignore
```

## Agent categories

**Application** (code + test unified) -- the agent knows the codebase architecture, data models, API layer, design patterns, and testing strategy all in one file. Part I covers the codebase, Part II covers testing. When implementing a feature, the agent sees both the code patterns and the test conventions without switching files.

**Platform** (infra + deploy + specialist unified) -- the agent knows the deployment topology, infrastructure as code, CI/CD pipelines, deployment procedures, rollback strategies, and cloud provider expertise all in one file. Part I covers infrastructure, Part II covers deployment, Part III covers specialist knowledge for each cloud provider.

**Sub-agents** -- any agent can spawn scoped children. A full-scope application agent can have an auth sub-agent and a payments sub-agent. A full-scope platform agent can have an AWS sub-agent, a GCP sub-agent, and an Azure sub-agent. The parent delegates to children when a task matches their narrower scope. This keeps context small and output quality high.

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

Workspaces created with earlier versions (v1/v2/v3) auto-migrate when scaffolding is run. Individual agent files (CODE-AGENT, TEST-AGENT, INFRA-AGENT, DEPLOY-AGENT) are preserved as legacy nodes in the tree. You can regenerate them at any time using the `application` or `platform` options to consolidate into the unified format.

## Credits

Author: Clement VEROVE <verove.clement@gmail.com>
