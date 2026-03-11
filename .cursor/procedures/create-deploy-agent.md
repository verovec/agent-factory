The user wants to create a deploy agent. The MASTER-AGENT metadata (`{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`) is already available from the mayday scan.

## Step 1: Gather deployment context

Scan existing agents to understand the deployment topology:

1. Read shared infra agents under `agent/{{ORG_NAME_SLUG}}/shared/` for AWS account topology, domain architecture, environment list
2. Read per-service infra agents under `agent/{{ORG_NAME_SLUG}}/infra/` for deploy commands, ECR tags, health check endpoints
3. Read `templates/DEPLOY-AGENT-TEMPLATE.md`

## Step 2: Generate

Fill the template with:

- **Environment Topology**: account IDs, ECS cluster names, ECR registries, domain prefixes, Terraform tfvars paths
- **Promotion Pipeline**: dev -> staging -> prod gates with Linear card state requirements, CI checks, approval rules
- **Pre-Deploy Checklist**: infrastructure, secrets, database, Linear/roadmap readiness checks per environment
- **Deploy Procedures**: ECR image promotion, Terraform plan/apply, ECS force deploy, post-deploy health validation
- **Rollback Procedures**: ECS circuit breaker, manual image rollback, Terraform revert, migration rollback
- **Release Tracking**: Linear card lifecycle, changelog format, post-production roadmap update

Write to: `agent/{{ORG_NAME_SLUG}}/deploy/DEPLOY-AGENT-{{ORG_NAME_UPPER}}.md`

## Step 3: Update state

Update `.factory-state.json`: set `agents.deploy = true`.

Print: `Deploy agent created: agent/{{ORG_NAME_SLUG}}/deploy/DEPLOY-AGENT-{{ORG_NAME_UPPER}}.md`
