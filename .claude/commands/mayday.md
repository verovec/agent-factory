---
description: Menu and router for this workspace's commands
---

Route the user to the right command:

- New project from this template -> run `/setup`.
- Sync the roadmap from Linear -> run `/roadmap`.
- Create or update a Linear card -> run `/card`.
- Verify best practice / latest version for a pattern -> run `/research`.
- Compare local vs Linear version -> run `/version`.

If the user is unsure, ask one question to identify intent, then route. Do not scan the
codebase here - the Understand-Anything plugin and Context7 provide structure on demand.
