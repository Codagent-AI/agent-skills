# Slice ledger format

Keep the ledger as one Markdown file outside the repository. Update it after every slice and
every ruling. Read it again whenever your context has been compacted.

```markdown
# Ledger: <change name>

Artifacts: <artifact directory>
Start commit: <sha>

## Checklist
- [ ] 1. Read the artifacts and map the code
- [ ] 2. Write the slice ledger
- [ ] 3. Implement, check, and review each slice in order
- [ ] 4. Run the integration check
- [ ] 5. Report

## Commands
Targeted tests: <command pattern>
Full checks: <test, lint, format, build commands>

## Slices
### S1: <short goal>
- Scenarios: <spec file>: <requirement> / <scenario>, ...
- Test-plan items: <ids or short names>
- Expected files: <paths or packages>
- Depends on: none
- Status: pending | in progress | done | blocked
- Commits: <base>..<head>
- Review: <outcome, findings fixed or rejected and why>

### S2: ...

## Coverage
Every scenario and test-plan item, each mapped to a slice. A row with no slice is a gap: make a
ruling and record it below.

## Rulings and decisions
- <decision>: <why>, <which slice made it>

## Assumptions and open gaps
- <assumption or gap>: <source>, <impact>
```
