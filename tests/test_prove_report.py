"""Regression checks for false-success cases in the proof gate."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location(
    "prove_report", Path(__file__).resolve().parents[1] / "tools/prove_report.py")
REPORT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(REPORT)


class ProofReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        old_root = REPORT.ROOT
        REPORT.ROOT = self.root
        self.addCleanup(setattr, REPORT, "ROOT", old_root)
        source = self.root / "src/subject.ads"
        source.parent.mkdir()
        source.write_text("package Subject is procedure Run; end Subject;")
        (self.root / "sparkling_mujoco.gpr").write_text("project Test is end Test;")
        os.utime(source, (100, 100))
        self.path = self.root / "obj/development/gnatprove/subject.spark"
        self.path.parent.mkdir(parents=True)
        self.data = {
            "progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
            "proof": [{"severity": "info"}], "flow": [], "warn_error": [],
            "skip_proof": [], "skip_flow_proof": [], "pragma_assume": [],
            "entities": {"1": {"name": "Subject.Run"}}, "spark": {"1": "all"},
        }

    def run_report(self, *args):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = REPORT.main(["--build-root", str(self.root), *args])
        return code, output.getvalue()

    def write_report(self):
        self.path.write_text(json.dumps(self.data))
        REPORT.record_invocation(self.path.parent, self.path.stem, 1000,
                                 REPORT.source_hashes(), ["gnatprove", "-u", self.path.stem + ".ads"])

    def test_complete_report_passes(self):
        self.write_report()
        self.assertEqual(self.run_report()[0], 0)

    def test_missing_unit_fails(self):
        self.assertNotEqual(self.run_report()[0], 0)

    def test_standalone_body_requires_report(self):
        (self.root / "src/extra.adb").write_text(
            "procedure Extra is begin null; end Extra;")
        self.write_report()
        code, output = self.run_report()
        self.assertNotEqual(code, 0)
        self.assertIn("extra", output)
        self.assertIn("MISSING", output)

    def test_separate_body_belongs_to_parent(self):
        (self.root / "src/subject-inner.adb").write_text(
            "pragma Assertion_Policy (Pre => Ignore);\n"
            "separate (Subject) procedure Inner is begin null; end Inner;")
        self.data["entities"]["2"] = {"name": "Subject.Inner"}
        self.data["spark"]["2"] = "all"
        self.write_report()
        self.assertEqual(self.run_report()[0], 0)

    def test_stale_report_fails(self):
        self.write_report()
        os.utime(self.path, (99, 99))
        self.assertNotEqual(self.run_report()[0], 0)

    def test_previous_run_fails(self):
        self.write_report()
        self.assertNotEqual(self.run_report("--since", "9999999999")[0], 0)

    def test_flow_only_report_fails(self):
        self.data["progress"] = "PROGRESS_FLOW"
        self.write_report()
        self.assertNotEqual(self.run_report()[0], 0)

    def test_stopped_report_fails(self):
        self.data["stop_reason"] = "STOP_REASON_ERROR"
        self.write_report()
        self.assertNotEqual(self.run_report()[0], 0)

    def test_skipped_proof_fails(self):
        self.data["skip_proof"] = ["Run"]
        self.write_report()
        self.assertNotEqual(self.run_report()[0], 0)

    def test_assumed_property_fails(self):
        self.data["pragma_assume"] = [{"file": "subject.ads", "line": 1}]
        self.write_report()
        code, output = self.run_report()
        self.assertNotEqual(code, 0)
        self.assertIn("ASSUMED", output)

    def test_unproved_check_and_message(self):
        self.data["proof"] = [{
            "severity": "medium", "rule": "VC_RANGE_CHECK",
            "message": {"text": "range check might fail"},
        }]
        self.write_report()
        code, output = self.run_report("-v")
        self.assertNotEqual(code, 0)
        self.assertIn("range check might fail", output)

    def test_warning_is_separate_from_unproved(self):
        self.data["flow"] = [{"severity": "warning", "rule": "INEFFECTIVE"}]
        self.write_report()
        code, output = self.run_report()
        self.assertEqual(code, 0)
        self.assertIn("TOTAL proved=1 unproved=0 warnings=1", output)

    def test_frontend_info_is_not_a_proved_check(self):
        self.data["warn_error"] = [{
            "severity": "info", "rule": "error",
            "message": {"text": "cannot unroll loop (too many loop iterations)"},
        }]
        self.write_report()
        code, output = self.run_report("-v")
        self.assertEqual(code, 0)
        self.assertIn("TOTAL proved=1 unproved=0 warnings=0", output)
        self.assertIn("cannot unroll loop", output)

    def test_malformed_report_fails(self):
        self.path.write_text("{")
        self.assertNotEqual(self.run_report()[0], 0)

    def test_non_object_report_fails(self):
        self.path.write_text("[]")
        self.assertNotEqual(self.run_report()[0], 0)

    def test_missing_report_section_fails(self):
        del self.data["proof"]
        self.write_report()
        self.assertNotEqual(self.run_report()[0], 0)

    def test_limited_leaf_proof_fails_coverage(self):
        (self.root / "src/subject.ads").write_text(
            "package Subject is procedure Run; procedure Uncalled; end Subject;")
        self.write_report()
        code, output = self.run_report("-v")
        self.assertNotEqual(code, 0)
        self.assertIn("PARTIAL", output)
        self.assertIn("uncalled", output)

    def test_report_without_invocation_fails_even_with_all_entities(self):
        self.path.write_text(json.dumps(self.data))
        code, output = self.run_report()
        self.assertNotEqual(code, 0)
        self.assertIn("UNATTESTED", output)

    def test_line_limited_command_cannot_certify_complete_entities(self):
        self.write_report()
        REPORT.record_invocation(self.path.parent, "subject", 1000,
                                 REPORT.source_hashes(), ["gnatprove", "-u", "subject.ads",
                                                         "--limit-region=subject.ads:1:1"])
        self.assertNotEqual(self.run_report()[0], 0)

    def test_replaced_report_does_not_match_invocation(self):
        self.write_report()
        self.path.write_text(self.path.read_text() + "\n")
        self.assertNotEqual(self.run_report()[0], 0)

    def test_source_change_with_preserved_timestamp_invalidates_invocation(self):
        self.write_report()
        source = self.root / "src/subject.ads"
        stamp = source.stat().st_mtime_ns
        source.write_text(source.read_text() + "\n-- changed\n")
        os.utime(source, ns=(stamp, stamp))
        self.assertNotEqual(self.run_report()[0], 0)

    def test_trusted_conversion_instance_needs_no_body_report(self):
        (self.root / "src/subject.ads").unlink()
        (self.root / "src/mj-bytes.ads").write_text(
            "package MJ.Bytes is function Bits_To_Real return Integer; end MJ.Bytes;")
        (self.root / "src/mj-bytes.adb").write_text(
            "package body MJ.Bytes is function Bits_To_Real return Integer is pragma SPARK_Mode (Off); "
            "function Conv is new Ada.Unchecked_Conversion (Integer, Integer); "
            "begin return 0; end Bits_To_Real; end MJ.Bytes;")
        self.path = self.path.with_name("mj-bytes.spark")
        self.data["entities"]["1"]["name"] = "MJ.Bytes.Bits_To_Real"
        self.data["spark"]["1"] = "spec"
        self.write_report()
        self.assertEqual(self.run_report()[0], 0)

    def test_untrusted_spec_only_body_fails(self):
        self.data["spark"]["1"] = "spec"
        self.write_report()
        code, output = self.run_report()
        self.assertNotEqual(code, 0)
        self.assertIn("OUTSIDE_SPARK", output)

    def test_unknown_spark_mode_fails(self):
        self.data["spark"]["1"] = "none"
        self.write_report()
        self.assertNotEqual(self.run_report()[0], 0)

    def test_trusted_name_in_wrong_unit_fails(self):
        (self.root / "src/subject.ads").write_text(
            "package Subject is function Bits_To_Real return Integer; end Subject;")
        self.data["entities"]["1"]["name"] = "MJ.Bytes.Bits_To_Real"
        self.data["spark"]["1"] = "spec"
        self.write_report()
        code, output = self.run_report()
        self.assertNotEqual(code, 0)
        self.assertIn("OUTSIDE_SPARK", output)


if __name__ == "__main__":
    unittest.main()
