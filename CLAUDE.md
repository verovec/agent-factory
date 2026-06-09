# Claude-First Workspace

This repo is a project template. The workspace IS the monorepo: project code lives in
`stack/` (backend/, frontend/, terraform/, docs/). Run `/setup` to bootstrap a new project.

## Always-on rules
- Never commit, push, or deploy on your own. Always ask for explicit approval first.
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
