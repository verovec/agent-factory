# {{ORG_NAME}} Roadmap - Implementation Plan

```
LINEAR_TEAM: {{LINEAR_TEAM}}
LINEAR_PROJECT: {{LINEAR_PROJECT}}
LINEAR_TICKETS: {{LINEAR_TICKETS}}
AGENT_INDUSTRY_VERSION: {{AGENT_INDUSTRY_VERSION}}
SCOPE: {{ORG_NAME}} implementation lifecycle
STATUS: Active
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
```

## Linear Card Rules

This section is the single source of truth for how Linear cards are created and updated across all agents in this domain. Every agent references this section via the roadmap gate. Do not duplicate these rules elsewhere.

### Confidentiality

- NEVER mention agent files, their paths, their existence, or their structure in card content
- NEVER reference the `agent/` folder, `MASTER-AGENT`, `CODE-AGENT`, `INFRA-AGENT`, or any `*.md` agent file
- NEVER describe how agent documentation is organized or where it lives
- Cards are for humans and must contain only actionable implementation content

### Card Structure

Every card description follows this exact layout:

1. **Opening paragraph** - 1-3 sentences explaining what the card is about. Plain language, no jargon walls. Say what happens, not how it works internally
2. **Acceptance Criteria** (heading with `**Acceptance Criteria**`) - bullet list of observable outcomes. Each item starts with `*` and describes a verifiable result, not an implementation step. Write them as "X does Y" or "X is Z", not "implement X"
3. **Todo** (heading with `**Todo**`) - checkbox list of concrete implementation tasks. Each item starts with `- [ ]` and is a single actionable step someone can pick up and do

### Formatting

- Use markdown bold (`**text**`) for section headings inside the description, not `#` headings (Linear renders them poorly)
- Use `*` bullets for acceptance criteria, `- [ ]` checkboxes for todos
- Use inline code (backticks) for command names, file paths, resource names, and environment variables
- Use markdown tables only when comparing a small set of items side by side. Do not overuse
- No emojis. No filler language ("In order to...", "This ticket aims to..."). Get to the point
- Keep it human-readable - someone unfamiliar with the codebase should understand the intent after reading the opening paragraph
- Use a single hyphen `-` as separator, never double dash `--`
- Do not end a sentence with a period if it is the only sentence in a paragraph or the last sentence of a paragraph

### Tone

- Short, direct sentences. Technical but not dense
- Describe what the system should do, not the engineering journey to get there
- Acceptance criteria are written from the user's or operator's perspective
- Todos are written from the implementer's perspective

### Defaults

- **State**: Always create cards in "Todo", never "Backlog". Use `update_issue_state` right after `create_issue` if needed
- **Cross-references**: When referencing another card, use its identifier directly (e.g. "see INF-22"), not vague phrases like "see related card"
- **Scope awareness**: Check that the card content aligns with the current roadmap phase and does not duplicate or contradict existing cards

### MCP Tool Usage

When creating or updating cards, use the Linear MCP server (the server name depends on the project's MCP configuration -- look for the server whose tools include `get_viewer`, `projects`, `project_issues`, `create_issue`, etc.):

- **Create**: `create_issue` with `teamId` from the relevant team (use `get_viewer` to list teams if needed)
- **Update description**: `update_issue` with `issueId` (the UUID, not the identifier). Fetch it first with `issue` using the human-readable identifier
- **Change state**: `update_issue_state` with `stateId`. Fetch available states with `issue_states`. There are duplicate state names across teams - if one fails, try the next matching ID
- **Fetch by identifier**: use the `issue` tool with `issueId` set to the identifier string (e.g. `INF-19`). Do NOT use `search_issues` for identifier-based lookups - it does not support them

### Example Card

```
Slash commands to provision infrastructure components. Each command generates IaC code, creates a branch, and opens a PR

**Acceptance Criteria**

* `/new-service web <name>` generates the service definition + load balancer target + routing rule
* `/new-rds <name>` generates database instance + credentials secret
* Generated infrastructure code passes validation in CI before merge
* Resources follow the `{org}-{environment}-{name}` naming convention

**Todo**

- [ ] IaC template for web service (task def, load balancer, autoscaling)
- [ ] IaC template for database instance (instance, subnet group, credentials)
- [ ] Parameter validation and help output for each command
- [ ] Integration with command engine
```

## Dependency Graph

```
{{DEPENDENCY_GRAPH}}
```

## Current State (as of {{DATE}})

{{CURRENT_STATE}}

---

{{ISSUES_SECTION}}

---

## Design Decisions Log

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | [TO BE FILLED] | | |

---

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- Any phase completion or state change
- New Linear cards created that affect this roadmap
- Design decisions finalized
- Implementation details changed during execution
- Linear card rules or formatting standards change
```

END_OF_DOCUMENT
