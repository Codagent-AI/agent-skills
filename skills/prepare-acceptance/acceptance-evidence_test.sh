#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

python3 - "$SCRIPT_DIR/SKILL.md" <<'PY'
from pathlib import Path
import re
import sys

skill = Path(sys.argv[1]).read_text()


def section(title):
    match = re.search(rf"^## {re.escape(title)}\n(.*?)(?=^## |\Z)", skill, re.M | re.S)
    assert match, f"missing section: {title}"
    return match.group(1)


evidence = section("Before blaming the environment")
for phrase in (
    "coverage-floor item",
    "required acceptance test",
    "exploration step",
    "request/response files",
    "logs",
    "resolved config",
    "credentials",
    "endpoint",
    "request.json",
    "auditor.cli = claude",
    "Not logged in",
    "acceptance-findings.md",
):
    assert phrase in evidence, f"missing failure-evidence guidance: {phrase}"

assert re.search(r"read.*(failure|retained).*evidence", evidence, re.I | re.S)
assert re.search(r"(fixture|smoke config|pin|default).*defect", evidence, re.I | re.S)
assert re.search(r"cite.*evidence path.*limitation", evidence, re.I | re.S)
assert re.search(r"no evidence.*(do not|don't).*external cause", evidence, re.I | re.S)

assert "evidence" in section("Coverage floor")
assert "evidence" in section("When to stop")
assert re.search(r"read.*logs.*external", section("Wait for CI and hand off"), re.I | re.S)
assert re.search(r"Exploration.*evidence path.*limitation", section("Wait for CI and hand off"), re.I | re.S)

print("PASS: acceptance failures require retained evidence before external attribution")
PY
