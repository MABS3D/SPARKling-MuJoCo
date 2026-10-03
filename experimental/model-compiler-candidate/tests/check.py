#!/usr/bin/env python3
"""Freeze compiler inputs; build or prove one minimal subprogram/whole unit."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
UNITS = ['mj-model_compiler-addresses']

def environment():
    env = os.environ.copy()
    tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = os.pathsep.join(str(next((tc/n).glob('*/bin')))
        for n in ['gnat', 'gprbuild', 'gnatprove']) + os.pathsep + env['PATH']
    return env

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--phase', choices=['build', 'small', 'whole'], required=True)
    ap.add_argument('--mode', choices=['validation', 'release'], default='validation')
    ap.add_argument('--unit', choices=UNITS, default=UNITS[0])
    ap.add_argument('--only')
    ap.add_argument('--timeout', type=int, default=5)
    args = ap.parse_args()
    if args.only and args.phase != 'small': ap.error('--only requires --phase small')
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    (out/'src').mkdir()
    files = [ROOT/'src/mj.ads', ROOT/'src/mj-types.ads',
        *sorted((HERE/'src').glob('*.ad?')), HERE/'tests/compiler_probe.adb', HERE/'model_compiler.gpr']
    hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    for p in files: shutil.copyfile(p, out/'src'/p.name)
    project = (HERE/'model_compiler.gpr').read_text().replace(
        'for Source_Dirs use ("src", "../../src", "tests");', 'for Source_Dirs use ("src");')
    (out/'model_compiler.gpr').write_text(project)
    (out/'sources.json').write_text(json.dumps(hashes, indent=2)+'\n')
    env = environment(); env['MODEL_COMPILER_BUILD_ROOT'] = str(out/'build')
    env['MODEL_COMPILER_MODE'] = args.mode
    versions = {name: subprocess.check_output([name, '--version'], env=env, text=True).splitlines()[0]
        for name in ['gprbuild', 'gnatprove']}
    (out/'tools.json').write_text(json.dumps(versions, indent=2)+'\n')
    def run(command, label):
        cmd = [sys.executable, str(ROOT/'tools/guarded.py'), '--cap-mb', '2500',
            '--min-free-mb', '1000', '--timeout', '180', '--', *command]
        start = time.monotonic(); p = subprocess.run(cmd, env=env, text=True, capture_output=True)
        (out/(label+'.log')).write_text(p.stdout+p.stderr)
        return p, dict(command=cmd, exit=p.returncode, seconds=time.monotonic()-start)
    if args.phase == 'build':
        p, record = run(['gprbuild', '-P', str(out/'model_compiler.gpr'), '-j1'], 'build')
        binary = out/'build'/args.mode/'bin/compiler_probe'
        if p.returncode: print((p.stdout+p.stderr)[-5000:]); raise SystemExit(p.returncode)
        record.update(binary=str(binary), sha256=hashlib.sha256(binary.read_bytes()).hexdigest())
        (out/'build.json').write_text(json.dumps(record, indent=2)+'\n'); print(binary); return
    targets = [(None, 'whole')]
    if args.phase == 'small':
        targets = []
        body = (HERE/'src'/f'{args.unit}.adb').read_text()
        for suffix in ['ads','adb']:
            for line, text in enumerate((HERE/'src'/f'{args.unit}.{suffix}').read_text().splitlines(), 1):
                m = re.match(r'\s*(?:function|procedure) (\w+)\b', text)
                if not m or (args.only and args.only != m[1]): continue
                if suffix == 'ads' and re.search(r'\b(?:function|procedure) '+m[1]+r'\b', body): continue
                targets.append((f'{args.unit}.{suffix}:{line}', m[1]))
        if not targets: raise ValueError('No minimal subprogram selected')
    records = []
    for limit, label in targets:
        obj = out/'build'/args.mode/'obj/gnatprove'
        for p in obj.glob('*.spark'): p.unlink()
        command = ['gnatprove', '-f', '-P', str(out/'model_compiler.gpr'), '-u', args.unit+'.ads',
            '--prover=cvc5,z3,altergo', '--timeout='+str(args.timeout), '--steps=0', '--memlimit=700',
            '--proof=per_path', '--level=2', '-j1', '--checks-as-errors=on', '--warnings=continue',
            '--report=all', '--counterexamples=off']
        if limit: command.append('--limit-subp='+limit)
        p, record = run(command, label)
        report = obj/(args.unit+'.spark')
        record.update(label=label, limit=limit, passed=False)
        if report.exists():
            d = json.loads(report.read_text()); shutil.copyfile(report, out/(label+'.spark.json'))
            diagnostics = [x for section in ['proof','flow','warn_error'] for x in d.get(section,[])]
            record.update(checks=sum(x.get('severity')=='info' for section in ['proof','flow'] for x in d.get(section,[])),
                proof_checks=sum(x.get('severity')=='info' for x in d.get('proof',[])),
                flow_checks=sum(x.get('severity')=='info' for x in d.get('flow',[])),
                open=[x for x in diagnostics if x.get('severity') not in ['info','warning']],
                warnings=[x for x in diagnostics if x.get('severity')=='warning'])
            coverage = (not d['skip_proof'] and not d['skip_flow_proof'] and not d['pragma_assume']
                and all(v=='all' for v in d['spark'].values()) and d['progress']=='PROGRESS_PROOF'
                and d['stop_reason']=='STOP_REASON_NONE')
            record['coverage'] = coverage
            # Reviewed notices describe controlled recursive ghost-model
            # unfolding. They stay visible in the raw reports; no application
            # obligation is waived and no GNAT diagnostic is suppressed.
            reviewed = {'contracts-recursive', 'numeric-variant'}
            record['unreviewed_warnings'] = [w for w in record['warnings'] if w.get('rule') not in reviewed]
            record['passed'] = p.returncode==0 and not record['open'] and not record['unreviewed_warnings'] and record['proof_checks']>0 and bool(d.get('spark')) and coverage
        records.append(record)
        (out/'results.json').write_text(json.dumps(records, indent=2)+'\n')
        print(label, 'PASS' if record['passed'] else 'OPEN', record.get('checks'), flush=True)
        if not record['passed']:
            print('\n'.join(l for l in (p.stdout+p.stderr).splitlines() if re.search(r'error:|medium:|high:|low:|warning:',l))[-4500:], flush=True)
            if 'open' not in record: raise SystemExit(p.returncode or 1)
    assert hashes == {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    raise SystemExit(0 if all(r['passed'] for r in records) else 1)

if __name__ == '__main__': main()
