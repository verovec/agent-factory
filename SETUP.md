# Claude-First Project Template

A Claude-first monorepo project template. Clone it once, open in Claude Code, and run `/setup` to bootstrap a production-ready project with AI-native tooling, CI, and Linear integration.

---

## Prerequisites

- **git** — version control
- **GitHub CLI** (`gh`) — authenticated (`gh auth status`); used to create and link the project repo
- **Node.js + npx** — required to run the stack scaffolding CLIs
- **Claude Code** — the agent interface this template is designed for
- **API keys** — edit the placeholders in `.mcp.json` before running `/setup`:
  - `YOUR_GITHUB_TOKEN` — a GitHub personal access token with repo scope
  - `YOUR_LINEAR_API_KEY` — a Linear API key (Settings > API > Personal API keys)

Never commit real secrets. `.mcp.json` is gitignored by default; keep it that way.

---

## Recommended Plugin: Understand-Anything

Install the **Understand-Anything** plugin via the Claude Code `/plugin` marketplace before running `/setup`.

This plugin provides the code knowledge graph that powers Gortex MCP tools (`search_symbols`, `get_callers`, `smart_context`, etc.). Instead of hand-maintaining a mental model of the codebase, Claude pulls structure on demand — callers, dependencies, dataflow — directly from the graph. Without the plugin, Claude falls back to file reads, which is slower and less accurate for large codebases.

---

## Quick Start

```bash
git clone https://github.com/verovec/agent-factory.git my-project
cd my-project
```

1. Open the `my-project` folder in Claude Code.
2. Install the **Understand-Anything** plugin via `/plugin`.
3. Fill in the API key placeholders in `.mcp.json`.
4. Run `/setup`.

---

## What `/setup` Does

1. **Checks preconditions** — verifies `git`, `gh` (authenticated), and `node`/`npx` are available.
2. **Detaches the template remote** — removes the `origin` remote so the new project is not linked back to this template.
3. **Asks for project identity** — project name, slug, and description; written into the agent config.
4. **Asks about the stack** — frontend framework (e.g. Next.js, none), backend framework (e.g. FastAPI, none); infrastructure is always Terraform on AWS.
5. **Presents the optional MCP menu** — lets you enable additional MCP servers (database, browser/automation) for this project.
6. **Asks which CI to keep** — removes the workflows you do not need.
7. **Scaffolds a runnable skeleton** under `stack/` using the official latest CLIs for each chosen technology (no `terraform apply`).
8. **Generates a stack-tuned Claude config** — writes agent files and `.claude/settings.json` entries matched to your stack.
9. **Trims CI** — deletes the workflow files that do not match your chosen CI provider.
10. **Creates and links a new GitHub repo** — runs `gh repo create` with your project name and pushes the initial commit.
11. **Optionally creates a Linear project** — if a `LINEAR_API_KEY` is present, scaffolds a Linear project and writes its ID into `.factory-state.json`.
12. **Prints a summary** — lists what was created, what secrets still need filling, and the next steps.

---

## Default MCP Servers

Configured in `.mcp.json` and enabled via `.claude/settings.json` (`enabledMcpjsonServers`):

| Server | Transport | Package | Purpose |
|--------|-----------|---------|---------|
| **context7** | stdio | `@upstash/context7-mcp` | Up-to-date library documentation on demand — fetches current API docs so Claude never relies on stale training data |
| **github** | http | GitHub MCP (remote) | Repository operations, pull requests, issues, and code search directly in the agent |
| **linear** | stdio | `@mkusaka/mcp-server-linear` | Linear card management — create, read, and update issues, projects, and roadmap state |

The `YOUR_GITHUB_TOKEN` and `YOUR_LINEAR_API_KEY` placeholders in `.mcp.json` must be replaced with real values before these servers will function.

---

## Optional MCP Servers

Available via the MCP menu during `/setup`:

- **Database** — `@bytebase/dbhub`; gives Claude read/write access to your database for schema inspection and query assistance.
- **Browser / automation** — enables Claude to open, navigate, and interact with a browser for E2E testing assistance and UI verification.

These are not enabled by default. Select them during `/setup` if your stack needs them.

---

## Manual Fallback

If `gh` is unavailable or you prefer to create the GitHub repo by hand:

1. Create the repo in the GitHub web UI (github.com/new).
2. Back in the project directory, add the remote and push:

```bash
git remote add origin https://github.com/<your-org>/<your-repo>.git
git push -u origin main
```

Then continue running `/setup` — it will detect that a remote is already configured and skip the `gh repo create` step.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/setup` | Bootstrap the project (run once after cloning) |
| `/roadmap` | View and update the Linear roadmap |
| `/card` | Create or update a Linear card |
| `/research` | Deep research on a topic |
| `/version` | Show and sync the project version |
| `/mayday` | Emergency triage — surface errors, dead code, and open TODOs |

Commands live in `.claude/commands/`.
