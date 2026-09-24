#!/usr/bin/env python3
"""Verify the coverage contract for karavi-asterisk-voip references."""

import argparse
import re
import sys
from pathlib import Path


REQUIRED_DOMAINS = {
    "Fundamentals",
    "Build/Deployment/Operation",
    "Configuration",
    "SIP/PJSIP",
    "RTP/Media",
    "Dialplan/IVR/Queues",
    "AMI/ARI/AGI",
    "Data/Operations",
    "Security",
    "Development/Testing",
    "Version Compatibility",
}
HEADER = re.compile(r"^\|\s*domain\s*\|", re.IGNORECASE)
ROW = re.compile(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*$")
URL = re.compile(r"https://(?:docs\.asterisk\.org|github\.com/asterisk)/")


def matrix_rows(path: Path) -> list[dict[str, str]]:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if HEADER.match(line) or line.lstrip().startswith("|---"):
            continue
        match = ROW.match(line)
        if match:
            values = [value.strip() for value in match.groups()]
            rows.append(dict(zip(("domain", "reference", "officialSources", "canonicalVersion", "compatibilityVersions", "lastReviewedUtc", "status"), values)))
    return rows


def verify(skill: Path, matrix: Path) -> list[str]:
    errors = []
    rows = matrix_rows(matrix)
    by_domain = {row["domain"]: row for row in rows}
    for domain in sorted(REQUIRED_DOMAINS):
        if domain not in by_domain:
            errors.append(f"required domain missing: {domain}")
    for row in rows:
        if row["domain"] not in REQUIRED_DOMAINS:
            errors.append(f"unexpected domain: {row['domain']}")
        references = [item.strip() for item in row["reference"].split(";") if item.strip()]
        for reference_name in references:
            reference = skill / "references" / reference_name
            if not reference.is_file():
                errors.append(f"reference file missing: {reference_name}")
        if not URL.search(row["officialSources"]):
            errors.append(f"official Asterisk source missing: {row['domain']}")
        if not row["canonicalVersion"] or not row["compatibilityVersions"] or not row["lastReviewedUtc"]:
            errors.append(f"version metadata incomplete: {row['domain']}")
        if re.search(r"\b(?:TBD|TODO|FIXME)\b", " ".join(row.values()), re.IGNORECASE):
            errors.append(f"placeholder in coverage row: {row['domain']}")
    skill_file = skill / "SKILL.md"
    if not skill_file.is_file():
        errors.append("SKILL.md missing")
    else:
        text = skill_file.read_text(encoding="utf-8")
        for match in re.finditer(r"\]\((references/[^)]+)\)", text):
            if not (skill / match.group(1)).is_file():
                errors.append(f"router link missing: {match.group(1)}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill", type=Path, required=True)
    parser.add_argument("--matrix", type=Path, required=True)
    args = parser.parse_args()
    try:
        errors = verify(args.skill, args.matrix)
    except (OSError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        print(f"coverage failed: {len(errors)} error(s)")
        return 1
    print(f"coverage passed: {len(REQUIRED_DOMAINS)} required domains verified")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
