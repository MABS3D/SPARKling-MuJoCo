"""Prove a frozen plugin unit and retain coverage, checks and source hashes."""
import argparse, hashlib, json, re, subprocess
from pathlib import Path
from build import environment, ROOT, HERE

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--unit', default='mj-plugin_protocol')
    p.add_argument('--only', help='subprogram name in the spec, or GNATprove file:line selection')
    p.add_argument('--timeout', type=int, default=5)
    p.add_argument('--budget', type=int, default=300)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    snap = a.out / 'source'
    hashes = {}
    for folder in ['src', 'experimental/plugin-runtime/src', 'experimental/plugin-runtime/tests']:
        for f in (ROOT / folder).iterdir():
            if f.is_file() and f.suffix in ('.ads', '.adb'):
                data = f.read_bytes()
                q = snap / f.relative_to(ROOT)
                q.parent.mkdir(parents=True, exist_ok=True)
                q.write_bytes(data)
                hashes[str(f.relative_to(ROOT))] = hashlib.sha256(data).hexdigest()
    project = snap / 'experimental/plugin-runtime/proof.gpr'
    project.write_bytes((HERE / 'proof.gpr').read_bytes())
    hashes[str(project.relative_to(snap))] = hashlib.sha256(project.read_bytes()).hexdigest()
    changed = [n for n, h in hashes.items() if hashlib.sha256((ROOT / n).read_bytes()).hexdigest() != h]
    if changed:
        raise RuntimeError('Sources changed while snapshotting: ' + repr(changed))
    env = environment()
    env['PLUGIN_PROOF_ROOT'] = str(a.out / 'proof')
    command = ['gnatprove', '-P', str(project), '-u', a.unit + '.ads',
               '--prover=cvc5,z3,altergo', '--timeout=' + str(a.timeout), '--steps=0',
               '--proof=per_path', '--checks-as-errors=on', '--warnings=continue',
               '--proof-warnings=on', '--report=all', '-j1']
    if a.only:
        selection = a.only
        if ':' not in selection:
            candidates = list((snap / 'experimental/plugin-runtime').glob('*/' + a.unit + '.ads'))
            if len(candidates) != 1:
                p.error('unit must identify exactly one plugin source or test file')
            source = candidates[0]
            matches = [i for i, line in enumerate(source.read_text().splitlines(), 1)
                       if re.match(r'\s*(function|procedure)\s+' + re.escape(selection) + r'\b', line, re.I)]
            if len(matches) != 1:
                p.error('subprogram selection must identify exactly one declaration')
            selection = source.name + ':' + str(matches[0])
        command += ['--limit-subp=' + selection]
    with (a.out / 'proof.log').open('w') as log:
        run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '2500',
                              '--timeout', str(a.budget), '--', *command],
                             env=env, stdout=log, stderr=subprocess.STDOUT)
    reports = list((a.out / 'proof/obj/gnatprove').glob('*.spark'))
    records = []
    for f in reports:
        data = json.loads(f.read_text())
        diagnostics = [x for k in ['proof', 'flow', 'warn_error'] for x in data.get(k, [])]
        target = a.out / (f.stem + '.spark.json')
        target.write_text(json.dumps(data, indent=2) + '\n')
        records.append(dict(unit=f.stem,
                            proof_checks=sum(x.get('severity') == 'info' for x in data.get('proof', [])),
                            flow_checks=sum(x.get('severity') == 'info' for x in data.get('flow', [])),
                            checks=sum(x.get('severity') == 'info' for x in diagnostics),
                            open=[x for x in diagnostics if x.get('severity') not in ['info', 'warning']],
                            warnings=[x for x in diagnostics if x.get('severity') == 'warning'],
                            coverage=bool(data.get('spark')) and all(v == 'all' for v in data.get('spark', {}).values())
                            and not any(data.get(k) for k in ['skip_proof', 'skip_flow_proof', 'pragma_assume'])))
    (a.out / 'manifest.json').write_text(json.dumps(dict(sources=hashes, command=command,
        exit=run.returncode, selection=a.only, reports=records), indent=2) + '\n')
    print(a.out / 'proof.log')
    target = [r for r in records if r['unit'] == a.unit]
    passed = (run.returncode == 0 and len(target) == 1 and target[0]['coverage']
              and target[0]['proof_checks'] > 0 and not any(r['open'] for r in records))
    raise SystemExit(0 if passed else 1)

if __name__ == '__main__':
    main()
