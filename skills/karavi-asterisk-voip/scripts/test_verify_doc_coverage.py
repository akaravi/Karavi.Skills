import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
VERIFY_PATH = SCRIPT_DIR / "verify-doc-coverage.py"


class VerifyDocCoverageTests(unittest.TestCase):
    def test_missing_domain_and_reference_are_reported(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir) / "skill"
            refs = root / "references"
            refs.mkdir(parents=True)
            (root / "SKILL.md").write_text(
                "---\nname: karavi-test\ndescription: Use when testing.\n---\n",
                encoding="utf-8",
            )
            (refs / "present.md").write_text(
                "# Present\n\nVersion: 22\nSecurity\nVerification\n"
                "Primary references\nhttps://docs.asterisk.org/\n",
                encoding="utf-8",
            )
            matrix = refs / "coverage-matrix.md"
            matrix.write_text(
                "| domain | reference | officialSources | canonicalVersion | compatibilityVersions | lastReviewedUtc | status |\n"
                "|---|---|---|---|---|---|---|\n"
                "| Fundamentals | present.md | https://docs.asterisk.org/ | 22 | 20,23 | 2026-09-24 | covered |\n"
                "| Missing Domain | missing.md | https://docs.asterisk.org/ | 22 | 20,23 | 2026-09-24 | covered |\n",
                encoding="utf-8",
            )
            result = subprocess.run(
                [sys.executable, str(VERIFY_PATH), "--skill", str(root), "--matrix", str(matrix)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("required domain missing", result.stdout + result.stderr)
            self.assertIn("reference file missing", result.stdout + result.stderr)

    def test_all_reference_files_have_required_sections(self):
        skill_root = SCRIPT_DIR.parent
        references = sorted(
            reference
            for reference in (skill_root / "references").glob("*.md")
            if reference.name != "coverage-matrix.md"
        )
        required = ("version", "security", "verification", "primary references")
        missing = []
        for reference in references:
            text = reference.read_text(encoding="utf-8").lower()
            for heading in required:
                if f"## {heading}" not in text:
                    missing.append(f"{reference.name}: {heading}")
        self.assertEqual([], missing, "missing required sections: " + ", ".join(missing))

    def test_router_relative_links_exist_and_skill_stays_small(self):
        skill_root = SCRIPT_DIR.parent
        skill_text = (skill_root / "SKILL.md").read_text(encoding="utf-8")
        self.assertLess(len(skill_text.splitlines()), 500)
        self.assertIn("description: Use when", skill_text)
        import re

        links = re.findall(r"\]\((references/[^)]+)\)", skill_text)
        self.assertGreaterEqual(len(links), 11)
        for link in links:
            self.assertTrue((skill_root / link).is_file(), link)


if __name__ == "__main__":
    unittest.main()
