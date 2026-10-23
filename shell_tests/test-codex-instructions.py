#!/usr/bin/env python3
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "bin/codex-instructions"


class InstructionPreflightTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-instructions-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.config = self.root / "config"
        self.config.mkdir()

    def check(self, cwd=None):
        result = subprocess.run([str(SCRIPT), "--cwd", str(cwd or self.repo),
                                 "--config-home", str(self.config)], capture_output=True, text=True)
        return result.returncode, json.loads(result.stdout)

    def git(self, *args):
        return subprocess.run(["git", "-C", str(self.repo), *args], check=True, capture_output=True)

    def test_budget_and_override_precedence_include_global_and_nested_guidance(self):
        self.git("init", "-b", "main")
        (self.config / "AGENTS.md").write_text("global")
        (self.repo / "AGENTS.md").write_text("x" * 33000)
        code, result = self.check()
        self.assertEqual(1, code)
        self.assertIn("instruction_chain_exceeds_budget", result["problems"])
        (self.repo / "AGENTS.override.md").write_text("read current policy")
        nested = self.repo / "lib"
        nested.mkdir()
        (nested / "AGENTS.md").write_text("nested")
        code, result = self.check(nested)
        self.assertEqual(0, code)
        self.assertEqual(["AGENTS.md", "AGENTS.override.md", "AGENTS.md"],
                         [Path(s["path"]).name for s in result["sources"]])
        self.assertEqual(35, result["bytes"])
        (self.config / "config.toml").write_text("project_doc_max_bytes = 20\n")
        self.assertEqual(1, self.check(nested)[0])

    def test_old_instructions_block_without_mutating_the_checkout(self):
        self.git("init", "-b", "main")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        (self.repo / "AGENTS.md").write_text("old rules")
        self.git("add", "AGENTS.md")
        self.git("commit", "-m", "old")
        self.git("branch", "old")
        (self.repo / "AGENTS.md").write_text("current rules")
        self.git("commit", "-am", "new")
        self.git("update-ref", "refs/remotes/origin/main", "HEAD")
        self.git("checkout", "old")
        original = self.git("rev-parse", "HEAD").stdout
        code, result = self.check()
        self.assertEqual(1, code)
        self.assertIn("stale_checkout_instructions", result["problems"])
        self.assertEqual(original, self.git("rev-parse", "HEAD").stdout)
        self.assertEqual(b"", self.git("status", "--porcelain").stdout)

    def test_empty_override_falls_back_and_custom_names_are_checked(self):
        (self.config / "config.toml").write_text('project_doc_fallback_filenames = ["TEAM.md"]\n')
        (self.repo / "AGENTS.override.md").write_text("")
        (self.repo / "TEAM.md").write_text("team rules")
        code, result = self.check()
        self.assertEqual(0, code)
        self.assertEqual("TEAM.md", Path(result["sources"][0]["path"]).name)


if __name__ == "__main__":
    unittest.main()
