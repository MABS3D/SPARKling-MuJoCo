#!/usr/bin/env python3
"""Check edge arithmetic against native C, including zero-axis branches."""
import argparse
import ctypes
import hashlib
import itertools
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.14.0'
    args.out.mkdir(parents=True, exist_ok=False)
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    lib = ctypes.CDLL(str(library))
    ptr = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
    lib.mju_mulMatTVec.argtypes = [ptr, ptr, ptr, ctypes.c_int, ctypes.c_int]
    lib.mju_mulMatTVec.restype = None
    lib.mju_sub3.argtypes = [ptr, ptr, ptr]
    lib.mju_sub3.restype = None
    cases = []
    for length, rest in itertools.product([0., -0., 1e-15, 1., 1e10], repeat=2):
        result = np.empty(3)
        lib.mju_sub3(result, np.array([length, 0., 0.]), np.array([rest, 0., 0.]))
        cases.append(('residual', [0, length, rest], float(result[0])))
    rng = np.random.default_rng(20261003)
    projections = []
    for direction in itertools.product([0., -0., 1., -1.], repeat=3):
        for jac in ([0., -0., 0.], [1., -2., 3.], [1e30, -1e30, 1e-30]):
            projections.append((jac, direction))
    for scale in [1e-20, 1., 1e20, 1e30]:
        for _ in range(64):
            jac = rng.uniform(-1., 1., 3)*scale
            direction = rng.uniform(-1., 1., 3)*scale
            direction[rng.integers(0, 3)] = rng.choice([0., -0.])
            projections.append((jac, direction))
    for jac, direction in projections:
        result = np.empty(1)
        lib.mju_mulMatTVec(result, np.ascontiguousarray(jac, dtype=np.float64),
                          np.ascontiguousarray(direction, dtype=np.float64), 3, 1)
        cases.append(('projection', [1, *jac, *direction], float(result[0])))
    # Exercise the ordinary C vector implementation, including AVX blocks
    # and tails, while the Ada kernel computes each resulting column.
    for width in [1, 4, 5, 16, 17, 64, 128]:
        for direction in ([0., -0., 0.], [1., 0., 0.], [0., -1., 0.],
                          [0., 0., 1.], [1., -1., 1.],
                          [1e30, -1e30, 1e30]):
            matrix = np.ascontiguousarray(rng.uniform(-1., 1., (3, width))*1e30)
            result = np.empty(width)
            lib.mju_mulMatTVec(result, matrix.ravel(),
                              np.ascontiguousarray(direction, dtype=np.float64), 3, width)
            for column in range(width):
                cases.append((f'projection-C-width-{width}',
                              [1, *matrix[:, column], *direction], float(result[column])))
    payload = '\n'.join(' '.join(str(x) if isinstance(x, int) else format(x, '.17g')
                                for x in values) for _, values, _ in cases)+'\n'
    (args.out/'input.txt').write_text(payload)
    run = subprocess.run([str(args.binary.resolve())], input=payload,
                         text=True, capture_output=True, timeout=60)
    (args.out/'probe.log').write_text(run.stdout+run.stderr)
    actual = [float(x) for x in run.stdout.split()] if run.returncode == 0 else []
    records = []
    for i, (kind, values, expected) in enumerate(cases):
        found = actual[i] if i < len(actual) else None
        same = (found is not None and
                np.float64(found).tobytes() == np.float64(expected).tobytes())
        records.append(dict(index=i, kind=kind, input=values, expected=expected,
                            actual=found, passed=same))
    result = dict(reference=mujoco.__version__,
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  input_sha256=hashlib.sha256(payload.encode()).hexdigest(),
                  returncode=run.returncode, cases=len(cases), outputs=len(actual),
                  passed=sum(r['passed'] for r in records), records=records,
                  scope='edge residual/projection kernels; flex integration pending')
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'records'}))
    raise SystemExit(0 if run.returncode == 0 and len(actual) == len(cases)
                     and all(r['passed'] for r in records) else 1)


if __name__ == '__main__':
    main()
