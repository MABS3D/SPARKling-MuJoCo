#!/usr/bin/env python3
"""Summarise gnatprove results from the per-unit .spark files.

  python tools/prove_report.py            -> one line per unit: proved / unproved counts
  python tools/prove_report.py -v         -> also list every unproved check

gnatprove writes obj/<mode>/gnatprove/<unit>.spark (JSON) after analysing a
unit; this reads them so that proof status is visible even when the run was
driven through tools/guarded.ps1, whose log only holds the watchdog lines.
"""
from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
GNATPROVE_DIR = ROOT / "obj" / "development" / "gnatprove"


def main(argv: list[str]) -> int:
    verbose = "-v" in argv
    files = sorted(GNATPROVE_DIR.glob("*.spark"))
    if not files:
        print(f"no .spark files under {GNATPROVE_DIR}")
        return 1
    total_ok = total_bad = 0
    for f in files:
        data = json.loads(f.read_text(encoding="utf-8", errors="replace"))
        ok = bad = 0
        unproved = []
        for section in ("flow", "proof"):
            for entry in data.get(section, []):
                sev = entry.get("severity", "")
                if sev == "info":
                    ok += 1
                else:
                    bad += 1
                    unproved.append(entry)
        total_ok += ok
        total_bad += bad
        print(f"{f.stem:<28} proved={ok:6}  unproved={bad:4}")
        if verbose:
            for e in unproved:
                print(f"    {e.get('file')}:{e.get('line')}:{e.get('col')} {e.get('rule')} {e.get('severity')}: {e.get('msg', '')}")
    print(f"{'TOTAL':<28} proved={total_ok:6}  unproved={total_bad:4}")
    return 0 if total_bad == 0 else 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
