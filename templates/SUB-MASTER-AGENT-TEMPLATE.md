# SUB-MASTER: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_INDUSTRY_VERSION: {{AGENT_INDUSTRY_VERSION}}
AGENT_TYPE: sub-master
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
LINEAR_TEAM: {{LINEAR_TEAM}}
LINEAR_PROJECT: {{LINEAR_PROJECT}}
```

## Purpose

This agent orchestrates a subtree of agents scoped to **{{SCOPE_NAME}}** within the {{ORG_NAME}} project. It does NOT contain implementation details. It maps its domain into scoped child agents, describes their responsibilities, and routes actions to the correct child.

When a task falls outside this agent's scope, delegate upward to the parent: `{{PARENT_PATH}}`.

## Domain Overview

{{DOMAIN_OVERVIEW}}

## Agent Architecture

{{AGENT_ARCHITECTURE_DIAGRAM}}

## Folder Structure

```
{{FOLDER_STRUCTURE}}
```

## Child Registry

Each child agent owns a specific scope within this sub-master's domain. Children are organized by category:

- **application** -- unified code + test: source code knowledge AND testing strategy
- **platform** -- unified infra + deploy + specialist: infrastructure, deployment, AND cloud provider expertise
- **planning** (roadmap) -- backlog and dependency tracking

When performing an action, consult the relevant child agent(s) below. If the work crosses into a sibling sub-master's scope, delegate upward to the parent.

{{CHILD_REGISTRY}}

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

## Action Routing

Use this table to determine which child agent(s) to read for common tasks within this domain:

{{ACTION_ROUTING}}

## Delegation Protocol

### Downward (to children)

When a task arrives that falls within this sub-master's scope:

1. Identify which child agent(s) the task affects using the Action Routing table
2. Read the relevant child agent(s) and follow their conventions
3. After completing the task, update the affected child agent(s) using their `update_when` triggers

### Upward (to parent)

Delegate to the parent (`{{PARENT_PATH}}`) when:

- The task affects code, infrastructure, or domains outside this sub-master's scope
- The task requires coordination with sibling agents at the same level
- A cross-cutting concern spans multiple sub-master domains (e.g., shared auth, shared infra)

### Lateral (sibling coordination)

When a task touches both this sub-master's scope and a sibling's:

1. Delegate upward to the parent
2. The parent routes the relevant portion to the sibling sub-master
3. Each sub-master handles its own portion independently

## Update Protocol

After completing any task:

1. Identify which child agent file(s) your changes affect using their `update_when` triggers
2. Update those files with the new state
3. If the change affects this sub-master's scope definition or child registry, update this file
4. If the change crosses scope boundaries, notify the parent

## Cross-References

```yaml
parent: {{PARENT_PATH}}
roadmap: {{ROADMAP_PATH}}
siblings: {{SIBLING_REFS}}
```

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New child agents created under this sub-master
- Child agent scope changes
- New sub-masters added as children
- Action routing table needs new entries
- Folder structure changes
- Scope boundary changes
```

END_OF_DOCUMENT
