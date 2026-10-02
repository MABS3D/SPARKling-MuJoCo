#!/usr/bin/env python3
"""Diagnose minimal subprograms before fresh complete-unit acceptance."""
import argparse
import json
from pathlib import Path
import re
import resource
import shutil
import subprocess
import sys
import time
from evidence import ROOT, freeze, environment, unchanged, versions

ap = argparse.ArgumentParser()
ap.add_argument('--out', type=Path, required=True)
ap.add_argument('--phase', choices=['small', 'whole', 'all'], default='small')
ap.add_argument('--only', help='comma-separated subprogram names')
ap.add_argument('--units', default='mj-friction_kernels,mj-friction_random')
ap.add_argument('--timeout', type=int, default=10)
args = ap.parse_args()
out = args.out.resolve()
snapshot, manifest = freeze(out)
env = environment(out)
(out / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n')
(out / 'versions.json').write_text(json.dumps(versions(env), indent=2) + '\n')
resource.setrlimit(resource.RLIMIT_STACK, (64 * 1024 * 1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
records = []
accepted = True
for unit in args.units.split(','):
    jobs = []
    if args.phase in ('small', 'all'):
        for suffix in ('ads', 'adb'):
            inside_model = False
            for line, text in enumerate((snapshot / 'src' / (unit + '.' + suffix)).read_text().splitlines(), 1):
                if 'package Model with' in text:
                    inside_model = True
                if 'end Model;' in text:
                    inside_model = False
                match = re.match(r'\s*(function|procedure) (\w+)\b', text)
                if not match or (suffix == 'ads' and not inside_model):
                    continue
                name = match[2]
                if args.only and name not in args.only.split(','):
                    continue
                jobs.append((f'small-{unit}-{suffix}-{line}-{name}',
                             [f'--limit-subp={unit}.{suffix}:{line}']))
    if args.phase in ('whole', 'all'):
        jobs.append(('whole-' + unit, []))
    for label, extra in jobs:
        env['FRICTION_BUILD_ROOT'] = str(out / label / 'build')
        reports = out / label / 'build/validation/obj/gnatprove'
        report = reports / (unit + '.spark')
        report.unlink(missing_ok=True)
        cmd = [sys.executable, str(ROOT / 'tools/guarded.py'), '--cap-mb', '3000',
               '--timeout', '900', '--', 'gnatprove', '-f', '-P', str(snapshot / 'friction.gpr'),
               '-u', unit + '.ads', '--prover=cvc5,z3,altergo', '--timeout=' + str(args.timeout),
               '--memlimit=800', '--steps=0', '--proof=per_check', '-j1',
               '--checks-as-errors=on', '--warnings=continue', '--report=all',
               '--counterexamples=off', *extra]
        start = time.time()
        p = subprocess.run(cmd, cwd=ROOT, env=env, text=True, capture_output=True)
        (out / (label + '.log')).write_text(p.stdout + p.stderr)
        data = json.loads(report.read_text()) if report.exists() else {}
        if data:
            shutil.copyfile(report, out / (label + '.spark.json'))
        messages = [m for sec in ('proof', 'flow', 'warn_error') for m in data.get(sec, [])]
        open_checks = [m for m in messages if m.get('severity') not in ('info', 'warning')]
        count = {'closed': sum(m.get('severity') == 'info' for m in messages),
                 'open': len(open_checks),
                 'warnings': sum(m.get('severity') == 'warning' for m in messages)}
        covered = (bool(data) and data.get('progress') == 'PROGRESS_PROOF'
                   and data.get('stop_reason') == 'STOP_REASON_NONE'
                   and not data.get('skip_proof') and not data.get('skip_flow_proof')
                   and not data.get('pragma_assume')
                   and all(v == 'all' for v in data.get('spark', {}).values()))
        ok = p.returncode == 0 and bool(data) and not open_checks and not count['warnings']
        if label.startswith('whole-'):
            names = {data['entities'][key]['name'].rsplit('.', 1)[-1].lower()
                     for key, coverage in data.get('spark', {}).items() if coverage == 'all'}
            declared = set()
            for suffix in ('ads', 'adb'):
                for text in (snapshot / 'src' / (unit + '.' + suffix)).read_text().splitlines():
                    match = re.match(r'\s*(function|procedure) (\w+)\b', text)
                    if match:
                        declared.add(match[2].lower())
            missing = declared - names
            ok = ok and covered and not missing
            count['covered_subprograms'] = sorted(names)
            count['missing_subprograms'] = sorted(missing)
        records.append(dict(label=label, exit_code=p.returncode, seconds=time.time() - start,
                            command=cmd, passed=ok, **count))
        (out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
        print(label, p.returncode, count, flush=True)
        if not ok:
            print('\n'.join(t for t in (p.stdout + p.stderr).splitlines()
                            if re.search(r'error:|medium:|high:|low:|warning:', t))[-8000:], flush=True)
        accepted = accepted and ok
        assert unchanged(manifest), 'candidate changed while proving'
assert records, 'no subprograms selected'
(out / 'acceptance.json').write_text(json.dumps(dict(passed=accepted, phase=args.phase,
    units=args.units, diagnostic_filter=args.only, sources_unchanged=True), indent=2) + '\n')
sys.exit(0 if accepted else 1)
