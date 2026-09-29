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


def requires_terms(title, label, *terms):
    body = re.sub(r"\s+", " ", section(title))
    missing = [term for term in terms if not re.search(term, body, re.I)]
    assert not missing, f"{title}: {label}; missing {missing}"


requires_terms("Before blaming the environment", "failed runs require retained evidence before attribution",
               r"any run", r"fails", r"retained", r"before", r"external")
requires_terms("Before blaming the environment", "change-owned causes are defects",
               r"change owns", r"defect", r"acceptance-findings\.md")
requires_terms("Before blaming the environment", "failed-run rulings carry the message and provenance",
               r"verbatim excerpt", r"evidence path", r"provenance", r"exploration-log\.md", r"assumptions")
requires_terms("Before blaming the environment", "bounded investigation and unconfirmed fallback",
               r"budget", r"envelope", r"inconclusive", r"unconfirmed", r"external cause")
requires_terms("Coverage floor", "unrun floor item remains a limitation",
               r"could not exercise", r"limitation", r"no run", r"no failure evidence")
requires_terms("When to stop", "unrun paths need no failure evidence",
               r"[Nn]ot exercised", r"not run", r"no failure evidence")
requires_terms("When to stop", "external failed-run rulings include the message and provenance",
               r"failed run", r"evidence path", r"verbatim excerpt", r"provenance")
requires_terms("Report", "failed-run records carry the message and provenance",
               r"exploration-log\.md", r"verbatim excerpt", r"evidence path", r"provenance")
requires_terms("Wait for CI and hand off", "failed checks and comments have separate evidence paths",
               r"`failed`", r"failing check's logs", r"`comments`", r"comment",
               r"Before blaming the environment")
requires_terms("Wait for CI and hand off", "handoff exploration quotes failed-run limitations",
               r"Exploration", r"evidence path", r"verbatim excerpt", r"provenance")

print("PASS: acceptance failures require bounded, quoted evidence before external attribution")
PY
