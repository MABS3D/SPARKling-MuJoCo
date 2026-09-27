import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location(
    "compare_blas", Path(__file__).resolve().parents[1] / "tools/compare_blas.py")
COMPARE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(COMPARE)


class BlasComparisonTests(unittest.TestCase):
    def setUp(self):
        self.rows = [[1, 0, 0, 0, 1, 0, 1]]
        self.reference = "1 1 0 1 -1 0 1 0 0 0\n"

    def test_matching_outputs_pass(self):
        self.assertEqual(COMPARE.compare(self.rows, self.reference, self.reference), 10)

    def test_missing_case_fails(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, "", self.reference)

    def test_wrong_dot_product_fails(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, "1 1 0 1 -1 0 1 0 0 1\n", self.reference)

    def test_non_finite_output_fails(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, "nan 1 0 1 -1 0 1 0 0 0\n", self.reference)


if __name__ == "__main__":
    unittest.main()
