The user wants to sync the roadmap agent with the latest state of Linear. This command queries Linear for the current project's issues, diffs them against the existing roadmap, and updates the roadmap file accordingly.

## Step 0: Identify the MASTER-AGENT and roadmap

1. Look for `agent/*/MASTER-AGENT-*.md` files in the project root
2. If exactly one exists, use it. If multiple exist, ask the user which domain to update.
3. Read the MASTER-AGENT to extract:
   - `{{ORG_NAME}}`, `{{ORG_NAME_SLUG}}`, `{{ORG_NAME_UPPER}}`
   - `LINEAR_PROJECT` from the metadata block
   - The roadmap path from the Agent Registry section
4. Read the existing roadmap file at `agent/{{ORG_NAME_SLUG}}/plans/ROADMAP-{{ORG_NAME_UPPER}}.md`

If no MASTER-AGENT exists, tell the user to run `/init-agents` first.
If no roadmap file exists, tell the user to run `/init-agents` first.

## Step 1: Validate Linear connection

1. Call `get_viewer` on the Linear MCP server to confirm the API key works. The server name depends on the project's MCP configuration -- look for the server whose tools include `get_viewer`, `projects`, `project_issues`, `create_issue`, etc.
2. If it fails, stop and tell the user the Linear connection is broken

## Step 1b: Version check

1. Read the local `VERSION` file at the agent-industry root to get the local version string
2. Read the `AGENT_INDUSTRY_VERSION` field from the roadmap file's metadata block
3. Find the Linear project matching `LINEAR_PROJECT` (same lookup as Step 2 below)
4. Search the project's issues for one titled exactly `agent-industry-version`
5. If found, compare its description (the remote version) against the local `VERSION` file:
   - If they match: proceed silently
   - If the remote version is NEWER than the local version, display:

```
------------------------------------------------------------
WARNING: Agent Industry version mismatch detected.

  Local version:  X.Y.Z  (from VERSION file)
  Remote version: A.B.C  (from Linear card "agent-industry-version")

Your local agent-industry copy is OUTDATED. The templates,
commands, and agent structure may have changed. Pull the
latest version of agent-industry before continuing.

Proceeding with the roadmap sync, but generated agents may
not match the latest standards.
------------------------------------------------------------
```

   - If the local version is NEWER than the remote version (you just updated agent-industry), update the Linear card's description to match the local version, and display:

```
Agent Industry version updated in Linear: X.Y.Z -> A.B.C
```

6. If the card does not exist, create it (same procedure as /init-agents Step 5) and proceed

## Step 2: Fetch current Linear state

1. Call `projects` on the Linear MCP server to list all projects
2. Find the project matching `LINEAR_PROJECT` from the roadmap metadata (case-insensitive)
3. If not found, stop and tell the user: "Linear project '{{LINEAR_PROJECT}}' no longer exists. Update the LINEAR_PROJECT field in the MASTER-AGENT or create the project in Linear."
4. Call `project_issues` with the `projectId` to fetch all current issues
5. For each issue, store: identifier, title, state, priority, description

## Step 3: Diff against the existing roadmap

Compare the Linear issues against what the roadmap currently documents:

1. **New issues**: issues in Linear that have no corresponding section in the roadmap
2. **State changes**: issues whose state (Todo, In Progress, Done, Cancelled) has changed since the roadmap was last written
3. **Removed issues**: issues documented in the roadmap that no longer exist in the Linear project
4. **Updated content**: issues whose title, priority, or description has meaningfully changed

Present the diff to the user before applying:

```
Roadmap sync for {{ORG_NAME}}:

  NEW (N):
    - TEAM-123: New feature title (state: Todo, priority: High)
    - TEAM-456: Another new card (state: In Progress, priority: Medium)

  STATE CHANGED (N):
    - TEAM-789: Was "In Progress" -> now "Done"
    - TEAM-012: Was "Todo" -> now "In Progress"

  REMOVED FROM PROJECT (N):
    - TEAM-345: No longer in the Linear project

  UNCHANGED (N):
    - TEAM-678, TEAM-901, ...
```

Ask the user: "Apply these changes to the roadmap? (yes/no)"

## Step 4: Apply changes to the roadmap

If the user confirms:

1. **Update the metadata block**:
   - Set `LINEAR_TICKETS` to the current comma-separated list of all issue identifiers
   - Set `LAST_UPDATED` to today's date

2. **Update the Current State section**:
   - Rewrite with an accurate summary based on the latest issue states
   - Mention which issues are done, in progress, and upcoming

3. **Update the Issues Section**:
   - For each issue (ordered by state: In Progress first, then Todo, then Done), write:

```markdown
### {{IDENTIFIER}}: {{TITLE}}

**State**: {{state}}
**Priority**: {{priority}}

{{description or "No description yet."}}
```

   - Remove sections for issues no longer in the project
   - Add sections for new issues
   - Update state/priority/description for changed issues

4. **Update the Dependency Graph**:
   - If new issues were added, ask the user if any have dependencies on existing issues
   - If issues were completed, mark them as Done in the graph
   - If unclear, leave the graph as-is and note: "Dependency graph may need manual review after this sync."

5. **Preserve the Design Decisions Log**: never overwrite or remove existing design decisions

6. **Update Document Maintenance**: set `LAST_UPDATED` to today's date

## Step 5: Update the MASTER-AGENT

Read the MASTER-AGENT file. Update:

1. The `linear_tickets` list under the Roadmap entry in the Agent Registry to reflect the current set
2. `LAST_UPDATED` to today's date

## Step 6: Warn about sibling agents

After completing the roadmap update, ALWAYS display this warning:

```
------------------------------------------------------------
WARNING: The roadmap has been updated with changes from Linear.

If any of the following are true, the corresponding agent
files may now be out of date and should be reviewed:

  CODE-AGENT (agent/{{ORG_NAME_SLUG}}/code/CODE-AGENT-{{ORG_NAME_UPPER}}.md)
    -> Review if: new features were added, existing features changed
       scope, or completed tickets introduced new code patterns

  INFRA-AGENT (agent/{{ORG_NAME_SLUG}}/infra/INFRA-AGENT-{{ORG_NAME_UPPER}}.md)
    -> Review if: infrastructure tickets changed state, new infra
       tickets were added, or deployment topology was affected

Run /create-code-agent or /create-infra-agent to regenerate
them from scratch, or manually update the relevant sections.
------------------------------------------------------------
```
