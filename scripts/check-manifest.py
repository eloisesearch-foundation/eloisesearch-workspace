#!/usr/bin/env python3
"""Check that repos.txt, eloisesearch.code-workspace and the dev container agree.

Every repository in repos.txt must:
  - appear as a folder in eloisesearch.code-workspace (an active or a commented
    line both count: planned repositories stay commented until they exist);
  - have an entry in customizations.codespaces.repositories in
    .devcontainer/devcontainer.json, so Codespaces can clone it.
And every repository granted in devcontainer.json must be listed in repos.txt.

Exit code 1 on any mismatch.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

META = Path(__file__).resolve().parent.parent


def manifest() -> dict[str, str]:
    repos = {}
    for line in (META / "repos.txt").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) != 3:
            sys.exit(f"repos.txt: expected '<dir> <url> <group>', got: {line}")
        directory, url, _group = parts
        match = re.search(r"github\.com[:/]([^/]+/[^/]+?)(?:\.git)?$", url)
        if not match:
            sys.exit(f"repos.txt: cannot read owner/name from {url}")
        repos[directory] = match.group(1)
    return repos


def strip_line_comments(text: str) -> str:
    return "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("//"))


def main() -> int:
    repos = manifest()
    problems = []

    workspace = (META / "eloisesearch.code-workspace").read_text(encoding="utf-8")
    for directory in repos:
        if f'"path": "../{directory}"' not in workspace:
            problems.append(f"eloisesearch.code-workspace: no folder for ../{directory}")

    devcontainer = json.loads(strip_line_comments((META / ".devcontainer/devcontainer.json").read_text(encoding="utf-8")))
    granted = set(devcontainer.get("customizations", {}).get("codespaces", {}).get("repositories", {}))
    expected = set(repos.values())
    for name in sorted(expected - granted):
        problems.append(f"devcontainer.json: {name} is in repos.txt but has no Codespaces permission")
    for name in sorted(granted - expected):
        problems.append(f"devcontainer.json: {name} has Codespaces permission but is not in repos.txt")

    for problem in problems:
        print(problem, file=sys.stderr)
    if not problems:
        print(f"check-manifest: {len(repos)} repositories consistent")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
