# Agent Industry

A portable agent system for AI-assisted development. Four scoped knowledge files (code, infrastructure, deploy, roadmap) orchestrated by a master agent, backed by Linear for project management. Works on Cursor, Claude Code, and Antigravity.

## Workspace layout

Clone this repo once per customer. It becomes the workspace root. Clone the customer's repositories inside it under `repos/` (gitignored).

```
~/projects/customer-name/            <-- agent-industry clone (workspace root)
  .cursor/commands/mayday.md         <-- detected by Cursor
  .claude/commands/mayday.md         <-- detected by Claude Code
  .agent/workflows/mayday.md         <-- detected by Antigravity
  templates/                         <-- agent templates
  agent/                             <-- generated per customer (gitignored)
  repos/                             <-- customer repos (gitignored)
    customer-repo/
  VERSION
```

This structure is required because all three IDEs (Cursor, Claude Code, Antigravity) only detect commands, workflows, and rules from the workspace root. They will not traverse into subdirectories.

Linear is organized with one group (project) per customer, all in your workspace.

## Entry point

Run `/mayday` to get started. It is the only slash command exposed across all IDEs. The menu is contextual -- it adapts based on initialization state and which agents exist, prioritizing the most useful next action:

| Option | Action | What it does |
|--------|--------|-------------|
| init | Initialize a new customer | Validates Linear + Context7, scaffolds agent tree, populates roadmap, creates version card |
| code | Create a Code Agent | Parses the codebase, generates the CODE-AGENT, updates the master |
| infra | Create an Infrastructure Agent | Parses infrastructure, generates the INFRA-AGENT, updates the master |
| deploy | Create a Deploy Agent | Reads infra agents and template, generates the DEPLOY-AGENT with promotion pipeline and rollback procedures |
| update | Update agents and sync Linear | Re-scans repos, regenerates stale agents, syncs roadmap and version with Linear |
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
    create-code-agent.md
    create-infra-agent.md
    update-roadmap.md
.claude/commands/mayday.md           -- delegates to .cursor/commands/
.agent/
  workflows/mayday.md                -- delegates to .cursor/commands/
  rules/agent-system.md              -- always-on behavioral rules
templates/                           -- agent templates (source of truth)
  MASTER-AGENT-TEMPLATE.md
  CODE-AGENT-TEMPLATE.md
  INFRA-AGENT-TEMPLATE.md
  DEPLOY-AGENT-TEMPLATE.md
  ROADMAP-TEMPLATE.md
repos/                               -- customer repos cloned here (gitignored)
agent/                               -- generated per-customer (gitignored)
VERSION                              -- local version anchor
CLAUDE.md                            -- Claude Code project context
AGENTS.md                            -- Antigravity/universal project context
.gitignore                           -- ignores repos/ and agent/
```

The Cursor procedure files in `.cursor/procedures/` are the single source of truth for all logic. Claude Code and Antigravity delegate to them.

## Version management

Agent-industry tracks its version through a `VERSION` file at the root and a corresponding Linear card per customer.

When you initialize a customer (`init`), it creates a Linear card titled `agent-industry-version` in the customer's group with the version as its description.

When you sync the roadmap (`sync`) or check version (`version`), it compares the local `VERSION` file against the Linear card:
- Remote newer than local = your copy is outdated, pull the latest
- Local newer than remote = pushes the new version to Linear
- Match = in sync

This lets you update agent-industry once, then see which customers are on which version by checking their Linear group.

## Prerequisites

Two MCP servers must be configured before running `/mayday`:

**Linear MCP** -- roadmap sync, card management, version tracking. Needs a Linear API key from your workspace.

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

## Onboarding a new customer

```bash
git clone <agent-industry-url> ~/projects/customer-name
cd ~/projects/customer-name
mkdir -p repos
git clone <customer-repo-url> repos/customer-repo
```

Then:

1. Open `~/projects/customer-name` as the workspace root in your IDE
2. Create a Linear group (project) for the customer in your workspace
3. Configure the Linear and Context7 MCP servers if not already done (see setup above)
4. Run `/mayday` and pick `init`

## Credits

Author: Clément VEROVE <verove.clement@gmail.com>
