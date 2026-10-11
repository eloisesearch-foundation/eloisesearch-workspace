#!/usr/bin/env python3
"""Report broken relative links in Markdown files across the workspace.

Checks the meta-repo and every sibling repository from repos.txt that is cloned.
A link is broken when its target file does not exist or, for links into Markdown
files, when the #anchor matches no heading. External URLs are not fetched.

Usage: python3 scripts/check-docs.py [--root <dir>]...
Exit code 1 when any link is broken.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

META_DIR = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = Path(os.environ.get("WORKSPACE_ROOT", META_DIR.parent)).resolve()
SKIP_DIRS = {".git", "target", "node_modules", "vendor", ".nuxt", ".output", "dist", "tmp"}

LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)|!\[[^\]]*\]\(([^)\s]+)\)")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE_RE = re.compile(r"`[^`]*`")
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")


def repos() -> list[Path]:
    roots = [META_DIR]
    manifest = META_DIR / "repos.txt"
    for line in manifest.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        candidate = WORKSPACE_ROOT / line.split()[0]
        if candidate.is_dir():
            roots.append(candidate)
    return roots


def markdown_files(root: Path):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name.endswith(".md"):
                yield Path(dirpath) / name


def strip_code(text: str) -> list[tuple[int, str]]:
    """Lines outside fenced code blocks, with inline code and comments removed."""
    text = COMMENT_RE.sub(lambda m: "\n" * m.group(0).count("\n"), text)
    lines, in_fence = [], False
    for number, line in enumerate(text.splitlines(), start=1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            lines.append((number, INLINE_CODE_RE.sub("", line)))
    return lines


def slug(heading: str) -> str:
    """GitHub-style heading anchor."""
    heading = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)  # links -> text
    heading = heading.replace("`", "").strip().lower()
    heading = re.sub(r"[^\w\- ]", "", heading)
    return heading.replace(" ", "-")


_anchor_cache: dict[Path, set[str]] = {}


def anchors(path: Path) -> set[str]:
    if path not in _anchor_cache:
        found: set[str] = set()
        counts: dict[str, int] = {}
        in_fence = False
        for line in path.read_text(encoding="utf-8").splitlines():
            if FENCE_RE.match(line):
                in_fence = not in_fence
                continue
            match = None if in_fence else HEADING_RE.match(line)
            if match:
                base = slug(match.group(2))
                n = counts.get(base, 0)
                counts[base] = n + 1
                found.add(base if n == 0 else f"{base}-{n}")
        _anchor_cache[path] = found
    return _anchor_cache[path]


def check(root: Path) -> list[str]:
    problems = []
    for md in sorted(markdown_files(root)):
        for number, line in strip_code(md.read_text(encoding="utf-8")):
            for match in LINK_RE.finditer(line):
                target = match.group(1) or match.group(2)
                if re.match(r"^[a-z][a-z0-9+.-]*:", target, re.I) or target.startswith("{{"):
                    continue  # external URL, mailto:, template placeholder
                path_part, _, anchor = target.partition("#")
                resolved = md if not path_part else (md.parent / path_part).resolve()
                where = f"{md.relative_to(WORKSPACE_ROOT)}:{number}"
                if not resolved.exists():
                    problems.append(f"{where}: missing target {target}")
                elif anchor and resolved.suffix == ".md" and anchor not in anchors(resolved):
                    problems.append(f"{where}: no heading for #{anchor} in {path_part or md.name}")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", action="append", type=Path, help="check only these directories")
    args = parser.parse_args()

    roots = [r.resolve() for r in args.root] if args.root else repos()
    problems = []
    for root in roots:
        found = check(root)
        status = "ok" if not found else f"{len(found)} broken"
        print(f"==> {root.name}: {status}")
        problems += found
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
