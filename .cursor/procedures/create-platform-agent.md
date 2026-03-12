First, do you understand well the project's infrastructure, deployment, and cloud setup? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create a PLATFORM-AGENT (unified infra + deploy + specialist knowledge) for the project.

## Step 0: Load the agent tree and select parent

1. Read `.factory-state.json` at the workspace root
2. Extract the `tree` object and the org metadata (`org_name`, `org_name_slug`, `org_name_upper`)
3. If `.factory-state.json` does not exist, tell the user to run `/mayday` > init first.

### Tree walk -- select parent

Present the agent tree to the user and ask where this platform agent should be placed. Use AskQuestion with one option per valid parent.

Valid parents are:
- `master` or `sub-master` nodes (orchestrators)
- `platform` nodes (the new agent becomes a scoped sub-agent, e.g. an AWS-only platform agent under a full platform agent)
- `application` nodes (for platform knowledge scoped to a specific application concern)

Build the options by walking the tree recursively. Indent child nodes to show hierarchy:

| id | label |
|----|-------|
| master | MASTER-AGENT (root) |
| backend | SUB-MASTER: Backend (under root) |
| full-platform | PLATFORM-AGENT (full) -- narrow down a sub-scope |

If there is exactly one valid parent (just the MASTER, no other agents), skip the question and use the MASTER automatically.

Store the selected parent node's `id`, `path`, and directory.

## Step 1: Define scope

Ask the user: "Does this platform agent cover shared infrastructure, a specific service, or full infrastructure?"

Use AskQuestion:

| id | label |
|----|-------|
| shared | Shared infrastructure (networking, CI/CD, secrets, platform-level resources) |
| service | Service-specific (container config, deploy, health checks for one service) |
| full | Full infrastructure and deployment (everything) |

**If `shared`**:
- `SCOPE_NAME` = "Shared Infrastructure"
- Ask: "Describe what shared infra this covers" and "List paths (e.g. 'terraform/, .github/workflows/, infrastructure/')"

**If `service`**:
- Ask: "Which service? (e.g. 'api', 'web', 'worker')"
- Ask: "Describe what this platform agent covers for that service"
- Ask: "List paths"

**If `full`**:
- `SCOPE_NAME` = `{{ORG_NAME_UPPER}}`
- `SCOPE_DESCRIPTION` = "Full infrastructure, deployment, and provider knowledge"
- `SCOPE_PATHS` = "full"

Derive `SCOPE_NAME_SLUG`, `SCOPE_NAME_UPPER`, `SCOPE_DESCRIPTION`, `SCOPE_PATHS` from answers.

## Step 2: Ask about specialist domains

Ask: "Which cloud/platform providers does this project use?"

Use AskQuestion with `allow_multiple: true`:

| id | label |
|----|-------|
| aws | AWS (Amazon Web Services) |
| gcp | GCP (Google Cloud Platform) |
| azure | Azure (Microsoft Cloud) |
| k8s | Kubernetes |
| custom | Other (specify) |
| none | No specialist knowledge needed yet |

**If `custom`**: Ask "Name the provider/platform (e.g. 'cloudflare', 'vercel', 'stripe')" -- free text.

For each selected provider, ask: "Describe what {{PROVIDER}} services you use (e.g. 'ECS Fargate, RDS Postgres, S3, CloudFront')" -- free text.

Store the list of specialist domains with their descriptions.

## Step 3: Parse the infrastructure (Part I of the template)

Analyze the project structure **within the defined scope** from an infrastructure perspective:

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

## Step 4: Parse the deployment lifecycle (Part II of the template)

Analyze the deployment setup within scope:

- Environment topology (dev, staging, production -- account IDs, cluster names, registries, domains)
- Promotion pipeline (gates, approvals, CI checks between environments)
- Pre-deploy checklists per environment
- Deploy procedures (image promotion, Terraform plan/apply, service deploy, health validation)
- Rollback procedures (circuit breaker, manual rollback, Terraform revert, migration rollback)
- Release tracking (changelog, Linear card lifecycle, post-production updates)

If no deployment process exists yet, document the target state based on the infrastructure analysis.

## Step 5: Research specialist knowledge (Part III of the template)

For each specialist domain selected in Step 2:

Use Context7 MCP (if available) or web search to look up current best practices and documentation. Focus on:

- Services the project actually uses (inferred from infra analysis, Terraform files, etc.)
- Current SDK patterns and version-specific guidance
- Security baselines and IAM best practices
- Networking patterns for the provider
- Cost optimization guidance
- Known gotchas and breaking changes

Also scan the project repos for provider-specific configuration:
- AWS: `aws-cdk`, `@aws-sdk`, `boto3`, `.aws/`, terraform AWS provider blocks
- GCP: `@google-cloud`, terraform Google provider blocks
- Azure: `@azure`, terraform azurerm provider blocks
- K8s: helm charts, kustomize, k8s manifests

If neither Context7 nor web search is available, rely on established knowledge but note in the agent file that documentation should be verified.

## Step 6: Read the PLATFORM-AGENT template

Read `templates/PLATFORM-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 7: Generate the PLATFORM-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your analysis.

Key placeholders:
- `{{SCOPE_NAME}}` -- the scope name
- `{{SCOPE_DESCRIPTION}}` -- what this agent covers
- `{{SCOPE_PATHS}}` -- repo paths or "full"
- `{{PARENT_PATH}}` -- path to the parent agent file
- `{{ROADMAP_PATH}}` -- path to the roadmap (walk up the tree to root to find it)
- `{{APPLICATION_AGENT_PATH}}` -- path to the sibling application agent under the same parent, or `[not yet created]`
- `{{SIBLING_REFS}}` -- list other children of the same parent
- `{{SPECIALIST_DOMAINS}}` -- comma-separated list of provider slugs (e.g. "aws, k8s") or `[none]`
- `{{CURRENT_STATUS}}` -- current infra state
- `{{LAST_DEPLOY}}` -- last production deploy date or "never"
- All infrastructure sections (Part I)
- All deployment sections (Part II)
- `{{SPECIALIST_SECTIONS}}` -- for each specialist domain, generate a full specialist subsection:

```markdown
## S1. {{DOMAIN_NAME}}: Services In Use

{{SERVICES_IN_USE}}

## S2. {{DOMAIN_NAME}}: Authentication and IAM

{{AUTH_AND_IAM}}

## S3. {{DOMAIN_NAME}}: Networking and Connectivity

{{NETWORKING}}

## S4. {{DOMAIN_NAME}}: SDK and CLI Patterns

{{SDK_CLI_PATTERNS}}

## S5. {{DOMAIN_NAME}}: Cost and Quotas

{{COST_AND_QUOTAS}}

## S6. {{DOMAIN_NAME}}: Security Baseline

{{SECURITY_BASELINE}}

## S7. {{DOMAIN_NAME}}: Operational Patterns

{{OPERATIONAL_PATTERNS}}

## S8. {{DOMAIN_NAME}}: Known Gotchas and Provider Quirks

{{GOTCHAS}}
```

If multiple specialists exist, repeat the S1-S8 pattern for each domain, numbered per domain (e.g., `## AWS: Services In Use`, `## K8s: Services In Use`).

If no specialists, set `{{SPECIALIST_SECTIONS}}` to `[no specialists configured]`.

### File naming and placement

- If scope is `full`: write to `<parent_directory>/platform/PLATFORM-AGENT-{{ORG_NAME_UPPER}}.md`
- If scoped: write to `<parent_directory>/platform/PLATFORM-AGENT-{{SCOPE_NAME_UPPER}}.md`

## Step 8: Update the parent agent

Read the parent agent file. The parent can be a MASTER, SUB-MASTER, or another APPLICATION/PLATFORM agent. Update:

1. **Child Registry**: add a new entry for this platform agent:

```yaml
### {{N}}. Platform ({{SCOPE_NAME}}) -- PLATFORM-AGENT-{{SCOPE_NAME_UPPER}}

path: <path to new platform agent file>
type: platform
category: platform
scope: {{SCOPE_DESCRIPTION}}
scope_paths: {{SCOPE_PATHS}}
specialists: [list of provider slugs]
owns:
  - Infrastructure and IaC within scope
  - Deployment lifecycle within scope
  - Provider-specific knowledge for listed specialists

update_when:
  - Deployment topology changes
  - Infrastructure code changes
  - Secret or environment variable changes
  - CI/CD pipeline changes
  - New environment provisioned
  - Promotion pipeline changes
  - Rollback procedure changes
  - Cloud provider service changes
  - Quarterly specialist docs review
```

2. **Agent Hierarchy Diagram**: add the platform agent node and edge from parent
3. **Folder Structure**: add the platform agent path
4. **Action Routing**: add routing entries for infra, deploy, and provider-specific tasks within this scope
5. **LAST_UPDATED**: set to today's date

Do NOT change any other child's section.

## Step 9: Update factory state

Read `.factory-state.json`. Find the parent node in the `tree` by matching its `id`. Add a new child node:

```json
{
  "id": "{{SCOPE_NAME_SLUG}}-platform",
  "type": "platform",
  "category": "platform",
  "scope": "{{SCOPE_DESCRIPTION}}",
  "scope_paths": ["path1", "path2"],
  "specialists": ["aws", "k8s"],
  "path": "<path to new platform agent file>",
  "links": [],
  "children": []
}
```

If scope is `full`, use `"full"` as the scope and omit `scope_paths`.
If no specialists, omit `specialists` or set to `[]`.

Write `.factory-state.json` back.

## Step 10: Confirm

Tell the user what was created, its scope, which specialist domains are included, and what the parent agent now contains.

## Agent structure rules

- Platform agents go under `<parent_directory>/platform/`
- The file MUST include a metadata block with SCOPE, SCOPE_PATHS, PARENT, SPECIALISTS
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a "Scope Boundary" section
- The file MUST include a cross-references section with correct paths to the parent, sibling application agent, and sibling agents
- The file contains infrastructure (Part I), deployment (Part II), and specialist knowledge (Part III) in a single document
- Specialist sections can be added later by re-running `/mayday > platform` and selecting "add specialist domain"
- Platform agents can have children (sub-scoped platform or application agents) for finer-grained context
- When a platform agent has children, it acts as both a knowledge base for its scope AND a parent that routes narrower tasks to its children
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
