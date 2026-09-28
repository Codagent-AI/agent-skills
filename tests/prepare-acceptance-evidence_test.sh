#!/usr/bin/env bash

set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

python3 - "$REPO_DIR/skills/prepare-acceptance/SKILL.md" <<'PY'
from pathlib import Path
import re
import sys

skill = Path(sys.argv[1]).read_text()


def section(title):
    match = re.search(rf"^## {re.escape(title)}\n(.*?)(?=^## |\Z)", skill, re.M | re.S)
    assert match, f"missing section: {title}"
    return match.group(1)


def requires(title, label, pattern):
    assert re.search(pattern, section(title), re.I | re.S), f"{title}: {label}"


requires("Before blaming the environment", "failed runs require evidence review before external attribution",
         r"fails.*read.*retained failure evidence.*before.*(?:external|limitation)")
requires("Before blaming the environment", "inspect artifacts and actual runtime choices",
         r"request/response.*logs.*resolved config.*CLI.*agent.*credentials.*endpoint")
requires("Before blaming the environment", "change-owned fixtures are defects",
         r"change owns.*fixtures.*pins.*record a defect.*acceptance-findings\.md")
requires("Before blaming the environment", "external rulings cite reviewed evidence",
         r"Cite.*evidence\s+path.*limitation.*out-of-scope")
requires("Before blaming the environment", "absence of evidence is not an external cause",
         r"no evidence.*do not assert an external cause")
requires("Before blaming the environment", "reported fallback is classified as a fixture defect",
         r"unpinned agent.*Not logged in.*request\.json.*auditor\.cli = claude.*fixture.*defect")
requires("Before blaming the environment", "required tests come from approved plans",
         r"required acceptance test.*approved test plan")
requires("Before blaming the environment", "search the run output before declaring evidence absent",
         r"(?:working|output) directory.*evidence directory")

requires("Coverage floor", "unrun floor items do not require failure evidence",
         r"could not exercise.*limitation.*no run.*(?:envelope|credential)")
requires("When to stop", "unrun exclusions do not require failure evidence",
         r"Not exercised.*(?:unrun|not run).*no failure evidence")
requires("Wait for CI and hand off", "read failing CI logs before external attribution",
         r"read the failing check's logs.*external")
requires("Wait for CI and hand off", "handoff cites evidence for failed-run limitations",
         r"Exploration.*evidence\s+path.*limitation.*failed run")

print("PASS: acceptance failures require retained evidence before external attribution")
PY
