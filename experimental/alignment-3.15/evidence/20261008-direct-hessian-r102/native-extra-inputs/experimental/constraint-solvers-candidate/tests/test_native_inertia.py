"""Compare the Ada LDL backsolve with official mj_solveLD, preserving slots.

Native replay inputs use exported C factors only in this kernel test. Runtime
integration must obtain its factors from Ada. Random inputs cover arbitrary
strict lower layouts, structural zeros, SIMD tails and output atomicity.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np


def encode(p):
    fields = [len(p['rhs']), len(p['values'])]
    fields.extend(np.column_stack([p['offsets'], p['widths']]).ravel())
    fields.extend(np.asarray(p['columns']) + 1)
    fields.extend(p['values']); fields.extend(p['inverse']); fields.extend(p['rhs'])
    return ' '.join(format(float(x), '.17g') for x in fields) + '\n'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--replays', type=Path)
    args = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    lib = ctypes.CDLL(str(library))
    dp = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
    ip = np.ctypeslib.ndpointer(dtype=np.int32, flags='C_CONTIGUOUS')
    lib.mj_solveLD.argtypes = [dp, dp, dp, ctypes.c_int, ctypes.c_int, ip, ip, ip, ctypes.c_void_p]
    cases = []
    rng = np.random.default_rng(271828)
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16, 24, 32, 64, 96, 128]:
        for sample in range(12):
            offsets, widths, columns, values = [], [], [], []
            for r in range(n):
                offsets.append(len(values))
                cols = [c for c in range(r) if sample % 4 == 0 or rng.random() < .17]
                widths.append(len(cols)); columns.extend(cols)
                row = rng.uniform(-.05, .05, len(cols))
                row[rng.random(len(cols)) < .2] = 0.
                if sample % 3 == 0:
                    row[row == 0.] = -0.
                values.extend(row)
                # Store the diagonal too, as in the production factor; its
                # slot is deliberately outside the strict-lower row width.
                columns.append(r); values.append(1.)
            rhs = rng.uniform(-2., 2., n)
            if sample % 3 == 0:
                rhs[:] = -0. if sample % 2 else 0.
            inverse = rng.uniform(.2, 3., n)
            cases.append(dict(name=f'random-{n}-{sample}', offsets=offsets, widths=widths,
                columns=columns, values=values, rhs=rhs.tolist(), inverse=inverse.tolist()))
    if args.replays:
        for number, case in enumerate(json.loads(args.replays.read_text())):
            m = case['native_mass']
            for name in ['native_smooth_force', 'expected_acceleration']:
                cases.append(dict(name=f'native-{number}-{name}', offsets=m['rowadr'],
                    widths=[v-1 for v in m['rownnz']], columns=m['colind'], values=m['qLD'],
                    inverse=m['qLDiagInv'], rhs=case[name]))
    expected = []
    for p in cases:
        out = np.array(p['rhs'], dtype=np.float64)
        lib.mj_solveLD(out, np.array(p['values'], dtype=np.float64),
            np.array(p['inverse'], dtype=np.float64), len(out), 1,
            np.array(p['widths'], dtype=np.int32)+1,
            np.array(p['offsets'], dtype=np.int32), np.array(p['columns'], dtype=np.int32), None)
        expected.append(('SUCCESS', out))
    good = dict(name='base', offsets=[0, 1], widths=[0, 1], columns=[0, 0, 1],
                values=[1., .1, 1.], rhs=[1., 2.], inverse=[1., 1.])
    rejected = [dict(good, name='bad-offset', offsets=[0, 4]),
        dict(good, name='bad-width', widths=[0, 3]),
        dict(good, name='upper-column', columns=[0, 1, 1]),
        dict(good, name='negative-inverse', inverse=[-1., 1.]),
        dict(good, name='large-factor', values=[1., 1e101, 1.]),
        dict(good, name='large-rhs', rhs=[1e101, 1.]),
        dict(good, name='numeric-scale', rhs=[1e100, 0.], inverse=[1e16, 1.]),
        dict(good, name='numeric-scatter', rhs=[0., 1e100], values=[1., 1e100, 1.])]
    cases += rejected
    expected += [('NUMERIC_LIMIT' if p['name'].startswith('numeric-') else 'INVALID_INPUT',
                  np.full(2, .375)) for p in rejected]
    args.out.mkdir(parents=True, exist_ok=False)
    payload = ''.join(map(encode, cases)); (args.out/'input.txt').write_text(payload)
    p = subprocess.run([str(args.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (args.out/'output.txt').write_text(p.stdout+p.stderr)
    assert p.returncode == 0, p.stderr
    lines = p.stdout.splitlines(); assert len(lines) == len(cases)
    records = []
    for c, (status, ref), line in zip(cases, expected, lines):
        fields = line.split(); got = np.array(fields[1:], dtype=np.float64)
        passed = fields[0] == status and np.array_equal(got.view(np.uint64), ref.view(np.uint64))
        records.append(dict(name=c['name'], passed=bool(passed), status=fields[0], expected_status=status,
            error=float(np.max(np.abs(got-ref), initial=0))))
    failures = [r for r in records if not r['passed']]
    result = dict(cases=len(records), passed=len(records)-len(failures), failures=failures,
        records=records, reference=mujoco.__version__, bitwise=True,
        wrong_output_origin_rejected_for_every_case=True,
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        input_sha256=hashlib.sha256(payload.encode()).hexdigest(),
        runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(result['passed'], '/', result['cases'], 'native LDL backsolve')
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
