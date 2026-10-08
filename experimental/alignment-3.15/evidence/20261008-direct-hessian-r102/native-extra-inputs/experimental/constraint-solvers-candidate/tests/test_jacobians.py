"""Exact native reductions, preserving CSR zeros, duplicates, order and gaps."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    lib = ctypes.CDLL(str(library))
    double = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
    integer = np.ctypeslib.ndpointer(dtype=np.int32, flags='C_CONTIGUOUS')
    lib.mju_mulMatVecSparse.argtypes = [double, double, double, ctypes.c_int,
                                      integer, integer, integer, ctypes.c_void_p]
    rng = np.random.default_rng(314100313)
    cases, lines = [], []
    for count in [*range(17), 31, 32, 33, 63, 127, 128, 129, 257, 1025]:
        for mode in ['random', 'zeros', 'cancellation', 'duplicate', 'signed-zero']:
            # Coalesced dense entries must also remain in the kernel operand domain.
            for scale in [1., 1e-120, 1e116]:
                n, rows = 7, 3
                widths = np.array([count, count//2, count % 5], dtype=np.int32)
                offsets = np.array([2, 3+count, 5+count+count//2], dtype=np.int32)
                stored = int(offsets[-1]+widths[-1])
                indices = rng.integers(0, n, stored, dtype=np.int32)
                values = rng.uniform(-1, 1, stored)*scale
                x = rng.uniform(-1, 1, n)*scale
                if mode == 'zeros':
                    values[::2] = 0.
                elif mode == 'cancellation':
                    values[:] = np.resize([1., 1e-16, -1., 1e-16, 0., 1e-20, -1e-20], stored)*scale
                    x[:] = scale
                elif mode == 'duplicate':
                    indices[:] = np.resize([6, 0, 6, 0, 1], stored)
                elif mode == 'signed-zero':
                    values[:] = np.resize([-0., 0., -0., 0., 0.], stored)
                    x[:] = np.resize([-1., 1.], n)
                expected = np.empty(rows)
                lib.mju_mulMatVecSparse(expected, values, x, rows, widths, offsets, indices, None)
                dense = np.zeros((rows, n))
                sequential = np.zeros(rows)
                for r in range(rows):
                    for i in range(offsets[r], offsets[r]+widths[r]):
                        dense[r, indices[i]] += values[i]
                        sequential[r] += values[i]*x[indices[i]]
                expected_dense = np.array([mujoco.mju_dot(row, x) for row in dense])
                fields = [n, rows, stored, *np.column_stack([offsets, widths]).ravel(),
                          *(indices+1), *values, *x]
                lines.append(' '.join(format(float(v), '.17g') for v in fields)+'\n')
                cases.append(dict(count=count, mode=mode, scale=scale,
                    expected=expected, dense=expected_dense,
                    differs_from_sequential=bool(np.any(sequential != expected))))
    # Invalid layouts are rejected before touching their rows.
    invalid = ['2 1 1 1 1 1 0 1 1\n', '2 1 1 0 1 3 0 1 1\n',
               '2 1 1 1048576 1 1 0 1 1\n']
    payload = ''.join(lines+invalid)
    args.out.mkdir(parents=True, exist_ok=False)
    (args.out/'input.txt').write_text(payload)
    run = subprocess.run([str(args.binary)], input=payload, text=True, capture_output=True, timeout=60)
    (args.out/'output.txt').write_text(run.stdout+run.stderr)
    assert run.returncode == 0, run.stderr
    output = run.stdout.splitlines()
    assert len(output) == len(cases)+len(invalid)
    records = []
    for line, case in zip(output, cases):
        got = np.fromstring(line, sep=' ').reshape(-1, 2)
        expected = np.column_stack([case.pop('expected'), case.pop('dense')])
        records.append(dict(**case, passed=bool(np.array_equal(got.view(np.uint64), expected.view(np.uint64))),
                            ada=got.tolist(), native=expected.tolist()))
    rejected = output[len(cases):] == ['INVALID']*len(invalid)
    failures = [r for r in records if not r['passed']]
    report = dict(reference=mujoco.__version__, cases=len(cases), passed=len(cases)-len(failures),
        malformed_rejected=rejected, failures=failures, records=records,
        differs_from_sequential=sum(r['differs_from_sequential'] for r in records),
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (args.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(report['passed'], '/', report['cases'], 'exact native CSR+dense reductions;',
          report['differs_from_sequential'], 'distinguish reduction order; malformed:', rejected)
    raise SystemExit(bool(failures) or not rejected)


if __name__ == '__main__':
    main()
