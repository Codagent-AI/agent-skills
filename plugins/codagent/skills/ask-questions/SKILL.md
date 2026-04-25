---
description: >
  How to ask users questions interactively: which tool to use, how to batch questions, and
  when to ask serially. Follow this skill when asking clarifying questions, requesting
  confirmation, collecting missing requirements, or pausing for user input.
  Invoked by other skills rather than directly by the user.
---

# Ask Questions

This skill encodes how to ask users questions effectively. It is **not invoked directly** by the user — it is invoked by other skills whenever they need to collect information through interactive dialogue.

## Which Tool to Use

**Always use the dedicated question/input tool, not a plain message.**

- **Claude**: use the `mcp__ide__askQuestion` tool (or `ask_followup_question` in agentic contexts). Do NOT embed questions in plain prose — use the tool.
- **Other agents**: use the equivalent input-requesting tool for your runtime (e.g., `request_input`, `ask_user`, or similar). If your runtime exposes a native question tool, always prefer it over a plain assistant turn.

The tool ensures the agent explicitly waits for a response before continuing, rather than proceeding with assumptions.

<HARD-GATE>
NEVER ask a question by writing it in prose and continuing the response. ALWAYS use the appropriate question tool to pause and wait for the user's answer. Violating this is the most common failure mode.
</HARD-GATE>

## Batching Strategy

**Prefer asking 2–4 questions at a time.** Batching reduces round-trips and respects the user's time.

### When to batch (default)

Group related questions into a single tool call when:
- The questions are independent of each other (answering one doesn't change what you'd ask next)
- They cover the same topic or decision area
- 2–4 questions fit naturally together

**Good batch example** (for a spec clarifying session):
> 1. What happens when a user submits the form with an empty required field — validation error inline, or blocked on submit?
> 2. Should validation run on blur (leaving the field) or only on submit?
> 3. Are there any fields that should be optional in draft mode but required on final submit?

### When to ask one question at a time (serial)

Ask a single question only when:
- The answer determines what the *next* question should be (a branching decision point)
- The question is a binary gate that may end the conversation entirely (e.g., "Is this change approved?")

**Good serial example:**
> "Before I write the spec file, does this look right to you?" ← wait for yes/no before continuing

Even when asking serially, use the question tool — not prose.

### Anti-patterns

- **Asking 1 question when 3 are independent** — unnecessarily drag out the conversation
- **Asking 7 questions at once** — overwhelming; users stop reading carefully past question 3
- **Embedding questions in prose** — the agent may not pause for a response; always use the tool
- **Asking follow-up questions that ignore the dependency** — if Q1's answer eliminates Q3, drop Q3

## Question Quality

- **Prefer multiple-choice** when the option space is bounded — easier to answer quickly
- **Open-ended is fine** when the space is genuinely open (e.g., "What should happen when X?")
- **Provide context with each question** — quote relevant material if needed so the user isn't switching context
- **One topic per question** — don't bundle two decisions into one question

## Applying This Skill

When another skill says "use the appropriate tool for asking the user a question or requesting input":

1. Determine whether to batch or ask serially (see above)
2. Draft your questions following the quality guidelines
3. Call the question tool with all questions in this batch
4. Wait for the user's response before proceeding
5. Adjust your next batch based on what you learned
