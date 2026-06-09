# Agent Factory

A Claude-first monorepo **project template**. Clone it once, run `/setup`, and you get a
runnable project (frontend + backend + Terraform/AWS) wired with AI-native tooling, CI, and
Linear integration. Claude Code is the primary surface; Cursor and Antigravity work too via
thin delegators.

This is the **multi-IDE** edition. A Claude-only twin lives at
[`claude-workspace`](https://github.com/verovec/claude-workspace).

## Philosophy: native-first and lean

Context is expensive, so almost nothing is always-on. `CLAUDE.md` carries only the rules
that apply to every task. Everything else is pulled on demand:

- **Skills** (`.claude/skills/`) — knowledge loaded only when relevant (coding philosophy,
  Linear/roadmap rules, how to research a new pattern).
- **Subagents** (`.claude/agents/`) — noisy work (research, review, scaffolding) runs in an
  isolated context and reports back a summary.
- **Code structure** comes from the [Understand-Anything](https://github.com/Egonex-AI/Understand-Anything)
  plugin + Context7, not hand-maintained docs.
- **Hooks** (`.claude/hooks/`) — invisible non-negotiables (e.g. no emojis).

`.claude/` is the single source of truth. `.cursor/` and `.agent/` are one-line delegators
that point back at it, so Cursor and Antigravity stay in sync with zero duplication.

## Layout

The workspace **is** the project monorepo. Clone it once per project; it becomes that
project's repo. Application code lives in `stack/` (committed).

```
~/projects/my-project/                <-- template clone (becomes the project repo)
  .claude/                            <-- source of truth
    commands/   skills/   agents/   hooks/   settings.json
  .cursor/  .agent/                  <-- delegate to .claude/
  .github/workflows/                 <-- reusable + stack-aware CI
  .vscode/  .devcontainer/
  CLAUDE.md  AGENTS.md  SETUP.md  .mcp.json
  templates/                         <-- optional agent-tree templates (generated on demand)
  stack/                             <-- project code (committed)
    backend/  frontend/  terraform/  docs/
```

## Commands

| Command | Purpose |
|---------|---------|
| `/setup` | Bootstrap a new project: detach the template remote, scaffold the chosen stack at latest versions, generate stack-tuned config, create and link a new GitHub repo |
| `/roadmap` | Sync the roadmap state file from Linear |
| `/card` | Create or update a Linear card (rules live in the `roadmap-linear` skill) |
| `/research` | Verify current best practice and latest stable version before integrating a pattern |
| `/version` | Compare the local `VERSION` with the Linear version card |
| `/mayday` | Router that points you to the right command |

## Quick start

```bash
git clone git@github.com:verovec/agent-factory.git ~/projects/my-project
cd ~/projects/my-project
export GITHUB_TOKEN=...   LINEAR_API_KEY=...   # referenced by .mcp.json, never committed
# In Claude Code: install the Understand-Anything plugin via /plugin, then run /setup
```

See [`SETUP.md`](SETUP.md) for the full guide.

## MCP servers

`.mcp.json` ships a lean default set, trusted explicitly via
`.claude/settings.json` (`enabledMcpjsonServers`). Secrets are `${ENV}` references, never
literals:

- **context7** — up-to-date library docs on demand
- **github** — repo / PR / issue operations
- **linear** — roadmap and card management

Optional servers (database, browser) are offered by `/setup`, off by default.

## Conventions

- **Never commit, push, or deploy without explicit approval.** This is the first always-on
  rule in `CLAUDE.md`.
- No emojis. Best practice and long-term maintainability first.
- Infrastructure is always Terraform on AWS.

## Version

`VERSION` is the local anchor (currently `5.0.0`); a Linear card titled
`agent-industry-version` mirrors it per workspace.

## Credits

Author: Clement VEROVE <verove.clement@gmail.com>
