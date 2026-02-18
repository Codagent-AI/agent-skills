---
name: pull-skills
description: Use when downloading skills listed in a skill-manifest.json, after running discover-skills, or when the user says "pull skills" or invokes /pull-skills. No arguments needed.
---

# Pull Skills

Downloads skill files from GitHub repos based on the local `skill-manifest.json`. Run `discover-skills` first to set up the manifest.

## Process

Run the pull script:

```bash
npx tsx .claude/skills/pull-skills/pull-skills.ts
```

Report the script's output to the user. If the script exits with an error, report the error message.

## Prerequisites

- Node.js must be installed (for `npx tsx`)
- `gh` CLI must be authenticated (the script shells out to `gh api`)
- `skill-manifest.json` must exist (run `discover-skills` first)

## What the script does

1. Auto-discovers `skill-manifest.json` (repo root first, then top-level subdirs)
2. For each source and skill in the manifest, downloads the full skill directory via `gh api`
3. Writes files to the `target` directory specified in the manifest (relative to manifest location)
4. Checks `prerequisites` entries and warns about missing or version-mismatched CLIs
5. Prints a summary of pulled skills and any warnings

## Important

- Do NOT modify `skill-manifest.json` — this skill only reads it
- If the script fails, check that `gh auth status` succeeds and that the manifest is valid JSON
