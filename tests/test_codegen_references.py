"""Every C reference row must be represented, including wide size expressions."""
from pathlib import Path
import importlib.util
import re
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("sparkling_reference_codegen", ROOT / "tools/gen.py")
GEN = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = GEN
SPEC.loader.exec_module(GEN)


def table(rows):
    return "#define MJMODEL_REFERENCES \\\n" + " \\\n".join(rows) + "\n\n#define X(adrarray, nadrs, ntarget, numarray) {}\n"


class ReferenceGenerationTests(unittest.TestCase):
    def test_multiplied_target_is_not_silently_omitted(self):
        rows = GEN.parse_reference_table(table([
            "X(flex_vertedgeadr, nflexvert, nflexedge*2, m->flex_vertedgenum)",
            "X(flex_vertedge, nflexedge*2, nflexedge, 0)",
            "X(tex_contenttypeadr, ntex, npaths, 0)",
        ]))
        self.assertEqual(rows, [
            ("flex_vertedgeadr", "nflexedge*2", "flex_vertedgenum"),
            ("flex_vertedge", "nflexedge", None),
            ("tex_contenttypeadr", "npaths", None),
        ])

    def test_literal_whitespace_and_comments(self):
        self.assertEqual(GEN.parse_reference_table(table([
            "X(flex_vertedgeadr, nflexvert, nflexedge * 2, m->flex_vertedgenum) // row",
            "/* harmless comment */ X(body_parentid, nbody, nbody, 0)",
        ])), [("flex_vertedgeadr", "nflexedge*2", "flex_vertedgenum"),
              ("body_parentid", "nbody", None)])

    def test_unknown_row_or_expression_rejects_table(self):
        for row in ("X(a, na, target + 1, 0)", "X(a, na + 1, target, 0)",
                    "X(a, na, target, arbitrary_call())", "X(a, na, target)",
                    "X(a, na, target, 0) trailing_garbage"):
            with self.subTest(row=row):
                with self.assertRaises(ValueError):
                    GEN.parse_reference_table(table(["X(b, nb, nb, 0)", row]))

    def test_wide_target_uses_int64_before_multiply(self):
        self.assertEqual(GEN.reference_target_expression("nflexedge*2"),
                         ("Int64 (M.S.Nflexedge) * 2", True))
        self.assertEqual(GEN.reference_target_expression("nv"), ("M.S.Nv", False))
        with self.assertRaises(ValueError):
            GEN.reference_target_expression("nflexedge*9223372036854775807")

    def test_actual_reference_has_no_unparsed_x_rows(self):
        text = GEN.ENGINE_IO.read_text()
        start = text.index("#define MJMODEL_REFERENCES")
        end = text.index("#define X(adrarray", start)
        named_rows = re.findall(r"^\s*X\(\s*(\w+)\s*,", text[start:end], re.MULTILINE)
        rows = GEN.parse_reference_table(text)
        self.assertGreater(len(named_rows), 0)
        self.assertEqual([row[0] for row in rows], named_rows)
        # The 3.17 regression specifically has an expression in the target
        # column; counting more than an arbitrary threshold missed that row.
        if "flex_vertedgeadr" in named_rows:
            self.assertIn(("flex_vertedgeadr", "nflexedge*2", "flex_vertedgenum"), rows)


if __name__ == "__main__":
    unittest.main()
