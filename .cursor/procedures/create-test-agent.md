This procedure is called automatically by `create-code-agent.md` after the CODE-AGENT is generated. It is never run standalone from the menu. The code agent's codebase analysis and the MASTER-AGENT metadata (`{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`) are already available from the parent procedure.

## Step 1: Read the CODE-AGENT

Read `agent/{{ORG_NAME_SLUG}}/code/CODE-AGENT-{{ORG_NAME_UPPER}}.md` to understand:

- The application architecture and data flow
- Data models and schemas
- External service integrations
- API layer and authentication
- Existing testing patterns (section 8 of the code agent)
- Design patterns and conventions

This gives you the full picture of what the codebase does and where the critical paths are.

## Step 2: Analyze the test landscape

Deeply analyze the repo's existing test setup. You need to understand:

- **Test framework and runner**: what tool runs the tests (Jest, pytest, Go test, Vitest, etc.), assertion libraries, configuration files
- **Existing test files**: where they live, how they are organized, what naming convention they follow
- **Test categories present**: unit tests, integration tests, e2e tests, contract tests, snapshot tests
- **Mocking patterns**: what libraries or approaches are used (test doubles, dependency injection, HTTP interception, database fixtures)
- **Test data management**: factories, fixtures, seeds, in-memory databases, test containers
- **Coverage tooling**: if any coverage tool is configured, what thresholds exist
- **CI/CD integration**: which pipeline stages run tests, what triggers them, whether tests gate deployment

If the project has no tests yet, that is fine. Document the framework/runner the project uses (infer from dependencies) and build the strategy from scratch.

## Step 3: Identify critical paths

Using the code agent's architecture analysis and your own codebase scan, identify the critical paths that MUST have test coverage. These are functions and features where breakage has cascading or high-severity impact:

- Authentication and authorization flows
- Payment or billing logic
- Data persistence and integrity (database writes, migrations)
- Public API contracts (request/response shapes, status codes)
- Core business logic (the domain-specific rules that define what the product does)
- Data transformation pipelines
- External service integration boundaries
- State machines or workflow engines

Rank them by impact severity. Not everything needs a test -- focus on what would cause real damage if broken.

## Step 4: Research best practices

Use Context7 MCP (if available) or web search to look up current best practices for the project's specific test framework and language. This ensures the test agent's recommendations are up to date and not based on stale patterns. Look up:

- The framework's recommended test structure and configuration
- Current assertion patterns and anti-patterns
- Mocking best practices for the specific ecosystem
- Integration testing patterns for the frameworks in use

If neither Context7 nor web search is available, rely on established knowledge but note in the agent file that best practices should be verified.

## Step 5: Read the TEST-AGENT template

Read `templates/TEST-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 6: Generate the TEST-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your analysis. The sections:

- **TEST_FRAMEWORK**: framework, runner, assertion library, configuration file paths, how to run tests locally, coverage commands
- **TEST_CONVENTIONS**: file naming (`*.test.ts`, `test_*.py`, etc.), directory structure, describe/it nesting conventions, assertion style, setup/teardown patterns. These conventions are law -- every test in the project must follow them.
- **TEST_CATEGORIES**: define each test category used in the project (unit, integration, e2e, etc.), what each covers, when to use each, and the expected ratio
- **CRITICAL_PATHS**: the ranked list from Step 3 with current coverage status and required test types per path
- **MOCKING_STRATEGY**: how to mock external services, databases, time, file system. What to mock vs what to use real implementations for. Test data factories and fixtures.
- **CI_TEST_PIPELINE**: which tests run where (PR checks, nightly, pre-deploy), timeouts, parallelization, failure handling
- **CODE_LONGEVITY**: deprecation detection, dependency health monitoring, refactoring safety nets, technical debt indicators that tests should catch

The level of detail should make this agent the single authority on how tests are written, run, and maintained. Another agent reading this file should be able to write a test that is indistinguishable from any other test in the project.

Write the result to: `agent/{{ORG_NAME_SLUG}}/test/TEST-AGENT-{{ORG_NAME_UPPER}}.md`

## Step 7: Update the MASTER-AGENT

Read the MASTER-AGENT file again. Update these sections:

1. **Agent Registry**: add the test agent entry (section 5) with its scope, owns, and update_when fields
2. **Agent Architecture diagram**: add the TEST node and its connections (CODE -> TEST for test requests, TEST -> INFRA for pipeline integration)
3. **Folder Structure**: add the test agent path
4. **Action Routing**: add test-related routing entries
5. **LAST_UPDATED**: set to today's date

Do NOT change any other agent's section beyond adding the test agent entry.

## Step 8: Update factory state

Read `.factory-state.json` at the workspace root. Set `agents.test` to `true`. Write the file back.

If `.factory-state.json` does not exist, skip this step silently.

## Step 9: Confirm

Tell the user what was created and what the MASTER-AGENT now contains.

## Agent structure rules

- Domain-scoped agents go under `agent/{{ORG_NAME_SLUG}}/test/`
- The file MUST include a metadata block with CREATED, LAST_UPDATED, VERSION, AGENT_TYPE, SCOPE, and MASTER fields
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a cross-references section with correct paths to sibling agents and the master agent
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.

## Interaction model

The test agent is **not invoked directly by the user** for day-to-day work. Instead:

1. The **code agent** delegates to the test agent when implementing a feature that touches a critical path. The code agent reads the test agent file and follows its conventions to write tests.
2. The test agent is **consulted** (its file is read) whenever someone needs to know the testing conventions, critical path coverage status, or whether a test modification is acceptable.
3. The test agent file is **updated** after test suite changes via the `/mayday` update flow.
4. When tests are modified, the test agent's **Test Modification Policy** (section 7) applies -- existing test changes require a warning and justification.
