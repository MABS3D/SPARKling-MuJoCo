"""Diagnose one real integration subprogram on an immutable build closure.

This receipt deliberately claims no complete-unit or complete-engine coverage.
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
    parser.add_argument('--unit', default='mj-data-constrained.adb')
    parser.add_argument('--name', required=True)
    parser.add_argument('--timeout', type=int, default=10)
    parser.add_argument('--wall-timeout', type=int, default=240)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.build / 'source'
    manifest = json.loads((args.build / 'manifest.json').read_text())
    def unchanged():
        return all(hashlib.sha256((source / name).read_bytes()).hexdigest() == value
                   for name, value in manifest['sources'].items())
    assert unchanged(), 'frozen source differs from its manifest'
    paths = [source / name for name in manifest['sources']
             if Path(name).name == args.unit]
    if len(paths) != 1:
        raise ValueError('Unit must name exactly one frozen source')
    text = paths[0].read_text()
    matches = list(re.finditer(r'^[ \t]*(?:function|procedure) '
        + re.escape(args.name) + r'\b', text, re.M))
    if len(matches) != 1:
        raise ValueError('Subprogram must name exactly one frozen body')
    line = text[:matches[0].start()].count('\n') + 1
    env = environment()
    env.update(CONSTRAINED_BUILD_ROOT=str(args.out / 'build'),
               CONSTRAINED_MODE='validation')
    command = ['gnatprove', '-P', str(source / 'experimental/constrained-step/constrained.gpr'),
        '-u', args.unit, '--limit-subp=' + args.unit + ':' + str(line),
        '--prover=cvc5,z3,altergo', '--timeout=' + str(args.timeout),
        '--memlimit=800', '--steps=0', '--proof=per_check', '--no-inlining',
        '-j1', '--checks-as-errors=on', '--warnings=continue', '--report=all',
        '--counterexamples=off']
    start = time.monotonic()
    run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'),
        '--cap-mb', '3000', '--min-free-mb', '12000',
        '--timeout', str(args.wall_timeout), '--', *command],
        env=env, capture_output=True, text=True)
    (args.out / 'proof.log').write_text(run.stdout + run.stderr)
    record = dict(unit=args.unit, subprogram=args.name, command=command,
                  code=run.returncode, seconds=time.monotonic() - start,
                  complete_unit=False, passed=False)
    report = args.out / 'build/validation/obj/gnatprove' / (Path(args.unit).stem + '.spark')
    if report.is_file():
        data = json.loads(report.read_text())
        shutil.copyfile(report, args.out / 'proof.spark.json')
        entries = [item for kind in ('proof', 'flow', 'warn_error')
                   for item in data.get(kind, [])]
        record.update(checks=sum(item.get('severity') == 'info' for item in entries),
                      open=[item for item in entries if item.get('severity') not in ('info', 'warning')],
                      warnings=[item for item in entries if item.get('severity') == 'warning'])
        record['passed'] = (run.returncode == 0 and not record['open']
                            and not record['warnings'] and not data['pragma_assume'])
    assert unchanged(), 'frozen source changed during proof'
    record['snapshot_hashes_unchanged'] = True
    record['checkout_matches_snapshot'] = all((ROOT / name).is_file()
        and hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == value
        for name, value in manifest['sources'].items())
    (args.out / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (args.out / 'results.json').write_text(json.dumps(record, indent=2) + '\n')
    print({key: value for key, value in record.items()
           if key not in ('command', 'open', 'warnings')})
    raise SystemExit(0 if record['passed'] else 1)


if __name__ == '__main__':
    main()
