"""Regression checks for the exact matrix differential gate."""
import importlib.util
from pathlib import Path
import unittest
SPEC=importlib.util.spec_from_file_location("matrix_comparison",Path(__file__).resolve().parents[1]/"tools/compare_matrices.py")
M=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(M)
class MatrixComparisonTests(unittest.TestCase):
    def setUp(self):
        self.row=next(r for r in M.cases() if r[:3]==(3,3,3))
        self.n=sum(n for _,n in M.layout(self.row))
        self.zero=" ".join(["0"]*self.n)+"\n"
    def test_equal(self):
        self.assertEqual(M.compare([self.row],self.zero,self.zero),self.n)
    def test_reject_missing(self):
        with self.assertRaises(ValueError): M.compare([self.row],"",self.zero)
    def test_reject_short(self):
        with self.assertRaises(ValueError): M.compare([self.row],"0\n",self.zero)
    def test_reject_small_difference(self):
        actual=self.zero.replace("0","1e-300",1)
        with self.assertRaises(ValueError): M.compare([self.row],actual,self.zero)
    def test_reject_nonfinite(self):
        for value in ["nan","inf","-inf"]:
            with self.subTest(value=value),self.assertRaises(ValueError):
                M.compare([self.row],self.zero.replace("0",value,1),self.zero)
    def test_all_matrix_operations_covered(self):
        names={name for row in M.cases() for name,n in M.layout(row) if n}
        self.assertEqual(len(names),20)
    def test_corpus_has_null_rectangular_and_square(self):
        shapes={(r[0],r[1],r[2]) for r in M.cases()}
        self.assertTrue({(0,0,0),(0,3,2),(3,0,2),(2,3,5),(3,3,3)}<=shapes)
    def test_deterministic_serialization(self):
        self.assertEqual(M.serialize(M.cases()),M.serialize(M.cases()))
        self.assertEqual(len(M.serialize(M.cases()).splitlines()),len(M.cases()))
if __name__=="__main__": unittest.main()
