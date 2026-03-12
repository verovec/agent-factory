# PLATFORM-AGENT: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: platform
CATEGORY: platform
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
SPECIALISTS: {{SPECIALIST_DOMAINS}}
```

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

## CRITICAL WARNING

```
THIS DOCUMENT MUST BE UPDATED WHEN:
- Deployment topology changes (new services, removed services, scaling)
- Infrastructure code changes (Terraform, CloudFormation, Pulumi, etc.)
- Secret architecture changes (new secrets, new keys, injection pattern)
- CI/CD pipeline changes
- Docker entrypoint, CMD, or image changes
- New environment provisioned or removed
- Health check or monitoring changes
- DNS record or load balancer routing changes
- Container registry or image tagging strategy changes
- Promotion pipeline gates change
- Rollback procedures change
- Cloud provider service changes
- IAM or security policy changes
- SDK or CLI version updates
```

## Current State

```yaml
status: {{CURRENT_STATUS}}
last_production_deploy: {{LAST_DEPLOY}}
blocking_issues: []
```

---

# Part I: Infrastructure

---

## 1. Deployment Topology

{{DEPLOYMENT_TOPOLOGY}}

---

## 2. Infrastructure as Code

{{IAC_DETAILS}}

---

## 3. Secret Architecture

{{SECRET_ARCHITECTURE}}

---

## 4. Environment Variables

{{ENV_VARS}}

---

## 5. CI/CD Pipeline

{{CICD_PIPELINE}}

---

## 6. Operational Commands

{{OPERATIONAL_COMMANDS}}

---

## 7. Monitoring and Health Checks

{{MONITORING}}

---

# Part II: Deployment

---

## 8. Environment Topology

{{ENVIRONMENT_TOPOLOGY}}

---

## 9. Promotion Pipeline

{{PROMOTION_PIPELINE}}

---

## 10. Pre-Deploy Checklist

{{PRE_DEPLOY_CHECKLIST}}

---

## 11. Deploy Procedures

{{DEPLOY_PROCEDURES}}

---

## 12. Rollback Procedures

{{ROLLBACK_PROCEDURES}}

---

## 13. Release Tracking

{{RELEASE_TRACKING}}

---

# Part III: Specialist Knowledge

Each specialist section below provides up-to-date, provider-specific expertise that informs infrastructure and deployment decisions. When working on a task that touches a provider, read the relevant specialist section first.

If no specialist sections exist yet, this part will say `[no specialists configured]`. Add specialists via `/mayday > platform`.

---

{{SPECIALIST_SECTIONS}}

---

# Children (optional)

If this agent has sub-agents (scoped platform or application agents nested under it), they are listed here. Sub-agents carry narrower context for better output quality. For example, an AWS-specific platform sub-agent under a full platform agent, or a Kubernetes sub-agent. When a task falls within a child's scope, delegate to it.

{{CHILD_REGISTRY}}

---

# Shared

---

## Scope Boundary

This agent covers: {{SCOPE_DESCRIPTION}}

Paths: {{SCOPE_PATHS}}

If a task falls outside this scope, delegate to the parent (`{{PARENT_PATH}}`), which will route it to the correct sibling agent.

## Cross-References

```yaml
parent: {{PARENT_PATH}}
siblings: {{SIBLING_REFS}}
application_agent: {{APPLICATION_AGENT_PATH}}
roadmap: {{ROADMAP_PATH}}
```

## Workflow

When working on infrastructure or deployment tasks within scope:

1. Check if this agent has **children** (see Children section above). If a child's scope matches the task (e.g. an AWS-specific sub-agent for an AWS task), delegate to it for tighter context.
2. Read the **Infrastructure** sections (Part I) for current topology, IaC, secrets, and CI/CD
3. Read the **Deployment** sections (Part II) for promotion pipeline, procedures, and rollback
4. Read the relevant **Specialist** section (Part III) for provider-specific patterns and gotchas
5. If the change touches application code (env vars, config, SDK usage), check the sibling APPLICATION-AGENT

Infrastructure, deployment, and provider knowledge live together. A deploy is not safe unless the infra is understood, and the infra is not correct unless the provider patterns are followed.

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- Deployment topology changes
- Infrastructure code changes
- Secret architecture changes
- CI/CD pipeline changes
- New environment provisioned
- Health check or monitoring changes
- Docker or container changes
- Promotion pipeline changes
- Rollback procedure changes
- New service added to deployment pipeline
- Image promotion strategy changes
- Release tracking process changes
- Cloud provider service changes
- IAM or security policy changes
- SDK or CLI version updates
- Provider API breaking changes
- Quarterly specialist docs review
```

END_OF_DOCUMENT
