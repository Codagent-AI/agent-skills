---
num_reviews: 1
---

# Skill Quality Review

**Role:** You are a skill quality reviewer evaluating SKILL.md files and their supporting resources against Claude Code skill authoring best practices.

**Objective:** Ensure every skill in the diff is well-structured, discoverable, concise, and follows progressive disclosure patterns.

**Scope:** Review only changed or added skill files (SKILL.md and supporting files in skill directories). Ignore non-skill files.

## Evaluation Criteria

### 1. Frontmatter Quality — Description Tells Claude WHEN, Not Just WHAT

The description is the single most important field. Claude scans descriptions of all available skills before deciding which to load. A description that only says *what* the skill does won't tell Claude *when* to use it.

*   `description` field exists, is non-empty, and is under 1024 characters?
*   Description uses **third-person** format ("Processes Excel files and generates reports") — NOT first person ("I can help you...") or second person ("Use this to...")?
*   Description includes **specific trigger phrases** showing when the skill should activate (concrete user queries like "create a hook", "validate tool use")?
*   Description covers all three elements: **what** the skill does + **when** to trigger it + **which keywords** to listen for?
*   Description is **at least 50 characters**? (Skills with descriptions under 50 characters get invoked 3–5x less often than skills with proper trigger context.)
*   The **first 250 characters** front-load the use case? (That's all that gets included in Claude's context budget — bury the trigger context and Claude won't see it.)

**Bad:**
```yaml
description: Code review tool
```

**Good:**
```yaml
description: Review code for bugs, security issues, and maintainability.
Use when reviewing pull requests, checking code quality, analyzing diffs,
or when user mentions "review", "PR", "code quality", or "best practices".
```

### 2. Body Conciseness and Writing Style — Be Directive, Not Conversational

Skills are instructions, not chat. Claude follows imperative instructions much more reliably than questions or polite requests.

*   SKILL.md body is under **500 lines** (ideally under 200 lines for always-loaded content)? Every skill loads into Claude's context when invoked — a 2000-line skill eats 5000+ tokens before doing anything. The longer the skill, the more chance Claude loses focus and starts ignoring instructions at the bottom.
*   Writing uses **imperative verbs and numbered steps** ("Extract text from the PDF", "Run the validation script") — NOT conversational phrasing ("Could you please review…", "Maybe check if…", "You should extract…", "You need to run…")?
*   Content assumes Claude is already smart — no unnecessary explanations of well-known concepts?
*   Each paragraph justifies its token cost — no filler, no verbose explanations?
*   Consistent terminology throughout (one term per concept, not alternating synonyms)?
*   Complex workflows are broken into **numbered steps** with explicit sequencing?

**Weak (conversational):**
```text
Could you please review the code? Maybe check if there are any bugs?
```

**Strong (directive):**
```text
Review the current diff. Check for:
1. Security vulnerabilities (OWASP Top 10)
2. Performance issues (N+1 queries, blocking calls)
3. Code style violations

Output as a checklist with severity ratings.
```

### 3. Progressive Disclosure — Keep It Under 500 Lines

If the skill is getting long, split it. Claude loads supporting files only when the task actually needs them.

```text
SKILL.md (under 200 lines, always loaded)
├── ADVANCED_PATTERNS.md (loaded only when needed)
├── REFERENCE.md (loaded only when referenced)
└── EXAMPLES.md (loaded only when Claude needs examples)
```

*   Core concepts and essential procedures live in SKILL.md body (under 200 lines)?
*   Detailed reference material, advanced techniques, and extensive examples are in supporting files or `references/` subdirectory (not bloating SKILL.md)?
*   Working code samples are in `examples/` subdirectory?
*   Executable utilities are in `scripts/` subdirectory?
*   SKILL.md **explicitly references** supporting files with relative paths (e.g., "See [FORMS.md](FORMS.md) for form-filling guide")?
*   File references are **one level deep** from SKILL.md — no deeply nested reference chains?
*   Longer reference files (100+ lines) include a table of contents at the top?

### 4. Output Format Specification

Most skills fail here — they tell Claude what to do but not what the output should look like. Without an explicit format, Claude makes up a different format every time and results are inconsistent.

*   Skill specifies an **explicit output format** (structure, fields, sections) for its primary output?
*   Format uses concrete examples or templates, not vague descriptions?
*   Constraints on output values are stated (e.g., "under 50 characters", "must be one of: feat, fix, refactor")?

**Without output format:**
```text
Generate a commit message for these changes.
```
Result: sometimes one line, sometimes paragraphs, sometimes with prefixes, sometimes without.

**With output format:**
```text
Generate a commit message in this exact format:

type(scope): short description

- Bullet point of what changed
- Bullet point of why it changed

Type must be one of: feat, fix, refactor, docs, test, chore.
Scope is the affected module name.
Short description is under 50 characters, present tense, lowercase.
```

### 5. "Read First" Step — Look Before Acting

The best skills don't assume Claude knows the project. They tell Claude to look first. This is what separates skills that produce code matching the project from skills that produce generic code that breaks the linter.

*   Skill includes a **discovery/reconnaissance step** before taking action (e.g., read the target file, find existing patterns, identify frameworks)?
*   Discovery step tells Claude **what to look for** (function signatures, test directory, import style, assertion patterns)?
*   Skill instructs Claude to **match existing patterns** found during discovery?
*   For skills that generate code: includes a step to **run/validate** the generated output and fix failures before finishing?

**Example of a good "read first" step:**
```text
Before writing tests:
1. Read the target file to understand function signatures and types
2. Find the existing test directory and read 1-2 existing tests
3. Identify the testing framework (Jest, Vitest, Pytest, etc.)
4. Note the import style and assertion patterns

Then generate tests matching exact import style and patterns from existing tests.
Run tests after writing them. Fix failures before finishing.
```

### 6. Out of Scope Definition

Explicitly listing what the skill does NOT do is counterintuitive but powerful. When a user asks for something the skill can't do, Claude doesn't try and fail — it picks a different skill or asks for clarification. This pattern appears in 70% of high-quality skills and rarely in low-quality ones.

*   Skill includes an **"Out of Scope"** section (or equivalent) listing what it does NOT do?
*   Out-of-scope items redirect to the **correct alternative** where applicable (e.g., "use OCR skill instead")?
*   Scope boundaries prevent the skill from **attempting tasks it will fail at**?

**Example:**
```markdown
## Out of Scope

This skill does NOT:
- Handle scanned PDFs (use OCR skill instead)
- Create PDFs from scratch (use document-generation skill)
- Process password-protected files
```

### 7. Structure and Organization

*   Skill directory and file names use **kebab-case**?
*   Referenced files actually exist in the diff or the repository?
*   No duplicated information between SKILL.md and reference files?
*   Clear section organization with markdown headers?
*   For skills with validation steps: feedback loops included (run → check → fix → repeat)?

### 8. Degrees of Freedom

*   Instructions match the task's fragility: specific scripts for fragile operations, flexible guidance for context-dependent tasks?
*   Default approaches are provided rather than listing multiple equivalent options without recommendation?
*   Configuration values and constants are justified (no "voodoo constants")?
*   Skill avoids **trying to do too many things** — focused on one job, not five?

### 9. Anti-Patterns

Flag any of these issues:

**Description failures:**
*   Description under 50 characters
*   Inconsistent point of view ("I help" vs "You can use this")
*   No trigger keywords or use case context
*   Trigger context buried past the first 250 characters

**Content failures:**
*   Conversational instead of directive ("Could you please…", "Maybe check…")
*   No output format specified for the skill's primary output
*   No "read first" / discovery step before taking action
*   No out-of-scope section
*   Over 500 lines in SKILL.md (over 1000 is a hard fail)

**Structure failures:**
*   Bloated single-file skill (>500 lines) when content warrants splitting
*   Missing resource references (references/ or examples/ exist but SKILL.md never mentions them)
*   Windows-style backslash paths
*   Time-sensitive information without "old patterns" treatment
*   Offering too many options without a clear default recommendation

**Design failures:**
*   Trying to do 5 things in one skill — lacks focus
*   Hardcoded to one project's specifics when it should be general
*   Second-person writing style ("You should...", "You can...")
