"""Prove one exact ABI decoding minimum on an immutable 3.14/3.15/3.17 snapshot."""
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--foundation", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    scope = parser.add_mutually_exclusive_group(required=True)
    scope.add_argument("--part", type=int, choices=range(1, 14))
    scope.add_argument("--parent", action="store_true")
    scope.add_argument("--model", action="store_true")
    scope.add_argument("--without-flex", action="store_true")
    scope.add_argument("--stride", action="store_true")
    scope.add_argument("--flags", action="store_true")
    scope.add_argument("--reference-field", choices=("flex_vertedgeadr", "flex_vertedge", "tex_contenttypeadr"))
    parser.add_argument("--analysis", type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    foundation = args.foundation.resolve()
    source = foundation / "source"
    manifest_path = foundation / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    assert manifest["reference"] in ("3.14.0", "3.15.0", "3.17.0")

    def snapshot_matches():
        return all(digest(source / name) == value
                   for name, value in manifest["candidate_sources"].items())

    assert snapshot_matches(), "Frozen foundation inputs differ"
    unit = ("mj-models-gen_clauses" if args.reference_field else "mj-models"
            if args.without_flex or args.stride else "mj-mjb-readers")
    suffix = ".ads" if args.model or args.without_flex or args.stride or args.reference_field else ".adb"
    path = source / "src/gen" / (unit + suffix)
    field_name = "_".join(part[:1].upper() + part[1:] for part in (args.reference_field or "").split("_"))
    name = ("Ref_" + field_name + "_At" if args.reference_field else "Read_Flags" if args.flags else "Flex_Stiffness_Stride" if args.stride else "Without_Flex" if args.without_flex else "Sizes_Decoded" if args.model else
            "Read_Sizes" if args.parent else "Read_Sizes_" + str(args.part))
    lines = [i for i, line in enumerate(path.read_text().splitlines(), 1)
             if re.match(r"\s*(?:procedure|function) " + name + r"\b", line)]
    assert len(lines) == 1, "Minimum definition must be unique"
    line = lines[0]
    analysis = args.analysis.resolve() if args.analysis else args.out.resolve() / "build"
    analysis.mkdir(parents=True, exist_ok=True)
    signature = digest(manifest_path)
    stamp = analysis / "foundation-manifest.sha256"
    if stamp.exists():
        assert stamp.read_text().strip() == signature, "Analysis source mismatch"
    else:
        stamp.write_text(signature + "\n")
    # Never attribute a cached report to an interrupted new invocation.
    for report in analysis.rglob(unit + ".spark"):
        report.unlink()
    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for tool in ("gnat", "gprbuild", "gnatprove")
                             for path in (toolchain / tool).glob("*/bin")) + ":" + env["PATH"]
    env["SPARKLING_BUILD_ROOT"] = str(analysis)
    command = ["gnatprove", "-P", str(source / "sparkling_mujoco.gpr"),
               "-XSPARKLING_BUILD_MODE=development", "-u", unit + (".ads" if args.reference_field else ".adb"), "-j1",
               "--report=all", "--checks-as-errors=on", "--warnings=continue", "--no-inlining",
               "--mode=prove", "--prover=cvc5,z3,altergo", "--timeout=3", "--memlimit=650",
               "--steps=0", "--proof=per_check", "--counterexamples=off",
               "--limit-subp=" + unit + suffix + ":" + str(line)]
    started = time.monotonic()
    log = args.out / "proof.log"
    with log.open("w") as stream:
        run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"),
                              "--cap-mb", "2500", "--timeout", "240", "--", *command],
                             cwd=source, env=env, stdout=stream, stderr=subprocess.STDOUT)
    result = dict(reference=manifest["reference"], part=args.part, subprogram=name, line=line, exit=run.returncode,
                  command=command, seconds=time.monotonic() - started,
                  foundation_manifest_sha256=signature, runner_sha256=digest(Path(__file__)),
                  log_sha256=digest(log), source_hashes_unchanged=snapshot_matches(),
                  obligations_closed=False, passed=False,
                  claim=("Generated C-reference predicate expression safety, including wide target arithmetic; complete validator contracts remain separate."
                         if args.reference_field else "Read_Flags exact ABI-specific byte decoding, including legacy missing-adhesion output; Read_Fixed and whole loader remain separate."
                         if args.flags else "Flex_Stiffness_Stride exact ABI-dependent block step; metric loaders remain separate."
                         if args.stride else "Without_Flex exact FLEX size clearing and non-FLEX scalar frame; factories remain separate."
                         if args.without_flex else "Read_Sizes contracts under proved minima; other readers and callers remain separate."
                         if args.parent else "Sizes_Decoded expression safety only; decoding caller remains separate."
                         if args.model else "Minimum functional decoding and frame only; no whole reader or caller claim."))
    reports = list(analysis.rglob(unit + ".spark"))
    if len(reports) == 1:
        report = reports[0]
        data = json.loads(report.read_text())
        shutil.copyfile(report, args.out / "unit.spark.json")
        selected = [data.get("entities", {}).get(key, {})
                    for key, value in data.get("spark", {}).items() if value == "all"]
        requested = {(unit + suffix, line)}
        if args.parent or args.flags:
            spec_lines = (source / "src/gen" / (unit + ".ads")).read_text().splitlines()
            matches = [i for i, text in enumerate(spec_lines, 1)
                       if re.match(r"\s*procedure " + name + r"\b", text)]
            assert len(matches) == 1
            requested.add((unit + ".ads", matches[0]))
        result["report_scope_matches"] = any(
            entity.get("name", "").lower().endswith("." + name.lower())
            and any((loc.get("file"), loc.get("line")) in requested
                    for loc in entity.get("sloc", [])) for entity in selected)
        entries = [entry for kind in ("proof", "flow", "warn_error")
                   for entry in data.get(kind, [])]
        result.update(proof_checks=len(data.get("proof", [])),
                      flow_checks=len(data.get("flow", [])),
                      checks=sum(entry.get("severity") == "info" for entry in entries),
                      open=[entry for entry in entries if entry.get("severity") not in ("info", "warning")],
                      warnings=[entry for entry in entries if entry.get("severity") == "warning"],
                      entities=[entity.get("name") for entity in selected])
        result["scope_coverage_complete"] = (
            all(key in data for key in ("skip_proof", "skip_flow_proof", "pragma_assume"))
            and not data.get("skip_proof") and not data.get("skip_flow_proof")
            and not data.get("pragma_assume") and bool(data.get("spark"))
            and all(value == "all" for value in data["spark"].values())
            and data.get("progress") == "PROGRESS_PROOF"
            and data.get("stop_reason") == "STOP_REASON_NONE")
        result["obligations_closed"] = (
            run.returncode == 0 and result["source_hashes_unchanged"]
            and result["report_scope_matches"] and result["scope_coverage_complete"]
            and result["proof_checks"] > 0 and not result["open"])
        result["passed"] = result["obligations_closed"] and not result["warnings"]
    else:
        result["report_rejected"] = "Expected exactly one fresh report"
    (args.out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: result.get(key) for key in
                      ("part", "exit", "checks", "proof_checks", "obligations_closed", "passed")}))
    raise SystemExit(not result["obligations_closed"])


if __name__ == "__main__":
    main()
