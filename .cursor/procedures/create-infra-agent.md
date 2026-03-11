First, do you understand well the project structure? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create an INFRA-AGENT for the project.

## Step 0: Load the agent tree and select parent

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object and the org metadata (`org_name`, `org_name_slug`, `org_name_upper`)
3. If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

### Tree walk -- select parent

Present the agent tree to the user and ask where this infra agent should be placed. Use AskQuestion with one option per valid parent (any node of type `master` or `sub-master`).

Build the options by walking the tree recursively. Indent child nodes to show hierarchy:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) |
| frontend | SUB-MASTER: Frontend (under root) |
| backend | SUB-MASTER: Backend (under root) |

Only `master` and `sub-master` nodes are valid parents. Leaf agents cannot be parents.

If there is exactly one valid parent (just the MASTER, no sub-masters), skip the question and use the MASTER automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

Ask the user: "Does this infra agent cover shared infrastructure or service-specific infrastructure?"

Use AskQuestion:

| id | label |
|----|-------|
| shared | Shared infrastructure (networking, CI/CD, secrets, platform-level resources) |
| service | Service-specific infrastructure (container config, service deploy, health checks) |
| full | Full infrastructure (everything) |

**If `shared`**:
- `SCOPE_NAME` = "Shared Infrastructure"
- Ask: "Describe what shared infra this covers" and "List paths (e.g. 'terraform/, .github/workflows/, infrastructure/')"

**If `service`**:
- Ask: "Which service? (e.g. 'api', 'web', 'worker')"
- Ask: "Describe what this infra agent covers for that service"
- Ask: "List paths"

**If `full`**:
- `SCOPE_NAME` = `{{ORG_NAME_UPPER}}`
- `SCOPE_DESCRIPTION` = "Full infrastructure"
- `SCOPE_PATHS` = "full"

Derive `SCOPE_NAME_SLUG`, `SCOPE_NAME_UPPER`, `SCOPE_DESCRIPTION`, `SCOPE_PATHS` from answers.

## Step 2: Parse the infrastructure

Analyze the project structure **within the defined scope** from an infrastructure perspective. You need to understand:

- Deployment topology (services, containers, serverless functions, etc.)
- Infrastructure as code (Terraform, CloudFormation, Pulumi, CDK, Kubernetes manifests)
- Secret management (how secrets are stored, injected, rotated)
- Environment variables (what the app expects vs what infra provides)
- CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, etc.)
- Docker configuration (Dockerfiles, compose files, entrypoints)
- Load balancing, DNS, TLS/SSL
- Database and broker configuration
- Monitoring and health checks
- Operational commands (deploy, rollback, migrations, shell access)

You are an agent working only on the infrastructure side. You must be aware of the application's infrastructure concerns (config, environment variables, secrets) but you do not own application logic.

## Step 3: Read the INFRA-AGENT template

Read `templates/INFRA-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 4: Generate the INFRA-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your infrastructure analysis.

Key placeholders:
- `{{SCOPE_NAME}}` -- the scope name
- `{{SCOPE_DESCRIPTION}}` -- what this agent covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{ROADMAP_PATH}}` -- path to the roadmap (walk up the tree to root to find it)
- `{{CODE_AGENT_PATH}}` -- path to sibling code agent, or `[not yet created]`
- `{{SIBLING_REFS}}` -- list other children of the same parent

### File naming and placement

- If scope is `full`: write to `<parent_directory>/infra/INFRA-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/infra/INFRA-AGENT-{{SCOPE_NAME_UPPER}}.md`

## Step 5: Update the parent agent

Read the parent agent file. Update:

1. **Child Registry**: add a new entry for this infra agent
2. **Agent Hierarchy Diagram**: add the infra agent node and edge from parent
3. **Folder Structure**: add the infra agent path
4. **Action Routing**: add infra-related routing entries for this scope
5. **LAST_UPDATED**: set to today's date

Do NOT change any other child's section.

## Step 6: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}-infra",
  "type": "infra",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "path": "<path to new infra agent file>",
  "children": []
}
```

Write `.factory-state.json` back.

## Step 7: Confirm

Tell the user what was created, its scope, and what the parent agent now contains.

## Agent structure rules

- Infra agents go under `<parent_directory>/infra/`
- The file MUST include a metadata block with SCOPE, SCOPE_PATHS, PARENT
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a "Scope Boundary" section
- The file MUST include a cross-references section with correct paths to the parent and sibling agents
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
