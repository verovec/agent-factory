# TEST-AGENT: {{SCOPE_NAME}} ({{ORG_NAME}})

```
CREATED: {{DATE}}
LAST_UPDATED: {{DATE}}
VERSION: 1.0.0
AGENT_TYPE: test
SCOPE: {{SCOPE_DESCRIPTION}}
SCOPE_PATHS: {{SCOPE_PATHS}}
PARENT: {{PARENT_PATH}}
```

## Linear Card Policy

Before creating or updating any Linear card, you MUST read the roadmap agent first. The roadmap owns all card rules (structure, formatting, tone, defaults, MCP usage, confidentiality). Defer to: `{{ROADMAP_PATH}}` > "Linear Card Rules".

## CRITICAL WARNING

```
THIS DOCUMENT MUST BE UPDATED WHEN:
- Test framework, runner, or assertion library changes
- New test patterns or conventions are adopted
- Coverage thresholds change
- CI/CD test pipeline stages change
- New test categories are introduced (e.g. contract tests, visual regression)
- Test data management strategy changes
- Mocking or stubbing patterns change
- Existing tests are modified or deleted (requires explicit justification)
```

## Purpose

This agent owns the test strategy, test quality, and code longevity for its scope within the project. It does NOT own application logic (that belongs to the sibling CODE-AGENT) or CI/CD pipeline configuration (that belongs to the INFRA-AGENT). It owns:

- **What** gets tested and at what level (unit, integration, e2e)
- **How** tests are written -- conventions, patterns, and structure that remain consistent across the scope
- **When** tests are required -- which features and functions are critical enough to warrant test coverage
- **Why** tests exist -- each test protects a specific behavior; tests without clear purpose are liabilities

The sibling code agent delegates to this agent when a feature or function has fundamental impact and must be protected by tests. This agent decides the test approach, writes the tests, and ensures they follow project-wide conventions.

## Guiding Principles

1. **Consistency over cleverness** -- every test in the scope follows the same structure, naming, and assertion style. A developer reading any test file should immediately recognize the patterns.
2. **Protect critical paths** -- not everything needs a test. Focus on functions and features where breakage has cascading impact: data integrity, authentication, payment flows, core business logic, public API contracts.
3. **Tests are documentation** -- a well-written test suite describes what the system does. Test names and structure should read as a specification.
4. **Stability over coverage metrics** -- a flaky test is worse than no test. Every test must be deterministic and independent.
5. **Test modifications are breaking changes** -- updating or deleting an existing test means the contract it protected has changed. This requires explicit acknowledgment.

## Current State

```yaml
status: [TO BE FILLED - e.g. "test framework configured, 42 unit tests, 8 integration tests"]
coverage: [TO BE FILLED - e.g. "line: 68%, branch: 55%"]
ci_integration: [TO BE FILLED - e.g. "tests run on every PR via GitHub Actions"]
blocking_issues: []
```

---

## 1. Test Framework and Tooling

{{TEST_FRAMEWORK}}

---

## 2. Test Structure and Conventions

{{TEST_CONVENTIONS}}

---

## 3. Test Categories and Strategy

{{TEST_CATEGORIES}}

---

## 4. Critical Path Coverage

{{CRITICAL_PATHS}}

---

## 5. Mocking and Test Data Strategy

{{MOCKING_STRATEGY}}

---

## 6. CI/CD Test Pipeline

{{CI_TEST_PIPELINE}}

---

## 7. Test Modification Policy

Any modification to an existing test (edit, delete, skip, or change assertion) MUST be flagged with a warning. When this agent detects a test modification request:

1. **Warn explicitly**: state which test is being changed and what behavior it currently protects
2. **Require justification**: the change must be tied to a deliberate contract change, not a convenience fix
3. **Assess blast radius**: identify other tests or features that depend on the behavior being changed
4. **Update this document**: if the modification reflects a new pattern or removes coverage from a critical path, update the relevant sections

Tests are the safety net. Weakening them without understanding the consequences is how regressions ship.

---

## 8. Pipeline Integration Checklist

When tests are authored for a new feature, this agent asks whether they need to run in the CI/CD pipeline. The decision tree:

- **Always in pipeline**: tests covering critical paths (section 4), integration tests, e2e tests
- **Pipeline recommended**: tests for public API contracts, data model validation, authentication/authorization
- **Local-only acceptable**: exploratory tests, performance benchmarks (unless thresholds are enforced), development-time smoke tests

If pipeline integration is chosen, coordinate with the INFRA-AGENT for pipeline stage configuration.

---

## 9. Code Longevity and Lifecycle

{{CODE_LONGEVITY}}

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
- Test framework or runner changes
- New test patterns or conventions adopted
- Coverage thresholds change
- CI/CD test pipeline changes
- New test categories introduced
- Test data management strategy changes
- Mocking patterns change
- Critical path coverage changes
```

END_OF_DOCUMENT
