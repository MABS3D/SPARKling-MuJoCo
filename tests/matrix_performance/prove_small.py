#!/usr/bin/env python3
"""Diagnose transpose subprograms separately; this is not a whole-unit receipt."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent


def hashes():
    files = [*ROOT.glob("src/**/*.ad?"), HERE / "proof.gpr"]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--match", default="", help="substring of the subprogram name")
    parser.add_argument("--build-root", type=Path, default=HERE / "build/minimal")
    args = parser.parse_args()
    targets = []
    for line, text in enumerate((ROOT / "src/mj-matrices.adb").read_text().splitlines(), 1):
        match = re.match(r"   procedure (Transpose\w*) \(", text)
        if match and args.match in match[1]:
            targets.append((match[1], line))
    if not targets:
        parser.error("no matching transpose subprogram")
    build = args.build_root.resolve()
    build.mkdir(parents=True, exist_ok=True)
    original = hashes()
    result = {"diagnostic_only": True, "complete": False,
              "source_sha256": original, "targets": []}
    for name, line in targets:
        target = build / name
        reports = target / "obj/gnatprove"
        # Keep prover sessions, but do not let an older report supply success.
        for report in reports.glob("*.spark"):
            report.unlink()
        command = ["gnatprove", "-P", str(HERE / "proof.gpr"),
                   "-XMATRIX_PROOF_ROOT=" + str(target), "-u", "mj-matrices.adb",
                   "--limit-subp=mj-matrices.adb:" + str(line), "--level=2",
                   "--proof=per_check", "--timeout=10", "-j2", "--report=all",
                   "--checks-as-errors=on", "--warnings=continue", "--counterexamples=off"]
        with (build / (name + ".log")).open("w") as log:
            run = subprocess.run([sys.executable, str(ROOT / "tools/guarded.py"),
                                  "--cap-mb", "4000", "--timeout", "180", "--", *command],
                                 cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
        result["targets"].append({"name": name, "line": line,
                                  "command": command, "exit_code": run.returncode})
        print(name, run.returncode, flush=True)
        (build / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
        if run.returncode:
            return run.returncode
        if hashes() != original:
            raise RuntimeError("sources changed during diagnostics")
    result["complete"] = True
    (build / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
