#!/usr/bin/env python3
"""Bitwise comparison of ordered rank-one updates with official C 3.14 bodies."""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', required=True, type=Path)
    ap.add_argument('--out', required=True, type=Path)
    ap.add_argument('--reference', type=Path, default=Path('/var/tmp/sparkling-movement-c/source'))
    a = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True, exist_ok=False)
    package = Path(mujoco.__file__).parent
    library = package/'libmujoco.so.3.14.0'
    source = a.reference/'src/engine/engine_util_solve.c'
    original = source.read_text()
    dense_body = original.split('int mju_cholUpdate(', 1)[1].split('//---------------------------- sparse Cholesky', 1)[0]
    sparse_body = original.split('int mju_cholUpdateSparse(', 1)[1].split('//---------------------------- banded Cholesky', 1)[0]
    helper = a.out/'reference.c'
    helper.write_text('#include "engine/engine_util_blas.h"\n#include "engine/engine_util_sparse.h"\n'
                      'int reference_dense('+dense_body+'\nint reference_sparse('+sparse_body)
    command = ['gcc', '-shared', '-fPIC', '-O3', '-march=native', '-DmjUSEPLATFORMSIMD', '-ffp-contract=off',
               '-I'+str(a.reference/'src'), '-I'+str(package/'include'), str(helper), str(library),
               '-Wl,-rpath,'+str(package), '-o', str(a.out/'reference.so')]
    subprocess.run(command, check=True, capture_output=True, text=True)
    lib = ct.CDLL(str(a.out/'reference.so'))
    dp, ip = ct.POINTER(ct.c_double), ct.POINTER(ct.c_int)
    lib.reference_dense.argtypes = [dp, dp, ct.c_int, ct.c_int]
    lib.reference_dense.restype = ct.c_int
    lib.reference_sparse.argtypes = [dp, dp, ct.c_int, ct.c_int, ip, ip, ip, ct.c_int, ip, dp]
    lib.reference_sparse.restype = ct.c_int

    def ptr(v, kind):
        return v.ctypes.data_as(kind)

    rng = np.random.default_rng(314101403)
    cases = []
    for n in [1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 31, 32, 33]:
        for pattern in ['diagonal', 'chain', 'random', 'dense']:
            mask = np.eye(n, dtype=bool)
            if pattern == 'chain': mask[np.arange(1, n), np.arange(n-1)] = True
            if pattern == 'random': mask |= np.tril(rng.random((n, n)) < .3, -1)
            if pattern == 'dense': mask |= np.tri(n, dtype=bool)
            for mode in [0, 1]:
                for plus in [0, 1]:
                    l = rng.uniform(-.1, .1, (n, n))
                    l[np.diag_indices(n)] = rng.uniform(1, 2, n)
                    x = rng.uniform(-.01, .01, n)
                    x[rng.random(n) < .3] = 0
                    start = n if mode == 0 else int(rng.integers(0, n+1))
                    x[start:] = 0
                    cases.append((f'{pattern}-{mode}-{plus}', mode, start, plus, mask, l, x, False))
    for n in [1, 2, 3, 4, 5]:
        for mode in [0, 1]:
            for plus in [0, 1]:
                for value in [0., -0., 1., np.nextafter(1., 0.), np.nextafter(1., np.inf), 2.]:
                    l = np.eye(n)
                    x = np.zeros(n); x[0 if mode == 0 else n-1] = value
                    cases.append(('pivot-edge', mode, n, plus, np.tri(n, dtype=bool), l, x, False))
    # Extreme yet admitted values: numerical rejection is observable and all
    # partially updated internal buffers must remain within their bounds.
    for mode in [0, 1]:
        l = np.array([[1e120, 0.], [0., 1e120]])
        x = np.array([1e120, 1e120])
        cases.append(('root-outside-domain', mode, 2, 1, np.tri(2, dtype=bool), l, x, True))
    payload = ''.join(f'{len(x)} {mode} {start} {plus} '+
                      ' '.join(str(int(v)) for v in mask.ravel())+' '+
                      ' '.join(format(v, '.17g') for v in np.r_[l.ravel(), x])+'\n'
                      for _, mode, start, plus, mask, l, x, _ in cases)
    (a.out/'input.txt').write_text(payload)
    run = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (a.out/'output.txt').write_text(run.stdout+run.stderr)
    if run.returncode: raise RuntimeError(run.stdout[-1000:]+run.stderr)
    lines = run.stdout.splitlines()
    assert len(lines) == len(cases)
    records = []
    for index, ((name, mode, start, plus, mask, l, x, reject), line) in enumerate(zip(cases, lines)):
        n = len(x)
        fields = line.split()
        status, rank = fields[0], int(fields[1])
        actual = np.asarray([float(v) for v in fields[2:]])
        if reject:
            ok = status == 'NUMERIC_LIMIT' and np.max(np.abs(actual)) <= 1e120
            ok = ok and np.all(actual[:n*n].reshape(n, n).diagonal() >= 1e-15)
            records.append(dict(index=index, name=name, passed=bool(ok), rejection=True))
            continue
        expected_l, expected_x = l.copy(), x.copy()
        if mode == 0:
            rank_c = lib.reference_dense(ptr(expected_l, dp), ptr(expected_x, dp), n, plus)
        else:
            lengths = mask.sum(axis=1).astype(np.int32)
            offsets = np.r_[0, np.cumsum(lengths[:-1])].astype(np.int32)
            columns = np.where(mask)[1].astype(np.int32)
            values = np.ascontiguousarray(l[mask])
            indices = np.arange(start, dtype=np.int32)
            input_x = np.ascontiguousarray(x[:start])
            rank_c = lib.reference_sparse(ptr(values, dp), ptr(input_x, dp), n, plus,
                        ptr(lengths, ip), ptr(offsets, ip), ptr(columns, ip), start,
                        ptr(indices, ip), ptr(expected_x, dp))
            expected_l[mask] = values
        expected = np.r_[expected_l.ravel(), expected_x]
        mismatches = np.flatnonzero(actual.view(np.uint64) != expected.view(np.uint64))
        records.append(dict(index=index, name=name, passed=bool(status == 'SUCCESS' and rank == rank_c and not len(mismatches)),
                            status=status, rank=rank, rank_c=rank_c, mismatches=mismatches.tolist(),
                            max_error=float(np.max(np.abs(actual-expected)))))
    report = dict(passed=sum(r['passed'] for r in records), total=len(records), records=records,
                  baseline=mujoco.__version__, binary_sha256=digest(a.binary), driver_sha256=digest(Path(__file__)),
                  library_sha256=digest(library), source_sha256=digest(source), helper_sha256=digest(helper), command=command,
                  input_sha256=digest(a.out/'input.txt'))
    (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(f"{report['passed']}/{report['total']} rank-one update cases passed")
    raise SystemExit(0 if report['passed'] == report['total'] else 1)


if __name__ == '__main__':
    main()
