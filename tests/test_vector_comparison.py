import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location(
    "compare_vectors", Path(__file__).resolve().parents[1] / "tools/compare_vectors.py")
COMPARE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(COMPARE)


class VectorComparisonTests(unittest.TestCase):
    def setUp(self):
        self.rows = [(7, [3.0], [4.0], 2.0)]
        self.values = [0, 2, 3, 6, 7, -1, 7, -1, 11, 11, 3, 3, 12, 3, 1, 3]
        self.reference = self.text(self.values)

    @staticmethod
    def text(values):
        return " ".join(map(str, values)) + "\n"

    def test_matching_outputs(self):
        self.assertEqual(COMPARE.compare(self.rows, self.reference, self.reference), 16)

    def test_incomplete_case(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, "", self.reference)

    def test_missing_component(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, self.text(self.values[:-1]), self.reference)

    def test_extra_component(self):
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, self.text(self.values + [0]), self.reference)

    def test_wrong_reductions_and_normalization(self):
        for column in range(10, 16):
            values = self.values[:]
            values[column] += 1
            with self.subTest(column=column), self.assertRaises(ValueError):
                COMPARE.compare(self.rows, self.text(values), self.reference)

    def test_copy_requires_exact_equality(self):
        values = self.values[:]
        values[2] = 3.0000000000000004
        with self.assertRaises(ValueError):
            COMPARE.compare(self.rows, self.text(values), self.reference)

    def test_nonfinite_rejected_on_either_side(self):
        for bad in [float("nan"), float("inf"), -float("inf")]:
            values = self.values[:]
            values[13] = bad
            for outputs in [(self.text(values), self.reference), (self.reference, self.text(values))]:
                with self.subTest(bad=bad), self.assertRaises(ValueError):
                    COMPARE.compare(self.rows, *outputs)

    def test_fallback_requires_exact_unit_vector(self):
        rows = [(0, [0.0], [1.0], 1.0)]
        values = [0, 1, 0, 0, 1, -1, 1, -1, 1, 1, 0, 0, 0, 0, 1, 0]
        changed = values[:]
        changed[14] = 0.9999999999999999
        with self.assertRaises(ValueError):
            COMPARE.compare(rows, self.text(changed), self.text(values))


if __name__ == "__main__":
    unittest.main()
