"""Prove a single coupled-FLEX minimum on a checked immutable engine snapshot."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
SCOPES = {
    "Prefix_Count": ("mj-flex_collisions-selection", ".ads", "flex-state-integration", "flex_state.gpr"),
    "Compact": ("mj-flex_collisions-selection", ".adb", "flex-state-integration", "flex_state.gpr"),
    "Bending_Update": ("mj-flex_elastic_kernels-coupled", ".adb", "flex-elasticity-integration", "flex.gpr"),
    "Add_Scaled": ("mj-constraint_solvers-cone_kernels", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Fold_Value": ("mj-constraint_solvers-cone_kernels", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Unfold_Fold": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Fold_Column": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Update": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Scale": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Scaled": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_From_Scaled": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Source": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Ordered_Prefix": ("mj-constraint_solvers-cone_kernels", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Unchanged": ("mj-constraint_solvers-cone_kernels", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Row": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Columns_Ordered": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Separate_Column": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Prefix": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Element": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Prefix_Progress": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Frame_Transitive": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Row_Progress": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Gram_Row_Frame": ("mj-constraint_solvers-cone_kernels", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Set_Offset": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Build_Offsets": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Slot": ("mj-constraint_solvers-packed_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Pack_Row": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Offsets_Ordered": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Prior_Rows": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Pack": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Expand": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Ordered": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Separate_Column": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Bound_Monotone": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Set_Scratch": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Packed_Update_Row": ("mj-constraint_solvers-packed_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Update": ("mj-constraint_solvers-sparse_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scale": ("mj-constraint_solvers-sparse_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scratch_Bound": ("mj-constraint_solvers-sparse_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Headroom_Term": ("mj-constraint_solvers-sparse_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Headroom_Update": ("mj-constraint_solvers-sparse_cholesky", ".ads", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Bound_Monotone": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scratch_Element": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Row_Headroom": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Update_Row": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Prepare_Row": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Store_Offdiagonal": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Store_Row": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scatter_Prefix": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scatter_Row": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Scatter_Element": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Columns_Ordered": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Separate_Column": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Store_Element": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Row_Frame_Transitive": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Clear_Row": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Diagonal_Progress": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Factor": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
    "Backsolve": ("mj-constraint_solvers-sparse_cholesky", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--engine", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--subprogram", choices=SCOPES, required=True)
    parser.add_argument("--proof-timeout", type=int, default=3)
    args = parser.parse_args()
    assert args.proof_timeout in range(1, 31)
    runner_hash = digest(Path(__file__))
    guard_hash = digest(ROOT / "tools/guarded.py")
    args.out.mkdir(parents=True, exist_ok=False)
    engine = args.engine.resolve()
    source = engine / "source"
    manifest_path = engine / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    assert manifest["reference"] == "3.15.0"

    def matches():
        return all(digest(source / name) == value for name, value in manifest["sources"].items())

    assert matches(), "Frozen engine differs"
    unit, suffix, folder, project = SCOPES[args.subprogram]
    path = next(source.rglob(unit + suffix))
    subprogram = args.subprogram.removeprefix("Packed_")
    positions = [i for i, line in enumerate(path.read_text().splitlines(), 1)
                 if re.match(r"\s*(?:procedure|function) " + subprogram + r"\b", line)]
    assert len(positions) == 1
    line = positions[0]
    build = args.out.resolve() / "build"
    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild", "gnatprove")
                             for path in (toolchain / name).glob("*/bin")) + ":" + env["PATH"]
    env.update(FLEX_STATE_BUILD_ROOT=str(build), FLEX_BUILD_ROOT=str(build),
               FLEX_STATE_MODE="validation", FLEX_MODE="validation")
    command = ["gnatprove", "-P", str(source / "experimental" / folder / project),
               "-u", unit + ".adb", "-j1", "--report=all", "--checks-as-errors=on",
               "--warnings=continue", "--no-inlining", "--mode=prove",
               "--prover=cvc5,z3,altergo", "--timeout=" + str(args.proof_timeout), "--memlimit=650",
               "--steps=0", "--proof=per_check", "--counterexamples=off",
               "--limit-subp=" + unit + suffix + ":" + str(line)]
    log = args.out / "proof.log"
    start = time.monotonic()
    with log.open("w") as stream:
        run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "2500",
                              "--timeout", "240", "--", *command], cwd=source, env=env,
                             stdout=stream, stderr=subprocess.STDOUT)
    result = dict(reference=manifest["reference"], subprogram=args.subprogram,
                  command=command, exit=run.returncode, seconds=time.monotonic()-start,
                  manifest_sha256=digest(manifest_path), runner_sha256=runner_hash,
                  guard_sha256=guard_hash,
                  runner_source_unchanged=digest(Path(__file__)) == runner_hash,
                  guard_source_unchanged=digest(ROOT / "tools/guarded.py") == guard_hash,
                  log_sha256=digest(log), source_hashes_unchanged=matches(), passed=False)
    reports = list(build.rglob(unit + ".spark"))
    if len(reports) == 1:
        data = json.loads(reports[0].read_text())
        shutil.copyfile(reports[0], args.out / "unit.spark.json")
        selected = [data.get("entities", {}).get(key, {})
                    for key, value in data.get("spark", {}).items() if value == "all"]
        locations = {(unit + suffix, line)}
        if suffix == ".adb":
            spec = path.with_suffix(".ads")
            locations.update((unit + ".ads", i) for i, text in enumerate(spec.read_text().splitlines(), 1)
                             if re.match(r"\s*(?:procedure|function) " + subprogram + r"\b", text))
        entries = [entry for kind in ("proof", "flow", "warn_error") for entry in data.get(kind, [])]
        result.update(checks=sum(e.get("severity") == "info" for e in entries),
                      proof_checks=len(data.get("proof", [])), flow_checks=len(data.get("flow", [])),
                      open=[e for e in entries if e.get("severity") not in ("info", "warning")],
                      warnings=[e for e in entries if e.get("severity") == "warning"],
                      entities=[e.get("name") for e in selected],
                      report_scope_matches=any(e.get("name", "").lower().endswith("." + subprogram.lower())
                          and any((s.get("file"), s.get("line")) in locations for s in e.get("sloc", []))
                          for e in selected),
                      scope_coverage_complete=(all(k in data for k in ("skip_proof", "skip_flow_proof", "pragma_assume"))
                          and not data.get("skip_proof") and not data.get("skip_flow_proof")
                          and not data.get("pragma_assume") and bool(data.get("spark"))
                          and all(v == "all" for v in data["spark"].values())
                          and data.get("progress") == "PROGRESS_PROOF"
                          and data.get("stop_reason") == "STOP_REASON_NONE"))
        result["obligations_closed"] = (run.returncode == 0 and result["source_hashes_unchanged"]
            and result["runner_source_unchanged"] and result["guard_source_unchanged"]
            and result["report_scope_matches"] and result["scope_coverage_complete"]
            and result["proof_checks"] > 0 and not result["open"])
        result["passed"] = result["obligations_closed"] and not result["warnings"]
    else:
        result["report_rejected"] = "Expected exactly one fresh scoped report"
    (args.out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: result.get(k) for k in ("subprogram", "exit", "checks", "obligations_closed", "passed")}))
    # Keep warnings visible in the receipt. They do not turn proved checks
    # into open obligations; `passed` additionally records a warning-free run.
    raise SystemExit(not result.get("obligations_closed", False))


if __name__ == "__main__":
    main()
