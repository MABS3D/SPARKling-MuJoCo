"""Bounded proofs of frozen SDF inputs, from scalar helpers to composition.

An interrupted run retains one receipt per completed scope. Flow, individual
contracts and whole-unit proofs are recorded separately; an open scope fails
the command rather than silently extending a helper's evidence to its callers.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import time

from build import ROOT, environment


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    scopes = ['Proxy_Extent', 'Bounded_Index', 'kernels', 'scene-flow', 'step-flow',
              'scene', 'step']
    parser.add_argument('--scope', action='append', choices=scopes)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    snapshot = args.build.resolve() / 'source'
    manifest = json.loads((args.build / 'manifest.json').read_text())
    for name, expected in manifest['sources'].items():
        if hashlib.sha256((snapshot / name).read_bytes()).hexdigest() != expected:
            raise RuntimeError('Frozen source differs from its manifest: ' + name)
    (args.out / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n')
    project = snapshot / 'experimental/sdf-step/sdf.gpr'
    rows = []
    for scope in args.scope or scopes[:5]:
        unit = ('mj-sdf_scene.adb' if scope.startswith('scene') else
                'mj-data-constrained-sdf.adb' if scope.startswith('step') else
                'mj-sdf_kernels.adb')
        env = environment()
        env.update(SDF_BUILD_ROOT=str(args.out.resolve() / scope), SDF_MODE='validation')
        command = ['gnatprove', '-P', str(project), '-u', unit, '-j1',
                   '--report=all', '--checks-as-errors=on', '--warnings=continue']
        if scope.endswith('-flow'):
            command += ['--mode=flow']
        else:
            command += ['--mode=prove', '--prover=cvc5,z3,altergo', '--timeout=3',
                        '--memlimit=650', '--steps=0', '--proof=per_check',
                        '--counterexamples=off', '--no-inlining']
        if scope in ['Proxy_Extent', 'Bounded_Index']:
            filename = 'mj-sdf_kernels.' + ('ads' if scope == 'Bounded_Index' else 'adb')
            lines = (snapshot / 'experimental/sdf-step/src' / filename).read_text().splitlines()
            line = next(i for i, text in enumerate(lines, 1)
                        if re.match(r'\s*function ' + scope + r'\b', text))
            command += ['--limit-subp=' + filename + ':' + str(line)]
        guarded = ['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '2500',
                   '--timeout', '180', '--', *command]
        started = time.monotonic()
        with (args.out / (scope + '.log')).open('w') as log:
            run = subprocess.run(guarded, env=env, stdout=log, stderr=subprocess.STDOUT)
        reports = args.out / scope / 'validation/obj/gnatprove'
        for report in reports.glob('*.spark'):
            shutil.copyfile(report, args.out / (scope + '--' + report.name))
        report = reports / (Path(unit).stem + '.spark')
        entries=[]
        if report.is_file():
            data=json.loads(report.read_text())
            entries=[entry for kind in ('proof','flow','warn_error') for entry in data.get(kind,[])]
        open_checks=sum(entry.get('severity') not in ('info','warning') for entry in entries)
        row = dict(scope=scope, kind='flow' if scope.endswith('-flow') else 'proof',
                   exit=run.returncode, checks=sum(e.get('severity')=='info' for e in entries),
                   open=open_checks, warnings=sum(e.get('severity')=='warning' for e in entries),
                   passed=run.returncode == 0 and report.is_file() and open_checks==0,
                   seconds=time.monotonic() - started, command=guarded)
        rows.append(row)
        (args.out / 'results.json').write_text(json.dumps(dict(
            scopes=rows, complete=len(rows) == len(args.scope or scopes[:5]),
            runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            limits='Flow does not establish runtime safety or functional behavior; '
                   'a caller proof depends on every called contract being established.'), indent=2) + '\n')
        print(json.dumps(row), flush=True)
    raise SystemExit(not all(row['passed'] for row in rows))


if __name__ == '__main__':
    main()
