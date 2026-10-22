<p align="center">
  <img src="docs/assets/logo.svg" width="120" height="120" alt="agent-factory logo">
</p>

<h1 align="center">agent-factory</h1>

<p align="center">
  <strong>Clone it once, run <code>/setup</code>, and start from a project that already knows how to work with Claude.</strong><br>
  A Claude-first monorepo template for Claude Code, Cursor and Antigravity: commands, skills,
  subagents, hooks, CI and Linear wired in, with <code>.claude/</code> as the single source of truth.
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> &middot;
  <a href="#how-it-works">How it works</a> &middot;
  <a href="#commands">Commands</a> &middot;
  <a href="#tech-stack">Tech stack</a> &middot;
  <a href="#documentation">Documentation</a>
</p>

<p align="center">
  <img alt="Version 5.0.0" src="https://img.shields.io/badge/version-5.0.0-f59e0b">
  <img alt="Claude Code" src="https://img.shields.io/badge/Claude_Code-source_of_truth-D97757?logo=claude&amp;logoColor=white">
  <img alt="Cursor and Antigravity" src="https://img.shields.io/badge/Cursor_%2F_Antigravity-delegators-1f2937">
  <img alt="GitHub Actions" src="https://img.shields.io/badge/GitHub_Actions-CI-2088FF?logo=githubactions&amp;logoColor=white">
  <img alt="Terraform on AWS" src="https://img.shields.io/badge/Terraform-AWS-7B42BC?logo=terraform&amp;logoColor=white">
  <img alt="Linear" src="https://img.shields.io/badge/Linear-MCP-5E6AD2?logo=linear&amp;logoColor=white">
</p>

---

Starting a project with an AI coding agent means rebuilding the same scaffolding every time: the
rules the agent must follow, the commands it can run, the CI, the link to the issue tracker.
**agent-factory** is a project template that ships all of it. You clone it once per project, open
it in Claude Code and run `/setup`. The wizard detaches the template remote, asks for the stack
(frontend, backend, Terraform on AWS), scaffolds a runnable skeleton under `stack/` with the
official CLIs, trims CI to what you chose and creates the GitHub repository. The clone becomes the
project repository.

The template is lean on purpose. Context is expensive, so `CLAUDE.md` carries only the rules that
apply to every task and everything else is pulled on demand: skills for knowledge (coding
philosophy, Linear and roadmap rules, how to research a pattern), subagents for noisy work
(research, review, scaffolding) that report back a summary, hooks for the non-negotiables such as
no emojis. Code structure comes from the
[Understand-Anything](https://github.com/Egonex-AI/Understand-Anything) plugin and Context7, not
from hand-maintained documents.

This is the multi-IDE edition. `.claude/` is the source of truth; `.cursor/` and `.agent/` hold
one-line delegators that point back at it, so Cursor and Antigravity stay in sync with zero
duplication. A Claude-only twin, with GitNexus code intelligence and parallel card delivery, lives
at [`claude-workspace`](https://github.com/verovec/claude-workspace).

## Quick start

**Prerequisites:** `git`, the GitHub CLI authenticated (`gh auth status`), Node.js with `npx`,
Claude Code, and two API keys exported in your shell: `GITHUB_TOKEN` (repo scope) and
`LINEAR_API_KEY`. `.mcp.json` references them as `${VAR}`, so no secret is ever written to a
tracked file.

```bash
git clone git@github.com:verovec/agent-factory.git ~/projects/my-project
cd ~/projects/my-project
export GITHUB_TOKEN=...     # add to your shell profile, not the repo
export LINEAR_API_KEY=...   # Linear: Settings > API > Personal API keys
# Open the folder in Claude Code, install the Understand-Anything plugin via /plugin, then run /setup
```

`/setup` confirms each destructive step and ends with a summary of what was created and what is
left to fill. The full walkthrough, the optional MCP servers and the manual fallback when `gh` is
unavailable are in [`SETUP.md`](SETUP.md).

## How it works

```
  Clone         one clone of the template per project; the clone becomes the project repository
     |
  /setup        detach the remote, ask identity and stack, scaffold stack/ with the official latest CLIs
     |
  Config        a lean CLAUDE.md, per-stack skills, .mcp.json, .factory-state.json (gitignored)
     |
  CI            thin trigger workflows call the reusable _lint, _test and _terraform blocks, gated per stack
     |
  GitHub        gh repo create, initial commit and push; optionally a Linear project seeded by /roadmap
     |
  Work          /roadmap, /card, /research, /version; skills and subagents load only when relevant
```

Every command body lives in `.claude/commands/<name>.md`. The matching `.cursor/commands/<name>.md`
and `.agent/workflows/<name>.md` contain exactly one line, `Follow .claude/commands/<name>.md in
this workspace.`, so the three IDEs run the same procedure. A `PreToolUse` hook on `Write` and
`Edit` blocks any content that contains an emoji.

## Commands

| Command | Purpose |
|---------|---------|
| `/setup` | Bootstrap a new project: detach the template remote, scaffold the chosen stack at latest versions, generate stack-tuned config, create and link a new GitHub repo |
| `/roadmap` | Sync the roadmap state file from Linear |
| `/card` | Create or update a Linear card (rules live in the `roadmap-linear` skill) |
| `/research` | Verify current best practice and latest stable version before integrating a pattern |
| `/version` | Compare the local `VERSION` with the Linear version card |
| `/mayday` | Router that points you to the right command |

## Tech stack

| Layer | Tech | Location |
|-------|------|----------|
| Commands, skills, subagents, hooks | Markdown and Bash for Claude Code | `.claude/commands`, `.claude/skills`, `.claude/agents`, `.claude/hooks` |
| IDE delegators | one-line Cursor commands and Antigravity workflows | `.cursor/commands`, `.agent/workflows` |
| Always-on rules | `CLAUDE.md` (authoritative), mirrored by `AGENTS.md` and `.cursor/rules` | repository root, `.cursor/rules` |
| MCP servers | context7, GitHub, Linear, trusted through `enabledMcpjsonServers` | `.mcp.json`, `.claude/settings.json` |
| CI | GitHub Actions, reusable `workflow_call` blocks, OIDC to AWS | `.github/workflows` |
| Agent-tree templates | Markdown templates generated on demand by `/setup` | `templates/` |
| Dev environment | devcontainer (universal image, Terraform and `gh` features), VS Code settings | `.devcontainer`, `.vscode` |

Details in [Architecture](docs/architecture.md).

## Documentation

| Topic | Where |
|-------|-------|
| Layout, source of truth, skills, subagents, hooks, MCP servers, CI | [`docs/architecture.md`](docs/architecture.md) |
| Bootstrap steps, recipes, conventions, adding a command | [`docs/development.md`](docs/development.md) |
| Full setup guide, optional MCP servers, manual fallback | [`SETUP.md`](SETUP.md) |
| Design of the Claude-first template | [`docs/superpowers/specs/`](docs/superpowers/specs/2026-06-09-claude-first-workspace-template-design.md) |
| Implementation plan of the template | [`docs/superpowers/plans/`](docs/superpowers/plans/2026-06-09-claude-first-workspace-template.md) |
| Everything else | [`docs/`](docs/README.md) |

## Contributing

Issues and pull requests are welcome. The template follows its own rules: no emojis (the hook
blocks them), no comments that restate the code, and the latest stable version verified before a
new pattern is integrated. When you add or rename a command, update the `.cursor/` and `.agent/`
delegators in the same change; the `slash-commands` skill explains the contract.

Author: [Clement Verove](https://github.com/verovec)
