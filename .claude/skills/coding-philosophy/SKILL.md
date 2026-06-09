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
