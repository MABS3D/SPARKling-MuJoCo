"""Bounded minimal-first proofs; kernel Gold and integration flow stay separate."""
import argparse
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import time
from build import ROOT, HERE, FOLDERS, environment


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', required=True, type=pathlib.Path)
    parser.add_argument('--build', type=pathlib.Path, help='Use an existing frozen build closure')
    parser.add_argument('--only', action='append',
                        choices=['Component', 'Point', 'Rotation_Component', 'Compose', 'whole', 'flow'])
    parser.add_argument('--timeout', type=int, default=3)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    if args.build:
        snap = args.build / 'source'
        hashes = json.loads((args.build / 'manifest.json').read_text())['sources']
        changed = [name for name, value in hashes.items()
                   if hashlib.sha256((snap / name).read_bytes()).hexdigest() != value]
        if changed:
            raise RuntimeError('Frozen sources changed: ' + repr(changed))
        project = snap / 'experimental/flex-state-integration/flex_state.gpr'
    else:
        snap = args.out / 'source'
        hashes = {}
        for folder in FOLDERS:
            for source in (ROOT / folder).iterdir():
                if source.is_file() and source.suffix in ['.ads', '.adb']:
                    target = snap / source.relative_to(ROOT)
                    target.parent.mkdir(parents=True, exist_ok=True)
                    data = source.read_bytes(); target.write_bytes(data)
                    hashes[str(source.relative_to(ROOT))] = hashlib.sha256(data).hexdigest()
        project = snap / 'experimental/flex-state-integration/flex_state.gpr'
        shutil.copyfile(HERE / 'flex_state.gpr', project)
        hashes['experimental/flex-state-integration/flex_state.gpr'] = hashlib.sha256(project.read_bytes()).hexdigest()
        if any(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != value
               for name, value in hashes.items()):
            raise RuntimeError('Source changed while freezing proof inputs')
    environment_values = environment()
    scopes = []
    source = snap / 'experimental/flex-state-integration/src/mj-flex_state_kernels.adb'
    for scope in ['Component', 'Point', 'Rotation_Component', 'Compose', 'whole', 'flow']:
        if args.only and scope not in args.only:
            continue
        units = ['mj-flex_state', 'mj-data-flex_adapter'] if scope == 'flow' else ['mj-flex_state_kernels']
        command = ['gnatprove', '-P', str(project), '-XFLEX_STATE_BUILD_ROOT=' + str(args.out / scope),
                   '-j1', '--report=all', '--checks-as-errors=on', '--warnings=continue', '-u',
                   *[unit + '.adb' for unit in units]]
        if scope == 'flow':
            command += ['--mode=flow', '--no-inlining']
        else:
            command += ['--mode=prove', '--prover=cvc5,z3,altergo', '--timeout=' + str(args.timeout),
                        '--memlimit=650', '--steps=0', '--proof=per_check', '--no-inlining',
                        '--counterexamples=off']
            if scope != 'whole':
                line = next(i for i, text in enumerate(source.read_text().splitlines(), 1)
                            if re.match(r'\s*function ' + scope + r'\b', text))
                command += ['--limit-subp=mj-flex_state_kernels.adb:' + str(line)]
        guarded = [sys.executable, str(ROOT / 'tools/guarded.py'), '--cap-mb', '2500',
                   '--timeout', '180', '--', *command]
        started = time.monotonic()
        with (args.out / (scope + '.log')).open('w') as log:
            result = subprocess.run(guarded, env=environment_values, stdout=log, stderr=subprocess.STDOUT)
        row = dict(scope=scope, exit=result.returncode, seconds=time.monotonic() - started, command=guarded,
                   proved=0, open=0, warnings=0, reports=0)
        for unit in units:
            report = next((p for p in (args.out / scope).rglob('*.spark') if p.stem == unit), None)
            if report:
                shutil.copyfile(report, args.out / (scope + '-' + unit + '.spark.json'))
                data = json.loads(report.read_text())
                entries = [entry for kind in ['proof', 'flow', 'warn_error'] for entry in data.get(kind, [])]
                row['reports'] += 1
                row['proved'] += sum(e.get('severity') == 'info' for e in entries)
                row['warnings'] += sum(e.get('severity') == 'warning' for e in entries)
                row['open'] += sum(e.get('severity') not in ['info', 'warning'] for e in entries)
        row['ok'] = result.returncode == 0 and row['open'] == 0 and row['reports'] == len(units)
        scopes.append(row)
        print(json.dumps(row), flush=True)
        (args.out / 'summary.json').write_text(json.dumps(dict(
            scopes=scopes, sources=hashes, runner_sha256=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest()), indent=2) + '\n')
    raise SystemExit(any(not row['ok'] for row in scopes))


if __name__ == '__main__':
    main()
