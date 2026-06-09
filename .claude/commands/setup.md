---
description: Bootstrap a new project from this template - detach, scaffold the stack, link a new GitHub repo
---

The flagship bootstrap wizard. Confirm each destructive step. Use the `scaffolder` and
`researcher` subagents for heavy work. Follow the coding-philosophy and research-patterns skills.

## Step 0: Preconditions
- Verify `git`, `gh` (run `gh auth status`), and `node`/`npx` are available. Report gaps and stop if `gh` is unauthenticated.

## Step 1: Detach from the template
- Show the current `origin` (`git remote -v`). Confirm with the user, then `git remote remove origin`.
- This makes the clone an independent project.

## Step 2: Project identity
Ask, one at a time: project name, slug (default: kebab-case of name), short description,
GitHub visibility (private/public).

## Step 3: Stack choices
Ask:
- Frontend technology (Next.js / React+Vite / SvelteKit / none).
- Backend technology (FastAPI+Python / NestJS+Node / Go / none).
- Infrastructure is always Terraform on AWS - ask only: AWS region, and remote state backend (S3 bucket name or "decide later").
- Optional MCP servers to enable (database / browser / none).
- Which CI workflows to keep (lint, test, terraform, deploy) based on the chosen stack.

## Step 4: Scaffold a runnable skeleton (dispatch `scaffolder`)
- frontend -> `stack/frontend` via the official latest CLI for the chosen framework.
- backend -> `stack/backend` via the framework's init (verify latest version first).
- terraform -> `stack/terraform` minimal AWS layout (providers, remote state, env folders). No apply.
- `.devcontainer` + `docker-compose` for local dev.

## Step 5: Generate stack-tuned Claude config
- Rewrite the project `CLAUDE.md` (lean) with the project facts + pointers.
- Generate per-stack skills under `.claude/skills/<tech>/SKILL.md` (dispatch `researcher` for
  latest version + idiomatic setup notes per chosen tech).
- Update `.mcp.json` to enable the chosen optional servers (placeholders for secrets).
- Write `.factory-state.json` with identity + `stack` choices.
- If the user opts in, generate a lean agent-tree (master + roadmap) from `templates/`.

## Step 6: Trim CI to the chosen stack
- In `.github/workflows/`, remove trigger workflows that do not apply (e.g. frontend lint when
  no frontend). Keep the reusable `_*.yml` blocks that are still referenced.

## Step 7: Create and link the GitHub repo
- `gh repo create <slug> --<visibility> --source=. --remote=origin --push` (github MCP fallback).
- Make the initial commit if the tree is dirty, then push.

## Step 8: Linear (optional)
- Offer to create/link a Linear project and run `/roadmap` to seed the state file.

## Step 9: Summary
- List what was created, which MCPs/CI are enabled, and next steps (set secrets, run dev).
