The user wants to update all agent files to reflect changes made during the current work session, then sync Linear cards to match.

This is a post-work housekeeping operation. It reads git changes, recent conversation context, and current agent files to determine what needs updating. The system walks the agent tree and only updates agents whose scope intersects with the changes.

## Step 0: Load the agent tree

1. Read `.factory-state.json` to get the `tree` and org metadata
2. Walk the tree recursively to build a flat list of all agent nodes with their types, categories, scopes, scope_paths, and file paths
3. Detect the current git branch in each repo under `repos/`. If a branch name matches a Linear identifier pattern (e.g. `INF-42-...`), note the ticket(s) involved

## Step 1: Gather what changed

1. For each repo in `repos/`, run `git diff main --stat` (or the appropriate base branch) to list changed files
2. Read the current state of all agent files (walk the tree, read each node's file)
3. Match changed files against agent scopes:
   - For each agent node that has `scope_paths`, check if any changed file falls within those paths
   - For agents with `scope: "full"`, all changes in the relevant repo are in scope
   - For sub-masters, changes are in scope if any of their children's scopes are affected

Build a list of agents that need updating, grouped by parent:

```
Affected agents:

  MASTER-AGENT (root)
    SUB-MASTER: Frontend
      APPLICATION-AGENT (auth) -- 3 files changed in src/auth/, 1 test file changed
    APPLICATION-AGENT (full backend) -- 5 files changed

  Not affected:
    PLATFORM-AGENT
    ROADMAP (synced separately)
```

For application agents, code changes and test changes are both in scope since they live in the same file. For platform agents, infra changes, deploy changes, and provider-related changes are all in scope.

## Step 2: Update agent files

For each affected agent (leaf agents first, then sub-masters, then master -- bottom-up order):

1. Read the current agent file
2. Identify sections that are stale based on the changes detected in Step 1
3. Update those sections with the new state. Preserve sections that haven't changed.
4. Set `LAST_UPDATED` to today's date in the metadata block

**Rules**:
- Only update facts that have verifiably changed (file exists, config value changed, resource added/removed)
- Do not rewrite prose or restructure sections that are still accurate
- Do not remove information unless it is provably obsolete
- Preserve `CREATED`, `DOCUMENT_OWNER`, `AUTHORS` fields as-is
- For application agents: code changes may require updating both Part I (codebase) and Part II (testing) sections. If a new feature was added, check if critical path coverage (section 14) needs updating.
- For platform agents: infra changes may affect both Part I (infrastructure) and Part II (deployment) sections. If provider-specific config changed, update the relevant Part III specialist section. Check `last_docs_refresh` -- if the specialist section is older than 30 days, flag it as stale.
- For sub-masters: update their Child Registry if any child's scope or status changed
- For the master: update the top-level Child Registry and hierarchy diagram if the tree structure changed

Show the user a summary of what will change before writing:

```
Agent updates:

  APPLICATION-AGENT (auth) -- agent/acme/frontend/application/APPLICATION-AGENT-AUTH.md
    - Architecture: update to reflect new auth middleware
    - API Layer: add new /auth/refresh endpoint
    - Critical Path Coverage: add auth refresh to coverage map

  APPLICATION-AGENT (full backend) -- agent/acme/application/APPLICATION-AGENT-ACME.md
    - Data Models: update User schema
    - Known Gotchas: add note about migration order

  SUB-MASTER: Frontend -- agent/acme/frontend/SUB-MASTER-FRONTEND.md
    - Child Registry: update APPLICATION-AGENT (auth) status

  No changes needed:
    - PLATFORM-AGENT
    - MASTER-AGENT
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
Updated: APPLICATION-AGENT (auth), APPLICATION-AGENT (full backend), SUB-MASTER: Frontend
Linear:  TEAM-42 -> Done, TEAM-38 -> In Progress
Roadmap synced.
```
