"""Small subprograms first; then whole units, retaining unresolved checks."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import re
import resource
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from common import ROOT, REPO, SCRATCH, environment


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--scope", choices=("small", "whole", "flow"), default="small")
    parser.add_argument("--only", help="Run task names containing this substring")
    parser.add_argument("--seconds", type=int, default=None)
    args = parser.parse_args()
    evidence = ROOT / "evidence" / ("proof-" + args.scope)
    evidence.mkdir(parents=True, exist_ok=True)
    limits = resource.getrlimit(resource.RLIMIT_STACK)
    resource.setrlimit(resource.RLIMIT_STACK, (64 * 1024 * 1024, limits[1]))
    tasks = []
    if args.scope == "small":
        for unit, selected in (("mj-tendon_vectors", None), ("mj-tendon_geometry", {"Norm", "Unit", "Dot2", "Norm2", "Unit2", "Determinant", "Intersect"}), ("mj-spatial_tendons", {
                "Valid_Path", "Valid_Kinematics", "Point_Column", "Project_Component",
                "Velocity_Prefix", "Velocity", "Project_Force"})):
            for line, text in enumerate((ROOT / "src" / (unit + ".adb")).read_text().splitlines(), 1):
                match = re.match(r"   (?:function|procedure) (\w+)", text)
                if match and (selected is None or match[1] in selected):
                    tasks.append((unit + "-" + match[1], [f"--limit-subp={unit}.adb:{line}"]))
    else:
        tasks = [(unit, ["-u", unit + ".adb"]) for unit in
                 ("mj-tendon_vectors", "mj-tendon_geometry", "mj-spatial_tendons")]
    if args.only:
        tasks = [(name, scope) for name, scope in tasks if args.only in name]
        evidence = evidence / args.only
        evidence.mkdir(parents=True, exist_ok=True)
    def fingerprints():
        files = [p for p in sorted(ROOT.rglob("*"))
                 if p.is_file() and p.suffix in (".ads", ".adb", ".gpr")]
        files += [REPO / "src" / name for name in
                  ("mj.ads", "mj-types.ads", "mj-quaternion_math.ads")]
        return {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in files}
    sources = fingerprints()
    # Analyze an immutable copy so concurrent integration work cannot mix
    # source versions within one proof run.
    snapshot = Path(tempfile.mkdtemp(prefix="kernel-proof-source-", dir=SCRATCH))
    shutil.copytree(ROOT / "src", snapshot / "src")
    (snapshot / "tests").mkdir()
    shutil.copy2(ROOT / "tests/spatial_probe.adb", snapshot / "tests/spatial_probe.adb")
    for filename in ("mj.ads", "mj-types.ads", "mj-quaternion_math.ads"):
        shutil.copy2(REPO / "src" / filename, snapshot / "src" / filename)
    project = snapshot / "spatial.gpr"
    project.write_text((ROOT / "spatial.gpr").read_text().replace('("src", "../../src", "tests")', '("src", "tests")'))
    assert sources == fingerprints(), "sources changed during snapshot"
    results = []
    for name, scope in tasks:
        command = [sys.executable, str(REPO / "tools/guarded.py"), "--cap-mb", "3800",
                   "--min-free-mb", "2048", "--timeout", ("600" if args.scope == "small" else "360"), "--", "gnatprove", "-P",
                   str(project), ("--prover=cvc5,z3,altergo" if args.scope == "small" or args.seconds else "--prover=cvc5"), "--timeout=" + str(args.seconds or (5 if args.scope == "small" else 1)), ("--steps=0" if args.scope == "small" or args.seconds else "--steps=300"),
                   "--proof=per_check", "-j2", "--report=all", "--counterexamples=off",
                   "--checks-as-errors=on", "--warnings=continue", *scope]
        if args.scope == "flow":
            command += ["--mode=flow"]
        log = evidence / (name + ".log")
        env = environment()
        env["SPATIAL_BUILD_ROOT"] = str(snapshot / "build" / name)
        with log.open("w") as out:
            completed = subprocess.run(command, env=env, stdout=out, stderr=subprocess.STDOUT)
        text = log.read_text()
        proof_root = snapshot / "build" / name / "validation/obj/gnatprove"
        saved = evidence / name
        saved.mkdir(exist_ok=True)
        # Keep machine evidence, not only the exit status or final summary.
        for item in proof_root.glob("*.spark"):
            if item.stem in name:
                shutil.copy2(item, saved / item.name)
        if (proof_root / "gnatprove.out").exists():
            shutil.copy2(proof_root / "gnatprove.out", saved / "gnatprove.out")
        info = {"name": name, "returncode": completed.returncode,
                "success_banner": "Success: all checks proved" in text,
                "command": command}
        results.append(info)
        print(name, completed.returncode, text[-300:], flush=True)
    manifest = {"timestamp": datetime.now(timezone.utc).isoformat(), "scope": args.scope, "snapshot": str(snapshot),
                "results": results,
                "source_sha256": sources,
                "current_sources_match_snapshot": sources == fingerprints()}
    (evidence / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    # Failure/open checks remain visible to the invoking user and CI.
    return int(any(r["returncode"] != 0 for r in results))


if __name__ == "__main__":
    raise SystemExit(main())
