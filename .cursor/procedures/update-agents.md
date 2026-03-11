The user wants to update all agent files to reflect changes made during the current work session, then sync Linear cards to match.

This is a post-work housekeeping operation. It reads git changes, recent conversation context, and current agent files to determine what needs updating.

## Step 0: Identify scope

1. Read `.factory-state.json` to get `agent_paths` and the list of agent files
2. Read all MASTER-AGENT files to get roadmap paths and agent registry
3. Detect the current git branch in each repo under `repos/`. If a branch name matches a Linear identifier pattern (e.g. `INF-42-...`), note the ticket(s) involved

## Step 1: Gather what changed

1. For each repo in `repos/`, run `git diff main --stat` (or the appropriate base branch) to list changed files
2. Read the current state of all agent files:
   - MASTER-AGENT(s)
   - CODE-AGENT(s) if they exist
   - TEST-AGENT(s) if they exist
   - INFRA-AGENT(s) if they exist
   - ROADMAP(s)
3. Cross-reference changed files against agent scopes:
   - Terraform / infrastructure changes -> INFRA-AGENT
   - Application code changes -> CODE-AGENT
   - Test files, test configuration, coverage changes -> TEST-AGENT
   - Deployment topology, secrets, env vars, health checks -> INFRA-AGENT
   - New Linear tickets or state changes -> ROADMAP

## Step 2: Update agent files

For each agent file that needs updating:

1. Read the current file
2. Identify sections that are stale based on the changes detected in Step 1
3. Update those sections with the new state. Preserve sections that haven't changed.
4. Set `LAST_UPDATED` to today's date in the metadata block

**Rules**:
- Only update facts that have verifiably changed (file exists, config value changed, resource added/removed)
- Do not rewrite prose or restructure sections that are still accurate
- Do not remove information unless it is provably obsolete
- Preserve `CREATED`, `DOCUMENT_OWNER`, `AUTHORS` fields as-is

Show the user a summary of what will change before writing:

```
Agent updates:

  INFRA-AGENT-{{ORG_NAME_UPPER}}.md
    - Current State: update status, remove blocking_issues that are resolved
    - Secret Architecture: update to reflect completed changes
    - Services: update configuration to match actual state
    - Terraform Resources: update resource list

  ROADMAP-{{ORG_NAME_UPPER}}.md
    - TEAM-42: move to Done (or update state)
    - Current State: update summary

  No changes needed:
    - CODE-AGENT-{{ORG_NAME_UPPER}}.md
    - MASTER-AGENT-{{ORG_NAME_UPPER}}.md
```

Ask: "Apply these updates?"

## Step 3: Sync Linear cards

After agent files are updated:

1. Read the roadmap to identify all tracked Linear tickets
2. For each ticket whose state in the roadmap differs from its state in Linear, use the `issue` tool to fetch the current Linear state
3. Show the diff:

```
Linear sync:

  State changes to push:
    - INF-42: In Progress -> Done
    - INF-38: Todo -> In Progress

  Description updates:
    - INF-42: update todo checkboxes

  No changes:
    - INF-22, INF-26, ...
```

Ask: "Push these changes to Linear?"

4. If confirmed, update each card using `update_issue` (for description) and `update_issue_state` (for state changes). Use the `issue` tool to fetch each ticket's UUID first.

## Step 4: Run roadmap sync

After Linear cards are updated, run the roadmap sync procedure (`.cursor/procedures/update-roadmap.md`) to pull the canonical state back from Linear into the roadmap file. This ensures the roadmap is the single source of truth and reflects exactly what Linear shows.

## Step 5: Summary

Print a single summary:

```
Updated: INFRA-AGENT-{{ORG_NAME_UPPER}}.md, ROADMAP-{{ORG_NAME_UPPER}}.md
Linear:  TEAM-42 -> Done, TEAM-38 -> In Progress
Roadmap synced.
```
