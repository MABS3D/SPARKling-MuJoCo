#!/usr/bin/env python3
"""Freeze inputs, build profiles, diagnose minimal subprograms, prove whole units."""
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
UNITS = ['mj-elastic_materials', 'mj-contact_materials']

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def sources():
    return [ROOT/'src/mj.ads', ROOT/'src/mj-types.ads',
            *sorted((HERE/'src').glob('*.ad?')), HERE/'tests/materials_probe.adb']

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
    ap.add_argument('--unit', choices=UNITS)
    ap.add_argument('--only', help='minimal subprogram name, not a whole-unit filter')
    ap.add_argument('--timeout', type=int, default=10)
    args = ap.parse_args()
    if args.only and args.phase != 'small':
        ap.error('--only is allowed only for small-subprogram diagnostics')
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out/'src').mkdir()
    hashes = {str(p.relative_to(ROOT)): digest(p) for p in sources()}
    for p in sources():
        shutil.copyfile(p, out/'src'/p.name)
    project = (HERE/'materials.gpr').read_text().replace(
        'for Source_Dirs use ("src", "../../src", "tests");',
        'for Source_Dirs use ("src");')
    (out/'materials.gpr').write_text(project)
    (out/'sources.json').write_text(json.dumps(hashes, indent=2)+'\n')
    env = environment()
    env['MATERIALS_BUILD_ROOT'] = str(out/'build')
    env['MATERIALS_MODE'] = args.mode
    versions = {name: subprocess.check_output([name, '--version'], env=env, text=True).splitlines()[0] for name in ['gprbuild', 'gnatprove']}
    (out/'tools.json').write_text(json.dumps(versions, indent=2)+'\n')
    records = []
    def run(command, label):
        command = [sys.executable, str(ROOT/'tools/guarded.py'),
                   '--cap-mb', '3800', '--timeout', '600', '--', *command]
        start = time.time()
        p = subprocess.run(command, env=env, text=True, capture_output=True)
        (out/(label+'.log')).write_text(p.stdout+p.stderr)
        return p, dict(label=label, command=command, code=p.returncode,
                      seconds=time.time()-start)
    if args.phase == 'build':
        p, rec = run(['gprbuild', '-P', str(out/'materials.gpr'), '-j2'], 'build')
        binary = out/'build'/args.mode/'bin/materials_probe'
        if p.returncode:
            print((p.stdout+p.stderr)[-5000:])
            raise SystemExit(p.returncode)
        rec.update(binary=str(binary), binary_sha256=digest(binary), mode=args.mode)
        (out/'binary.json').write_text(json.dumps(rec, indent=2)+'\n')
        assert hashes == {str(p.relative_to(ROOT)): digest(p) for p in sources()}
        print(binary)
        return
    targets = []
    for unit in ([args.unit] if args.unit else UNITS):
        if args.phase == 'whole':
            targets.append((unit, None, unit))
        else:
            # Definitions in the spec, separately implemented bodies in .adb.
            body = (HERE/'src'/f'{unit}.adb').read_text()
            for suffix in ['ads', 'adb']:
                for n, line in enumerate((HERE/'src'/f'{unit}.{suffix}').read_text().splitlines(), 1):
                    m = re.match(r'\s*(function|procedure) (\w+)\b', line)
                    if not m or (args.only and m[2] != args.only):
                        continue
                    if suffix == 'ads' and re.search(r'\b(?:function|procedure) '+m[2]+r'\b', body):
                        continue
                    targets.append((unit, f'{unit}.{suffix}:{n}', m[2]))
    ok = True
    for unit, limit, label in targets:
        directory = out/'build'/args.mode/'obj/gnatprove'
        for report in directory.glob('*.spark'):
            report.unlink()
        command = ['gnatprove', '-f', '-P', str(out/'materials.gpr'), '-u', unit+'.ads',
            '--prover=cvc5,z3,altergo', f'--timeout={args.timeout}', '--memlimit=800',
            '--steps=0', '--proof=per_check', '-j2', '--checks-as-errors=on',
            '--warnings=continue', '--report=all', '--counterexamples=off']
        if limit:
            command.append('--limit-subp='+limit)
        label = args.phase+'-'+label
        p, rec = run(command, label)
        rec.update(unit=unit, limit=limit)
        report = directory/(unit+'.spark')
        if report.exists():
            d = json.loads(report.read_text())
            shutil.copyfile(report, out/(label+'.spark.json'))
            diagnostics = [x for s in ['proof', 'flow', 'warn_error'] for x in d.get(s, [])]
            rec.update(checks=sum(x.get('severity') == 'info'
                for s in ['proof', 'flow'] for x in d.get(s, [])),
                open=[x for x in diagnostics if x.get('severity') not in ['info', 'warning']],
                warnings=[x for x in diagnostics if x.get('severity') == 'warning'])
            if not limit:
                rec['complete_coverage'] = (
                    not d['skip_proof'] and not d['skip_flow_proof'] and not d['pragma_assume']
                    and all(v == 'all' for v in d['spark'].values())
                    and d['progress'] == 'PROGRESS_PROOF'
                    and d['stop_reason'] == 'STOP_REASON_NONE')
                rec['entities'] = sorted(d['entities'][k]['name']
                    for k, v in d['spark'].items() if v == 'all')
                expected = {m.lower() for suffix in ['ads', 'adb']
                    for m in re.findall(r'\b(?:function|procedure)\s+(\w+)',
                        (out/'src'/f'{unit}.{suffix}').read_text())}
                proved = {name.split('.')[-1].lower() for name in rec['entities']}
                rec['missing_entities'] = sorted(expected-proved)
                rec['complete_coverage'] = rec['complete_coverage'] and not rec['missing_entities']
        passed = (p.returncode == 0 and 'open' in rec and not rec['open']
                  and not rec['warnings'] and (limit or rec.get('complete_coverage')))
        rec['passed'] = bool(passed)
        ok = bool(passed) and ok
        records.append(rec)
        (out/'results.json').write_text(json.dumps(records, indent=2)+'\n')
        print(label, 'passed' if passed else 'OPEN', rec.get('checks'), flush=True)
        if not passed:
            print('\n'.join(x for x in (p.stdout+p.stderr).splitlines()
                            if re.search(r'error:|medium:|high:|low:', x))[-3500:], flush=True)
            if 'open' not in rec:
                raise SystemExit(p.returncode or 1)
    assert hashes == {str(p.relative_to(ROOT)): digest(p) for p in sources()}
    (out/'acceptance.json').write_text(json.dumps(dict(passed=ok, phase=args.phase,
        source_hashes_unchanged=True), indent=2)+'\n')
    raise SystemExit(0 if ok else 1)

if __name__ == '__main__':
    main()
