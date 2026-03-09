First, do you understand well the project structure? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create an INFRA-AGENT for the project.

## Step 0: Identify the MASTER-AGENT

1. Look for `agent/*/MASTER-AGENT-*.md` files in the project root
2. If exactly one exists, use it. If multiple exist, ask the user which domain this infra agent belongs to.
3. Read the MASTER-AGENT to understand the domain name, folder structure, and existing agents
4. Extract `{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, and `{{ORG_NAME_UPPER}}` from the MASTER-AGENT metadata

If no MASTER-AGENT exists, tell the user to run `/init-agents` first.

## Step 1: Parse the infrastructure

Analyze the entire project structure from an infrastructure perspective. You need to understand:

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

## Step 2: Read the INFRA-AGENT template

Read `templates/INFRA-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 3: Generate the INFRA-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your infrastructure analysis. The level of detail should make an agent immediately productive on infrastructure tasks without needing to explore files.

Write the result to: `agent/{{ORG_NAME_SLUG}}/infra/INFRA-AGENT-{{ORG_NAME_UPPER}}.md`

## Step 4: Update the MASTER-AGENT

Read the MASTER-AGENT file again. Update these sections:

1. **Agent Registry > Infrastructure**: fill in the `owns` list with the actual scope discovered during parsing
2. **Folder Structure**: verify the infra agent path is listed
3. **LAST_UPDATED**: set to today's date

Do NOT change any other agent's section. Only update the infrastructure agent entry and metadata.

## Step 5: Update factory state

Read `.factory-state.json` at the workspace root. Set `agents.infra` to `true`. Write the file back.

If `.factory-state.json` does not exist, skip this step silently.

## Step 6: Confirm

Tell the user what was created and what the MASTER-AGENT now contains.

## Agent structure rules

- Domain-scoped agents go under `agent/{{ORG_NAME_SLUG}}/infra/`
- The file MUST include a metadata block with CREATED, LAST_UPDATED, VERSION, AGENT_TYPE, SCOPE, and MASTER fields
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a cross-references section with correct paths to sibling agents and the master agent
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
