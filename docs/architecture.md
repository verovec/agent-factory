# Architecture

agent-factory is a project template, not an application: Markdown commands, skills and agents,
JSON settings, Bash hooks and GitHub Actions workflows. There is no runtime of its own; `/setup`
shells out to the official stack CLIs when a project is bootstrapped. The design decisions are
recorded in
[`superpowers/specs/2026-06-09-claude-first-workspace-template-design.md`](superpowers/specs/2026-06-09-claude-first-workspace-template-design.md).

## Layout

```
.claude/                          source of truth
  commands/                       /setup /roadmap /card /research /version /mayday, one Markdown file each
  skills/                         ci, coding-philosophy, research-patterns, roadmap-linear, slash-commands
  agents/                         researcher, reviewer, scaffolder: scoped tools, own context, sonnet model
  hooks/guards.sh                 PreToolUse on Write|Edit: rejects content that contains an emoji
  settings.json                   enabledMcpjsonServers and the hook wiring
.cursor/
  commands/                       one-line delegators to .claude/commands (all six commands)
  rules/no-noise-comments.mdc     comment-quality rule, always applied by Cursor
  procedures/                     agent-tree procedures (init-agents, create-*-agent, update-roadmap, ...)
.agent/
  workflows/                      one-line delegators for Antigravity (setup, mayday)
  rules/agent-system.md           core rules of the agent system
.github/workflows/                pr.yml and terraform.yml triggers; _lint, _test, _terraform reusable blocks
.devcontainer/  .vscode/          universal devcontainer with the Terraform and gh features; editor settings
CLAUDE.md  AGENTS.md              always-on rules; CLAUDE.md is authoritative, AGENTS.md mirrors it
SETUP.md                          full bootstrap guide
.mcp.json                         context7, github and linear servers, secrets as ${ENV} references
VERSION                           local version anchor (5.0.0)
templates/                        agent-tree templates: application, platform, sub-master, domain, shared, config
stack/                            project code once /setup has run: backend/ frontend/ terraform/ docs/
docs/superpowers/                 design spec and implementation plan of the template
```

The workspace is the project monorepo. It is cloned once per project and the clone becomes that
project's repository; application code lives in `stack/` and is committed.

## Source of truth and delegation

The real command body lives at `.claude/commands/<name>.md`. The files
`.cursor/commands/<name>.md` and `.agent/workflows/<name>.md` are one-line delegators that read
exactly:

```
Follow `.claude/commands/<name>.md` in this workspace.
```

Delegation flows `cursor / agent -> claude`. Renaming or moving a `.claude/commands/*` file
orphans its delegators, so both are updated in the same change. Cursor also reads its own
`.cursor/rules/*.mdc`; Claude gets the equivalent rules through `CLAUDE.md` and the skills.

A command file has a single `description:` frontmatter line and an imperative body in
`## Step N` headings. Durable rules go into a skill, heavy or noisy work into a subagent,
`$ARGUMENTS` is used when input is needed, and `mayday` lists every top-level command.

## Always-on versus on-demand

`CLAUDE.md` holds the rules that apply to every task: never commit, push or deploy without
explicit approval; best practice and long-term maintainability first; verify the latest stable
version through Context7 before integrating a library or pattern; no emojis, no comments that
restate the code, only touch the files needed; code structure through Understand-Anything and
Context7 rather than hand-maintained documents.

Everything else loads only when relevant.

| Skill | Loaded when |
|-------|-------------|
| `coding-philosophy` | Writing or reviewing code: lean, long-term, DRY, YAGNI, no dead code |
| `roadmap-linear` | Creating, updating or syncing Linear cards: MCP tools, card structure, tone, the version card |
| `research-patterns` | Before integrating a library, framework or pattern: Context7 first, then the web, record the decision |
| `ci` | Adding or editing GitHub Actions workflows: trigger plus reusable block convention, stack gating, OIDC |
| `slash-commands` | Adding, renaming or editing a command: the `.claude` source of truth and the delegator contract |

| Subagent | Role | Tools |
|----------|------|-------|
| `researcher` | Latest stable version and idiomatic integration of one library or pattern | WebSearch, WebFetch, Context7 |
| `reviewer` | Prioritised findings (blocking, should-fix, nit) on a focused diff, never edits | Read, Bash, Grep, Glob |
| `scaffolder` | Runs the official stack-init CLIs under `stack/` during `/setup`, never `terraform apply` | Bash, Read, Write, Edit |

Each subagent runs in an isolated context and returns a summary; the main context stays clean.

## Hooks

`.claude/settings.json` registers `.claude/hooks/guards.sh` as a `PreToolUse` hook on `Write`
and `Edit`. The script reads the tool payload on stdin, extracts `content` or `new_string` with
`jq` and exits 2 with a message when the text contains an emoji, which blocks the write.

## MCP servers

`.mcp.json` ships a lean default set, trusted explicitly through `enabledMcpjsonServers` in
`.claude/settings.json`. Secrets are `${ENV}` references, never literals.

| Server | Transport | Package | Purpose |
|--------|-----------|---------|---------|
| `context7` | stdio | `@upstash/context7-mcp` | Up-to-date library documentation on demand, so Claude never relies on stale training data |
| `github` | http | GitHub MCP (remote, `https://api.githubcopilot.com/mcp/`) | Repository, pull request, issue and code search operations |
| `linear` | stdio | `@mkusaka/mcp-server-linear` | Linear cards, projects and roadmap state |

Optional servers are offered by `/setup` and are off by default: a database server
(`@bytebase/dbhub`, schema inspection and query assistance) and a browser or automation server
(E2E testing assistance and UI verification). For supply-chain hardening, exact MCP package
versions may be pinned in `.mcp.json` and a gitleaks pre-commit hook added.

## Continuous integration

Two layers under `.github/workflows/`:

- Trigger workflows (`pr.yml`, `terraform.yml`) own the `on:` events and only call blocks.
- Reusable blocks (`_lint.yml`, `_test.yml`, `_terraform.yml`) run on `workflow_call`,
  parameterised by `path` and `lang` (`node` or `python`). The `_` prefix marks them callable only.

Jobs are gated on the chosen stack, for example
`if: ${{ hashFiles('stack/backend/pyproject.toml') != '' }}`, so the committed workflows are a
superset and jobs for an absent stack skip. `/setup` trims them further. The Terraform block
always runs `init` and `plan`, applies only when the trigger passes
`apply: ${{ github.ref == 'refs/heads/main' }}`, and authenticates through GitHub OIDC with
`aws-actions/configure-aws-credentials` and an `AWS_ROLE_ARN` secret: no long-lived keys.

## State and version

`.factory-state.json` (gitignored, example in `templates/config/factory-state.json.example`)
holds the project identity, the Linear team and project ids, the agent root and the `stack`
choices. `VERSION` is the local anchor, currently `5.0.0`; a Linear card titled
`agent-industry-version` mirrors it per workspace and `/version` compares the two.
