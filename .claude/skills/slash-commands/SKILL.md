---
name: slash-commands
description: Use when adding, renaming, or editing a slash command in this multi-IDE template - the .claude source-of-truth and .cursor/.agent delegation contract
---

# Slash Commands

## Source of truth and delegation

The real command body lives at `.claude/commands/<name>.md`. The files
`.cursor/commands/<name>.md` and `.agent/workflows/<name>.md` are ONE-LINE
DELEGATORS, nothing more. Each reads exactly:

```
Follow `.claude/commands/<name>.md` in this workspace.
```

Delegation flows `cursor / agent -> claude`. Cursor and Antigravity invoke their
own file, which points back to the canonical Claude command. Never put command
logic in a delegator.

## The rule when adding or renaming a command

1. Author the body in `.claude/commands/<name>.md`.
2. Add the matching one-line delegator in BOTH `.cursor/commands/<name>.md` and
   `.agent/workflows/<name>.md`.
3. Renaming or moving a `.claude/commands/*` file orphans its delegators -> update
   both in the same change, or the command breaks in Cursor/Antigravity.

Cursor also reads its own `.cursor/rules/*.mdc`; Claude gets the equivalent rules
via `CLAUDE.md` plus skills. Keep both in sync when a durable rule changes.

## Authoring a .claude command

- Frontmatter is a single `description:` line. No other keys.
- Body is imperative `## Step N` headings.
- Push durable rules into a skill (e.g. `roadmap-linear`, `coding-philosophy`,
  `research-patterns`); push heavy or noisy work into a SUBAGENT.
- Use `$ARGUMENTS` when input is needed; otherwise ask one question.
- `mayday` is the router - new top-level commands get listed there.

## Skills vs agents vs hooks

- Skills = on-demand knowledge; frontmatter is `name` + `description` only.
- Agents = isolated work; carry their own `tools` + `model` (see `researcher`,
  `reviewer`, `scaffolder` in `.claude/agents/`).
- Hooks = invisible guards, e.g. the PreToolUse emoji guard - keep all files ASCII.

## Commands

| Command | Purpose | Delegates to |
|---|---|---|
| `mayday` | Menu and router for all commands | - |
| `setup` | Bootstrap a new project from the template | `scaffolder`, `researcher`, coding-philosophy, research-patterns |
| `roadmap` | Sync the roadmap state file from Linear | roadmap-linear |
| `card` | Create or update a Linear card | roadmap-linear |
| `research` | Verify best practice / latest version | `researcher`, research-patterns |
| `version` | Compare local `VERSION` with the Linear card | - |

## Don't

- Don't edit only one delegator - update `.cursor` and `.agent` together.
- Don't put logic in a `.cursor/` or `.agent/` file; they delegate only.
