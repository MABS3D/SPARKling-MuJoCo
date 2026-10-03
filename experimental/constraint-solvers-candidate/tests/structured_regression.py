"""Compare separated/permuted quadratic systems with an independent dense solve.

The objective is globally coupled through its stopping test even for separated
blocks. Interleaving the coordinates exercises conservative block merging.
"""
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np
from differential import row, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    rng = np.random.default_rng(841002)
    problems, expected = [], []
    for groups in (1, 2, 4, 8, 16):
        width, rows_per_group = 6, 8
        n, k = width * groups, rows_per_group * groups
        mass, jac = np.zeros((n, n)), np.zeros((k, n))
        for group in range(groups):
            first, rfirst = group * width, group * rows_per_group
            basis = rng.uniform(-.3, .3, (width, width))
            block = np.eye(width) + basis.T @ basis
            mass[first:first+width, first:first+width] = (block + block.T) * .5
            jac[rfirst:rfirst+rows_per_group, first:first+width] = rng.uniform(-.7, .7, (rows_per_group, width))
        free, ref = rng.uniform(-1, 1, n), rng.uniform(-1, 1, k)
        reg = rng.uniform(.2, 1.1, k)
        target = np.linalg.solve(mass + jac.T @ (jac / reg[:, None]),
                                 mass @ free + jac.T @ (ref / reg))
        force = (ref - jac @ target) / reg
        permutations = [np.arange(n), np.arange(n)[::-1],
                        np.arange(n).reshape(groups, width).T.ravel()]
        for order, permutation in enumerate(permutations):
            for method in range(3):
                problems.append(dict(name=f'{groups}-blocks-order-{order}-method-{method}',
                    method=method, M=mass[np.ix_(permutation, permutation)], J=jac[:, permutation],
                    free=free[permutation], ref=ref, a0=np.zeros(n), f0=np.zeros(k),
                    tolerance=1e-14, rows=[row(kind=0, r=r) for r in reg]))
                expected.append((target[permutation], force))
    outputs = run(args.binary, problems)
    records = []
    for p, actual, (acceleration, force) in zip(problems, outputs, expected):
        accepted = actual['status'] == 'CONVERGED'
        close = np.allclose(actual['a'], acceleration, atol=2e-7, rtol=2e-7)
        close = close and np.allclose(actual['f'], force, atol=2e-7, rtol=2e-7)
        records.append(dict(name=p['name'], passed=bool(accepted and close),
                            status=actual['status'], iterations=actual['iterations'],
                            acceleration_max_abs=float(np.max(np.abs(actual['a']-acceleration))),
                            force_max_abs=float(np.max(np.abs(actual['f']-force)))))
    failures = [r for r in records if not r['passed']]
    report = dict(binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  cases=len(records), passed=len(records)-len(failures),
                  failures=failures, records=records)
    args.out.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'records'}, indent=2))
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
