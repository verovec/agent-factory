---
description: Sync the roadmap state file from Linear for this workspace
---

Use the roadmap-linear skill for all card rules.

1. Read `.factory-state.json` for `linear_team_id` and `linear_project`.
2. List the project's issues via the Linear MCP (by project id).
3. Write a lean state file at `agent/<org_slug>/plans/ROADMAP-<ORG_UPPER>.md` containing
   ONLY: the current card list (identifier, title, state, priority) and a dependency graph.
   No rules text (rules live in the roadmap-linear skill).
4. Report the counts (e.g. "3 Todo, 1 In Progress, 2 Done").
