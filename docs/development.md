# Development

## Prerequisites

- `git`.
- The GitHub CLI, authenticated (`gh auth status`); `/setup` uses it to create and link the repo.
- Node.js with `npx`, to run the stack scaffolding CLIs.
- Claude Code, the agent interface this template is designed for. Cursor and Antigravity work
  through the delegators.
- `GITHUB_TOKEN` (a personal access token with repo scope) and `LINEAR_API_KEY` (Settings > API >
  Personal API keys) exported in your shell before launching Claude Code. `.mcp.json` references
  them as `${VAR}`; never commit real secrets.
- The Understand-Anything plugin, installed through the Claude Code `/plugin` marketplace. It
  provides the code knowledge graph behind the Gortex MCP tools (`search_symbols`, `get_callers`,
  `smart_context`). Without it Claude falls back to file reads, which is slower on large codebases.

## What `/setup` does

1. Checks preconditions: `git`, `gh` (authenticated) and `node`/`npx`.
2. Detaches the template remote (`git remote remove origin`), after confirmation.
3. Asks for the project identity: name, slug, description, GitHub visibility.
4. Asks about the stack: frontend (Next.js, React with Vite, SvelteKit, none), backend (FastAPI,
   NestJS, Go, none); infrastructure is always Terraform on AWS, so only the region and the remote
   state backend are asked.
5. Presents the optional MCP menu (database, browser or automation).
6. Asks which CI workflows to keep (lint, test, terraform, deploy).
7. Scaffolds a runnable skeleton under `stack/` with the official latest CLIs, plus a
   `.devcontainer` and `docker-compose` for local development. No `terraform apply`.
8. Generates a stack-tuned Claude config: a lean `CLAUDE.md`, per-stack skills under
   `.claude/skills/<tech>/SKILL.md`, the chosen servers in `.mcp.json`, `.factory-state.json`, and
   optionally a lean agent tree (master and roadmap) from `templates/`.
9. Trims CI to the chosen stack, keeping the reusable `_*.yml` blocks still referenced.
10. Creates and links a new GitHub repo with `gh repo create <slug> --<visibility> --source=.
    --remote=origin --push`, committing first if the tree is dirty.
11. Optionally creates or links a Linear project and runs `/roadmap` to seed the state file.
12. Prints a summary: what was created, which MCP servers and CI are enabled, the next steps.

If `gh` is unavailable, create the repository on github.com, then `git remote add origin
https://github.com/<your-org>/<your-repo>.git` and `git push -u origin main`; `/setup` detects the
existing remote and skips `gh repo create`.

## Recipes

```sh
gh auth status                                              # the GitHub CLI must be authenticated before /setup
export GITHUB_TOKEN=... LINEAR_API_KEY=...                  # read by .mcp.json through ${VAR}, never committed
jq . .mcp.json .claude/settings.json                        # both JSON files must stay valid after an edit
grep -L 'Follow `.claude/commands/' .cursor/commands/*.md .agent/workflows/*.md   # lists any delegator that lost its one line
cat VERSION                                                 # local version anchor, mirrored by the Linear version card
```

There is no build and no test suite: validation is file existence, JSON validity, delegator
correctness and a grep for stray references.

## Adding a command

1. Author the body in `.claude/commands/<name>.md`: a single `description:` frontmatter line, an
   imperative body in `## Step N` headings, `$ARGUMENTS` when input is needed.
2. Add the one-line delegator in both `.cursor/commands/<name>.md` and
   `.agent/workflows/<name>.md`.
3. List the command in `/mayday`, the router, and in the `Commands` section of `CLAUDE.md`.
4. Push durable rules into a skill and heavy work into a subagent; the command only orchestrates.

## Conventions

- Never commit, push or deploy without explicit approval. It is the first always-on rule.
- No emojis anywhere; the `PreToolUse` hook enforces it on writes.
- No comments that restate the code (`.cursor/rules/no-noise-comments.mdc` gives the examples).
- Verify the latest stable version and the idiomatic integration through Context7, then the web,
  before adding a library or pattern. Record the decision in the per-stack skill.
- Infrastructure is always Terraform on AWS. CI authenticates with OIDC; pin third-party actions
  to a commit SHA; pass event data through `env:`, never inline in `run:`.
- Linear card content never mentions agent files, paths or the workspace structure.
