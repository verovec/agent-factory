# MASTER-AGENT: {{ORG_NAME}}

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_INDUSTRY_VERSION: {{AGENT_INDUSTRY_VERSION}}
SCOPE: {{ORG_NAME}} domain -- orchestrates the full agent hierarchy
LINEAR_TEAM: {{LINEAR_TEAM}}
LINEAR_PROJECT: {{LINEAR_PROJECT}}
```

## Purpose

This is the single entry point for any agent working on the {{ORG_NAME}} project. It does NOT contain implementation details. Instead, it maps the domain into a hierarchy of scoped agent files, describes their responsibilities, and tells you where to look and what to update for any given action.

Import this file when starting any task related to {{ORG_NAME}} (code, infra, deployment, planning).

## Domain Overview

{{DOMAIN_OVERVIEW}}

## Agent Hierarchy

The agent tree below shows every agent in this workspace, grouped by category. Any agent can have children for finer-grained context. The tree can be nested to any depth.

Categories:
- **application** -- unified code + test. Can have scoped sub-agents (e.g. auth, payments) for tighter context.
- **platform** -- unified infra + deploy + specialist. Can have scoped sub-agents (e.g. AWS-only, K8s-only) for focused provider knowledge.
- **planning** (roadmap) -- backlog, dependency tracking, Linear integration

{{AGENT_HIERARCHY_DIAGRAM}}

## Folder Structure

```
{{FOLDER_STRUCTURE}}
```

## Child Registry

Each child entry below is an agent owning a specific scope. Any agent can have its own children for finer-grained context. When performing an action, consult the relevant child(ren). If a sub-master or scoped agent exists for the domain, delegate to it -- it will route to the correct sub-agent within its subtree.

{{CHILD_REGISTRY}}

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first:

```
{{ROADMAP_PATH}}
```

The roadmap owns all Linear card rules: structure, formatting, tone, defaults, MCP tool usage, and confidentiality constraints. No other agent file duplicates these rules. Always defer to the roadmap's "Linear Card Rules" section.

## Action Routing

Use this table to determine which agent(s) to read for common tasks. When a sub-master exists for the relevant domain, route to it first -- it will handle further delegation within its subtree.

{{ACTION_ROUTING}}

## Delegation Protocol

### Routing a task

1. Identify the scope of the task (which part of the codebase, which service, which domain)
2. Check the Child Registry for a sub-master or leaf agent whose scope matches
3. If a sub-master covers the domain, delegate to it entirely -- do not reach past it into its children
4. If a leaf agent is a direct child and covers the scope, delegate to it
5. If the task spans multiple children, delegate to each relevant child independently

### Cross-cutting tasks

When a task touches multiple domains (e.g., shared auth affecting both frontend and backend):

1. Identify all affected children
2. Delegate to each relevant child (sub-master or leaf)
3. Each child handles its own scope independently
4. Collect results and update the roadmap if needed

## Update Protocol

After completing any task:

1. Identify which agent file(s) your changes affect using the `update_when` triggers in the Child Registry
2. Update those files with the new state
3. If a roadmap phase was completed, update the roadmap status and dependency graph
4. If the agent hierarchy changed (new agents, removed agents, scope changes), update this file

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New child agents or sub-masters created
- Agent scope changes
- New Linear tickets added to the roadmap
- Action routing table needs new entries
- Folder structure changes
- Agent hierarchy changes
```

END_OF_DOCUMENT
