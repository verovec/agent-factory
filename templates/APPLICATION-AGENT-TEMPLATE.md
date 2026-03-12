# APPLICATION-AGENT: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: application
CATEGORY: application
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
```

> WARNING: This document MUST be updated whenever a new integration, model, service, API endpoint, schema, dependency, architectural pattern, test framework change, or test convention change occurs within this agent's scope. Failure to do so will cause agents working on this codebase to produce incorrect code or incorrect tests.

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

---

# Part I: Codebase

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

## 8. Design Patterns and Conventions

{{CONVENTIONS}}

---

## 9. Known Gotchas and Bugs

{{GOTCHAS}}

---

# Part II: Testing

---

## 10. Test Strategy

### Guiding Principles

1. **Consistency over cleverness** -- every test in the scope follows the same structure, naming, and assertion style.
2. **Protect critical paths** -- focus on functions and features where breakage has cascading impact: data integrity, authentication, payment flows, core business logic, public API contracts.
3. **Tests are documentation** -- a well-written test suite describes what the system does. Test names and structure should read as a specification.
4. **Stability over coverage metrics** -- a flaky test is worse than no test. Every test must be deterministic and independent.
5. **Test modifications are breaking changes** -- updating or deleting an existing test means the contract it protected has changed. This requires explicit acknowledgment.

### Current State

```yaml
status: {{TEST_STATUS}}
coverage: {{TEST_COVERAGE}}
ci_integration: {{TEST_CI_INTEGRATION}}
```

---

## 11. Test Framework and Tooling

{{TEST_FRAMEWORK}}

---

## 12. Test Structure and Conventions

{{TEST_CONVENTIONS}}

---

## 13. Test Categories and Strategy

{{TEST_CATEGORIES}}

---

## 14. Critical Path Coverage

{{CRITICAL_PATHS}}

---

## 15. Mocking and Test Data Strategy

{{MOCKING_STRATEGY}}

---

## 16. CI/CD Test Pipeline

{{CI_TEST_PIPELINE}}

---

## 17. Test Modification Policy

Any modification to an existing test (edit, delete, skip, or change assertion) MUST be flagged with a warning. When this agent detects a test modification request:

1. **Warn explicitly**: state which test is being changed and what behavior it currently protects
2. **Require justification**: the change must be tied to a deliberate contract change, not a convenience fix
3. **Assess blast radius**: identify other tests or features that depend on the behavior being changed
4. **Update this document**: if the modification reflects a new pattern or removes coverage from a critical path, update the relevant sections

---

## 18. Pipeline Integration Checklist

When tests are authored for a new feature, decide whether they need to run in CI/CD:

- **Always in pipeline**: tests covering critical paths (section 14), integration tests, e2e tests
- **Pipeline recommended**: tests for public API contracts, data model validation, authentication/authorization
- **Local-only acceptable**: exploratory tests, performance benchmarks (unless thresholds are enforced), development-time smoke tests

If pipeline integration is chosen, coordinate with the sibling PLATFORM-AGENT for pipeline stage configuration.

---

## 19. Code Longevity and Lifecycle

{{CODE_LONGEVITY}}

---

# Children (optional)

If this agent has sub-agents (scoped application or platform agents nested under it), they are listed here. Sub-agents carry narrower context for better output quality. When a task falls within a child's scope, delegate to it. When a task spans this agent's full scope, use this file directly.

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
platform_agent: {{PLATFORM_AGENT_PATH}}
roadmap: {{ROADMAP_PATH}}
linked_specialists: {{LINKED_SPECIALISTS}}
```

## Linked Specialists

When this agent has linked specialists (listed in `linked_specialists` above), read them before making decisions that involve the specialist's domain. For example, if linked to a cloud provider specialist, read it before writing SDK integration code, configuring provider-specific resources, or choosing service patterns.

## Workflow

When implementing a feature or fixing a bug within scope:

1. Check if this agent has **children** (see Children section above). If a child's scope matches the task, delegate to it for tighter context.
2. Read the **Codebase** sections (Part I) to understand architecture, conventions, and gotchas
3. Write the implementation following the patterns in section 8
4. Read the **Testing** sections (Part II) to determine required test coverage
5. Write tests following the conventions in section 12, targeting critical paths from section 14
6. If the change touches infrastructure (env vars, secrets, deployment), check the sibling PLATFORM-AGENT

Code and tests are written together. A feature is not complete until its critical paths are covered by tests that follow the conventions in this file.

## Document Maintenance

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
DOCUMENT_OWNER: {{ORG_NAME}} Team
AUTHORS: [TO BE FILLED]

UPDATE_TRIGGERS:
- New models, services, or API endpoints within scope
- New external service integrations within scope
- Schema or type system changes within scope
- Dependency version changes
- Docker build changes
- New design patterns introduced
- Architecture changes within scope
- Test framework or runner changes
- New test patterns or conventions adopted
- Coverage thresholds change
- CI/CD test pipeline changes
- New test categories introduced
- Mocking patterns change
- Critical path coverage changes
```

END_OF_DOCUMENT
