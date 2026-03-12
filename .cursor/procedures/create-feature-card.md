The user wants to create or work on a feature card. The MASTER-AGENT metadata (`{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`, `LINEAR_TEAM`, `LINEAR_PROJECT`) and agent flags are already available from the mayday scan. The `linear_team_id` from `.factory-state.json` is the `teamId` for all Linear API calls.

## Step 0: Agent gate

If `has_code_agent = false` or `has_infra_agent = false`, warn:

```
Missing agents: [Code] [Infra]
Create them first via /mayday so feature cards have full project context.
Continuing without full agent coverage -- card quality may be lower.
```

## Step 1: Load roadmap context

1. Read the MASTER-AGENT to get the roadmap path
2. Read the roadmap -- specifically the "Linear Card Rules" section and the "Dependency Graph" / card list sections. Follow every rule in the Linear Card Rules.
3. Find the **next suggested card**: the highest-priority "Todo" card whose dependencies are all "Done" or "In Progress". Also note "In Progress" cards.

## Step 2: Ask what to work on

Use AskQuestion:

| id | label |
|----|-------|
| next | Next up: {{CARD_ID}} - {{CARD_TITLE}} |
| existing | Pick an existing card by identifier |
| new | Describe a new feature |

## Step 3: Handle selection

**If `next`**: Fetch the card from Linear using the `issue` tool. Show summary (title, description excerpt, state, priority). Ask: "Start working on this card?" If yes, go to Step 4.

**If `existing`**: Ask: "Card identifier? (e.g. INF-22)". Fetch via `issue` tool. Show summary. Ask: "Start working on this card?" If yes, go to Step 4.

**If `new`**: Ask: "Describe the feature." Draft the card (opening paragraph, acceptance criteria, todo). Show only the draft. Ask: "Create this card in Linear?" If yes: `create_issue` with `linear_team_id` as the `teamId`, then `update_issue_state` to "Todo". Print: `Created: TEAM-123 -- Card title`. Ask: "Sync the roadmap to include this card?" If yes: read and execute `.cursor/procedures/update-roadmap.md`. Then go to Step 4 with the new card.

## Step 4: Start working

Update card state to "In Progress" via `update_issue_state` if not already. Read relevant agent files (code, infra, or both) based on card scope -- infer from title and description keywords. Print a summary of the card and relevant agent context, then hand off to the user.
