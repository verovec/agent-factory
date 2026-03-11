# DEPLOY-AGENT: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: deploy
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
```

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

## CRITICAL WARNING

```
THIS DOCUMENT MUST BE UPDATED WHEN:
- New environment added or removed
- Promotion pipeline gates change (approval requirements, CI checks)
- Rollback procedures change
- New service added to the deployment pipeline
- ECR image tagging or promotion strategy changes
- Terraform environment targeting changes
- Pre-deploy or post-deploy validation steps change
- Release tracking or changelog process changes
- Health check endpoints or validation criteria change
```

## Purpose

This agent owns the production deployment lifecycle within its scope. It does NOT own service configuration (that belongs to INFRA-AGENTs) or infrastructure provisioning. It owns:

- **When** and **in what order** services move between environments
- What gates must pass before promotion
- How to execute each promotion step
- How to roll back if something fails
- Which Linear cards are included in a release

Read the relevant INFRA-AGENT for service-specific configuration (env vars, secrets, task definitions). Read this agent for environment promotion and release coordination.

## Current State

```yaml
status: [TO BE FILLED - e.g. "dev active, staging not provisioned, production not provisioned"]
last_production_deploy: [TO BE FILLED - date or "never"]
blocking_issues: []
```

---

## 1. Environment Topology

{{ENVIRONMENT_TOPOLOGY}}

---

## 2. Promotion Pipeline

{{PROMOTION_PIPELINE}}

---

## 3. Pre-Deploy Checklist

{{PRE_DEPLOY_CHECKLIST}}

---

## 4. Deploy Procedures

{{DEPLOY_PROCEDURES}}

---

## 5. Rollback Procedures

{{ROLLBACK_PROCEDURES}}

---

## 6. Release Tracking

{{RELEASE_TRACKING}}

---

## Scope Boundary

This agent covers: {{SCOPE_DESCRIPTION}}

Paths: {{SCOPE_PATHS}}

If a task falls outside this scope, delegate to the parent (`{{PARENT_PATH}}`), which will route it to the correct sibling agent.

## Cross-References

```yaml
parent: {{PARENT_PATH}}
siblings: {{SIBLING_REFS}}
infra_agents: {{INFRA_AGENT_REFS}}
roadmap: {{ROADMAP_PATH}}
```

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New environment added or removed
- Promotion pipeline changes
- Rollback procedure changes
- New service added to deployment pipeline
- ECR image promotion strategy changes
- Release tracking process changes
- Health check or validation changes
```

END_OF_DOCUMENT
