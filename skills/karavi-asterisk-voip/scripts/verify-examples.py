#!/usr/bin/env python3
"""Validate the structural contract of Asterisk/Linux examples."""

import argparse
import re
from pathlib import Path

FENCE = re.compile(r"^~~~([a-zA-Z0-9_-]*)\s*$")
ALLOWED = {"bash", "sh", "csharp", "asterisk", "ini", "json", "text"}
REQUIRED = ("## Version", "## Security", "## Primary References", "## Verification")


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    references = root / "references"
    for path in sorted(references.glob("*.md")):
        if path.name == "coverage-matrix.md":
            continue
        text = path.read_text(encoding="utf-8")
        for heading in REQUIRED:
            if heading.lower() not in text.lower():
                errors.append(f"{path.name}: missing {heading}")
        lines = text.splitlines()
        open_fence = None
        for number, line in enumerate(lines, 1):
            match = FENCE.match(line)
            if not match:
                continue
            language = match.group(1).lower()
            if open_fence is None:
                if language not in ALLOWED:
                    errors.append(f"{path.name}:{number}: unsupported fence {language}")
                open_fence = number
            else:
                open_fence = None
        if open_fence is not None:
            errors.append(f"{path.name}:{open_fence}: unclosed code fence")

    linux = references / "linux-asterisk-command-reference.md"
    if not linux.is_file():
        errors.append("linux-asterisk-command-reference.md missing")
    else:
        linux_text = linux.read_text(encoding="utf-8").lower()
        for token in ("asterisk -rx", "systemctl", "journalctl", "ss ", "tcpdump", "pjsip", "rtp", "primary references"):
            if token not in linux_text:
                errors.append(f"linux command reference missing {token}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skill", type=Path, required=True)
    args = parser.parse_args()
    errors = validate(args.skill)
    if errors:
        print("\n".join(f"ERROR: {item}" for item in errors))
        print(f"example validation failed: {len(errors)} error(s)")
        return 1
    print("example validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
