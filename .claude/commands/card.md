---
description: Create or update a Linear card following the workspace card rules
---

Use the roadmap-linear skill for structure, tone, and MCP usage. Read it first.

1. Read `.factory-state.json` for `linear_team_id` and the project id.
2. Ask what the card is (feature or bug) and gather the outcome + acceptance criteria.
3. Create with `create_issue` (both `teamId` and `projectId`) or update with `update_issue`
   (UUID). Never mention agent files or paths in the content.
