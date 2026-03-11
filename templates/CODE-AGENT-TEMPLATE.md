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

The TEST-AGENT is the authority on all testing conventions, patterns, and requirements. This section contains a brief summary for quick reference -- the test agent file is the source of truth.

{{TESTING}}

For full test conventions, critical path coverage map, mocking strategy, and test modification policy, read: `agent/{{ORG_NAME_SLUG}}/test/TEST-AGENT-{{ORG_NAME_UPPER}}.md`

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

## Test Agent Integration

The TEST-AGENT is the code agent's companion. When writing or modifying code, you MUST read the test agent and follow its directives:

1. **Before implementing any feature or fix**: check the test agent's critical path coverage map (section 4). If the code you are writing touches a critical path, the test agent dictates what tests are required.
2. **When writing tests**: follow the test agent's conventions exactly -- file naming, directory structure, assertion style, setup/teardown patterns. Every test in the project must be indistinguishable in style.
3. **When modifying existing tests**: the test agent's modification policy (section 7) applies. Warn before changing or deleting any test. Justify the change against the contract the test protects.
4. **After writing tests**: ask whether they should run in the CI/CD pipeline. The test agent's pipeline checklist (section 8) has the decision tree. Coordinate with the infra agent if pipeline integration is needed.

The test agent is the authority on code longevity. It decides what gets tested, how, and warns when safety nets are weakened.

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
