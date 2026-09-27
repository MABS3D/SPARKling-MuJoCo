"""Regression: --limit-line hid a fatal flow error that blocked every VC.

The fixture is the structured flow output of the recorded failed Forces_Phase
line-127 invocation, reduced to the diagnostic data (2026-09-25).
"""
import json
from pathlib import Path
import sys
import unittest
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1]/"tools"))
from prove_fragments import diagnostic_messages

class HiddenFlowError(unittest.TestCase):
    def test_hidden_error_and_uninitialized_diagnostics_survive(self):
        structured = json.loads((HERE/"hidden_flow_error.json").read_text())
        rows = diagnostic_messages("", structured)
        self.assertEqual(sum(r["severity"] == "error" for r in rows), 1)
        self.assertTrue(any("subtype constraint cannot depend" in r["text"] for r in rows))
        self.assertTrue(any("might not be initialized" in r["text"] for r in rows))
        self.assertFalse(any(r["severity"] == "info" for r in rows))

    def test_visible_copy_does_not_double_count_hidden_error(self):
        structured = json.loads((HERE/"hidden_flow_error.json").read_text())
        stdout = 'mj-data-forces_phase.adb:143:51: error: subtype constraint cannot depend on variable input "D"'
        rows = diagnostic_messages(stdout, structured)
        self.assertEqual(sum(r["severity"] == "error" for r in rows), 1)

if __name__ == "__main__":
    unittest.main()
