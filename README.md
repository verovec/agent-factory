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
  +-- PLATFORM-AGENT (full) -- infra + deploy + AWS + K8s
  |     +-- PLATFORM-AGENT (aws) -- AWS specialist sub-agent
  |     +-- PLATFORM-AGENT (k8s) -- K8s specialist sub-agent
  +-- SUB-MASTER: Frontend
        +-- APPLICATION-AGENT (ui-components)
        +-- PLATFORM-AGENT (cdn)
```

The application agent knows the codebase and knows how to test it. The platform agent knows the infrastructure, knows how to deploy it, and has embedded specialist knowledge for the cloud providers in use. Sub-agents carry narrower slices of knowledge so each agent operates with only the context it needs.

## Workspace layout

Clone this repo once per workspace. It becomes the workspace root. Clone the project repositories inside it under `repos/` (gitignored).

```
~/projects/my-workspace/              <-- agent-industry clone (workspace root)
  .cursor/commands/mayday.md          <-- detected by Cursor
  .claude/commands/mayday.md          <-- detected by Claude Code
  .agent/workflows/mayday.md          <-- detected by Antigravity
  templates/                          <-- agent templates
  agent/                              <-- generated per workspace (committed)
  repos/                              <-- project repos (gitignored)
    my-app/
  VERSION
```

This structure is required because all three IDEs (Cursor, Claude Code, Antigravity) only detect commands, workflows, and rules from the workspace root. They will not traverse into subdirectories.

Linear is organized with one group (project) per workspace, all in your Linear team.

## Entry point

Run `/mayday` to get started. It is the only slash command exposed across all IDEs. The menu is contextual -- it adapts based on initialization state, agent tree depth, and which agents exist:

| Option | Action | What it does |
|--------|--------|-------------|
| init | Initialize a new workspace | Validates Linear + Context7, scaffolds MASTER + ROADMAP, creates version card |
| submaster | Create a Sub-Master | Adds an orchestration layer for a domain/service/module |
| application | Create an Application Agent | Parses codebase and test landscape, generates unified code + test agent |
| platform | Create a Platform Agent | Parses infra, deployment, and cloud providers, generates unified infra + deploy + specialist agent |
| update | Update agents and sync Linear | Tree-aware update: walks the hierarchy, updates only agents whose scope intersects with changes |
| sync | Sync Roadmap with Linear | Checks version, pulls latest from Linear, diffs and updates the roadmap |
| feature | New feature card | Suggests next card from roadmap or drafts a new feature card in Linear |
| bug | Bug / fix card | Drafts and creates a bug/fix card in Linear following the roadmap's card rules |
| version | Check version | Compares local, generated, and Linear versions side by side |

## Project structure

```
.cursor/
  commands/mayday.md                 -- the single slash command (source of truth)
  procedures/                        -- procedure files (logic, not exposed as commands)
    init-agents.md
    create-application-agent.md
    create-platform-agent.md
    create-sub-master.md
    update-agents.md
    update-roadmap.md
    create-feature-card.md
    create-bug-card.md
    check-version.md
.claude/commands/mayday.md           -- delegates to .cursor/commands/
.agent/
  workflows/mayday.md                -- delegates to .cursor/commands/
  rules/agent-system.md              -- always-on behavioral rules
templates/                           -- agent templates (source of truth)
  MASTER-AGENT-TEMPLATE.md
  SUB-MASTER-AGENT-TEMPLATE.md
  APPLICATION-AGENT-TEMPLATE.md
  PLATFORM-AGENT-TEMPLATE.md
  ROADMAP-TEMPLATE.md
  factory-state.json.example
  mcp.json.example
repos/                               -- project repos cloned here (gitignored)
agent/                               -- generated per workspace (committed)
VERSION                              -- local version anchor
CLAUDE.md                            -- Claude Code project context
AGENTS.md                            -- Antigravity/universal project context
.factory-state.json                  -- persisted workspace state (gitignored)
.gitignore                           -- ignores repos/ and .factory-state.json
```

The Cursor procedure files in `.cursor/procedures/` are the single source of truth for all logic. Claude Code and Antigravity delegate to them.

## Agent categories

Agents are grouped by concern:

**Application** (code + test unified) -- the agent knows the codebase architecture, data models, API layer, design patterns, and testing strategy all in one file. Part I covers the codebase, Part II covers testing. When implementing a feature, the agent sees both the code patterns and the test conventions without switching files.

**Platform** (infra + deploy + specialist unified) -- the agent knows the deployment topology, infrastructure as code, CI/CD pipelines, deployment procedures, rollback strategies, and cloud provider expertise all in one file. Part I covers infrastructure, Part II covers deployment, Part III covers specialist knowledge for each cloud provider.

**Sub-agents** -- any agent can spawn scoped children. A full-scope application agent can have an auth sub-agent and a payments sub-agent. A full-scope platform agent can have an AWS sub-agent and a K8s sub-agent. The parent delegates to children when a task matches their narrower scope. This keeps context small and output quality high.

## Version management

Agent-industry tracks its version through a `VERSION` file at the root and a corresponding Linear card per workspace.

When you initialize a workspace (`init`), it creates a Linear card titled `agent-industry-version` in the workspace's group with the version as its description.

When you sync the roadmap (`sync`) or check version (`version`), it compares the local `VERSION` file against the Linear card:
- Remote newer than local = your copy is outdated, pull the latest
- Local newer than remote = pushes the new version to Linear
- Match = in sync

This lets you update agent-industry once, then see which workspaces are on which version by checking their Linear group.

## Prerequisites

Two MCP servers must be configured before running `/mayday`:

**Linear MCP** -- roadmap sync, card management, version tracking. Needs a Linear API key from your team.

**Context7 MCP** -- up-to-date library documentation. Agents use this instead of relying on training data. Get a key at [context7.com/dashboard](https://context7.com/dashboard).

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

**Claude Code** -- run from your terminal:

```bash
claude mcp add linear -- npx -y @mkusaka/mcp-server-linear
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

Set `LINEAR_API_KEY` in your environment. Verify with `/mcp` inside Claude Code.

**Antigravity** -- add both MCP servers via Agent Manager > MCP Settings. Use the same packages as above.

## Linear integration

The roadmap agent is the single source of truth for all Linear card rules. Every other agent defers to it:

- **Card structure** -- opening paragraph, acceptance criteria (`*` bullets), todo checkboxes (`- [ ]`)
- **Formatting** -- bold headings (not `#`), inline code for paths and env vars, no emojis, no filler
- **Tone** -- short direct sentences, operator perspective for AC, implementer perspective for todos
- **Defaults** -- cards in "Todo" state (not "Backlog"), cross-references by identifier
- **MCP usage** -- `create_issue` to create, `issue` to fetch by identifier (never `search_issues`), `update_issue` with UUID
- **Confidentiality** -- never mention agent files, paths, or internal structure in card content

## Setting up a new workspace

```bash
git clone <agent-industry-url> ~/projects/my-workspace
cd ~/projects/my-workspace
mkdir -p repos
git clone <project-repo-url> repos/my-app
```

Then:

1. Open `~/projects/my-workspace` as the workspace root in your IDE
2. Create a Linear group (project) for the workspace in your team
3. Configure the Linear and Context7 MCP servers if not already done (see setup above)
4. Run `/mayday` and pick `init`
5. Create an application agent (`/mayday > application`) for your codebase -- this covers code + tests
6. Create a platform agent (`/mayday > platform`) for your infrastructure -- this covers infra + deploy + cloud providers
7. For large projects: create sub-masters first to organize by domain, then create scoped agents under them
8. For focused expertise: create sub-agents under existing agents to narrow the context (e.g. an AWS sub-agent under a full platform agent)

## Migrating from older versions

Workspaces created with earlier versions (v1/v2/v3) auto-migrate when you run `/mayday`. Individual agent files (CODE-AGENT, TEST-AGENT, INFRA-AGENT, DEPLOY-AGENT) are preserved as legacy nodes in the tree. You can regenerate them at any time using the `application` or `platform` options to consolidate into the unified format.

## Credits

Author: Clement VEROVE <verove.clement@gmail.com>
