#!/usr/bin/env python3
"""Replay the preceding stage's exact inputs (new fixtures change RNG order)."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--probe', type=Path, required=True)
p.add_argument('--prior', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--policy', choices=['Compatible', 'Strict'], required=True)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
sha = lambda b: hashlib.sha256(b).hexdigest()
rows = []
for previous in sorted(a.prior.glob('*.output')):
    name = previous.stem
    model = a.prior / (name + '.mjb')
    input_path = a.prior / (name + '.input')
    command = [str(a.probe), str(model)]
    if not name.startswith('unsupported_'):
        command.append('Strict' if name.startswith('reject_') else a.policy)
    data = input_path.read_text() if input_path.exists() else ''
    run = subprocess.run(command, input=data, text=True, capture_output=True,
                         check=True, timeout=60)
    output = run.stdout + (run.stderr if name.startswith(('reject_', 'unsupported_')) else '')
    (a.out / previous.name).write_text(output)
    rows.append(dict(case=name, identical=output == previous.read_text(),
                     model_sha256=sha(model.read_bytes()), input_sha256=sha(data.encode()),
                     prior_sha256=sha(previous.read_bytes()), current_sha256=sha(output.encode())))
result = dict(policy=a.policy, probe=str(a.probe), probe_sha256=sha(a.probe.read_bytes()),
              prior=str(a.prior), cases=len(rows), identical=all(r['identical'] for r in rows), rows=rows)
(a.out / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
print(a.policy, len(rows), 'outputs; identical:', result['identical'])
if not result['identical']:
    raise SystemExit('Differences: ' + ', '.join(r['case'] for r in rows if not r['identical']))
