#!/usr/bin/env python3
"""Numeric-domain stress, failure atomicity, capacities and deterministic replay.

These tests check failure behavior and finite outputs, not solution accuracy on
ill-conditioned problems; native accuracy is checked by differential.py.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
import numpy as np
from differential import run, row


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True); args = ap.parse_args()
    rng = np.random.default_rng(661)
    problems = []
    for seed in range(80):
        n = 1+seed % 4; k = 1+seed % 6
        m = np.diag(10.**rng.uniform(-13, 9, n))
        j = rng.uniform(-1, 1, (k, n))*10.**rng.uniform(-9, 9, (k, n))
        for method in range(3):
            problems.append(dict(name=f'extreme-{seed}', method=method, iterations=20, M=m, J=j,
                free=rng.uniform(-1e9, 1e9, n), ref=rng.uniform(-1e9, 1e9, k),
                a0=np.zeros(n), f0=np.zeros(k),
                rows=[row(t % 3, r=10.**rng.uniform(-11, 11), bound=1e4) for t in range(k)]))
    outputs = run(args.binary, problems)
    failures = []
    for p, o in zip(problems, outputs):
        if not np.isfinite(o['a']).all() or not np.isfinite(o['f']).all(): failures.append(p['name'])
        if o['status'] in ['INVALID_INPUT', 'NOT_POSITIVE_DEFINITE']: failures.append(p['name']+'-unexpected-rejection')
        if o['status'] == 'NUMERIC_LIMIT' and not (np.array_equal(o['a'], p['a0']) and np.array_equal(o['f'], p['f0'])):
            failures.append(p['name']+'-not-atomic')
    replay = run(args.binary, problems)
    for p, a, b in zip(problems, outputs, replay):
        if any(a[k] != b[k] for k in a if k not in ['a', 'f']) or not np.array_equal(a['a'], b['a']) or not np.array_equal(a['f'], b['f']):
            failures.append(p['name']+'-not-deterministic')
    capacities = []
    for n, k, expected in [(0, 0, 'INVALID_INPUT'), (129, 0, 'INVALID_INPUT'),
                           (1, 257, 'INVALID_INPUT'), (128, 0, 'CONVERGED'),
                           (1, 256, 'CONVERGED')]:
        p = dict(name=f'capacity-{n}-{k}', method=2, M=np.eye(n), J=np.zeros((k, n)),
                 free=np.zeros(n), ref=np.zeros(k), a0=np.zeros(n), f0=np.zeros(k),
                 rows=[row() for _ in range(k)])
        capacities.append((p, expected))
    for (p, expected), o in zip(capacities, run(args.binary, [p for p, _ in capacities])):
        if o['status'] != expected: failures.append(p['name'])
    result = dict(binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        stress_cases=len(problems), replay_cases=len(replay), capacity_cases=len(capacities),
        outcomes=dict(Counter(o['status'] for o in outputs)), failures=failures,
        passed=not failures)
    args.out.parent.mkdir(parents=True, exist_ok=True); args.out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))
    raise SystemExit(bool(failures))

if __name__ == '__main__': main()
