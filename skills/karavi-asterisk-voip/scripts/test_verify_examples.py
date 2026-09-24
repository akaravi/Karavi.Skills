import subprocess
import sys
import unittest
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
VERIFY_PATH = SCRIPT_DIR / "verify-examples.py"


class VerifyExamplesTests(unittest.TestCase):
    def test_skill_examples_pass(self):
        result = subprocess.run(
            [sys.executable, str(VERIFY_PATH), "--skill", str(SCRIPT_DIR.parent)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
