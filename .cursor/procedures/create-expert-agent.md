The user wants to create a shared expert agent. Expert agents live at `agent/shared/` and are available to any agent in the tree. They provide specialist knowledge on a technology or platform (e.g. AWS, Scaleway, Docker, PostgreSQL) and stay current by fetching documentation via Context7.

## Step 0: Check existing experts

1. Read `.factory-state.json` and list the current `shared_agents` array.
2. If experts already exist, show them:

```
Existing shared experts:
  EXPERT-AWS (AWS services, IAM, ECS, RDS, S3)
  EXPERT-DOCKER (Dockerfile, Compose, multi-stage builds)
```

## Step 1: Gather expert details

Ask the user:

1. "What technology or platform should this expert cover?" (e.g. AWS, Scaleway, Docker, PostgreSQL, Terraform)
2. "Brief scope description?" (e.g. "AWS services, IAM, ECS, RDS, S3, CloudFront, VPC")

Derive:
- `expert_name`: the technology name in title case (e.g. "AWS", "Scaleway", "Docker")
- `expert_slug`: lowercase hyphenated (e.g. "aws", "scaleway", "docker")
- `expert_id`: `expert-<slug>` (e.g. "expert-aws")
- `file_name`: `EXPERT-<UPPER>.md` (e.g. "EXPERT-AWS.md")

## Step 2: Fetch documentation context

Use Context7 to resolve the library/platform documentation:

1. Call `resolve-library-id` on Context7 with the technology name to find the best matching library
2. If found, call `get-library-docs` to fetch key documentation pages
3. Use the documentation to populate the expert agent's sections with accurate, current information

If Context7 is not available, warn the user and proceed with manual content -- the agent will still work but sections will need manual filling.

## Step 3: Generate the expert agent

Read `templates/shared/EXPERT-AGENT-TEMPLATE.md`. Replace all placeholders:

- `{{EXPERT_NAME}}` -- the technology name
- `{{DATE}}` -- today's date
- `{{AGENT_INDUSTRY_VERSION}}` -- from `VERSION` file
- `{{SCOPE_DESCRIPTION}}` -- the user's scope description
- `{{DOC_SOURCE}}` -- Context7 library identifier (or "manual" if not found)
- `{{EXPERTISE_SECTIONS}}` -- generate from documentation: key services, APIs, resource types, common operations
- `{{DOC_SOURCES_LIST}}` -- list of Context7 libraries or official doc URLs
- `{{CONVENTIONS_SECTION}}` -- naming conventions, tagging standards, resource organization patterns observed in the workspace
- `{{KNOWN_PATTERNS_SECTION}}` -- common patterns used in this workspace (scan existing infra/code agents for usage)
- `{{ANTI_PATTERNS_SECTION}}` -- common mistakes, security risks, cost pitfalls
- `{{REFERENCED_BY_LIST}}` -- initially empty, populated as domain agents link to this expert

Write to: `agent/shared/{{file_name}}`

## Step 4: Link to domain agents

Ask the user: "Link this expert to any existing domain agents?"

If yes, use AskQuestion to list all infra, code, application, and platform agents in the tree. Let the user pick which ones should reference this expert (allow multiple selection).

For each selected domain agent:
1. Add `expert_id` to the node's `refs` array in `.factory-state.json`
2. Add a "Referenced Experts" section to the domain agent file pointing to the expert's path

## Step 5: Update factory state

Add the new expert to the `shared_agents` array in `.factory-state.json`:

```json
{
  "id": "expert-<slug>",
  "type": "expert",
  "scope": "<scope description>",
  "path": "agent/shared/EXPERT-<UPPER>.md",
  "doc_source": "<context7 library id or 'manual'>"
}
```

Write `.factory-state.json` back.

## Step 6: Confirm

Print: `Expert agent created: agent/shared/EXPERT-<UPPER>.md`

If linked to domain agents, also print which agents now reference it.
