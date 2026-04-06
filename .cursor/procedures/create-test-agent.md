First, do you understand well the codebase and its existing test setup? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create a TEST-AGENT for the project.

## Prerequisites

A CODE-AGENT must already exist under the same parent. The test agent depends on the code agent's architecture analysis to identify critical paths and understand the codebase's patterns. Check the parent's children in `.factory-state.json` for a `code` type node. If none exists, tell the user to create the code agent first via `/mayday`.

## Step 0: Load the agent tree and select parent

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object and the org metadata (`org_name`, `org_name_slug`, `org_name_upper`)
3. If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

### Tree walk -- select parent

Present the agent tree to the user and ask where this test agent should be placed. Use AskQuestion with one option per valid parent (any node of type `master` or `sub-master` that already has at least one `code` child).

Build the options by walking the tree recursively. Only show parents that have at least one code agent child:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) -- has CODE-AGENT |
| frontend | SUB-MASTER: Frontend -- has CODE-AGENT (auth), CODE-AGENT (dashboard) |

If there is exactly one valid parent, skip the question and use it automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

If the selected parent has multiple code agents, ask which one this test agent pairs with. The test agent's scope should match its paired code agent's scope.

If only one code agent exists under the parent, inherit its scope automatically.

## Step 2: Read the CODE-AGENT

Read the paired code agent file to understand the application architecture and identify critical paths.

## Step 3: Analyze the test landscape

Deeply analyze the repo's existing test setup **within the defined scope**.

## Step 4: Identify critical paths

Using the code agent's architecture analysis, identify critical paths that MUST have test coverage.

## Step 5: Research best practices

Use Context7 MCP (if available) to look up current best practices for the project's test framework.

## Step 6: Read the TEST-AGENT template

Read `templates/domain/TEST-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 7: Generate the TEST-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your analysis.

### File naming and placement

- If scope is `full`: write to `<parent_directory>/test/TEST-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/test/TEST-AGENT-{{SCOPE_NAME_UPPER}}.md`

## Step 8: Update the parent agent

Read the parent agent file. Update child registry, hierarchy diagram, folder structure, action routing, and LAST_UPDATED.

## Step 9: Update factory state

Add the new test agent node to the tree in `.factory-state.json`.

## Step 10: Confirm

Tell the user what was created, its scope, which code agent it pairs with, and what the parent agent now contains.

## Agent structure rules

- Test agents go under `<parent_directory>/test/`
- The file MUST include a metadata block with SCOPE, SCOPE_PATHS, PARENT
- The file MUST include a "Linear Card Policy" section
- The file MUST include a "Scope Boundary" section
- The file MUST include a cross-references section
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
