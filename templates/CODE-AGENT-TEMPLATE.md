# CODE-AGENT: {{ORG_NAME}}

> Last updated: {{DATE}}
>
> WARNING: This document MUST be updated whenever a new integration, model, service, API endpoint, schema, dependency, or architectural pattern is added or modified. Failure to do so will cause agents working on this codebase to produce incorrect code.

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `agent/{{ORG_NAME_SLUG}}/plans/ROADMAP-{{ORG_NAME_UPPER}}.md` > "Linear Card Rules".

---

## 1. Overview

{{OVERVIEW}}

---

## 2. Directory Structure

```
{{DIRECTORY_STRUCTURE}}
```

---

## 3. Architecture and Data Flow

{{ARCHITECTURE}}

---

## 4. Data Models and Schemas

{{DATA_MODELS}}

---

## 5. External Service Integrations

{{INTEGRATIONS}}

---

## 6. API Layer

{{API_LAYER}}

---

## 7. Configuration and Environment

{{CONFIGURATION}}

---

## 8. Testing Patterns

{{TESTING}}

---

## 9. Design Patterns and Conventions

{{CONVENTIONS}}

---

## 10. Known Gotchas and Bugs

{{GOTCHAS}}

---

## Cross-References

```yaml
master_agent: agent/{{ORG_NAME_SLUG}}/MASTER-AGENT-{{ORG_NAME_UPPER}}.md
test_agent: agent/{{ORG_NAME_SLUG}}/test/TEST-AGENT-{{ORG_NAME_UPPER}}.md
infra_agent: agent/{{ORG_NAME_SLUG}}/infra/INFRA-AGENT-{{ORG_NAME_UPPER}}.md
roadmap: agent/{{ORG_NAME_SLUG}}/plans/ROADMAP-{{ORG_NAME_UPPER}}.md
```

## Test Delegation

When implementing a feature or function that touches a critical path (authentication, data integrity, payment, core business logic, public API contracts), read the TEST-AGENT before writing code. The test agent defines:

- Which test patterns and conventions to follow
- What level of testing is required (unit, integration, e2e)
- How to structure test files and assertions
- Whether the tests need pipeline integration

Follow the test agent's conventions exactly. Test consistency across the project is non-negotiable.

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New models, services, or API endpoints
- New external service integrations
- Schema or type system changes
- Dependency version changes
- Docker build changes
- New design patterns introduced
- Architecture changes
```

END_OF_DOCUMENT
