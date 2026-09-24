#!/usr/bin/env python3
"""Build a deterministic index from a local Asterisk documentation tree."""

import argparse
import hashlib
import json
import re
from pathlib import Path


HEADING = re.compile(r"^#{1,6}\s+(.+?)\s*$")


def title_for(path: Path) -> str:
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = HEADING.match(line)
        if match:
            return match.group(1).strip().strip("#")
    return path.stem.replace("-", " ").replace("_", " ").title()


def domain_for(relative: Path) -> str:
    parts = relative.parts
    return parts[0] if len(parts) > 1 else "root"


def build_index(source: Path) -> dict:
    if not source.is_dir():
        raise ValueError(f"source is not a directory: {source}")
    files = []
    for path in sorted(source.rglob("*.md")):
        relative = path.relative_to(source)
        data = path.read_bytes()
        files.append(
            {
                "path": relative.as_posix(),
                "title": title_for(path),
                "domain": domain_for(relative),
                "sourceRoot": str(source.resolve()),
                "sha256": hashlib.sha256(data).hexdigest(),
            }
        )
    return {"schemaVersion": "1.0", "sourceRoot": str(source.resolve()), "files": files}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        result = build_index(args.source)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"indexed {len(result['files'])} markdown files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
