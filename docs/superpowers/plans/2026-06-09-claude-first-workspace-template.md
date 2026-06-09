# Claude-First Workspace Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `agent-factory` into a token-efficient, Claude-first project template (keeping Cursor working as a delegating surface), then produce a Claude-only twin in `claude-workspace`.

**Architecture:** Native-first lean. `.claude/` is the source of truth; `CLAUDE.md` holds only always-on rules; knowledge lives in on-demand skills; code structure comes from the Understand-Anything plugin + Context7; specialist work runs in isolated subagents. The workspace *is* the project monorepo (code in `stack/`), bootstrapped by a `/setup` wizard that detaches the template remote and links a fresh GitHub repo.

**Tech Stack:** Markdown (commands/skills/agents), JSON (settings/mcp/state), Bash (hooks/scripts), GitHub Actions (CI). No application runtime — `/setup` shells out to official stack CLIs at run time.

**Validation note:** Most artifacts are markdown/config, so "tests" are validation checks: file existence, `jq` JSON validity, delegator correctness, and grep-for-stray-references. These are real and runnable, not placeholders.

**Reference:** Spec at `docs/superpowers/specs/2026-06-09-claude-first-workspace-template-design.md`. Live Claude-first example at `/home/clement/Documents/dev/projects/synquery/repos/synqueryai/` (read for patterns; do not copy project content).

---

## Phase 0: Branch and safety

### Task 0: Working branch

**Files:** none

- [ ] **Step 1: Create the working branch**

Run: `git -C /home/clement/Documents/dev/projects/agent-factory checkout -b claude-first-template`
Expected: `Switched to a new branch 'claude-first-template'`

- [ ] **Step 2: Confirm clean tree except the spec/plan docs**

Run: `git -C /home/clement/Documents/dev/projects/agent-factory status --short`
Expected: only `docs/superpowers/` files (the spec + this plan) show as untracked.

- [ ] **Step 3: Commit the planning docs**

```bash
cd /home/clement/Documents/dev/projects/agent-factory
git add docs/superpowers/
git commit -m "docs: add claude-first workspace template spec and plan"
```

---

## Phase 1: Restructure skeleton (`stack/`, rename sweep)

### Task 1: Rename `repos/` to `stack/` and reframe the monorepo model

**Files:**
- Create: `stack/.gitkeep`
- Modify: `README.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore`
- Modify: `templates/config/factory-state.json.example`

- [ ] **Step 1: Create the empty `stack/` folder**

```bash
cd /home/clement/Documents/dev/projects/agent-factory
mkdir -p stack
printf '%s\n' "# Project code lives here: backend/ frontend/ terraform/ docs/. Populated by /setup." > stack/.gitkeep
```

- [ ] **Step 2: Update `.gitignore` — stack/ is now COMMITTED, drop the repos/ ignore**

Open `.gitignore`. Remove any line ignoring `repos/` or `repos`. Ensure these lines are present (add if missing):

```
.factory-state.json
.cursor/mcp.json
.mcp.json.local
.claude/settings.local.json
node_modules/
.venv/
__pycache__/
```

Do NOT ignore `stack/`.

- [ ] **Step 3: Rewrite the `repos/` references in `README.md`**

Replace every `repos/` path and "project repos cloned here" framing. The new model: the
workspace IS the monorepo; project code lives in `stack/` (backend/, frontend/, terraform/,
docs/); you clone the template once per project and run `/setup`. Update the structure
block (`README.md:46-56` and `:92`) and the clone instructions (`:160-165`) to:

```
~/projects/my-project/                <-- template clone (becomes the project repo)
  .claude/                            <-- Claude-first config (source of truth)
  .github/  .vscode/  .devcontainer/
  CLAUDE.md  SETUP.md  .mcp.json
  templates/
  stack/                              <-- project code (committed)
    backend/  frontend/  terraform/  docs/
```

And replace the setup commands with:

```bash
git clone git@github.com:verovec/agent-factory.git ~/projects/my-project
cd ~/projects/my-project
# In Claude Code:  /setup
```

- [ ] **Step 4: Rewrite `repos/` references in `AGENTS.md`**

`AGENTS.md:33` and `:60`: change "Project repos are cloned into `repos/` (gitignored)" to
"Project code lives in `stack/` (backend/, frontend/, terraform/, docs/) and is committed."
Update the structure block `repos/` line to `stack/  -- project code (committed)`.

- [ ] **Step 5: Rewrite `repos/` references in `CLAUDE.md`**

(Full CLAUDE.md is rewritten in Task 9; for now just fix the three hits.) `CLAUDE.md:17`
"Project repos are in `repos/`" -> "Project code is in `stack/`". `CLAUDE.md:35` "`repos` --
array of repo names" -> "`stack` -- the project monorepo subfolders". `CLAUDE.md:63`
`repos/` line -> `stack/  -- project code (committed)`.

- [ ] **Step 6: Update the factory-state example**

In `templates/config/factory-state.json.example`, replace `"repos": ["repo-one", "repo-two"],`
with `"stack": { "backend": null, "frontend": null, "terraform": "aws" },` (string values are
the chosen tech, filled by `/setup`; `null` when absent).

- [ ] **Step 7: Verify no stray `repos/` path references remain outside the command layer**

Run:
```bash
grep -rn 'repos/' README.md AGENTS.md CLAUDE.md .gitignore templates/config/ 2>/dev/null
```
Expected: no output. (The `.cursor/commands` and `.cursor/procedures` hits are handled in
Phase 2/Task 8 when the command layer is rewritten.)

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: replace repos/ multi-repo model with committed stack/ monorepo"
```

---

## Phase 2: Build the `.claude/` layer + flip Cursor delegation

### Task 2: `.claude/settings.json`

**Files:**
- Create: `.claude/settings.json`

- [ ] **Step 1: Write settings.json**

```json
{
  "enableAllProjectMcpServers": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/guards.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Validate JSON**

Run: `jq . .claude/settings.json`
Expected: pretty-printed JSON, exit 0.

- [ ] **Step 3: Commit**

```bash
git add .claude/settings.json
git commit -m "feat(claude): add settings.json with mcp enable + guard hook wiring"
```

### Task 3: Guard hook

**Files:**
- Create: `.claude/hooks/guards.sh`

- [ ] **Step 1: Write the guard hook**

The hook reads the tool-call JSON from stdin and blocks edits that introduce emojis. It is
intentionally minimal (a non-negotiable, not a linter).

```bash
#!/usr/bin/env bash
# Reads PreToolUse payload on stdin. Blocks Write/Edit whose new content contains emojis.
set -euo pipefail
payload="$(cat)"
content="$(printf '%s' "$payload" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
if printf '%s' "$content" | grep -Pq '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}\x{2190}-\x{21FF}\x{2B00}-\x{2BFF}]'; then
  echo "Blocked: emojis are not allowed in this workspace (see CLAUDE.md)." >&2
  exit 2
fi
exit 0
```

- [ ] **Step 2: Make executable**

Run: `chmod +x .claude/hooks/guards.sh`

- [ ] **Step 3: Verify it blocks an emoji edit**

Run:
```bash
printf '{"tool_input":{"content":"hello \xf0\x9f\x98\x80"}}' | bash .claude/hooks/guards.sh; echo "exit=$?"
```
Expected: prints the "Blocked: emojis" message and `exit=2`.

- [ ] **Step 4: Verify it passes clean content**

Run:
```bash
printf '{"tool_input":{"content":"plain text"}}' | bash .claude/hooks/guards.sh; echo "exit=$?"
```
Expected: `exit=0`, no message.

- [ ] **Step 5: Commit**

```bash
git add .claude/hooks/guards.sh
git commit -m "feat(claude): add no-emoji guard hook"
```

### Task 4: Skills — coding-philosophy, roadmap-linear, research-patterns

**Files:**
- Create: `.claude/skills/coding-philosophy/SKILL.md`
- Create: `.claude/skills/roadmap-linear/SKILL.md`
- Create: `.claude/skills/research-patterns/SKILL.md`

- [ ] **Step 1: Write coding-philosophy skill**

```markdown
---
name: coding-philosophy
description: Use when writing or reviewing code in this workspace - core engineering standards (best-practice first, long-term, lean)
---

# Coding Philosophy

- Best practice and long-term maintainability first. Never optimize for the quickest patch.
- Before introducing a new library, framework, or pattern, verify current best practice and
  the latest stable version via Context7 (and web search if needed). Do not rely on memory.
- Match the surrounding code: naming, structure, comment density, idioms.
- DRY, YAGNI. Delete dead code rather than commenting it out.
- No emojis anywhere. No comments that restate what the code does.
- Small, focused files with clear boundaries over large multi-purpose ones.
- Only create, modify, or delete files explicitly requested or strictly necessary for the task.
```

- [ ] **Step 2: Write roadmap-linear skill (moved off always-on context)**

Port the Linear card rules out of the legacy roadmap agent and `CLAUDE.md`. Content:

```markdown
---
name: roadmap-linear
description: Use when creating, updating, or syncing Linear cards / the roadmap for this workspace
---

# Roadmap & Linear Rules

Identity comes from `.factory-state.json`: `linear_team_id`, `linear_project` (and its id).

## Fetching
- Fetch a card by identifier with the `issue` tool (e.g. `INF-19`). Never `search_issues`.

## Creating / updating
- `create_issue` requires both `teamId` and `projectId`.
- `update_issue` takes the issue UUID. `update_issue_state` changes state.

## Card structure
- Opening paragraph stating the outcome (operator perspective).
- Acceptance criteria as `*` bullets (operator perspective).
- Todos as `- [ ]` checkboxes (implementer perspective).
- Bold headings (not `#`), inline code for paths/env vars.

## Tone & confidentiality
- Short direct sentences. No emojis. No filler.
- Never mention agent files, paths, or internal workspace structure in card content.

## Version card
- A card titled `agent-industry-version` mirrors the local `VERSION` file. Keep it in `Done`.
```

- [ ] **Step 3: Write research-patterns skill**

```markdown
---
name: research-patterns
description: Use before integrating a new library, framework, or architectural pattern - how to verify current best practice and latest version
---

# Researching a New Pattern

1. Resolve the library/tool with Context7; read the current docs for the feature in scope.
2. Confirm the latest stable version (Context7 / package registry). Record it.
3. Web-search for current (this year) best-practice guidance when Context7 is insufficient.
4. Prefer the official, idiomatic integration. Note trade-offs in one or two lines.
5. Record the version + the integration decision in the relevant per-stack skill so it is
   not re-derived next time.

For heavy or noisy research, delegate to the `researcher` subagent to keep the main context clean.
```

- [ ] **Step 4: Verify frontmatter present in each skill**

Run:
```bash
for f in .claude/skills/*/SKILL.md; do head -1 "$f"; done
```
Expected: each prints `---`.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/
git commit -m "feat(claude): add coding-philosophy, roadmap-linear, research-patterns skills"
```

### Task 5: Subagents — researcher, reviewer, scaffolder

**Files:**
- Create: `.claude/agents/researcher.md`
- Create: `.claude/agents/reviewer.md`
- Create: `.claude/agents/scaffolder.md`

- [ ] **Step 1: Write researcher subagent**

```markdown
---
name: researcher
description: Verifies current best practices and latest stable versions for a library, framework, or pattern using Context7 and web search. Returns a concise recommendation.
tools: WebSearch, WebFetch, mcp__context7
model: sonnet
---

You research one technical question and return a concise, actionable answer.

- Resolve libraries with Context7; confirm the latest stable version.
- Use web search only when Context7 is insufficient; prefer current-year sources.
- Return: latest version(s), the recommended idiomatic integration, and at most two trade-offs.
- Do not write project files. Your output is a summary the main agent acts on.
```

- [ ] **Step 2: Write reviewer subagent**

```markdown
---
name: reviewer
description: Reviews a focused diff or set of files for correctness, best practice, and adherence to the coding-philosophy skill. Returns prioritized findings.
tools: Read, Bash, Grep, Glob
model: sonnet
---

You review code in an isolated context and report back only findings.

- Check correctness, security, and adherence to the workspace coding-philosophy.
- Prioritize findings (blocking / should-fix / nit). Cite file:line.
- Do not modify files. Return a short prioritized list.
```

- [ ] **Step 3: Write scaffolder subagent**

```markdown
---
name: scaffolder
description: Runs official stack-init CLIs to scaffold a runnable skeleton during /setup. Uses latest versions. Reports what it created.
tools: Bash, Read, Write, Edit
model: sonnet
---

You scaffold a runnable project skeleton on request.

- Use official latest CLIs (verify versions first). Examples: `npx create-next-app@latest`,
  backend framework init, a minimal Terraform AWS layout.
- Target paths under `stack/` (e.g. `stack/frontend`, `stack/backend`, `stack/terraform`).
- Never run `terraform apply` or provision real resources. Skeleton only.
- Report exactly what was created and any follow-up the user must do (e.g. set secrets).
```

- [ ] **Step 4: Verify frontmatter**

Run: `for f in .claude/agents/*.md; do head -1 "$f"; done`
Expected: each prints `---`.

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/
git commit -m "feat(claude): add researcher, reviewer, scaffolder subagents"
```

### Task 6: Commands — roadmap, card, research, version

**Files:**
- Create: `.claude/commands/roadmap.md`
- Create: `.claude/commands/card.md`
- Create: `.claude/commands/research.md`
- Create: `.claude/commands/version.md`

- [ ] **Step 1: Write `/roadmap`**

```markdown
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
```

- [ ] **Step 2: Write `/card`**

```markdown
---
description: Create or update a Linear card following the workspace card rules
---

Use the roadmap-linear skill for structure, tone, and MCP usage. Read it first.

1. Read `.factory-state.json` for `linear_team_id` and the project id.
2. Ask what the card is (feature or bug) and gather the outcome + acceptance criteria.
3. Create with `create_issue` (both `teamId` and `projectId`) or update with `update_issue`
   (UUID). Never mention agent files or paths in the content.
```

- [ ] **Step 3: Write `/research`**

```markdown
---
description: Verify current best practice and latest version before integrating a pattern
---

Use the research-patterns skill. For anything noisy, dispatch the `researcher` subagent.

1. Ask (or infer) the library/pattern in scope.
2. Confirm latest stable version + idiomatic integration (Context7, then web).
3. Summarize: version, recommended integration, key trade-offs.
4. If it pertains to the project stack, record it in the relevant per-stack skill.
```

- [ ] **Step 4: Write `/version`**

```markdown
---
description: Compare the local VERSION file with the Linear version card
---

1. Read the `VERSION` file at the workspace root.
2. Fetch the Linear card titled `agent-industry-version` (use the `issue`/project tools).
3. Report whether they match; if not, offer to update the Linear card to the local version.
```

- [ ] **Step 5: Validate frontmatter**

Run: `for f in .claude/commands/roadmap.md .claude/commands/card.md .claude/commands/research.md .claude/commands/version.md; do head -1 "$f"; done`
Expected: each prints `---`.

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/roadmap.md .claude/commands/card.md .claude/commands/research.md .claude/commands/version.md
git commit -m "feat(claude): add roadmap, card, research, version commands"
```

### Task 7: The `/setup` command

**Files:**
- Create: `.claude/commands/setup.md`

- [ ] **Step 1: Write `/setup`**

````markdown
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
````

- [ ] **Step 2: Validate frontmatter**

Run: `head -1 .claude/commands/setup.md`
Expected: `---`.

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "feat(claude): add /setup bootstrap wizard"
```

### Task 8: Rewrite `mayday` as a router and flip Cursor/Antigravity to delegators

**Files:**
- Create: `.claude/commands/mayday.md`
- Modify: `.cursor/commands/mayday.md` (replace with delegator)
- Create: `.cursor/commands/setup.md`, `roadmap.md`, `card.md`, `research.md`, `version.md` (delegators)
- Modify: `.agent/workflows/mayday.md` (replace with delegator)
- Create: `.agent/workflows/setup.md` (delegator)

- [ ] **Step 1: Write the new `.claude/commands/mayday.md` router**

The legacy mayday (multi-repo scanning menu) is superseded. New content is a thin router:

```markdown
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
```

- [ ] **Step 2: Replace `.cursor/commands/mayday.md` with a delegator**

Replace the ENTIRE file contents with:

```markdown
Follow `.claude/commands/mayday.md` in this workspace.
```

- [ ] **Step 3: Create Cursor delegators for the other commands**

For each of `setup`, `roadmap`, `card`, `research`, `version`, create
`.cursor/commands/<name>.md` containing exactly:

```markdown
Follow `.claude/commands/<name>.md` in this workspace.
```

(Substitute `<name>` per file.)

- [ ] **Step 4: Replace `.agent/workflows/mayday.md` with a delegator + add setup**

`.agent/workflows/mayday.md` contents:
```markdown
Follow `.claude/commands/mayday.md` in this workspace.
```
`.agent/workflows/setup.md` contents:
```markdown
Follow `.claude/commands/setup.md` in this workspace.
```

- [ ] **Step 5: Verify delegators point at real targets**

Run:
```bash
for f in .cursor/commands/*.md .agent/workflows/*.md; do
  t=$(grep -oE '\.claude/commands/[a-z]+\.md' "$f" | head -1)
  [ -f "$t" ] && echo "OK  $f -> $t" || echo "MISS $f -> $t"
done
```
Expected: every line starts with `OK`.

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/mayday.md .cursor/commands/ .agent/workflows/
git commit -m "refactor: flip .claude to source of truth; cursor/antigravity delegate"
```

### Task 8b: Reconcile legacy procedures with the new model

**Files:**
- Modify: `.cursor/procedures/init-agents.md`, `update-agents.md`, `create-platform-agent.md`

- [ ] **Step 1: Fix `repos/` semantics in the three procedures**

In each file, change multi-repo scanning language ("for each repo in `repos/`", "scan the
repos in `repos/`") to the single-monorepo model: scan `stack/` subfolders
(`stack/backend`, `stack/frontend`, `stack/terraform`). In `init-agents.md` replace the
`"repos": []` state field with `"stack": {}` and the "Populate the `repos` array" step with
"Record the detected `stack` technologies". Keep everything else intact.

- [ ] **Step 2: Verify no `repos/` path references remain anywhere except docs/superpowers**

Run:
```bash
grep -rn 'repos/' --include='*.md' --include='*.json' --include='*.example' . 2>/dev/null | grep -v '/.git/' | grep -v 'docs/superpowers/'
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add .cursor/procedures/
git commit -m "refactor: reconcile legacy procedures with single stack/ monorepo model"
```

---

## Phase 3: Root config — CLAUDE.md, .mcp.json, .vscode, .devcontainer

### Task 9: Lean `CLAUDE.md` and `AGENTS.md`

**Files:**
- Modify: `CLAUDE.md` (full rewrite, lean)
- Modify: `AGENTS.md` (pointer that mirrors essentials)

- [ ] **Step 1: Rewrite `CLAUDE.md` lean (always-on rules + pointers only)**

```markdown
# Claude-First Workspace

This repo is a project template. The workspace IS the monorepo: project code lives in
`stack/` (backend/, frontend/, terraform/, docs/). Run `/setup` to bootstrap a new project.

## Always-on rules
- Best practice and long-term maintainability first.
- Before integrating a new library/pattern/tool, verify current best practice and latest
  stable version via Context7 (web search if needed) before writing code.
- Never use emojis. No comments that restate code. Only touch files needed for the task.
- For code structure, use the Understand-Anything plugin and Context7 on demand. Do not
  hand-maintain large structure documents.

## On-demand context (load only when relevant)
- Writing/reviewing code -> coding-philosophy skill.
- Linear cards / roadmap -> roadmap-linear skill; commands `/roadmap`, `/card`.
- Integrating a new pattern -> research-patterns skill; command `/research`.

## Commands
`/setup` (bootstrap), `/roadmap`, `/card`, `/research`, `/version`, `/mayday` (router).

## State
`.factory-state.json` (gitignored) holds identity, Linear ids, and the `stack` choices.
```

- [ ] **Step 2: Rewrite `AGENTS.md` as a thin mirror**

Keep `AGENTS.md` short: one paragraph stating it mirrors `CLAUDE.md`, the same always-on
rules list, and "see `CLAUDE.md` for the authoritative version." Remove the legacy
agent-tree narrative and any `repos/` references.

- [ ] **Step 3: Verify both reference `stack/` and not `repos/`**

Run: `grep -c 'stack/' CLAUDE.md AGENTS.md && grep -c 'repos/' CLAUDE.md AGENTS.md || true`
Expected: `stack/` count >= 1 each; `repos/` count 0 each.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md AGENTS.md
git commit -m "refactor: lean always-on CLAUDE.md and AGENTS.md mirror"
```

### Task 10: `.mcp.json` lean defaults

**Files:**
- Create: `.mcp.json`
- Modify: `templates/config/mcp.json.example` (match the new default set)

- [ ] **Step 1: Write `.mcp.json` (committed, placeholders only)**

```json
{
  "mcpServers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer YOUR_GITHUB_TOKEN" }
    },
    "linear": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@mkusaka/mcp-server-linear@latest"],
      "env": { "LINEAR_API_KEY": "YOUR_LINEAR_API_KEY" }
    }
  }
}
```

- [ ] **Step 2: Mirror into the template example**

Make `templates/config/mcp.json.example` identical to `.mcp.json` (it is the documented
default). Add a trailing comment block in the README/SETUP about the optional menu
(database via `@bytebase/dbhub`, browser, etc.) rather than inflating the default file.

- [ ] **Step 3: Validate JSON**

Run: `jq . .mcp.json && jq . templates/config/mcp.json.example`
Expected: both pretty-print, exit 0.

- [ ] **Step 4: Commit**

```bash
git add .mcp.json templates/config/mcp.json.example
git commit -m "feat: lean default .mcp.json (context7 + github + linear)"
```

### Task 11: `.vscode` and `.devcontainer`

**Files:**
- Create: `.vscode/settings.json`, `.vscode/extensions.json`
- Create: `.devcontainer/devcontainer.json`

- [ ] **Step 1: Write `.vscode/extensions.json`**

```json
{
  "recommendations": [
    "anthropic.claude-code",
    "hashicorp.terraform",
    "ms-azuretools.vscode-docker"
  ]
}
```

- [ ] **Step 2: Write `.vscode/settings.json`**

```json
{
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "editor.formatOnSave": true
}
```

- [ ] **Step 3: Write a minimal root `.devcontainer/devcontainer.json`**

Root-level per spec 4.1 (auto-detected). Universal base; `/setup` extends it per stack.

```json
{
  "name": "workspace",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "customizations": {
    "vscode": { "extensions": ["anthropic.claude-code", "hashicorp.terraform"] }
  }
}
```

- [ ] **Step 4: Validate JSON**

Run: `jq . .vscode/settings.json .vscode/extensions.json .devcontainer/devcontainer.json`
Expected: all valid, exit 0.

- [ ] **Step 5: Commit**

```bash
git add .vscode .devcontainer
git commit -m "feat: add root .vscode and .devcontainer defaults"
```

---

## Phase 4: `.github` CI (reusable blocks, modeled on synquery)

### Task 12: Reusable CI building blocks

**Files:**
- Read (pattern only): `/home/clement/Documents/dev/projects/synquery/repos/synqueryai/.github/workflows/_lint.yml`, `_deploy.yml`, `terraform.yml`
- Create: `.github/workflows/_lint.yml`, `_test.yml`, `_terraform.yml`

- [ ] **Step 1: Read synquery's reusable workflows for structure (not content)**

Run:
```bash
sed -n '1,60p' /home/clement/Documents/dev/projects/synquery/repos/synqueryai/.github/workflows/_lint.yml
sed -n '1,80p' /home/clement/Documents/dev/projects/synquery/repos/synqueryai/.github/workflows/terraform.yml
```
Note the `workflow_call` inputs pattern and job structure. Do not copy project-specific steps.

- [ ] **Step 2: Write `_lint.yml` (reusable)**

```yaml
name: _lint
on:
  workflow_call:
    inputs:
      path: { type: string, required: true }
      lang: { type: string, required: true }   # node | python
jobs:
  lint:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: ${{ inputs.path }} } }
    steps:
      - uses: actions/checkout@v4
      - if: inputs.lang == 'node'
        uses: actions/setup-node@v4
        with: { node-version: 'lts/*' }
      - if: inputs.lang == 'node'
        run: npm ci && npm run lint --if-present
      - if: inputs.lang == 'python'
        uses: actions/setup-python@v5
        with: { python-version: '3.x' }
      - if: inputs.lang == 'python'
        run: pipx run ruff check .
```

- [ ] **Step 3: Write `_test.yml` (reusable)**

```yaml
name: _test
on:
  workflow_call:
    inputs:
      path: { type: string, required: true }
      lang: { type: string, required: true }
jobs:
  test:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: ${{ inputs.path }} } }
    steps:
      - uses: actions/checkout@v4
      - if: inputs.lang == 'node'
        uses: actions/setup-node@v4
        with: { node-version: 'lts/*' }
      - if: inputs.lang == 'node'
        run: npm ci && npm test --if-present
      - if: inputs.lang == 'python'
        uses: actions/setup-python@v5
        with: { python-version: '3.x' }
      - if: inputs.lang == 'python'
        run: pipx run pytest -q || true
```

- [ ] **Step 4: Write `_terraform.yml` (reusable, plan only by default)**

```yaml
name: _terraform
on:
  workflow_call:
    inputs:
      path: { type: string, default: stack/terraform }
      apply: { type: boolean, default: false }
    secrets:
      AWS_ROLE_ARN: { required: false }
jobs:
  terraform:
    runs-on: ubuntu-latest
    permissions: { id-token: write, contents: read }
    defaults: { run: { working-directory: ${{ inputs.path }} } }
    env:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - if: env.AWS_ROLE_ARN != ''
        uses: aws-actions/configure-aws-credentials@v4
        with: { role-to-assume: ${{ env.AWS_ROLE_ARN }}, aws-region: us-east-1 }
      - run: terraform init -input=false
      - run: terraform plan -input=false
      - if: inputs.apply
        run: terraform apply -auto-approve -input=false
```

- [ ] **Step 5: Validate YAML parses**

Run:
```bash
for f in .github/workflows/_lint.yml .github/workflows/_test.yml .github/workflows/_terraform.yml; do
  python3 -c "import sys,yaml; yaml.safe_load(open('$f'))" && echo "OK $f"
done
```
Expected: three `OK` lines (install pyyaml with `pipx run --spec pyyaml python3 ...` is not needed if pyyaml present; if missing, `pip install pyyaml` first).

- [ ] **Step 6: Commit**

```bash
git add .github/workflows/_lint.yml .github/workflows/_test.yml .github/workflows/_terraform.yml
git commit -m "feat(ci): add reusable lint/test/terraform workflows"
```

### Task 13: Trigger workflows

**Files:**
- Create: `.github/workflows/pr.yml`, `.github/workflows/terraform.yml`

- [ ] **Step 1: Write `pr.yml` (lint + test on PR; stack-aware via path filters)**

```yaml
name: pr
on:
  pull_request:
jobs:
  frontend-lint:
    if: ${{ hashFiles('stack/frontend/package.json') != '' }}
    uses: ./.github/workflows/_lint.yml
    with: { path: stack/frontend, lang: node }
  backend-lint:
    if: ${{ hashFiles('stack/backend/pyproject.toml') != '' }}
    uses: ./.github/workflows/_lint.yml
    with: { path: stack/backend, lang: python }
  backend-test:
    if: ${{ hashFiles('stack/backend/pyproject.toml') != '' }}
    uses: ./.github/workflows/_test.yml
    with: { path: stack/backend, lang: python }
```

- [ ] **Step 2: Write `terraform.yml` (plan on PR, apply on main)**

```yaml
name: terraform
on:
  push: { branches: [main], paths: ['stack/terraform/**'] }
  pull_request: { paths: ['stack/terraform/**'] }
jobs:
  tf:
    uses: ./.github/workflows/_terraform.yml
    with:
      path: stack/terraform
      apply: ${{ github.ref == 'refs/heads/main' }}
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
```

- [ ] **Step 3: Validate YAML**

Run:
```bash
for f in .github/workflows/pr.yml .github/workflows/terraform.yml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" && echo "OK $f"
done
```
Expected: two `OK` lines.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/pr.yml .github/workflows/terraform.yml
git commit -m "feat(ci): add pr and terraform trigger workflows (stack-aware)"
```

---

## Phase 5: SETUP.md and version bump

### Task 14: `SETUP.md` and `VERSION`

**Files:**
- Create: `SETUP.md`
- Modify: `VERSION`

- [ ] **Step 1: Write `SETUP.md`**

Human-readable guide. Sections: Prerequisites (git, gh authenticated, node, Claude Code,
Context7 + Linear MCP keys); Recommended plugin (Understand-Anything — install via Claude
Code `/plugin` marketplace; it provides the code knowledge graph so structure is pulled on
demand rather than hand-maintained); Quick start (`git clone` the template, open in Claude
Code, install the plugin, run `/setup`); What `/setup` does (numbered, mirrors the command);
Optional MCP menu (database via `@bytebase/dbhub`, browser); Manual fallback if `gh` is
unavailable. Keep it under ~140 lines.

- [ ] **Step 2: Bump `VERSION`**

Set `VERSION` contents to `5.0.0` (major: Claude-first restructure).

Run: `printf '5.0.0\n' > VERSION`

- [ ] **Step 3: Commit**

```bash
git add SETUP.md VERSION
git commit -m "docs: add SETUP.md and bump VERSION to 5.0.0"
```

---

## Phase 6: Self-test the template & repoint origin

### Task 15: End-to-end static validation

**Files:** none (validation only)

- [ ] **Step 1: Structure check**

Run:
```bash
test -d stack && test -f stack/.gitkeep \
  && test -f .claude/commands/setup.md && test -f .claude/settings.json \
  && test -f .claude/hooks/guards.sh && test -d .claude/skills && test -d .claude/agents \
  && test -f .mcp.json && test -f CLAUDE.md && test -f SETUP.md \
  && test -d .github/workflows && test -d .vscode && test -d .devcontainer \
  && echo "STRUCTURE OK"
```
Expected: `STRUCTURE OK`.

- [ ] **Step 2: No stray `repos/` anywhere but docs/superpowers**

Run:
```bash
grep -rn 'repos/' --include='*.md' --include='*.json' --include='*.yml' --include='*.example' . 2>/dev/null | grep -v '/.git/' | grep -v 'docs/superpowers/' || echo "CLEAN"
```
Expected: `CLEAN`.

- [ ] **Step 3: All JSON valid**

Run:
```bash
for f in .mcp.json .claude/settings.json .vscode/*.json .devcontainer/devcontainer.json templates/config/*.example; do jq . "$f" >/dev/null && echo "OK $f"; done
```
Expected: an `OK` line per file, no jq errors.

- [ ] **Step 4: All command/skill/agent files have frontmatter or delegate**

Run:
```bash
for f in .claude/commands/*.md .claude/skills/*/SKILL.md .claude/agents/*.md; do head -1 "$f" | grep -q '^---$' && echo "OK $f" || echo "BAD $f"; done
```
Expected: every line `OK`.

### Task 16: Repoint `agent-factory` origin and push

**Files:** none (git)

- [ ] **Step 1: Repoint origin**

Run:
```bash
cd /home/clement/Documents/dev/projects/agent-factory
git remote set-url origin git@github.com:verovec/agent-factory.git
git remote -v
```
Expected: origin (fetch/push) = `git@github.com:verovec/agent-factory.git`.

- [ ] **Step 2: Merge the branch to main and push**

Confirm with the user before pushing. Then:
```bash
git checkout main
git merge --no-ff claude-first-template -m "feat: claude-first workspace template (v5.0.0)"
git push -u origin main
```
Expected: push succeeds to the agent-factory remote.

---

## Phase 7: Duplicate into `claude-workspace` (Claude-only)

### Task 17: Copy and strip non-Claude surfaces

**Files:** operates on `/home/clement/Documents/dev/projects/claude-workspace`

- [ ] **Step 1: Copy the finished template (excluding git + non-Claude surfaces)**

Run:
```bash
cd /home/clement/Documents/dev/projects/agent-factory
rsync -a --delete \
  --exclude='.git/' --exclude='.cursor/' --exclude='.agent/' \
  --exclude='AGENTS.md' --exclude='.factory-state.json' \
  --exclude='docs/superpowers/' \
  ./ /home/clement/Documents/dev/projects/claude-workspace/
```
Expected: files copied; target has `.claude/`, `stack/`, `.github/`, `CLAUDE.md`, etc., but no `.cursor/`, `.agent/`, `AGENTS.md`.

- [ ] **Step 2: Verify the strip**

Run:
```bash
cd /home/clement/Documents/dev/projects/claude-workspace
test ! -d .cursor && test ! -d .agent && test ! -f AGENTS.md && test -d .claude && echo "CLAUDE-ONLY OK"
```
Expected: `CLAUDE-ONLY OK`.

- [ ] **Step 3: Adjust README to state Claude-dedicated**

Edit `claude-workspace/README.md`: replace the "Works on Cursor, Claude Code, and
Antigravity" line with "Claude Code dedicated template." Remove any Cursor/Antigravity
setup sections. Remove references to `.cursor`/`.agent`.

- [ ] **Step 4: Verify remote**

Run: `git -C /home/clement/Documents/dev/projects/claude-workspace remote -v`
Expected: origin = `git@github.com:verovec/claude-workspace.git`.

- [ ] **Step 5: Commit and push (confirm with user first)**

```bash
cd /home/clement/Documents/dev/projects/claude-workspace
git add -A
git commit -m "feat: claude-only workspace template (v5.0.0)"
git push -u origin main
```
Expected: push succeeds to claude-workspace remote.

---

## Done criteria

- `agent-factory` on its own remote: `.claude/` source of truth, Cursor/Antigravity delegate,
  `stack/` monorepo, `/setup` + supporting commands, lean CLAUDE.md, reusable CI, root
  devcontainer, lean `.mcp.json`. No stray `repos/` references.
- `claude-workspace` is the same minus `.cursor/`, `.agent/`, `AGENTS.md`, pushed to its remote.
- Both validated by the Phase 6 static checks.
