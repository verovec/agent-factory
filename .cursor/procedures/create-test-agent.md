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

Build the options by walking the tree recursively. Indent child nodes to show hierarchy. Only show parents that have at least one code agent child:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) -- has CODE-AGENT |
| frontend | SUB-MASTER: Frontend -- has CODE-AGENT (auth), CODE-AGENT (dashboard) |

If there is exactly one valid parent, skip the question and use it automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

If the selected parent has multiple code agents, ask which one this test agent pairs with:

| id | label |
|----|-------|
| auth | CODE-AGENT: auth (src/auth/, src/middleware/auth.ts) |
| dashboard | CODE-AGENT: dashboard (src/pages/dashboard/) |
| full | All code agents under this parent |

The test agent's scope should match its paired code agent's scope (or cover all code agents if `full`).

- `SCOPE_NAME` = the code agent's scope name (or the parent's scope name if `full`)
- `SCOPE_DESCRIPTION` = "Test strategy for <scope>"
- `SCOPE_PATHS` = same as the paired code agent's scope_paths

If only one code agent exists under the parent, inherit its scope automatically.

## Step 2: Read the CODE-AGENT

Read the paired code agent file to understand:

- The application architecture and data flow within scope
- Data models and schemas
- External service integrations
- API layer and authentication
- Existing testing patterns
- Design patterns and conventions

This gives you the full picture of what the scoped codebase does and where the critical paths are.

## Step 3: Analyze the test landscape

Deeply analyze the repo's existing test setup **within the defined scope**. You need to understand:

- **Test framework and runner**: what tool runs the tests (Jest, pytest, Go test, Vitest, etc.), assertion libraries, configuration files
- **Existing test files**: where they live within scope, how they are organized, what naming convention they follow
- **Test categories present**: unit tests, integration tests, e2e tests, contract tests, snapshot tests
- **Mocking patterns**: what libraries or approaches are used (test doubles, dependency injection, HTTP interception, database fixtures)
- **Test data management**: factories, fixtures, seeds, in-memory databases, test containers
- **Coverage tooling**: if any coverage tool is configured, what thresholds exist
- **CI/CD integration**: which pipeline stages run tests, what triggers them, whether tests gate deployment

If the project has no tests yet within scope, that is fine. Document the framework/runner the project uses (infer from dependencies) and build the strategy from scratch.

## Step 4: Identify critical paths

Using the code agent's architecture analysis and your own codebase scan, identify the critical paths within scope that MUST have test coverage:

- Authentication and authorization flows
- Payment or billing logic
- Data persistence and integrity (database writes, migrations)
- Public API contracts (request/response shapes, status codes)
- Core business logic (the domain-specific rules that define what the product does)
- Data transformation pipelines
- External service integration boundaries
- State machines or workflow engines

Rank them by impact severity.

## Step 5: Research best practices

Use Context7 MCP (if available) or web search to look up current best practices for the project's specific test framework and language. Look up:

- The framework's recommended test structure and configuration
- Current assertion patterns and anti-patterns
- Mocking best practices for the specific ecosystem
- Integration testing patterns for the frameworks in use

If neither Context7 nor web search is available, rely on established knowledge but note in the agent file that best practices should be verified.

## Step 6: Read the TEST-AGENT template

Read `templates/TEST-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 7: Generate the TEST-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your analysis.

Key placeholders:
- `{{SCOPE_NAME}}` -- the scope name
- `{{SCOPE_DESCRIPTION}}` -- what this agent covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{ROADMAP_PATH}}` -- path to the roadmap (walk up the tree to root to find it)
- `{{CODE_AGENT_PATH}}` -- path to the paired code agent
- `{{SIBLING_REFS}}` -- list other children of the same parent
- All content sections from test analysis

### File naming and placement

- If scope is `full`: write to `<parent_directory>/test/TEST-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/test/TEST-AGENT-{{SCOPE_NAME_UPPER}}.md`

## Step 8: Update the parent agent

Read the parent agent file. Update:

1. **Child Registry**: add a new entry for this test agent
2. **Agent Hierarchy Diagram**: add the test agent node and edge from parent, plus edge from paired code agent
3. **Folder Structure**: add the test agent path
4. **Action Routing**: add test-related routing entries for this scope
5. **LAST_UPDATED**: set to today's date

Do NOT change any other child's section.

## Step 9: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}-test",
  "type": "test",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "path": "<path to new test agent file>",
  "children": []
}
```

Write `.factory-state.json` back.

## Step 10: Confirm

Tell the user what was created, its scope, which code agent it pairs with, and what the parent agent now contains.

## Agent structure rules

- Test agents go under `<parent_directory>/test/`
- The file MUST include a metadata block with SCOPE, SCOPE_PATHS, PARENT
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a "Scope Boundary" section
- The file MUST include a cross-references section with correct paths to the parent, paired code agent, and sibling agents
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.

## Interaction model

The test agent is **not invoked directly by the user** for day-to-day work. Instead:

1. The paired **code agent** delegates to this test agent when implementing a feature that touches a critical path. The code agent reads the test agent file and follows its conventions to write tests.
2. The test agent is **consulted** (its file is read) whenever someone needs to know the testing conventions, critical path coverage status, or whether a test modification is acceptable.
3. The test agent file is **updated** after test suite changes via the `/mayday` update flow.
4. When tests are modified, the test agent's **Test Modification Policy** (section 7) applies -- existing test changes require a warning and justification.
