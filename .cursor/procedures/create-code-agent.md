First, do you understand well the codebase? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create a CODE-AGENT for the project.

## Step 0: Load the agent tree and select parent

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object and the org metadata (`org_name`, `org_name_slug`, `org_name_upper`)
3. If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

### Tree walk -- select parent

Present the agent tree to the user and ask where this code agent should be placed. Use AskQuestion with one option per valid parent (any node of type `master` or `sub-master`).

Build the options by walking the tree recursively. Indent child nodes to show hierarchy:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) |
| frontend | SUB-MASTER: Frontend (under root) |
| frontend-ui | SUB-MASTER: UI Components (under Frontend) |

Only `master` and `sub-master` nodes are valid parents. Leaf agents cannot be parents.

If there is exactly one valid parent (just the MASTER, no sub-masters), skip the question and use the MASTER automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

Ask the user: "Does this code agent cover the full repo/service, or a specific module/domain?"

Use AskQuestion:

| id | label |
|----|-------|
| full | Full repo/service (covers everything under this parent) |
| scoped | Specific module or domain (e.g., auth, API layer, data pipeline) |

**If `full`**:
- `SCOPE_NAME` = `{{ORG_NAME_UPPER}}` (or the parent's scope name if under a sub-master)
- `SCOPE_DESCRIPTION` = "Full application source code"
- `SCOPE_PATHS` = "full"

**If `scoped`**:
- Ask: "Name for this scope? (short, e.g. 'auth', 'api', 'payments')" -- free text
- Ask: "Describe what this code agent covers" -- free text
- Ask: "List the repo paths this agent owns (comma-separated, e.g. 'src/auth/, src/middleware/auth.ts')" -- free text
- Derive `SCOPE_NAME`, `SCOPE_NAME_SLUG`, `SCOPE_NAME_UPPER`, `SCOPE_DESCRIPTION`, `SCOPE_PATHS`

## Step 2: Parse the codebase

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

## Step 3: Read the CODE-AGENT template

Read `templates/CODE-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 4: Generate the CODE-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your codebase analysis. The level of detail should make an agent immediately productive on the codebase without needing to explore files.

Key placeholders:
- `{{SCOPE_NAME}}` -- the scope name
- `{{SCOPE_DESCRIPTION}}` -- what this agent covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{ROADMAP_PATH}}` -- path to the roadmap (walk up the tree to root to find it)
- `{{TEST_AGENT_PATH}}` -- path to the sibling test agent under the same parent, or `[not yet created]`
- `{{SIBLING_REFS}}` -- list other children of the same parent
- All content sections from codebase analysis

### File naming and placement

- If scope is `full`: write to `<parent_directory>/code/CODE-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/code/CODE-AGENT-{{SCOPE_NAME_UPPER}}.md`

The parent's directory is derived from its `path` field in the tree (the directory containing the parent's agent file).

## Step 5: Update the parent agent

Read the parent agent file (MASTER or SUB-MASTER). Update:

1. **Child Registry**: add a new entry for this code agent:

```yaml
### {{N}}. Codebase ({{SCOPE_NAME}}) -- CODE-AGENT-{{SCOPE_NAME_UPPER}}

path: <path to new code agent file>
type: code
scope: {{SCOPE_DESCRIPTION}}
scope_paths: {{SCOPE_PATHS}}
owns:
  - <filled from codebase analysis>

update_when:
  - Any code change within scope
  - New models, services, or API endpoints within scope
  - Schema or type system changes within scope
  - Dependency version changes
  - Docker build changes
```

2. **Agent Hierarchy Diagram**: add the new code agent node and edge from parent
3. **Folder Structure**: add the code agent path
4. **Action Routing**: add routing entries for this agent's scope
5. **LAST_UPDATED**: set to today's date

Do NOT change any other child's section.

## Step 6: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}-code",
  "type": "code",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "path": "<path to new code agent file>",
  "children": []
}
```

If scope is `full`, use `"full"` as the scope and omit `scope_paths`.

Write `.factory-state.json` back.

## Step 7: Confirm

Tell the user what was created, its scope, and what the parent agent now contains.

## Agent structure rules

- Code agents go under `<parent_directory>/code/`
- The file MUST include a metadata header with SCOPE, SCOPE_PATHS, PARENT, and a critical warning about update triggers
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a "Scope Boundary" section explaining what is inside and outside scope
- The file MUST include a cross-references section with correct paths to the parent and sibling agents
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
