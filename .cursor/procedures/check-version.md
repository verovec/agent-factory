The user wants to check the agent-industry version. The MASTER-AGENT metadata and `LINEAR_PROJECT` are already available from the mayday scan.

## Step 1: Gather versions

1. Read `VERSION` file
2. Read `AGENT_INDUSTRY_VERSION` from the MASTER-AGENT metadata
3. Find the Linear project matching `LINEAR_PROJECT`, search for issue titled `agent-industry-version`

## Step 2: Display

Print exactly:

```
Version Check

  Local:     X.Y.Z
  Agents:    A.B.C
  Linear:    D.E.F
  Status:    [in sync | local outdated | agents stale | linear outdated]
```

## Step 3: Resolve drift

- If local > Linear: ask "Push X.Y.Z to Linear?"
- If Linear > local: print "Pull the latest agent-industry before continuing."
- If agents differ from local: print "Agents generated with old version. Regenerate via code/infra/sync options."
