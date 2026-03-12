First, do you understand well the codebase and its existing test setup? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create an APPLICATION-AGENT (unified code + test) for the project.

## Step 0: Load the agent tree and select parent

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object and the org metadata (`org_name`, `org_name_slug`, `org_name_upper`)
3. If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

### Tree walk -- select parent

Present the agent tree to the user and ask where this application agent should be placed. Use AskQuestion with one option per valid parent.

Valid parents are:
- `master` or `sub-master` nodes (orchestrators)
- `application` nodes (the new agent becomes a scoped sub-agent of an existing application agent)
- `platform` nodes (for application knowledge scoped to a platform concern)

Build the options by walking the tree recursively. Indent child nodes to show hierarchy:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) |
| frontend | SUB-MASTER: Frontend (under root) |
| full-app | APPLICATION-AGENT (full) -- narrow down a sub-scope |

If there is exactly one valid parent (just the MASTER, no other agents), skip the question and use the MASTER automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

Ask the user: "Does this application agent cover the full repo/service, or a specific module/domain?"

Use AskQuestion:

| id | label |
|----|-------|
| full | Full repo/service (covers everything under this parent) |
| scoped | Specific module or domain (e.g., auth, API layer, data pipeline) |

**If `full`**:
- `SCOPE_NAME` = `{{ORG_NAME_UPPER}}` (or the parent's scope name if under a sub-master)
- `SCOPE_DESCRIPTION` = "Full application source code and tests"
- `SCOPE_PATHS` = "full"

**If `scoped`**:
- Ask: "Name for this scope? (short, e.g. 'auth', 'api', 'payments')" -- free text
- Ask: "Describe what this application agent covers" -- free text
- Ask: "List the repo paths this agent owns (comma-separated, e.g. 'src/auth/, src/middleware/auth.ts')" -- free text
- Derive `SCOPE_NAME`, `SCOPE_NAME_SLUG`, `SCOPE_NAME_UPPER`, `SCOPE_DESCRIPTION`, `SCOPE_PATHS`

## Step 2: Parse the codebase (Part I of the template)

Deeply analyze the codebase **within the defined scope**. If scope is `full`, analyze everything. If scoped, focus on the specified paths but also understand how they connect to the rest of the codebase.

You need to understand:

- The architecture and data flow within scope (entry points, pipelines, data transformations)
- Every module within scope, its purpose, and how it connects to others
- Type system and schemas (TypeScript interfaces, Pydantic models, Zod, etc.)
- Design patterns and conventions used in the codebase
- All external service integrations from the code perspective (clients, APIs, databases)
- AI/LLM agents if any: their prompts, models, input/output contracts
- Error handling patterns and error codes
- How to add new features within scope
- Known gotchas, legacy code, and inconsistencies
- **Boundary interfaces**: how this scope connects to code outside its boundaries (imports, exports, shared types, API contracts)

## Step 3: Analyze the test landscape (Part II of the template)

Deeply analyze the repo's existing test setup **within the defined scope**:

- **Test framework and runner**: what tool runs the tests (Jest, pytest, Go test, Vitest, etc.), assertion libraries, configuration files
- **Existing test files**: where they live within scope, how they are organized, what naming convention they follow
- **Test categories present**: unit tests, integration tests, e2e tests, contract tests, snapshot tests
- **Mocking patterns**: what libraries or approaches are used (test doubles, dependency injection, HTTP interception, database fixtures)
- **Test data management**: factories, fixtures, seeds, in-memory databases, test containers
- **Coverage tooling**: if any coverage tool is configured, what thresholds exist
- **CI/CD integration**: which pipeline stages run tests, what triggers them, whether tests gate deployment

If the project has no tests yet within scope, that is fine. Document the framework/runner the project uses (infer from dependencies) and build the strategy from scratch.

## Step 4: Identify critical paths

Using the codebase analysis and test landscape scan, identify the critical paths within scope that MUST have test coverage:

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

Use Context7 MCP (if available) or web search to look up current best practices for the project's specific:
- Language and framework conventions
- Test framework recommended patterns
- Current assertion patterns and anti-patterns
- Mocking best practices for the specific ecosystem
- Integration testing patterns

If neither Context7 nor web search is available, rely on established knowledge but note in the agent file that best practices should be verified.

## Step 6: Read the APPLICATION-AGENT template

Read `templates/APPLICATION-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 7: Generate the APPLICATION-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your analysis. The level of detail should make an agent immediately productive on the codebase without needing to explore files, AND immediately aware of how to test changes correctly.

Key placeholders:
- `{{SCOPE_NAME}}` -- the scope name
- `{{SCOPE_DESCRIPTION}}` -- what this agent covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{ROADMAP_PATH}}` -- path to the roadmap (walk up the tree to root to find it)
- `{{PLATFORM_AGENT_PATH}}` -- path to the sibling platform agent under the same parent, or `[not yet created]`
- `{{SIBLING_REFS}}` -- list other children of the same parent
- `{{LINKED_SPECIALISTS}}` -- `[none]` (populated via link-selection step)
- All codebase content sections (Part I)
- All testing content sections (Part II)

### File naming and placement

- If scope is `full`: write to `<parent_directory>/application/APPLICATION-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/application/APPLICATION-AGENT-{{SCOPE_NAME_UPPER}}.md`

The parent's directory is derived from its `path` field in the tree (the directory containing the parent's agent file).

## Step 8: Update the parent agent

Read the parent agent file. The parent can be a MASTER, SUB-MASTER, or another APPLICATION/PLATFORM agent. Update:

1. **Child Registry**: add a new entry for this application agent:

```yaml
### {{N}}. Application ({{SCOPE_NAME}}) -- APPLICATION-AGENT-{{SCOPE_NAME_UPPER}}

path: <path to new application agent file>
type: application
category: application
scope: {{SCOPE_DESCRIPTION}}
scope_paths: {{SCOPE_PATHS}}
owns:
  - <filled from codebase analysis>
  - code and test strategy for the above

update_when:
  - Any code change within scope
  - New models, services, or API endpoints within scope
  - Schema or type system changes within scope
  - Dependency version changes
  - Docker build changes
  - Test framework or convention changes
  - Coverage threshold changes
  - CI/CD test pipeline changes
```

2. **Agent Hierarchy Diagram**: add the new application agent node and edge from parent
3. **Folder Structure**: add the application agent path
4. **Action Routing**: add routing entries for code, test, and feature tasks within this agent's scope
5. **LAST_UPDATED**: set to today's date

Do NOT change any other child's section.

## Step 9: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}-app",
  "type": "application",
  "category": "application",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "path": "<path to new application agent file>",
  "links": [],
  "children": []
}
```

If scope is `full`, use `"full"` as the scope and omit `scope_paths`.

Write `.factory-state.json` back.

## Step 10: Confirm

Tell the user what was created, its scope, and what the parent agent now contains. Mention that both code knowledge and test strategy are unified in this single agent.

## Agent structure rules

- Application agents go under `<parent_directory>/application/`
- The file MUST include a metadata header with SCOPE, SCOPE_PATHS, PARENT, and a critical warning about update triggers
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a "Scope Boundary" section explaining what is inside and outside scope
- The file MUST include a cross-references section with correct paths to the parent, sibling platform agent, and sibling agents
- The file contains both codebase knowledge (Part I) and test strategy (Part II) in a single document
- Application agents can have children (sub-scoped application or platform agents) for finer-grained context
- When an application agent has children, it acts as both a knowledge base for its scope AND a parent that routes narrower tasks to its children
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
