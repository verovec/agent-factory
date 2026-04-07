# EXPERT-AGENT: {{EXPERT_NAME}}

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
AGENT_INDUSTRY_VERSION: {{AGENT_INDUSTRY_VERSION}}
SCOPE: {{SCOPE_DESCRIPTION}}
DOC_SOURCE: {{DOC_SOURCE}}
```

## Purpose

This is a shared specialist agent. Any agent in the workspace tree can reference it. It provides deep knowledge of {{EXPERT_NAME}} that stays current through documentation lookups.

When a domain agent (code, infra, deploy) references this expert, read this file for context before acting. This agent does not own code or infrastructure -- it provides knowledge and best practices.

## Expertise

{{EXPERTISE_SECTIONS}}

## Documentation Strategy

This agent uses Context7 (or equivalent MCP documentation server) to fetch up-to-date documentation at task time. Do NOT rely on training data for {{EXPERT_NAME}} specifics -- always verify against current docs.

Preferred documentation sources:
{{DOC_SOURCES_LIST}}

When working on a task:
1. Read this file for architectural context and conventions
2. Fetch current docs via Context7 for the specific service/API involved
3. Cross-reference with the domain's infra or code agent for project-specific configuration

## Conventions

{{CONVENTIONS_SECTION}}

## Known Patterns

{{KNOWN_PATTERNS_SECTION}}

## Anti-Patterns

{{ANTI_PATTERNS_SECTION}}

## Referenced By

Domain agents that depend on this expert:
{{REFERENCED_BY_LIST}}

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: Shared
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New service or resource type used in the workspace
- Conventions or best practices change
- New anti-patterns discovered
- Documentation sources change
```

END_OF_DOCUMENT
