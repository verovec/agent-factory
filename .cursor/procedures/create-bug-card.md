The user wants to create a bug card. The MASTER-AGENT metadata (`{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`, `LINEAR_PROJECT`) and agent flags are already available from the mayday scan.

## Step 0: Agent gate

If `has_code_agent = false` or `has_infra_agent = false`, warn:

```
Missing agents: [Code] [Infra]
Create them first via /mayday so bug cards have full project context.
Continuing without full agent coverage -- card quality may be lower.
```

## Step 1: Load roadmap context

1. Read the MASTER-AGENT to get the roadmap path
2. Read the roadmap -- specifically the "Linear Card Rules" section. Follow every rule.

## Step 2: Gather bug details

Ask: "Describe the bug or what needs fixing."

Use AskQuestion for scope:

| id | label |
|----|-------|
| code | Code (application bug) |
| infra | Infrastructure (config, deploy) |
| both | Both |

## Step 3: Draft and create

Draft the card. Opening paragraph: observed vs expected. AC: the fixed state. Todos: investigation and fix steps. Show only the draft.

Ask: "Create this card in Linear?"

If yes: `create_issue` with the correct `teamId`, then `update_issue_state` to "Todo". Print: `Created: TEAM-123 -- Card title`.

Ask: "Sync the roadmap to include this card?" If yes: read and execute `.cursor/procedures/update-roadmap.md`.
