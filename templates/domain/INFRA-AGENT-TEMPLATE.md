# INFRA-AGENT: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: infrastructure
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
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
- New environment provisioned
- Health check or monitoring changes
- DNS record or load balancer routing changes
- Container registry or image tagging strategy changes
```

## Current State

```yaml
status: [TO BE FILLED - e.g. "deployed to development", "initial setup"]
next_step: [TO BE FILLED - reference the next Linear ticket]
blocking_issues: []
```

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

## Scope Boundary

This agent covers: {{SCOPE_DESCRIPTION}}

Paths: {{SCOPE_PATHS}}

If a task falls outside this scope, delegate to the parent (`{{PARENT_PATH}}`), which will route it to the correct sibling agent.

## Cross-References

```yaml
parent: {{PARENT_PATH}}
siblings: {{SIBLING_REFS}}
code_agent: {{CODE_AGENT_PATH}}
roadmap: {{ROADMAP_PATH}}
```

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
```

END_OF_DOCUMENT
