#!/usr/bin/env python3
"""Parse all meta.xml under gamemode root; write export stats to stdout or file."""
from __future__ import annotations

import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GAMEROOT = os.path.normpath(os.path.join(SCRIPT_DIR, "..", ".."))

_EXPORT_RE = re.compile(r"<export\b[^>]*\bfunction=\"([^\"]+)\"", re.IGNORECASE)


def list_exports(meta_path: str) -> list[str]:
    """Regex-based parse — tolerates meta.xml with xmlns prefixes or minor quirks."""
    with open(meta_path, encoding="utf-8", errors="ignore") as f:
        return _EXPORT_RE.findall(f.read())


def main() -> None:
    root = GAMEROOT
    if len(sys.argv) > 1:
        root = os.path.abspath(sys.argv[1])

    rows: list[tuple[str, list[str]]] = []
    for dirpath, _, files in os.walk(root):
        if "meta.xml" not in files:
            continue
        mp = os.path.join(dirpath, "meta.xml")
        rname = os.path.basename(dirpath)
        ex = list_exports(mp)
        if ex:
            rows.append((rname, ex))

    rows.sort(key=lambda x: (-len(x[1]), x[0].lower()))
    total = sum(len(e) for _, e in rows)
    print(f"# Resources with exports: {len(rows)}")
    print(f"# Total export declarations: {total}\n")
    for name, ex in rows:
        head = ", ".join(ex[:20])
        if len(ex) > 20:
            head += f" … (+{len(ex) - 20})"
        print(f"{name}\t{len(ex)}\t{head}")


if __name__ == "__main__":
    main()
