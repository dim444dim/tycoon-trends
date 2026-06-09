# Claude Code Mastery — Roblox Development Guide

## What is Claude Code?

Claude Code is an AI-powered CLI that lives in your terminal and acts as a pair programmer. Unlike chat-based AI, it can **read your actual files**, **write code directly**, and **run commands** — making it a true development partner rather than a copy-paste tool.

---

## Core Workflow for Roblox Projects

### The Golden Rule: One Atomic Task Per Prompt

**Bad:**
```
Add a leaderboard, missions, new buildings, and fix the DataStore bug
```

**Good:**
```
Add a leaderboard (see docs/03_CLAUDE_CODE_PROMPTS.md for format)
```

Atomic prompts = clean diffs = easy review = no regressions.

---

## Setting Up Claude Code for Roblox

### CLAUDE.md (project-level instructions)

Create a `CLAUDE.md` at the project root. Claude reads this automatically at every session:

```markdown
# TycoonTrends — Claude Code Instructions

## Stack
- Roblox + Rojo 7.4.4 + Luau
- src/ synced to Studio via Rojo serve

## Code conventions
- print("[ModuleName] message") for all logs
- warn("[ModuleName] message") for non-fatal errors
- DataStore retry: GameplayConfig.DataStoreRetryCount (3), DataStoreRetryDelay (1.5s)
- task.spawn for independent loops
- Player state via Attributes (no Module-level tables for per-player data)

## Never modify
- default.project.json
- aftman.toml
- src/shared/Remotes.luau (unless adding a new Remote)

## Run tests
- ZZZ_TestRunner.server.luau runs automatically on server start
- Check Output for "[TestRunner] X/X tests passed"
```

### File Structure Context

Always give Claude the exact file path:
```
In src/server/ProductionTicker.server.luau, add...
```
Not: "In the production script, add..."

---

## Prompt Patterns That Work

### Pattern 1: Feature Addition

```
In TycoonTrends (Roblox/Luau), add [feature name].

Context:
- [Relevant existing code/file]
- [Constraint or convention]

Create/modify:
- [file1]: [what to change]
- [file2]: [what to change]

Do NOT modify: [files to preserve]
```

### Pattern 2: Bug Fix

```
Bug in TycoonTrends: [describe symptom]

Relevant file: src/server/[file].server.luau
Suspected cause: [your hypothesis]

Fix the bug. Do not refactor surrounding code.
```

### Pattern 3: Config Change

```
In src/shared/GameplayConfig.luau, change:
- TrendDuration from 120 to 60
- TrendBonusMultiplier from 2.0 to 1.5

No other changes needed.
```

### Pattern 4: New Script from Scratch

```
Create src/server/DailyBonus.server.luau for TycoonTrends.

Purpose: Give each player 500 cash once per day (UTC reset).

Requirements:
- DataStore key: "dailybonus_" .. player.UserId
- Store last claim timestamp (os.time())
- Check on PlayerAdded: if 24h have passed, grant bonus + update timestamp
- Use same retry pattern as PrestigeManager.server.luau
- Log with [DailyBonus] prefix
- No RemoteEvents needed (server-side only)
```

---

## Reading Code Before Editing

Always ask Claude to read first:

```
Read src/server/UpgradeShop.server.luau and explain 
how the building cost is calculated, then add a 10% discount 
when the player has prestige level ≥ 2.
```

This prevents Claude from making assumptions about code it hasn't seen.

---

## The Review Loop

After every Claude Code change:

1. **Read the diff** (VS Code source control panel)
2. **Run `rojo serve`** and test in Studio
3. **Check Output** for test results and log messages
4. **If something is wrong**: feed the error message back to Claude

```
The test failed with this error:
[TestRunner] ❌ FAIL: UpgradeShop — expected 115, got 100

The relevant code is:
[paste the generated code]

Fix it.
```

---

## Managing Context Across Sessions

### Memory Files

For persistent cross-session knowledge, use `.claude/memory/`:
```
Remember: In TycoonTrends, the DataStore retry pattern uses 
GameplayConfig.DataStoreRetryCount and DataStoreRetryDelay.
Always use this pattern for any new DataStore operation.
```

### Session Recap Prompt

Start a new session with:
```
/bilan
```
or:
```
I'm continuing work on TycoonTrends. 
The project is at C:\Users\Admin\projects\roblox-games\tycoon-trends\
Last session: [what you did]
Next task: [what you want to do]
```

---

## Token Economy Tips

### Use Haiku for Simple Tasks

| Task | Recommended Model |
|------|------------------|
| Config change (1-2 lines) | Haiku |
| Bug fix in a single file | Haiku / Sonnet |
| New feature (1-2 files) | Sonnet |
| Architecture decision | Sonnet / Opus |
| Multi-file system with complex logic | Opus |

### Avoid Wasting Tokens

- Don't ask Claude to explain code you can read yourself
- Don't ask "is this a good idea?" — make the decision, then ask Claude to implement
- Don't paste entire files when you can paste just the relevant section
- Use `src/server/X.server.luau:42-78` to reference specific lines

---

## Common Mistakes

### Mistake 1: Too Much Freedom

```
❌ "Improve the game"
✅ "Add input validation in UpgradeShop.OnServerEvent to prevent negative building counts"
```

### Mistake 2: Forgetting File Paths

```
❌ "Add a log message when production starts"
✅ "In src/server/ProductionTicker.server.luau, add print('[ProductionTicker] session started') 
    at line 52, inside the task.spawn production loop, after the State check"
```

### Mistake 3: Mixing Concerns

```
❌ "Rewrite the whole DataStore system and add missions at the same time"
✅ Prompt 1: Refactor DataStore
   Prompt 2: Add missions using the refactored DataStore
```

### Mistake 4: Not Specifying Constraints

```
❌ "Add a leaderboard"
✅ "Add a leaderboard — RAM only (no DataStore), refresh every 5 seconds, 
    top 10 players by Cash attribute, broadcast via new RemoteEvent LeaderboardUpdate"
```

---

## Advanced: Multi-Agent Workflow

For large features, split across parallel Claude sessions:

**Session A** (in terminal 1):
```
Create src/server/MissionsManager.server.luau (server logic only)
```

**Session B** (in terminal 2):
```
Create src/client/MissionsUI.client.luau (client UI only)
Assume the server will send mission data via RemoteEvent "MissionsUpdate"
with format: { missions: [{id, name, goal, progress}] }
```

**Session C** (merge):
```
Wire MissionsManager and MissionsUI together.
The server RemoteEvent name must match what the client expects.
```

---

## Cheat Sheet

```bash
# Start a session
claude

# Quick config change
claude "In src/shared/GameplayConfig.luau, change TrendDuration to 60"

# With file context
claude --file src/server/ProductionTicker.server.luau "Add debug logging"

# Check what changed
git diff src/

# Run after every Claude session
rojo serve  # then test in Studio
```

---

## Resources

- Claude Code docs: developer.anthropic.com
- Roblox DevHub: developer.roblox.com/en-us/
- Luau reference: luau-lang.org
- Rojo docs: rojo.space/docs/
- TycoonTrends prompts: [docs/03_CLAUDE_CODE_PROMPTS.md](03_CLAUDE_CODE_PROMPTS.md)
