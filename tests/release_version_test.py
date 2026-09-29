#!/usr/bin/env python3
"""Check that the release metadata stays in sync after the 0.12.2 bump."""

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFESTS = (
    (".claude-plugin/marketplace.json", "plugins", 0, "version"),
    (".claude-plugin/plugin.json", "version"),
    (".codex-plugin/plugin.json", "version"),
    (".cursor-plugin/plugin.json", "version"),
)


def version_tuple(version):
    assert re.fullmatch(r"\d+\.\d+\.\d+", version), version
    return tuple(map(int, version.split(".")))


changelog = (ROOT / "CHANGELOG.md").read_text()
headings = re.findall(r"^## (\d+\.\d+\.\d+)$", changelog, re.MULTILINE)
assert headings, "CHANGELOG.md has no release headings"
latest = headings[0]
assert version_tuple(latest) >= (0, 12, 2), f"release regressed to {latest}"
assert all(version_tuple(a) > version_tuple(b) for a, b in zip(headings, headings[1:])), (
    "CHANGELOG.md releases must be unique and newest first"
)

for manifest in MANIFESTS:
    path, *keys = manifest
    data = json.loads((ROOT / path).read_text())
    for key in keys:
        data = data[key]
    assert data == latest, f"{path} has version {data}, expected {latest}"

print(f"PASS: all plugin manifests match changelog release {latest}")
