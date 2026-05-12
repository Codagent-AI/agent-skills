---
name: ask-questions
description: >
  How to ask users questions interactively: which tool to use, how to batch questions, and
  when to ask serially. Follow this skill when asking clarifying questions, requesting
  confirmation, collecting missing requirements, or pausing for user input.
  Invoked by other skills rather than directly by the user.
---

# Ask Questions

This skill encodes how to ask users questions effectively. It is **not invoked directly** by the user — it is invoked by other skills whenever they need to collect information through interactive dialogue.

## Which Tool to Use

Prefer a dedicated question/input tool when the runtime makes one available for the current turn, but do not fail just because that tool is unavailable.

Use this decision order:

1. **Dedicated question tool available** — use the runtime's native input-requesting tool.
   - **Claude**: use `mcp__ide__askQuestion` or `ask_followup_question` when available.
   - **Codex Plan mode**: use `request_user_input` when available.
   - **Other agents**: use the equivalent input-requesting tool for the runtime (for example, `request_input`, `ask_user`, or similar).
2. **No dedicated tool, but the session is interactive** — ask the question directly in chat, then stop and wait for the user's answer. Do not continue with assumptions after asking.
3. **Headless/non-interactive session** — do not ask the user. Return a blocker/ambiguity explaining what decision is needed, or follow the caller skill's headless fallback instructions if it defines one.

The goal is to explicitly pause for user input before continuing. A dedicated tool is preferred because it enforces the pause, but an interactive plain-chat question is the correct fallback when the runtime does not expose that tool.

<HARD-GATE>
Do not proceed past an unresolved user decision. If you ask a question with a dedicated tool, wait for the tool response. If you ask in plain chat, end the turn and wait for the user's reply. In headless mode, return the ambiguity instead of inventing an answer.
</HARD-GATE>

## Batching Strategy

**Prefer asking 2–4 questions at a time when the caller skill does not require serial discovery.** Batching reduces round-trips and respects the user's time.

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

Ask a single question when:
- The answer determines what the *next* question should be (a branching decision point)
- The question is a binary gate that may end the conversation entirely (e.g., "Is this change approved?")
- The caller skill explicitly says to ask questions one at a time

**Good serial example:**
> "Before I write the spec file, does this look right to you?" ← wait for yes/no before continuing

Even when asking serially, prefer the dedicated question tool when available; otherwise ask directly in chat and stop.

### Anti-patterns

- **Asking 1 question when 3 are independent** — unnecessarily drag out the conversation
- **Asking 7 questions at once** — overwhelming; users stop reading carefully past question 3
- **Asking in prose and then continuing** — the agent may proceed without the answer; if you ask in chat, stop there
- **Asking follow-up questions that ignore the dependency** — if Q1's answer eliminates Q3, drop Q3

## Question Quality

- **Prefer multiple-choice** when the option space is bounded — easier to answer quickly
- **Open-ended is fine** when the space is genuinely open (e.g., "What should happen when X?")
- **Provide context with each question** — quote relevant material if needed so the user isn't switching context
- **One topic per question** — don't bundle two decisions into one question
- **Ask discovery questions before approval questions** — "Does this artifact look good?" is an approval gate, not requirements discovery. Before asking for approval, ask the specific behavior, boundary, trade-off, or grouping questions that would materially change the artifact.

## Applying This Skill

When another skill says "use the appropriate tool for asking the user a question or requesting input":

1. Determine whether to batch or ask serially (see above)
2. Draft your questions following the quality guidelines
3. Use the best available input path from "Which Tool to Use"
4. Wait for the user's response before proceeding, or stop the turn if asking in chat
5. Adjust your next batch based on what you learned

## Never

- Never use a generic artifact approval question as a substitute for clarifying the underlying requirements, architecture, or task grouping.
- Never present a completed artifact for approval while high-impact ambiguities remain unasked.
