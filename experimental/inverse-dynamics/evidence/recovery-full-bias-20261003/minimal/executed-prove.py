"""Small-subprogram diagnosis, then complete units, on a saved build closure."""
import argparse, json, os, re, subprocess, time
from pathlib import Path
from build import environment, ROOT

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--units', nargs='+', default=['mj-inverse_kernels', 'mj-inverse_mass'])
    parser.add_argument('--only', help='One subprogram name within the selected units')
    parser.add_argument('--timeout', type=int, default=5)
    parser.add_argument('--wall', type=int, default=180)
    parser.add_argument('--phase', choices=['small', 'whole', 'all'], default='all')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    snap = args.build.resolve() / 'source'
    env = environment()
    env['INVERSE_BUILD_ROOT'] = str(args.out / 'build')
    env['INVERSE_MODE'] = 'validation'
    project = snap / 'experimental/inverse-dynamics/inverse.gpr'
    records = []
    for unit in args.units:
        body = snap / ('experimental/inverse-dynamics/src/' + unit + '.adb')
        small = [(match.group(1), body.read_text().count('\n', 0, match.start()) + 1)
                 for match in re.finditer(r'^   (?:function|procedure) (\w+)', body.read_text(), re.M)]
        selected = small if args.phase == 'small' else [('whole', None)] if args.phase == 'whole' else small + [('whole', None)]
        if args.only: selected = [x for x in selected if x[0] == args.only]
        for name, line in selected:
            label = unit + '-' + name
            log = args.out / (label + '.log')
            command = ['gnatprove', '-P', str(project), '-u', unit + '.adb', '--mode=all',
                       '--prover=cvc5,z3,altergo', '--proof=per_check', '--timeout=' + str(args.timeout),
                       '--steps=0', '-j1', '--checks-as-errors=on', '--report=all', '--output=oneline', '--warnings=continue']
            if line is not None:
                command.append('--limit-subp=' + unit + '.adb:' + str(line))
            start = time.monotonic()
            with log.open('w') as output:
                run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '3000',
                                      '--timeout', str(args.wall), '--', *command], env=env,
                                     stdout=output, stderr=subprocess.STDOUT)
            text = log.read_text()
            successful_count = re.search(r'Success: all checks proved \((\d+) checks\)', text)
            checks = int(successful_count.group(1)) if successful_count else len(re.findall(r'\binfo: .* proved', text))
            diagnostics = [line for line in text.splitlines()
                           if re.search(r'(?:^|\s|:)\s*(?:low|medium|high|warning|error):', line)]
            data = {}
            spark = list((args.out / 'build').rglob(unit + '.spark'))
            if spark:
                data = json.loads(spark[0].read_text())
                (args.out / (label + '.spark.json')).write_bytes(spark[0].read_bytes())
            record = dict(unit=unit, subprogram=name, exit=run.returncode,
                          seconds=time.monotonic() - start, checks=checks,
                          diagnostics=diagnostics, command=command)
            messages = [m for k in ['proof', 'flow', 'warn_error'] for m in data.get(k, [])]
            record.update(proof_checks=sum(m.get('severity') == 'info' for m in data.get('proof', [])),
                flow_checks=sum(m.get('severity') == 'info' for m in data.get('flow', [])),
                open=[m for m in messages if m.get('severity') not in ['info', 'warning']],
                coverage=bool(data.get('spark')) and all(v == 'all' for v in data.get('spark', {}).values())
                    and not any(data.get(k) for k in ['skip_proof', 'skip_flow_proof', 'pragma_assume']))
            records.append(record)
            (args.out / 'summary.json').write_text(json.dumps(records, indent=2) + '\n')
            print(label, run.returncode, checks, 'diagnostics', len(diagnostics), flush=True)
    (args.out / 'source-manifest.json').write_bytes((args.build / 'manifest.json').read_bytes())
    passed = bool(records) and all(r['exit'] == 0 and r['coverage']
        and r['proof_checks'] > 0 and not r['open'] for r in records)
    raise SystemExit(0 if passed else 1)

if __name__ == '__main__':
    main()
