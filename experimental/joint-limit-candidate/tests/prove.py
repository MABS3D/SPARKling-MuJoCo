#!/usr/bin/env python3
"""Diagnostic subprograms first, fresh whole units afterwards; no assumptions."""
from pathlib import Path
import argparse, json, re, resource, shutil, subprocess, sys, time
from evidence import HERE, ROOT, environment, snapshot, provenance, digest

ap = argparse.ArgumentParser()
ap.add_argument('--out', type=Path, required=True)
ap.add_argument('--phase', choices=['small', 'whole', 'all'], default='all')
ap.add_argument('--only', help='diagnostic subprogram name')
ap.add_argument('--unit', choices=['mj-joint_limits', 'mj-joint_limit_response', 'mj-solimp_curve'])
ap.add_argument('--timeout', type=int, default=10, help='seconds per prover/check')
ap.add_argument('--proof-mode', choices=['per_check', 'per_path'], default='per_check')
args = ap.parse_args()
args.out.mkdir(parents=True, exist_ok=True)
sources = snapshot()
env = environment()
env['LIMIT_BUILD_ROOT'] = str(args.out.resolve() / 'build')
(args.out / 'sources.json').write_text(json.dumps(sources, indent=2) + '\n')
(args.out / 'environment.json').write_text(json.dumps(provenance(env), indent=2) + '\n')
resource.setrlimit(resource.RLIMIT_STACK, (64*1024*1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
common = ['gnatprove', '-P', str(HERE / 'limits.gpr'), '--prover=cvc5,z3,altergo',
          '--timeout='+str(args.timeout), '--steps=0', '--proof='+args.proof_mode, '-j1', '--checks-as-errors=on',
          '--warnings=continue', '--report=all', '--counterexamples=off']
records = []

def run(unit, label, extra):
    env['LIMIT_BUILD_ROOT'] = str(args.out.resolve() / label / 'build')
    reports = Path(env['LIMIT_BUILD_ROOT']) / 'validation/obj/gnatprove'
    cmd = [sys.executable, str(ROOT / 'tools/guarded.py'), '--cap-mb', '3800',
           '--min-free-mb', '12000', '--timeout', '180', '--', *common, '-u', unit + '.ads', *extra]
    report = reports / (unit + '.spark')
    report.unlink(missing_ok=True)
    start = time.time(); steady = time.monotonic()
    p = subprocess.run(cmd, cwd=ROOT, env=env, capture_output=True, text=True)
    (args.out / (label + '.log')).write_text(p.stdout + p.stderr)
    result = {'label': label, 'exit': p.returncode, 'seconds': time.monotonic() - steady, 'command': cmd}
    if report.exists():
        d = json.loads(report.read_text())
        shutil.copyfile(report, args.out / (label + '.spark.json'))
        entries = [m for s in ['proof', 'flow', 'warn_error'] for m in d.get(s, [])]
        warnings = [m for m in entries if m.get('severity') == 'warning']
        reviewed = [m for m in warnings if m['rule'] == 'imprecise-call'
                    and m['message'].get('arguments') in [['Sqrt'], ['Atan2'], ['Runtime_Pow']]]
        result.update(checks=sum(m.get('severity') == 'info' for m in entries),
                      open=sum(m.get('severity') not in ['info', 'warning'] for m in entries),
                      warnings=sum(m.get('severity') == 'warning' for m in entries),
                      reviewed_runtime_warnings=reviewed,
                      unreviewed_warnings=len(warnings)-len(reviewed), report_sha256=digest(report))
        if label.startswith('whole-'):
            assert report.stat().st_mtime >= start-2
            assert not d['skip_proof'] and not d['skip_flow_proof'] and not d['pragma_assume']
            assert d['progress'] == 'PROGRESS_PROOF' and d['stop_reason'] == 'STOP_REASON_NONE'
            # Runtime_Pow is the existing libm import, with no Ada body or
            # assumed output/range contract. Report that boundary explicitly;
            # every application body must still receive full coverage.
            external = [d['entities'][k]['name'] for k, v in d['spark'].items()
                        if v == 'spec' and d['entities'][k]['name'] == 'MJ.Solimp_Curve.Runtime_Pow']
            result['external_runtime_boundaries'] = external
            result['complete_application_coverage'] = all(
                v == 'all' or (v == 'spec' and d['entities'][k]['name'] in external)
                for k, v in d['spark'].items())
            assert result['complete_application_coverage']
            result['subprograms'] = sorted(d['entities'][k]['name'] for k in d['spark'])
    else:
        result['open'] = 1
    assert sources == snapshot(), 'source changed during proof'
    records.append(result)
    (args.out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
    print({k: v for k, v in result.items() if k not in ['command', 'subprograms', 'reviewed_runtime_warnings']}, flush=True)
    if p.returncode or result.get('open'):
        print('\n'.join(l for l in (p.stdout+p.stderr).splitlines()
                        if re.search(r'error:|medium:|high:|low:', l))[-5000:], flush=True)
    return p.returncode == 0 and result.get('open', 1) == 0 and result.get('unreviewed_warnings', 1) == 0

ok = True
units = [args.unit] if args.unit else ['mj-solimp_curve', 'mj-joint_limits', 'mj-joint_limit_response']
if args.phase in ['all', 'small']:
    for unit in units:
        for suffix in ['ads', 'adb']:
            in_model = False
            lines = (HERE / 'src' / (unit+'.'+suffix)).read_text().splitlines()
            for i, line in enumerate(lines, 1):
                if 'package Model with' in line or 'package Composition with' in line or 'package body Model is' in line:
                    in_model = True
                if 'end Model;' in line or 'end Composition;' in line:
                    in_model = False
                m = re.match(r'\s*(function|procedure) (\w+)\b', line)
                if not m:
                    continue
                if suffix == 'ads' and not in_model and not re.search(
                    r'\breturn[\w.\s]+\bis\b', '\n'.join(lines[i-1:i+4])):
                    continue
                if args.only and m[2] != args.only:
                    continue
                ok = run(unit, f'small-{unit}-{suffix}-{i}-{m[2]}',
                         [f'--limit-subp={unit}.{suffix}:{i}']) and ok
if args.phase in ['all', 'whole']:
    for unit in units + ([] if args.unit else ['mj-contact_rows']):
        ok = run(unit, 'whole-'+unit, []) and ok
(args.out / 'acceptance.json').write_text(json.dumps(
    {'passed': ok, 'phase': args.phase, 'filter': args.only, 'sources_unchanged': True}, indent=2) + '\n')
sys.exit(0 if ok else 1)
