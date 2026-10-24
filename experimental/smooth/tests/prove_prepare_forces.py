"""Prove the private force-preparation stage on an immutable runtime snapshot.

This composes existing phase contracts; it does not prove those phase bodies or
claim global dynamics Gold. Run serially with the project proof watchdog.
"""
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
SCOPES = {"Unpublished_Forces":
          ("mj-data-pipeline", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
          "Ready_Allocation":
          ("mj-data-pipeline", ".adb", "flex-elasticity-integration", "flex_constrained.gpr"),
          "Prepare_Forces_Ready":
          ("mj-data-pipeline", ".adb", "flex-elasticity-integration", "flex_constrained.gpr")}

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--engine", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--subprogram", choices=SCOPES, required=True)
    parser.add_argument("--analysis", type=Path, help="Share analysis only between minima on this exact frozen manifest")
    parser.add_argument("--resume", type=Path,
                        help="Reuse analysis only from a receipt for this exact immutable engine and scope; require a new scoped report")
    parser.add_argument("--proof-timeout", type=int, default=3)
    args = parser.parse_args()
    assert args.proof_timeout in range(1, 31)
    assert not (args.analysis and args.resume), "Choose shared analysis or a resume receipt"
    runner_hash = digest(Path(__file__))
    guard_hash = digest(ROOT / "tools/guarded.py")
    args.out.mkdir(parents=True, exist_ok=False)
    engine = args.engine.resolve()
    source = engine / "source"
    manifest_path = engine / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    assert manifest["reference"] in ("3.14.0", "3.15.0", "3.17.0")

    def matches():
        return all(digest(source / name) == value for name, value in manifest["sources"].items())

    assert matches(), "Frozen engine differs"
    unit, suffix, folder, project = SCOPES[args.subprogram]
    path = next(source.rglob(unit + suffix))
    subprogram = args.subprogram.removeprefix("Packed_").removeprefix("Hessian_")
    positions = [i for i, line in enumerate(path.read_text().splitlines(), 1)
                 if re.match(r"\s*(?:procedure|function) " + subprogram + r"\b", line)]
    assert len(positions) == 1
    line = positions[0]
    build = args.analysis.resolve() if args.analysis else args.out.resolve() / "build"
    resume_record = None
    if args.resume:
        prior_path = args.resume.resolve() / "results.json"
        prior = json.loads(prior_path.read_text())
        assert prior["manifest_sha256"] == digest(manifest_path), "Resume engine differs"
        assert prior["reference"] == manifest["reference"] and prior["subprogram"] == args.subprogram
        assert prior["source_hashes_unchanged"] and prior["guard_source_unchanged"] and prior["runner_source_unchanged"]
        assert prior["guard_sha256"] == guard_hash, "Resume guard differs"
        assert "--timeout=" + str(args.proof_timeout) in prior["command"], "Resume prover timeout differs"
        build = Path(prior.get("analysis_root", args.resume.resolve() / "build")).resolve()
        assert build == (args.resume.resolve() / "build").resolve(), "Resume the original analysis receipt"
        assert build.is_dir(), "Resume analysis missing"
        resume_record = dict(receipt=str(prior_path), receipt_sha256=digest(prior_path),
                             previous_exit=prior["exit"])
    if not args.resume:
        build.mkdir(parents=True, exist_ok=True)
        stamp = build / "engine-manifest.sha256"
        if stamp.exists():
            assert stamp.read_text().strip() == digest(manifest_path), "Shared analysis source mismatch"
        else:
            assert not any(build.iterdir()), "Unknown existing analysis"
            stamp.write_text(digest(manifest_path) + "\n")
    # No earlier report may stand in for this invocation. GNATprove validates
    # proof-cache task identities, and must emit a fresh complete scoped report.
    for report in build.rglob(unit + ".spark"):
        report.unlink()
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
    if args.resume:
        assert command == prior["command"], "Resume proof command differs"
    log = args.out / "proof.log"
    start = time.monotonic()
    with log.open("w") as stream:
        run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "2500",
                              "--timeout", "240", "--", *command], cwd=source, env=env,
                             stdout=stream, stderr=subprocess.STDOUT)
    result = dict(reference=manifest["reference"], subprogram=args.subprogram,
                  analysis_root=str(build), resumed_from=resume_record,
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
