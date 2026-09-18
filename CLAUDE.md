# Agent Skills — Development Notes

## Skill frontmatter

Do NOT add a `name` field to skill frontmatter. The `name` field overrides the skill's display prefix, causing it to show an incorrect or generic name instead of the proper namespaced prefix (e.g. `codagent:handoff`).

## Releases

Every PR must include a release. Run the `release` skill (`.claude/skills/release`) before creating or pushing a PR so the branch carries the version bump and changelog entry. Do not open a PR without it.
