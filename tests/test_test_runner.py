"""The test gate must reject empty, missing and stale executable sets."""
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("test_runner", Path(__file__).with_name("run.py"))
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


class TestRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_no_mains_rejected(self):
        p = self.root / "tests.gpr"
        p.write_text("project Tests is end Tests;")
        with self.assertRaises(ValueError):
            RUNNER.declared_tests(p)

    def test_duplicate_mains_rejected(self):
        p = self.root / "tests.gpr"
        p.write_text('for Main use ("test_one.adb", "test_one.adb");')
        with self.assertRaises(ValueError):
            RUNNER.declared_tests(p)

    def test_comment_is_not_a_test(self):
        p = self.root / "tests.gpr"
        p.write_text('-- for Main use ("test_old.adb");\nfor Main use ("test_new.adb");')
        self.assertEqual(RUNNER.declared_tests(p), ["test_new"])

    def test_unrecognized_main_is_not_silently_omitted(self):
        p = self.root / "tests.gpr"
        p.write_text('for Main use ("test_one.adb", "unexpected.cpp");')
        with self.assertRaises(ValueError):
            RUNNER.declared_tests(p)

    def test_empty_list_rejected(self):
        with self.assertRaises(ValueError):
            RUNNER.checked_executables(self.root, [], 0, ".exe")

    def test_missing_executable_rejected(self):
        with self.assertRaises(ValueError):
            RUNNER.checked_executables(self.root, ["test_one"], 0, ".exe")

    def test_stale_executable_rejected(self):
        p = self.root / "test_one.exe"
        p.touch()
        os.utime(p, ns=(100, 100))
        with self.assertRaises(ValueError):
            RUNNER.checked_executables(self.root, ["test_one"], 101, ".exe")

    def test_only_declared_fresh_tests_selected(self):
        p = self.root / "test_one.exe"
        p.touch()
        (self.root / "test_obsolete.exe").touch()
        self.assertEqual(RUNNER.checked_executables(self.root, ["test_one"], 0, ".exe"), [p])


if __name__ == "__main__":
    unittest.main()
