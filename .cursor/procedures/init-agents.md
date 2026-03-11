The user wants to initialize the agent system for a customer project. This command scaffolds the full agent folder structure, validates Linear integration, and generates a MASTER-AGENT pre-populated with roadmap data from Linear if available.

## Workspace layout

This repo is cloned once per customer. The customer's repository is cloned INSIDE it. The IDE opens this folder as the workspace root so all commands, templates, and rules are detected.

```
~/projects/customer-name/            <-- agent-industry clone (workspace root)
  .cursor/commands/mayday.md         <-- detected by Cursor
  .claude/commands/mayday.md         <-- detected by Claude Code
  .agent/workflows/mayday.md         <-- detected by Antigravity
  templates/                         <-- agent templates
  agent/
    customer-name/                   <-- generated per customer (named after org_name_slug)
  repos/                             <-- customer repositories (gitignored)
    customer-repo/
    other-repo/
```

The `repos/` folder is gitignored. Nothing from the customer's code is committed to agent-industry. Nothing from agent-industry is committed to the customer's remote. The `agent/` folder is committed so agent files can be shared.

## Parameters

- `org_name` (required): The organization/customer name. Used for folder naming, metadata, and agent context.
- `linear_group` (required): The Linear group (project) name in YOUR Linear workspace. One group per customer.

## Step 0: Validate MCP prerequisites

Before anything else, verify that both required MCP servers are available and configured. The project ships a template at `templates/mcp.json.example` with the correct format. The live config lives at `.cursor/mcp.json` (gitignored, never committed).

### 0a. Linear MCP (required)

1. Read `.cursor/mcp.json`. If it does not exist or `mcpServers` is empty:
   a. Copy `templates/mcp.json.example` to `.cursor/mcp.json`
   b. Ask the user: "Enter your Linear API key (generate one at https://linear.app/settings/api):"
   c. Write the key into `.cursor/mcp.json` replacing the `YOUR_LINEAR_API_KEY` placeholder
   d. Tell the user: "MCP config written to `.cursor/mcp.json`. Restart MCP servers (Ctrl+Shift+P > 'MCP: Restart') and re-run /mayday."
   e. **Stop** -- the servers need a restart before they can be used.

2. Check that a `linear` entry (or an entry whose command/args reference `mcp-server-linear`) exists with a non-empty `LINEAR_API_KEY` that is not `YOUR_LINEAR_API_KEY`.
3. Call `get_viewer` on the Linear MCP server to confirm the API key works. If it fails, stop and tell the user the key may be invalid.

### 0b. Context7 MCP (recommended)

1. Check that `.cursor/mcp.json` contains a Context7 entry (server named `context7` or referencing `@upstash/context7-mcp` or `mcp.context7.com`). The template already includes Context7, so this should be present if the template was used.
2. If missing, warn but do not block initialization:

```
Context7 MCP not configured. It is required for code/infra agent creation.
Add to .cursor/mcp.json when ready:

  "context7": { "url": "https://mcp.context7.com/mcp" }
```

Do not proceed without a working Linear connection.

## Step 1: Check if the Linear group/project already exists

1. Call `projects` on the Linear MCP server to list all projects
2. Search for a project whose name matches `{{linear_group}}` (case-insensitive)
3. If found:
   - Store the `projectId`
   - Call `project_issues` with that `projectId` to fetch all issues
   - Store the issues list (identifier, title, state, priority, description) -- this will feed the roadmap agent
   - Tell the user: "Found Linear project '{{linear_group}}' with N issues. These will be used to populate the roadmap agent."
4. If NOT found:
   - Tell the user: "No Linear project named '{{linear_group}}' found. The roadmap agent will be created with an empty backlog. You can populate it later by creating cards in Linear and re-running `/init-agents`."
   - Proceed with empty issues list

## Step 2: Scaffold the agent folder structure

Create the following directory tree at the project root. The customer's agent files live in a subfolder of `agent/` named after `{{ORG_NAME_SLUG}}`:

```
agent/
  {{ORG_NAME_SLUG}}/
    MASTER-AGENT-{{ORG_NAME_UPPER}}.md
    code/
    test/
    infra/
    plans/
```

The `templates/` folder already exists at the project root (shipped with agent-industry). Do NOT recreate or overwrite it. If `templates/` already exists with template files, do NOT overwrite them. They are the source of truth.

## Step 3: Read and apply the MASTER-AGENT template

Read the template at `templates/MASTER-AGENT-TEMPLATE.md`. Replace all placeholders:

- `{{ORG_NAME}}` -- the org name as provided (title case)
- `{{ORG_NAME_SLUG}}` -- the slugified org name
- `{{ORG_NAME_UPPER}}` -- the uppercased slug (hyphens preserved)
- `{{LINEAR_PROJECT}}` -- the Linear group/project name
- `{{DATE}}` -- today's date in YYYY-MM-DD format
- `{{DOMAIN_OVERVIEW}}` -- leave as `[TO BE FILLED BY USER]` for now
- `{{LINEAR_TICKETS_LIST}}` -- YAML list of ticket identifiers from Step 1, or `  - none` if empty

Write the result to `agent/{{ORG_NAME_SLUG}}/MASTER-AGENT-{{ORG_NAME_UPPER}}.md`.

## Step 4: Generate the roadmap agent from Linear issues

Read the template at `templates/ROADMAP-TEMPLATE.md`. Replace all placeholders:

- `{{ORG_NAME}}` -- the org name
- `{{ORG_NAME_SLUG}}` -- the slugified org name
- `{{ORG_NAME_UPPER}}` -- the uppercased slug
- `{{LINEAR_PROJECT}}` -- the Linear group/project name
- `{{DATE}}` -- today's date
- `{{LINEAR_TICKETS}}` -- comma-separated list of issue identifiers from Step 1 (or "none" if no project found)
- `{{DEPENDENCY_GRAPH}}` -- if issues exist, create a simple linear graph ordered by priority. If no issues, write `No issues yet`
- `{{CURRENT_STATE}}` -- summary of issue states (e.g. "3 Todo, 1 In Progress, 2 Done") or "No issues imported yet"
- `{{ISSUES_SECTION}}` -- for each issue found in Step 1, generate a section:

```markdown
### {{IDENTIFIER}}: {{TITLE}}

**State**: {{state}}
**Priority**: {{priority}}

{{description or "No description yet."}}
```

If no issues were found, write:

```markdown
No Linear issues found for this project. Create cards in Linear under the "{{linear_group}}" project and run `/update-roadmap` to populate this roadmap.
```

Write the result to `agent/{{ORG_NAME_SLUG}}/plans/ROADMAP-{{ORG_NAME_UPPER}}.md`.

## Step 5: Stamp the agent-industry version

1. Read the `VERSION` file at the agent-industry root to get the current version string (e.g. `1.0.0`)
2. Replace `{{AGENT_INDUSTRY_VERSION}}` in the generated MASTER-AGENT and ROADMAP files with this version string
3. Search the Linear project (from Step 1) for an issue whose title is exactly `agent-industry-version`
4. If it exists, update its description with the current version using `update_issue`
5. If it does NOT exist, create it:
   - Title: `agent-industry-version`
   - Description: the version string (e.g. `1.0.0`)
   - Use `create_issue` with the same `teamId` as the other issues in this project
   - After creation, immediately set its state to "Done" using `update_issue_state` -- this is a metadata card, not a task

This card is the remote version anchor. When `/update-roadmap` runs, it compares the local `VERSION` file against this card's description to detect drift.

## Step 6: Update the MASTER-AGENT with the roadmap reference

Go back to the generated MASTER-AGENT file and fill in the roadmap section's `linear_tickets` field with the actual ticket identifiers.

## Step 7: Write factory state file

Write `.factory-state.json` at the workspace root with the customer identity and initial agent flags. This file is gitignored and persists state across `/mayday` invocations so the system doesn't re-discover everything each time.

```json
{
  "org_name": "{{ORG_NAME}}",
  "org_name_slug": "{{org_name_slug}}",
  "org_name_upper": "{{ORG_NAME_UPPER}}",
  "linear_project": "{{LINEAR_PROJECT}}",
  "agent_root": "agent/{{org_name_slug}}",
  "initialized_at": "{{DATE}}",
  "agents": {
    "master": true,
    "roadmap": true,
    "code": false,
    "test": false,
    "infra": false,
    "deploy": false
  },
  "repos": []
}
```

Populate the `repos` array by listing subdirectories in `repos/` that contain a `.git` folder.

## Step 8: Confirm to the user

Print a summary:

```
Agent system initialized for {{org_name}}:

  agent/{{org_name_slug}}/MASTER-AGENT-{{ORG_NAME_UPPER}}.md     -- orchestrator (entry point)
  agent/{{org_name_slug}}/code/                                  -- run /create-code-agent to populate
  agent/{{org_name_slug}}/test/                                  -- run /create-test-agent to populate (requires code agent)
  agent/{{org_name_slug}}/infra/                                 -- run /create-infra-agent to populate
  agent/{{org_name_slug}}/plans/ROADMAP-...                      -- populated from Linear (N issues)
  templates/                                                     -- reusable templates

  Agent Industry version: X.Y.Z (synced to Linear card "agent-industry-version")

Next steps:
1. Fill in the "Domain Overview" section in the MASTER-AGENT
2. Run /create-code-agent to generate the code agent
3. Run /create-infra-agent to generate the infra agent
4. Run /update-roadmap any time to sync with Linear
```

## Important rules

- Do NOT hardcode any project-specific names, paths, or references in the generated files. Everything uses the `{{org_name}}` and `{{linear_group}}` parameters.
- The templates in `templates/` are the source of truth. The command only reads and fills them.
- All generated files must include the Linear Card Policy section.
- All generated files must include Document Maintenance metadata blocks.
