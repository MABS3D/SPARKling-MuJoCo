"""Prove the state publication boundary: minimal procedure, then whole unit."""
import argparse
import hashlib
import json
from pathlib import Path
import resource
import subprocess
import time

from build import ROOT, environment


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--build", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,
                       (64 * 1024 * 1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    snap = a.build / "source"
    unit = "mj-step_publication"
    source = snap / "experimental/constrained-step/src" / (unit + ".adb")
    instance = "mj-owned_step_publication"
    instance_file = source.parent / (instance + ".ads")
    instance_line = next(i for i, text in enumerate(instance_file.read_text().splitlines(), 1)
                         if text.startswith("package MJ.Owned_Step_Publication"))
    targets = [(text.split()[1], f"{instance}.ads:{instance_line}:{unit}.adb:{i}")
               for i, text in enumerate(source.read_text().splitlines(), 1)
               if text.strip().startswith(("procedure Publish", "function Has_Iterate"))]
    env = environment()
    env["CONSTRAINED_BUILD_ROOT"] = str(a.out / "proof-build")
    env["CONSTRAINED_MODE"] = "validation"
    records = []
    for label, limit in (*targets, ("whole", None)):
        cmd = ["gnatprove", "-P", str(snap / "experimental/constrained-step/publication.gpr"),
               "-u", instance + ".ads", "--prover=cvc5,z3,altergo", "--timeout=5",
               "--memlimit=700", "--steps=0", "--proof=per_check", "-j1",
               "--checks-as-errors=on", "--warnings=continue", "--report=all",
               "--counterexamples=off"]
        if limit:
            cmd.append("--limit-subp=" + limit)
        start = time.monotonic()
        run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "2600",
                              "--min-free-mb", "2000", "--timeout", "150", "--", *cmd],
                             env=env, capture_output=True, text=True)
        (a.out / (label + ".log")).write_text(run.stdout + run.stderr)
        row = dict(label=label, exit=run.returncode, seconds=time.monotonic() - start, command=cmd)
        reports = list((a.out / "proof-build").rglob(instance + ".spark"))
        if reports:
            data = json.loads(reports[0].read_text())
            (a.out / (label + ".spark.json")).write_text(json.dumps(data, indent=2) + "\n")
            entries = [m for kind in ("proof", "flow", "warn_error") for m in data.get(kind, [])]
            row.update(proved=sum(m.get("severity") == "info" for m in entries),
                       open=sum(m.get("severity") not in ("info", "warning") for m in entries),
                       warnings=sum(m.get("severity") == "warning" for m in entries))
        records.append(row)
        print({k: v for k, v in row.items() if k != "command"}, flush=True)
    files = [*source.parent.glob(unit + ".*"), source.parent / (instance + ".ads")]
    sources = {str(f.relative_to(snap)): hashlib.sha256(f.read_bytes()).hexdigest()
               for f in files}
    (a.out / "results.json").write_text(json.dumps(dict(sources=sources, runs=records), indent=2) + "\n")
    if any(r["exit"] or r.get("open", 1) for r in records):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
