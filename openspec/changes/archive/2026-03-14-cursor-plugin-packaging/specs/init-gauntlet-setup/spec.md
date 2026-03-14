## MODIFIED Requirements

### Requirement: Copy review and check files
The init skill SHALL copy `artifact-review.md` and `task-compliance.md` from the plugin's `.gauntlet/reviews/` into the consumer project's `.gauntlet/reviews/`, and `openspec-validate.yml` from the plugin's `.gauntlet/checks/` into the consumer project's `.gauntlet/checks/`. The init skill SHALL locate plugin files using generic prose ("locate the plugin's root directory") without referencing runtime-specific variables.

#### Scenario: First init — no existing review/check files
- **WHEN** the consumer project has no `.gauntlet/reviews/` or `.gauntlet/checks/` directories
- **THEN** the init skill creates the directories and copies the files from the plugin

#### Scenario: Re-init — existing review/check files
- **WHEN** the consumer project already has these files
- **THEN** the init skill overwrites them with the plugin's versions

#### Scenario: Plugin file location is runtime-agnostic
- **WHEN** the init skill copies files from the plugin
- **THEN** it locates the plugin root using the hosting runtime's native mechanism, not a runtime-specific variable
