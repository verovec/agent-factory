# Claude-First Workspace (universal agent context)

This file mirrors the essentials of `CLAUDE.md`, which is the authoritative version.

This repo is a project template. The workspace IS the monorepo: project code lives in
`stack/` (backend/, frontend/, terraform/, docs/). Run `/setup` to bootstrap a new project.

## Always-on rules
- Never commit, push, or deploy on your own. Always ask for explicit approval first.
- Best practice and long-term maintainability first.
- Before integrating a new library/pattern/tool, verify current best practice and latest
  stable version via Context7 (web search if needed) before writing code.
- Never use emojis. No comments that restate code. Only touch files needed for the task.
- For code structure, use the Understand-Anything plugin and Context7 on demand.

## On-demand context
- Writing/reviewing code -> coding-philosophy skill.
- Linear cards / roadmap -> roadmap-linear skill; commands `/roadmap`, `/card`.
- Integrating a new pattern -> research-patterns skill; command `/research`.

See `CLAUDE.md` for the authoritative version.
