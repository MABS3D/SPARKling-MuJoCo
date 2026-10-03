"""Diagnose both arithmetic kernels first, then prove the complete helper unit."""
import argparse
import json
import re
import shutil
import subprocess
import time
from pathlib import Path

from build import ROOT, environment

p = argparse.ArgumentParser()
p.add_argument('--build', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
args = p.parse_args()
args.out.mkdir(parents=True, exist_ok=False)
(args.out / 'sources.json').write_text((args.build / 'manifest.json').read_text())
source = args.build / 'source/experimental/constrained-step'
body = source / 'src/mj-elliptic_response.adb'
targets = [(match[1], f'mj-elliptic_response.adb:{line}')
           for line, text in enumerate(body.read_text().splitlines(), 1)
           if (match := re.match(r'\s*function (\w+)', text))]
targets.append(('whole', None))
records = []
for label, target in targets:
    env = environment()
    env['CONSTRAINED_BUILD_ROOT'] = str(args.out / label)
    env['CONSTRAINED_MODE'] = 'validation'
    command = ['gnatprove', '-P', str(source / 'constrained.gpr'), '-u', 'mj-elliptic_response.adb',
               '--prover=cvc5,z3,altergo', '--timeout=15', '--memlimit=700', '--steps=0',
               '--proof=per_check', '-j1', '--checks-as-errors=on', '--warnings=continue',
               '--report=all', '--counterexamples=off']
    if target:
        command.append('--limit-subp=' + target)
    start = time.monotonic()
    run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '2600',
                          '--timeout', '110', '--', *command], env=env, capture_output=True, text=True)
    (args.out / (label + '.log')).write_text(run.stdout + run.stderr)
    record = dict(label=label, exit=run.returncode, seconds=time.monotonic() - start, command=command)
    report = next((path for path in (args.out / label).rglob('mj-elliptic_response.spark')), None)
    if report:
        data = json.loads(report.read_text())
        shutil.copyfile(report, args.out / (label + '.spark.json'))
        entries = [item for kind in ['proof', 'flow', 'warn_error'] for item in data.get(kind, [])]
        record.update(passed=sum(item.get('severity') == 'info' for item in entries),
                      open=sum(item.get('severity') not in ('info', 'warning') for item in entries),
                      warnings=sum(item.get('severity') == 'warning' for item in entries))
    records.append(record)
    print(record, flush=True)
(args.out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
if not all(record['exit'] == 0 and record.get('open') == 0 and record.get('warnings') == 0 for record in records):
    raise SystemExit(1)
