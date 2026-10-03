"""Exact ordered dense factor comparison, including C deficient pivot policy."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    rng = np.random.default_rng(3141003)
    cases = []
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128]:
        for scale in [1e-20, 1e-10, 1., 1e10, 1e20]:
            m = rng.uniform(-1, 1, (n, n))
            spd = (m @ m.T + np.eye(n)) * scale
            mixed = spd.copy()
            mixed[np.arange(1, n, 3), np.arange(1, n, 3)] = 0.
            for kind, matrix in [('spd', spd), ('zero', np.zeros((n, n))),
                                 ('deficient', spd - np.eye(n) * scale * n),
                                 ('mixed-pivots', mixed)]:
                # C ignores and preserves the upper triangle.
                matrix[np.triu_indices(n, 1)] = 3.14
                cases.append((kind, scale, 1e-15, matrix, rng.uniform(-1, 1, n)))
    for diag in [-1., 0., np.nextafter(1e-15, 0.), 1e-15, np.nextafter(1e-15, np.inf)]:
        cases.append(('pivot-neighbor', 1., 1e-15, np.array([[diag]]), np.array([1.])))
    payload = ''.join(f'{len(m)} {floor:.17g} ' + ' '.join(format(x, '.17g') for x in np.r_[m.ravel(), rhs]) + '\n'
                      for kind, scale, floor, m, rhs in cases)
    run = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    a.out.mkdir(parents=True, exist_ok=False)
    (a.out/'input.txt').write_text(payload)
    (a.out/'output.txt').write_text(run.stdout + run.stderr)
    if run.returncode:
        raise RuntimeError(run.stdout[-1000:] + run.stderr)
    lines = run.stdout.splitlines()
    assert len(lines) == len(cases)
    records = []
    for line, (kind, scale, floor, matrix, rhs) in zip(lines, cases):
        cols = line.split()
        end_factor = 2 + matrix.size
        got = np.asarray([float(x) for x in cols[2:end_factor]]).reshape(matrix.shape)
        solved = np.asarray([float(x) for x in cols[end_factor+1:]])
        ref = matrix.copy()
        rank = mujoco.mju_cholFactor(ref, floor)
        expected = np.empty(len(matrix))
        mujoco.mju_cholSolve(expected, ref, rhs)
        records.append(dict(n=len(matrix), kind=kind, scale=scale,
                            passed=cols[0] == 'SUCCESS' and int(cols[1]) == rank and bool(np.array_equal(got, ref))
                            and cols[end_factor] == 'SUCCESS' and bool(np.array_equal(solved, expected)),
                            ada_rank=int(cols[1]), native_rank=rank,
                            max_error=float(np.max(np.abs(got-ref))),
                            solve_error=float(np.max(np.abs(solved-expected)))))
    failures = [r for r in records if not r['passed']]
    report = dict(reference=mujoco.__version__, cases=len(cases), passed=len(cases)-len(failures),
                  failures=failures, records=records,
                  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest())
    (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(report['passed'], '/', report['cases'], 'exact factors, ranks and solves')
    raise SystemExit(bool(failures))

if __name__ == '__main__':
    main()
