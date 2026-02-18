# Skill Management Skills — Design

Two Claude Code skills for managing skill manifests and pulling skills from GitHub repos.

---

## `discover-skills`

**Type:** Pure SKILL.md (agent uses `gh` CLI directly)

**Location:** `.claude/skills/discover-skills/SKILL.md`

### Input

- Optional argument: a GitHub URL like `https://github.com/obra/superpowers/tree/main/skills`
- If no argument provided, prompt the user for the URL

### URL Parsing

Extract from the URL:
- **owner/repo**: e.g., `obra/superpowers`
- **path**: e.g., `skills` (the directory containing skill subdirectories)
- **ref**: ignored for manifest — resolved to latest tag or commit SHA

Supported URL formats:
- `https://github.com/{owner}/{repo}/tree/{ref}/{path}`
- `https://github.com/{owner}/{repo}` (prompt user for path)

### Flow

1. Parse the URL into owner/repo/path
2. Resolve version: fetch latest tag via `gh api repos/{owner}/{repo}/tags --jq '.[0].name'`. If no tags exist, resolve to the current commit SHA of the default branch.
3. List subdirectories at path via `gh api repos/{owner}/{repo}/contents/{path}?ref={version}` — filter for `type == "dir"`, each is a skill
4. For each skill subdirectory, fetch its `SKILL.md` (or first `.md` file) and extract the first meaningful line as a description
5. Present the list with names + descriptions, let user multi-select
6. Locate `skill-manifest.json` (see Manifest Discovery below)
7. If no manifest found:
   - Ask user for target directory and manifest location
   - Create the manifest with the source entry
8. If manifest exists:
   - If this repo is already a source, merge new skills into existing selection (additive)
   - If new repo, add a new source entry
9. Write/update `skill-manifest.json`

### Manifest Discovery

1. Check repo root for `skill-manifest.json`
2. If not found, check each top-level subdirectory
3. If multiple found, prompt user to pick
4. If none found, ask user where to create it

### Edge Cases

- `gh` not installed/authenticated → fail with clear message
- No tags on repo → pin to commit SHA, warn user that tag pinning is preferred
- Duplicate skill selection (already in manifest for that source) → silently skip
- Source `name` defaults to repo name; if collision, append owner (e.g., `superpowers-obra`)

---

## `pull-skills`

**Type:** SKILL.md + TypeScript script

**Location:** `.claude/skills/pull-skills/SKILL.md` and `.claude/skills/pull-skills/pull-skills.ts`

### Input

No arguments. Reads `skill-manifest.json` (auto-discovered via same logic as `discover-skills`).

### SKILL.md

Instructs the agent to run `npx tsx .claude/skills/pull-skills/pull-skills.ts` and report the results.

### Script Flow (`pull-skills.ts`)

1. Discover and read `skill-manifest.json` — error if not found (tell user to run `discover-skills` first)
2. For each source in the manifest:
   a. For each skill in that source's `skills` array:
      - Fetch the full directory tree via `gh api repos/{owner}/{repo}/contents/{path}/{skill}?ref={version}`
      - Recursively download all files into `{target}/{skill}/`, preserving directory structure
      - File contents fetched via `gh api` (base64-decoded)
   b. After downloading all skills for a source, check `prerequisites` if present:
      - For each `prerequisites.cli` entry, run `which {package}` to check existence
      - Run `{package} --version` and compare against the specified version range (inline semver check, no dependencies)
      - Print warning + install suggestion for any missing/mismatched prerequisites
3. Print summary: skills pulled, files written, any prerequisite warnings

### Target Directory

- Read from `manifest.target` (relative to manifest location)
- Create the directory if it doesn't exist
- Existing files are overwritten (pull is idempotent)

### Prerequisite Warning Format

```
Warning: Missing prerequisite: agent-gauntlet (required by source 'agent-gauntlet')
  Install with: npm install -g agent-gauntlet@^0.15.0

Warning: Version mismatch: openspec v0.9.0 installed, requires ^1.0.2 (source 'openspec')
  Update with: npm install -g @fission-ai/openspec@^1.0.2
```

### Edge Cases

- Missing manifest → tell user to run `discover-skills`
- GitHub API failure for a single skill → log error, continue with remaining skills
- No network → fail early with clear message
- Script invoked via `npx tsx` — requires Node.js, no `npm install` step needed

---

## Manifest Schema

```json
{
  "target": "skills",
  "sources": [
    {
      "name": "superpowers",
      "repo": "https://github.com/obra/superpowers",
      "path": "skills",
      "version": "v4.3.0",
      "skills": ["brainstorming", "writing-plans", "test-driven-development"]
    },
    {
      "name": "openspec",
      "repo": "https://github.com/Fission-AI/OpenSpec",
      "path": "src/commands",
      "version": "v1.0.2",
      "skills": ["spec", "design"],
      "prerequisites": {
        "cli": { "package": "@fission-ai/openspec", "version": "^1.0.2" }
      }
    }
  ]
}
```

---

## File Structure

```
.claude/
└── skills/
    ├── discover-skills/
    │   └── SKILL.md
    └── pull-skills/
        ├── SKILL.md
        └── pull-skills.ts

skill-manifest.json          # (location varies — repo root or subdirectory)
```

---

## Monorepo Support

Both skills auto-discover `skill-manifest.json` by scanning the repo root first, then each top-level subdirectory. If multiple manifests are found, the user is prompted to pick one. The `target` path in the manifest is relative to the manifest's location.

---

## Dependencies

- `gh` CLI (authenticated) — required by both skills
- Node.js + `npx tsx` — required by `pull-skills` only
- No npm packages to install
