---
name: handoff
description: >
  Summarizes a specific aspect of the current conversation so another agent can resume.
  Use when the user says "handoff", "summarize for handoff", "write a handoff", or wants to
  capture context for another agent session. The user MUST specify what aspect to summarize
  in their prompt (e.g., "handoff the debugging progress", "handoff the design decisions").
---

# Handoff

Write a focused summary of a specific aspect of the current conversation so a fresh agent can pick up where this session left off.

This is NOT a full conversation summary. The user's prompt tells you which aspect to capture. If the aspect is unclear, ask for clarification before proceeding.

## What to capture

For the aspect the user specified, write:

1. **Objective** — What the user is trying to accomplish (the goal, not the history).
2. **Current state** — Where things stand right now. What's done, what's in progress, what's blocked.
3. **Key decisions** — Decisions made during this session that the next agent must honor, with brief rationale.
4. **Open questions** — Unresolved issues, trade-offs still being weighed, or things the user hasn't decided yet.
5. **Next steps** — Concrete actions the resuming agent should take first.
6. **Relevant files** — Paths to files that were created, modified, or are central to the work.

Omit any section that has nothing meaningful to say. Keep it tight — the resuming agent needs signal, not narration.

## Output

Write the summary to `handoff.md`.

**Determining the output location:**

1. If the user specified a path in their prompt, use it.
2. If a project configuration (e.g., AGENTS.md, openspec config, or similar conventions) specifies a change directory, write there.
3. Otherwise, determine the relevant change slug from context (the change being worked on, or a kebab-case slug from the topic) and write to `~/.agent-skills/changes/<slug>/handoff.md`.

Do not ask the user to confirm the location. Just write to the resolved path.

## Template

```markdown
# Handoff: <aspect being handed off>

## Objective

<!-- What the user is trying to accomplish -->

## Current State

<!-- Where things stand: done, in progress, blocked -->

## Key Decisions

<!-- Decisions made this session that the next agent must honor -->
- **<decision>** — <rationale>

## Open Questions

<!-- Unresolved issues or trade-offs -->

## Next Steps

<!-- Concrete first actions for the resuming agent -->

## Relevant Files

<!-- Paths to files central to this work -->
```

## Guardrails

- **Write from current context only.** The handoff should be based on what the agent already knows from the current conversation — do not explore files, run searches, or do additional research unless the user explicitly asks for it.
- **Do not summarize the entire conversation.** Focus only on the aspect the user specified.
- **Do not invent context.** Only capture what actually happened or was discussed in this session.
- **Do not prescribe solutions for open questions.** State the question; let the next agent and user decide.
- **Write for a cold reader.** The resuming agent has zero prior context — be precise about file paths, branch names, and terminology.
