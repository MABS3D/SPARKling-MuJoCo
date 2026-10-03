"""Minimal asset kernels first, then whole-unit and loader diagnostics."""
import argparse
import json
import re
import shutil
import subprocess
import time
from pathlib import Path
from build import ROOT, environment

p = argparse.ArgumentParser()
p.add_argument("--build", type=Path, required=True)
p.add_argument("--out", type=Path, required=True)
p.add_argument("--kernels-only", action="store_true")
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
source = a.build / "source"
project = source / "experimental/constrained-step/constrained.gpr"
records = []
targets = [("mj-constrained_asset_kernels.adb", name, False)
           for name in ["Promote", "Vertex_Index", "Graph_Span", "Copy_Vertices"]]
targets += [("mj-constrained_asset_kernels.adb", None, False)]
if not a.kernels_only:
    targets += [("mj-constrained_assets.adb", name, False)
                for name in ["Release", "Configure", "Load"]]
    targets += [("mj-constrained_assets.adb", None, False),
                ("mj-data-constrained.adb", None, True)]
for unit, name, flow in targets:
    label = ("flow-" if flow else "") + (name or unit)
    env = environment()
    env.update(CONSTRAINED_BUILD_ROOT=str(a.out / "build"), CONSTRAINED_MODE="validation")
    cmd = ["gnatprove", "-P", str(project), "-u", unit, "-j1", "--report=all",
           "--checks-as-errors=on", "--warnings=continue", "--counterexamples=off",
           "--prover=cvc5,z3,altergo", "--timeout=5", "--steps=0", "--proof=per_path"]
    if name:
        text = (source / "experimental/constrained-step/src" / unit).read_text()
        match = re.search(r"^   (?:function|procedure) " + name + r"\b", text, re.M)
        cmd.append("--limit-subp=" + unit + ":" + str(text[:match.start()].count("\n") + 1))
    if flow:
        cmd += ["--mode=flow", "--no-inlining"]
    if unit == "mj-constrained_assets.adb":
        cmd += ["--no-inlining"]
    report = a.out / "build/validation/obj/gnatprove" / (Path(unit).stem + ".spark")
    report.unlink(missing_ok=True)
    start = time.monotonic()
    run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "2600",
                          "--min-free-mb", "12000", "--timeout", "100", "--", *cmd], env=env, capture_output=True, text=True)
    (a.out / (label + ".log")).write_text(run.stdout + run.stderr)
    report = a.out / "build/validation/obj/gnatprove" / (Path(unit).stem + ".spark")
    record = dict(unit=unit, subprogram=name, flow=flow, exit=run.returncode,
                  seconds=time.monotonic() - start, command=cmd)
    if report.is_file():
        d = json.loads(report.read_text())
        shutil.copyfile(report, a.out / (label + ".spark.json"))
        checks = [entry for kind in ["proof", "flow", "warn_error"] for entry in d.get(kind, [])]
        record.update(proved=sum(e.get("severity") == "info" for e in checks),
                      open=sum(e.get("severity") not in ["info", "warning"] for e in checks),
                      warnings=sum(e.get("severity") == "warning" for e in checks))
        if name is None and not flow:
            record['complete_coverage'] = (not d['skip_proof'] and not d['skip_flow_proof']
                and not d['pragma_assume'] and all(v == 'all' for v in d['spark'].values())
                and d['progress'] == 'PROGRESS_PROOF' and d['stop_reason'] == 'STOP_REASON_NONE')
            record['entities'] = sorted(d['entities'][k]['name'] for k in d['spark'])
    records.append(record)
    print({k: v for k, v in record.items() if k != "command"}, flush=True)
    (a.out / "results.json").write_text(json.dumps(records, indent=2) + "\n")
shutil.copyfile(a.build / "manifest.json", a.out / "sources.json")

if any(r['exit'] or r.get('open', 1) or r.get('warnings', 1)
       or (r['subprogram'] is None and not r['flow'] and not r.get('complete_coverage'))
       for r in records):
    raise SystemExit(1)
