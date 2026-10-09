"""Prove the ordered site geometry minima on an immutable engine closure."""
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


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--engine", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--only", choices=("World_Coordinate", "Point_Column"))
    args = p.parse_args()
    args.out = args.out.resolve()
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.engine.resolve() / "source"
    manifest_path = args.engine.resolve() / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    matches = lambda: all(digest(source / name) == value for name, value in manifest["sources"].items())
    assert matches()
    project = source / "experimental/advanced-step/site_kinematics_proof.gpr"
    unit = "mj-site_kinematics"
    body = source / "experimental/advanced-step/src" / (unit + ".adb")
    spec = body.with_suffix(".ads")
    runner_hash = digest(Path(__file__))
    guard = ROOT / "tools/guarded.py"
    guard_hash = digest(guard)
    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild", "gnatprove")
        for path in (toolchain / name).glob("*/bin")) + ":" + env["PATH"]
    records = []
    for name in ([args.only] if args.only else ["World_Coordinate", "Point_Column"]):
        locations = {(unit + suffix, i) for suffix, path in ((".adb", body), (".ads", spec))
            for i, line in enumerate(path.read_text().splitlines(), 1)
            if re.match(r"\s*function " + name + r"\b", line)}
        line = next(i for file, i in locations if file.endswith(".adb"))
        out = args.out / name
        out.mkdir()
        build = out / "build"
        env["ADVANCED_BUILD_ROOT"] = str(build)
        command = ["gnatprove", "-P", str(project), "-u", unit + ".adb", "-j1",
            "--report=all", "--checks-as-errors=on", "--warnings=continue", "--no-inlining",
            "--mode=prove", "--prover=cvc5,z3,altergo", "--timeout=3", "--memlimit=650",
            "--steps=0", "--proof=per_check", "--counterexamples=off",
            "--limit-subp=" + unit + ".adb:" + str(line)]
        log = out / "proof.log"
        started = time.monotonic()
        with log.open("w") as stream:
            run = subprocess.run(["python3", str(guard), "--cap-mb", "2500",
                "--timeout", "240", "--", *command], cwd=source, env=env,
                stdout=stream, stderr=subprocess.STDOUT)
        result = dict(subprogram=name, command=command, exit=run.returncode,
            seconds=time.monotonic()-started, manifest_sha256=digest(manifest_path),
            runner_sha256=runner_hash, guard_sha256=guard_hash, log_sha256=digest(log),
            source_hashes_unchanged=matches(),
            runner_source_unchanged=digest(Path(__file__)) == runner_hash,
            guard_source_unchanged=digest(guard) == guard_hash, passed=False)
        reports = list(build.rglob(unit + ".spark"))
        if len(reports) == 1:
            data = json.loads(reports[0].read_text())
            shutil.copyfile(reports[0], out / "unit.spark.json")
            entries = [e for kind in ("proof", "flow", "warn_error") for e in data.get(kind, [])]
            selected = [data.get("entities", {}).get(key, {})
                for key, value in data.get("spark", {}).items() if value == "all"]
            result.update(checks=sum(e.get("severity") == "info" for e in entries),
                proof_checks=len(data.get("proof", [])),
                open=[e for e in entries if e.get("severity") not in ("info", "warning")],
                warnings=[e for e in entries if e.get("severity") == "warning"],
                report_scope_matches=any(e.get("name", "").lower().endswith("." + name.lower())
                    and any((s.get("file"), s.get("line")) in locations for s in e.get("sloc", []))
                    for e in selected),
                scope_coverage_complete=(all(k in data for k in ("skip_proof", "skip_flow_proof", "pragma_assume"))
                    and not any(data[k] for k in ("skip_proof", "skip_flow_proof", "pragma_assume"))
                    and bool(data.get("spark")) and all(v == "all" for v in data["spark"].values())
                    and data.get("progress") == "PROGRESS_PROOF"
                    and data.get("stop_reason") == "STOP_REASON_NONE"))
            result["passed"] = (run.returncode == 0 and result["source_hashes_unchanged"]
                and result["runner_source_unchanged"] and result["guard_source_unchanged"]
                and result["report_scope_matches"] and result["scope_coverage_complete"]
                and result["proof_checks"] > 0 and not result["open"] and not result["warnings"])
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        records.append(result)
        (args.out / "results.json").write_text(json.dumps(records, indent=2) + "\n")
        print(name, result.get("checks"), result["passed"], flush=True)
        if not result["passed"]:
            break
    raise SystemExit(not all(r["passed"] for r in records))


if __name__ == "__main__":
    main()
