#!/usr/bin/env python3
"""Explicit numeric-limit paths and the proved zero-input properties."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--probe', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
cases = [
    (0, 2, 1, [1e-15, 7.0, 1e100, 1e-15], [0.0, 0.0], 'NUMERIC_LIMIT'),
    (1, 1, 1, [1e-15], [1e100], 'NUMERIC_LIMIT'),
    (2, 1, 1, [1e150], [1e150], 'NUMERIC_LIMIT'),
    (2, 2, 0, [1e-15, 7.0, 0.0, 1e-15], [1e150, 0.0], 'NUMERIC_LIMIT'),
    (2, 2, 0, [1e150, 7.0, 1e150, 1e150], [0.0, 0.0], 'SUCCESS'),
    (1, 2, 1, [1e-15, 7.0, 1e100, 1e-15], [0.0, 0.0], 'SUCCESS'),
]
inputs = '\n'.join(' '.join(map(str, [op, n, sign, 1e-15, *a, *x]))
                   for op, n, sign, a, x, _ in cases) + '\n'
result = subprocess.run([str(args.probe)], input=inputs, text=True,
                        capture_output=True, check=True)
tokens = iter(result.stdout.split())
for op, n, sign, a, x, expected in cases:
    assert next(tokens) == expected
    rank = int(next(tokens))
    aa = [float(next(tokens)) for _ in a]
    xx = [float(next(tokens)) for _ in x]
    assert 0 <= rank <= n
    bound = 1e150 if op == 2 else 1e100
    assert all(abs(v) <= bound for v in aa + xx)
    assert all(aa[i*n+j] == a[i*n+j] for i in range(n) for j in range(i+1, n))
    if op == 2:
        assert xx[0] == x[0]
        if all(v == 0 for v in x):
            assert aa == a and xx == x and rank == n
    if op == 1 and all(v == 0 for v in x):
        assert all(v == 0 for v in xx)
assert next(tokens, None) is None
report = {'cases': len(cases), 'status': 'passed',
          'binary_sha256': hashlib.sha256(args.probe.read_bytes()).hexdigest(),
          'scope': 'partial-result bounds, unchanged upper triangle, zero inputs and Numeric_Limit'}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
