"""Run the existing differential corpus through the original-force API.

Native fixtures carry qfrc_smooth directly; analytic fixtures reconstruct their
exact elementary input. The usual comparison, certificate, and warm-start
criteria are unchanged. The probe also tests three malformed optional-force
inputs and atomic rejection on every call.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

import numpy as np

import differential


def run(binary, problems):
    payload = ''
    for p in problems:
        smooth = p.get('native_smooth_force')
        if smooth is None:
            smooth = np.asarray(p['M']) @ np.asarray(p['free'])
        payload += differential.encode(p).rstrip() + ' ' + ' '.join(
            format(float(x), '.17g') for x in smooth) + '\n'
    result = subprocess.run([str(binary), '--with-force', '--smooth-force'],
                            input=payload, text=True, capture_output=True, timeout=120)
    if result.returncode:
        raise RuntimeError(result.stderr + result.stdout[-2000:])
    lines = result.stdout.splitlines()
    assert len(lines) == len(problems)
    records = []
    for p, line in zip(problems, lines):
        s = line.split()
        n, k = len(p['free']), len(p['ref'])
        assert len(s) == 9 + 2*n + k
        records.append(dict(status=s[0], iterations=int(s[1]), evaluations=int(s[2]),
            restarts=int(s[3]), line_search_limits=int(s[4]), curvature_repairs=int(s[5]),
            cost=float(s[6]), gradient=float(s[7]), improvement=float(s[8]),
            a=np.array(s[9:9+n], float), f=np.array(s[9+n:9+n+k], float)))
    return records


if __name__ == '__main__':
    differential.run = run
    try:
        differential.main()
    finally:
        output = Path(sys.argv[sys.argv.index('--out') + 1])
        if output.is_file():
            record = json.loads(output.read_text())
            record.update(original_smooth_force=True,
                force_shape_domain_atomicity_checked_for_every_case=True,
                runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                differential_sha256=hashlib.sha256(Path(differential.__file__).read_bytes()).hexdigest())
            output.write_text(json.dumps(record, indent=2) + '\n')
