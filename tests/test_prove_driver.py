"""Exercise the whole-library gate with simulated compiler reports."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

TOOLS = Path(__file__).resolve().parents[1] / "tools"
sys.path.insert(0, str(TOOLS))
try:
    SPEC = importlib.util.spec_from_file_location("prove_driver", TOOLS / "prove.py")
    DRIVER = importlib.util.module_from_spec(SPEC)
    SPEC.loader.exec_module(DRIVER)
finally:
    sys.path.remove(str(TOOLS))


class ProveDriverTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "src").mkdir()
        (self.root / "docs").mkdir()
        self.source = self.root / "src/subject.ads"
        self.source.write_text("package Subject is procedure Run; end Subject;")
        (self.root / "sparkling_mujoco.gpr").write_text("project Test is end Test;")
        (self.root / "docs/proof-justifications.md").write_text("")
        self.report = self.root / "obj/development/gnatprove/subject.spark"

    def write_report(self, *_args, **_kwargs):
        self.report.parent.mkdir(parents=True, exist_ok=True)
        self.report.write_text(json.dumps({
            "progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
            "proof": [{"severity": "info"}], "flow": [], "warn_error": [],
            "skip_proof": [], "skip_flow_proof": [], "pragma_assume": [],
            "entities": {"1": {"name": "Subject.Run"}}, "spark": {"1": "all"},
        }))
        # Simulated compilation is shorter than the filesystem's clock tick.
        stamp = time.time_ns()
        os.utime(self.report, ns=(stamp, stamp))
        return subprocess.CompletedProcess([], 0)

    def run_driver(self, compiler, *extra):
        output = io.StringIO()
        with (patch.object(DRIVER, "ROOT", self.root),
              patch.object(DRIVER.prove_report, "ROOT", self.root),
              patch.object(sys, "argv", ["prove.py", *extra]),
              patch.dict(os.environ, {"SPARKLING_BUILD_ROOT": str(self.root)}),
              patch.object(DRIVER.subprocess, "run", side_effect=compiler),
              contextlib.redirect_stdout(output),
              contextlib.redirect_stderr(output)):
            result = DRIVER.main()
        self.output = output.getvalue()
        return result

    def test_fresh_complete_run_passes(self):
        self.assertEqual(self.run_driver(self.write_report), 0, self.output)

    def test_zero_child_exit_without_report_fails(self):
        self.assertEqual(self.run_driver(lambda *a, **kw: subprocess.CompletedProcess([], 0)), 1)

    def test_previous_failure_is_archived_before_a_fresh_run(self):
        self.report.parent.mkdir(parents=True)
        old = '{"proof": [{"severity": "medium"}]}'
        self.report.write_text(old)
        def compiler(*args, **kwargs):
            self.assertFalse(self.report.exists(), "old failure must not affect GNATprove's exit status")
            return self.write_report()
        self.assertEqual(self.run_driver(compiler), 0, self.output)
        saved = list((self.root / "proof-history").glob("*/subject.spark"))
        self.assertEqual(len(saved), 1)
        self.assertEqual(saved[0].read_text(), old)

    def test_stale_report_after_child_success_fails(self):
        def compiler(*args, **kwargs):
            result = self.write_report()
            os.utime(self.report, (1, 1))
            return result
        self.assertEqual(self.run_driver(compiler), 1)

    def test_source_change_with_preserved_timestamp_fails(self):
        def compiler(*args, **kwargs):
            stamp = self.source.stat().st_mtime_ns
            self.source.write_text(self.source.read_text() + "\n-- changed during proof\n")
            os.utime(self.source, ns=(stamp, stamp))
            return self.write_report()
        self.assertEqual(self.run_driver(compiler), 1)

    def test_ledger_mismatch_prevents_launch(self):
        (self.root / "docs/proof-justifications.md").write_text("- unmatched annotation\n")
        def compiler(*args, **kwargs):
            self.fail("compiler must not run before ledger validation")
        self.assertEqual(self.run_driver(compiler), 1)

    def test_line_limited_proof_is_rejected_before_launch(self):
        def compiler(*args, **kwargs):
            self.fail("a partial proof must not receive a complete-unit receipt")
        with self.assertRaises(SystemExit) as error:
            self.run_driver(compiler, "--", "--limit-region=subject.ads:1:1")
        self.assertEqual(error.exception.code, 2)

    def test_selected_unit_is_explicitly_partial_library_scope(self):
        (self.root / "src/extra.ads").write_text("package Extra is procedure Run; end Extra;")
        self.assertEqual(self.run_driver(self.write_report, "--unit", "subject"), 0, self.output)
        self.assertIn("scope=selected units", self.output)


if __name__ == "__main__":
    unittest.main()
