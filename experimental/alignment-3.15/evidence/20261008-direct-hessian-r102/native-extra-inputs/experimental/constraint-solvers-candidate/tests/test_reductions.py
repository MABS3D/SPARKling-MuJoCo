"""Check the wide solver reduction against the official normal SIMD C path."""
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
    args = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    rng = np.random.default_rng(3141002)
    cases = []
    for n in [*range(17), 31, 32, 33, 63, 64, 65, 127, 128, 129, 255, 256]:
        for scale in [1e-120, 1., 1e60, 1e120]:
            for kind in ['random', 'self', 'cancellation']:
                a = rng.uniform(-1, 1, n) * scale
                b = rng.uniform(-1, 1, n) * scale
                if kind == 'self':
                    b = a.copy()
                if kind == 'cancellation':
                    a[:] = scale
                    b[:] = np.resize([scale, -scale, 0., scale / 3], n)
                cases.append((n, scale, kind, a, b))
    payload = ''.join(str(n) + ' ' + ' '.join(format(x, '.17g') for x in np.r_[a, b])
                      + '\n' for n, scale, kind, a, b in cases)
    run = subprocess.run([str(args.binary)], input=payload, text=True,
                         capture_output=True, timeout=60)
    if run.returncode:
        raise RuntimeError(run.stdout + run.stderr)
    output = np.fromstring(run.stdout, sep=' ')
    assert len(output) == len(cases)
    records = []
    for got, (n, scale, kind, a, b) in zip(output, cases):
        expected = mujoco.mju_dot(a, b)
        records.append(dict(n=n, scale=scale, kind=kind,
                            passed=bool(got == expected), ada=float(got), native=float(expected)))
    failures = [r for r in records if not r['passed']]
    args.out.mkdir(parents=True, exist_ok=False)
    (args.out / 'input.txt').write_text(payload)
    (args.out / 'output.txt').write_text(run.stdout + run.stderr)
    report = dict(reference=mujoco.__version__, cases=len(cases),
                  passed=len(cases) - len(failures), failures=failures, records=records,
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest())
    (args.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    print(report['passed'], '/', report['cases'], 'exact binary64 matches')
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
