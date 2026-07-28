---
name: ask-questions
description: >
  How to ask users questions interactively: which tool to use, how to batch questions, and
  when to ask serially. Follow this skill when asking clarifying questions, requesting
  confirmation, collecting missing requirements, or pausing for user input.
  Invoked by other skills rather than directly by the user.
---

# Ask Questions

Ask only for decisions that materially affect behavior, scope, architecture, risk, sequencing, or
acceptance. First inspect the repository, documentation, configuration, prior artifacts, and
conversation so the user is not asked for discoverable facts. Decide low-risk implementation details
from context.

## Ask and wait

Use the runtime's dedicated input tool when one is available. Otherwise ask directly in an interactive
chat and end the turn. In a headless session, report the unresolved decision or follow the caller's
explicit fallback. Never continue past a question by inventing the user's answer.

Batch two to four related, independent questions by default. Ask serially when one answer determines
the next question, the question is an approval gate, or the caller requires one-at-a-time discovery.

## Write useful questions

- Explain enough context and impact for the user to decide without reopening source files.
- Use bounded options when the choice space is genuinely bounded; use open-ended questions otherwise.
- Recommend a path and briefly state the trade-off.
- Keep one decision per question.
- Distinguish discovery from approval. A generic “does this look right?” is not a substitute for
  resolving material behavior, boundaries, failure cases, trade-offs, or task grouping.
- At an approval gate, mention consequential defaults or assumptions you selected from context so the
  user can correct them; omit routine details.

Do not ask the user to choose among raw, unevaluated implementation options or present an artifact for
approval while known high-impact ambiguity remains.
