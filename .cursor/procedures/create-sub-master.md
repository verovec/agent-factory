First, do you understand well the current agent hierarchy? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create a SUB-MASTER agent.

## Step 0: Load the agent tree

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object -- this is the full agent hierarchy
3. Extract `{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`, `{{LINEAR_TEAM}}`, `{{LINEAR_TEAM_ID}}`, and `{{LINEAR_PROJECT}}`

If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

## Step 1: Walk the tree -- select parent

Present the agent tree to the user and ask where this sub-master should be placed. Use AskQuestion with one option per valid parent.

Valid parents are any node: `master`, `sub-master`, `application`, or `platform`. Any agent can have children.

Build the options by walking the tree recursively. Indent child nodes to show hierarchy:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) |
| frontend | SUB-MASTER: Frontend (under root) |
| full-app | APPLICATION-AGENT (full) -- organize sub-scopes under it |

Store the selected parent node's `id` and `path`.

## Step 2: Define the scope

Ask two questions:

1. "Name for this sub-master? (short, e.g. 'frontend', 'api', 'payments')" -- free text
2. "Describe what this sub-master covers (e.g. 'Frontend React application including all UI components, routing, and state management')" -- free text

Derive:
- `SCOPE_NAME` = the name as provided
- `SCOPE_NAME_SLUG` = slugified (lowercase, hyphens)
- `SCOPE_NAME_UPPER` = uppercased slug
- `SCOPE_DESCRIPTION` = the description

Then ask: "Does this sub-master map to specific paths in the repo?"

If yes, ask the user to list them. Store as `SCOPE_PATHS` (comma-separated list). If no, set `SCOPE_PATHS` to `full`.

## Step 3: Scaffold the directory

Create a subdirectory under the parent's folder:

- If parent is the MASTER (root): `agent/{{ORG_NAME_SLUG}}/{{SCOPE_NAME_SLUG}}/`
- If parent is a SUB-MASTER: `<parent_directory>/{{SCOPE_NAME_SLUG}}/`

The parent's directory is derived from its `path` field in the tree (the directory containing the parent's agent file).

## Step 4: Read and apply the SUB-MASTER template

Read `templates/SUB-MASTER-AGENT-TEMPLATE.md`. Replace all placeholders:

- `{{ORG_NAME}}` -- the org name
- `{{SCOPE_NAME}}` -- the sub-master name
- `{{SCOPE_DESCRIPTION}}` -- what it covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{DATE}}` -- today's date in YYYY-MM-DD format
- `{{AGENT_INDUSTRY_VERSION}}` -- read from `VERSION` file
- `{{LINEAR_PROJECT}}` -- the Linear project name
- `{{DOMAIN_OVERVIEW}}` -- leave as `[TO BE FILLED]`
- `{{AGENT_HIERARCHY_DIAGRAM}}` -- empty for now (no children yet), write `No children yet. Create agents under this sub-master via /mayday.`
- `{{FOLDER_STRUCTURE}}` -- the sub-master's directory with placeholder subdirectories
- `{{CHILD_REGISTRY}}` -- `No children yet.`
- `{{ACTION_ROUTING}}` -- `No children yet. Action routing will be populated as child agents are created.`
- `{{ROADMAP_PATH}}` -- path to the roadmap file (walk up to root to find it)
- `{{SIBLING_REFS}}` -- list other children of the same parent

Write the result to: `<new_directory>/SUB-MASTER-{{SCOPE_NAME_UPPER}}.md`

## Step 5: Update the parent agent

Read the parent agent file. Update:

1. **Child Registry**: add a new entry for this sub-master:

```yaml
### {{N}}. {{SCOPE_NAME}} -- SUB-MASTER-{{SCOPE_NAME_UPPER}}

path: <path to new sub-master file>
type: sub-master
scope: {{SCOPE_DESCRIPTION}}
scope_paths: {{SCOPE_PATHS}}
children: []

update_when:
  - New child agents created under this sub-master
  - Scope boundary changes
  - Domain architecture changes
```

2. **Agent Hierarchy Diagram**: add the new sub-master node and edge from parent
3. **Folder Structure**: add the new subdirectory
4. **Action Routing**: add routing entries for the new sub-master's domain
5. **LAST_UPDATED**: set to today's date

## Step 6: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}",
  "type": "sub-master",
  "category": "orchestration",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "path": "<path to new sub-master file>",
  "children": []
}
```

Write `.factory-state.json` back.

## Step 7: Confirm

Print:

```
Sub-master created: <path to new sub-master file>

  Scope:   {{SCOPE_DESCRIPTION}}
  Parent:  <parent agent name>
  Children: none (create agents under this sub-master via /mayday)
```

## Rules

- Sub-masters do NOT contain implementation details -- they are orchestrators only
- A sub-master can be placed under any agent: MASTER, SUB-MASTER, APPLICATION, or PLATFORM (unlimited depth)
- The roadmap and its Linear card rules live at the root level and are inherited by all agents in the tree
