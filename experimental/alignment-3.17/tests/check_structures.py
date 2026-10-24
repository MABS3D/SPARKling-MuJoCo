"""Freeze and prove one integer structural admission minimum against 3.17 types.

This does not integrate model admission, prove the complete validator, or admit
FLEX into the foundation. Each invocation has fresh sources and proof reports.
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
CANDIDATE = ROOT / "experimental/alignment-3.17"
UNIT = "mj-model_structures"

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def scopes():
    result = {}
    for suffix in (".ads", ".adb"):
        for line, text in enumerate((CANDIDATE / "src" / (UNIT+suffix)).read_text().splitlines(), 1):
            match = re.match(r"\s*(?:procedure|function) (\w+)\b", text)
            if match:
                # An executable body takes precedence over its declaration.
                result[match[1]] = (suffix, line)
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--foundation", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    selection = parser.add_mutually_exclusive_group(required=True)
    selection.add_argument("--subprogram", choices=scopes())
    selection.add_argument("--whole", action="store_true", help="Renew the entire isolated kernel unit after minimum proofs")
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    foundation = args.foundation.resolve()
    prior_path = foundation / "manifest.json"
    prior = json.loads(prior_path.read_text())
    assert prior["reference"] == "3.17.0"
    assert prior["commit"] == "800a109a4bdd02cb60404d565db4ae16fb04a53b"
    inputs = {"source/src/"+n: foundation/"source/src"/n for n in ("mj.ads", "mj-types.ads")}
    for name in ("mj.ads", "mj-types.ads"):
        assert digest(foundation/"source/src"/name) == prior["candidate_sources"]["src/"+name]
    for suffix in (".ads", ".adb"):
        name = UNIT+suffix
        inputs["source/experimental/alignment-3.17/src/"+name] = CANDIDATE/"src"/name
    project_rel = "source/experimental/alignment-3.17/tests/structures.gpr"
    inputs[project_rel] = CANDIDATE/"tests/structures.gpr"
    hashes = {name: digest(p) for name, p in inputs.items()}
    for name, p in inputs.items():
        target = out/name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(p, target)
    assert all(digest(p) == hashes[name] for name, p in inputs.items())
    def matches():
        return all(digest(out/name) == value for name, value in hashes.items())
    manifest = dict(reference=prior["reference"], commit=prior["commit"],
                    foundation_manifest_sha256=digest(prior_path), sources=hashes,
                    runner_sha256=digest(Path(__file__)), guard_sha256=digest(ROOT/"tools/guarded.py"))
    (out/"manifest.json").write_text(json.dumps(manifest, indent=2)+"\n")
    suffix, line = (".adb", None) if args.whole else scopes()[args.subprogram]
    env = os.environ.copy()
    tc = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(p) for tool in ("gnat", "gprbuild", "gnatprove")
                             for p in (tc/tool).glob("*/bin"))+":"+env["PATH"]
    env["STRUCTURES_BUILD_ROOT"] = str(out/"build")
    command = ["gnatprove", "-P", str(out/project_rel), "-u", UNIT+".adb", "-j1",
               "--report=all", "--checks-as-errors=on", "--warnings=continue", "--no-inlining",
               "--mode=prove", "--prover=cvc5,z3,altergo", "--timeout=3", "--memlimit=650",
               "--steps=0", "--proof=per_check", "--counterexamples=off"]
    if not args.whole:
        command.append("--limit-subp="+UNIT+suffix+":"+str(line))
    start = time.monotonic()
    log = out/"proof.log"
    with log.open("w") as stream:
        run = subprocess.run(["python3", str(ROOT/"tools/guarded.py"), "--cap-mb", "2500",
                              "--timeout", "240", "--", *command], env=env,
                             stdout=stream, stderr=subprocess.STDOUT)
    result = dict(subprogram=("whole unit" if args.whole else args.subprogram),
                  minimum_kind=("whole_unit" if args.whole else "body_contract" if suffix == ".adb" else "expression_safety"),
                  command=command, exit=run.returncode,
                  seconds=time.monotonic()-start, source_hashes_unchanged=matches(),
                  manifest_sha256=digest(out/"manifest.json"), log_sha256=digest(log),
                  driver_hashes_unchanged=(digest(Path(__file__)) == manifest["runner_sha256"]
                    and digest(ROOT/"tools/guarded.py") == manifest["guard_sha256"]),
                  obligations_closed=False, passed=False)
    reports = list((out/"build").rglob(UNIT+".spark"))
    if len(reports) == 1:
        data = json.loads(reports[0].read_text())
        shutil.copyfile(reports[0], out/"unit.spark.json")
        selected = [data.get("entities", {}).get(key, {}) for key, value in data.get("spark", {}).items() if value == "all"]
        locations = {(UNIT+suffix, line)}
        for i, text in enumerate((out/"source/experimental/alignment-3.17/src"/(UNIT+".ads")).read_text().splitlines(), 1):
            if not args.whole and re.match(r"\s*(?:procedure|function) "+args.subprogram+r"\b", text):
                locations.add((UNIT+".ads", i))
        entries = [entry for kind in ("proof", "flow", "warn_error") for entry in data.get(kind, [])]
        result.update(checks=sum(e.get("severity") == "info" for e in entries),
                      proof_checks=len(data.get("proof", [])), flow_checks=len(data.get("flow", [])),
                      open=[e for e in entries if e.get("severity") not in ("info", "warning")],
                      warnings=[e for e in entries if e.get("severity") == "warning"],
                      report_scope_matches=(all(any(e.get("name", "").lower().endswith("."+name.lower()) for e in selected) for name in scopes()) if args.whole else
                        any(e.get("name", "").lower().endswith("."+args.subprogram.lower())
                        and any((p.get("file"), p.get("line")) in locations for p in e.get("sloc", [])) for e in selected)),
                      scope_coverage_complete=(all(k in data for k in ("skip_proof", "skip_flow_proof", "pragma_assume"))
                        and not data.get("skip_proof") and not data.get("skip_flow_proof") and not data.get("pragma_assume")
                        and bool(data.get("spark")) and all(v == "all" for v in data["spark"].values())
                        and data.get("progress") == "PROGRESS_PROOF" and data.get("stop_reason") == "STOP_REASON_NONE"))
        result["obligations_closed"] = (run.returncode == 0 and result["source_hashes_unchanged"]
            and result["driver_hashes_unchanged"] and result["report_scope_matches"]
            and result["scope_coverage_complete"] and not result["open"]
            and (result["proof_checks"] > 0 or (suffix == ".ads" and result["flow_checks"] > 0)))
        result["passed"] = result["obligations_closed"] and not result["warnings"]
    else:
        result["report_rejected"] = "Expected exactly one fresh scoped report"
    (out/"results.json").write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({k: result.get(k) for k in ("subprogram", "exit", "checks", "obligations_closed", "passed")}))
    raise SystemExit(not result["obligations_closed"])

if __name__ == "__main__":
    main()
