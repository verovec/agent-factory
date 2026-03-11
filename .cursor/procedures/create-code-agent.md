First, do you understand well the codebase? Ask me any question you have.

If everything seems to be okay for you, follow this procedure to create a CODE-AGENT for the project.

## Step 0: Identify the MASTER-AGENT

1. Look for `agent/*/MASTER-AGENT-*.md` files in the project root
2. If exactly one exists, use it. If multiple exist, ask the user which domain this code agent belongs to.
3. Read the MASTER-AGENT to understand the domain name, folder structure, and existing agents
4. Extract `{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, and `{{ORG_NAME_UPPER}}` from the MASTER-AGENT metadata

If no MASTER-AGENT exists, tell the user to run `/init-agents` first.

## Step 1: Parse the codebase

Deeply analyze the entire codebase. You need to understand:

- The full architecture and data flow (entry points, pipelines, how data transforms step by step)
- Every module, its purpose, and how it connects to others
- Type system and schemas (TypeScript interfaces, Pydantic models, Zod, etc.)
- Design patterns and conventions used in the codebase
- All external service integrations from the code perspective (clients, APIs, databases)
- AI/LLM agents if any: their prompts, models, input/output contracts
- Error handling patterns and error codes
- How to add new features (new modules, new tools, new workflows)
- Known gotchas, legacy code, and inconsistencies

## Step 2: Read the CODE-AGENT template

Read `templates/CODE-AGENT-TEMPLATE.md`. This is the structure you must follow.

## Step 3: Generate the CODE-AGENT

Fill in every `{{PLACEHOLDER}}` section in the template with real content from your codebase analysis. The level of detail should make an agent immediately productive on the codebase without needing to explore files.

Write the result to: `agent/{{ORG_NAME_SLUG}}/code/CODE-AGENT-{{ORG_NAME_UPPER}}.md`

## Step 4: Update the MASTER-AGENT

Read the MASTER-AGENT file again. Update these sections:

1. **Agent Registry > Codebase**: fill in the `owns` list with the actual scope discovered during parsing
2. **Folder Structure**: verify the code agent path is listed
3. **LAST_UPDATED**: set to today's date

Do NOT change any other agent's section. Only update the codebase agent entry and metadata.

## Step 5: Update factory state

Read `.factory-state.json` at the workspace root. Set `agents.code` to `true`. Write the file back.

If `.factory-state.json` does not exist, skip this step silently.

## Step 6: Generate the TEST-AGENT

The test agent is the code agent's companion. It is always created alongside the code agent -- never separately. Read `.cursor/procedures/create-test-agent.md` and execute every step now, using the same repo and codebase analysis from Steps 1-3. The test agent procedure will use the code agent you just generated as its primary input.

After the test agent procedure completes, update `.factory-state.json` to set `agents.test` to `true` (the test agent procedure also does this, but confirm it is set).

## Step 7: Confirm

Tell the user what was created (both the code agent and test agent) and what the MASTER-AGENT now contains.

## Agent structure rules

- Domain-scoped agents go under `agent/{{ORG_NAME_SLUG}}/code/`
- The file MUST include a metadata header with last updated date and a critical warning about update triggers
- The file MUST include a "Linear Card Policy" section that defers to the roadmap agent's "Linear Card Rules" section
- The file MUST include a cross-references section with correct paths to sibling agents and the master agent
- This file is agent-dedicated and does not need to be human readable. Optimize for agent consumption.
