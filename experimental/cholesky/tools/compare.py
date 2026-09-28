#!/usr/bin/env python3
"""Checked dense Cholesky comparison with the unmodified MuJoCo wheel."""
import argparse, ctypes, hashlib, json, pathlib, subprocess
import numpy as np
import mujoco

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--probe', default='/tmp/sparkling-cholesky/bin/validation/cholesky_probe')
    p.add_argument('--output', type=pathlib.Path, required=True)
    a = p.parse_args()
    if mujoco.__version__ != '3.14.0':
        raise RuntimeError('Reference must be MuJoCo 3.14.0')
    library_dir = pathlib.Path(mujoco.__file__).parent
    libraries = list(library_dir.glob('libmujoco.so*')) + list(library_dir.glob('libmujoco*.dylib')) + list(library_dir.glob('mujoco.dll'))
    native = ctypes.CDLL(str(libraries[0]))
    native.mju_cholFactor.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_double]
    native.mju_cholFactor.restype = ctypes.c_int
    native.mju_cholSolve.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
    native.mju_cholSolve.restype = None
    native.mju_cholUpdate.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    native.mju_cholUpdate.restype = ctypes.c_int
    rng = np.random.default_rng(20260928)
    cases = []

    def add(op, mat, x=None, plus=True, minimum=1e-15, label=''):
        n = len(mat)
        x = np.zeros(n) if x is None else x
        cases.append((op, np.array(mat, order='C', copy=True), x.copy(), plus, minimum, label))
    for n in [*range(0, 18), 24, 32, 64, 96, 128]:
        for sample in range(8):
            q = rng.normal(size=(n, n))
            spd = q @ q.T + np.eye(n) * (0.5 + n * 0.1)
            inp = spd.copy()
            inp[np.triu_indices(n, 1)] = rng.uniform(-500, 500, n * (n - 1) // 2)
            add(0, inp, label='spd')
            l = np.linalg.cholesky(spd)
            l[np.triu_indices(n, 1)] = inp[np.triu_indices(n, 1)]
            add(1, l, rng.normal(size=n), label='solve')
            add(2, l, rng.normal(size=n) * 0.1, label='update')
            add(2, l, rng.normal(size=n) * 0.01, False, label='downdate_spd')
            add(2, l, np.zeros(n), False, label='zero_noop')
            x = np.zeros(n)
            if n:
                x[sample % n] = 0.1
            add(2, l, x, label='sparse_vector')
        m = np.eye(n)
        m[np.diag_indices(n)] = np.arange(n) % 3 - 1
        if n > 1:
            m[1, 0] = 0.7
        add(0, m, minimum=1e-08, label='deficient')
    for n in range(1, 9):
        for scale in [0.999999999, 1, 1.000000001, 2, 10]:
            x = np.full(n, scale / n ** 0.5) if n <= 4 else np.r_[scale, np.zeros(n - 1)]
            add(2, np.eye(n), x, False, label='downdate_clamped')
        for scale in [1e-20, 1e-08, 1, 100000000.0, 1e+20]:
            add(0, np.eye(n) * scale, minimum=1e-15, label='diagonal_scale')
    for v in [np.nextafter(1e-15, 0), 1e-15, np.nextafter(1e-15, np.inf)]:
        add(0, np.array([[v]]), label='threshold')
    inputs = []
    expected = []
    for op, mat, x, plus, minimum, label in cases:
        n = len(x)
        inputs.append(f'{op} {n} {int(plus)} {minimum:.17g}\n' + ' '.join((format(v, '.17g') for v in mat.flat)) + '\n' + ' '.join((format(v, '.17g') for v in x)) + '\n')
        c = mat.copy()
        cx = x.copy()
        rank = n
        if op == 0:
            rank = native.mju_cholFactor(c.ctypes.data, n, minimum)
        elif op == 1:
            native.mju_cholSolve(cx.ctypes.data, c.ctypes.data, x.ctypes.data, n)
        else:
            rank = native.mju_cholUpdate(c.ctypes.data, cx.ctypes.data, n, int(plus))
        expected.append((rank, c, cx))
    result = subprocess.run([a.probe], input=''.join(inputs), text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr)
    out = iter(result.stdout.split())
    failures = []
    comparisons = 0
    max_abs = 0.0
    max_scaled = 0.0
    residual_max = 0.0
    by_op = {}
    for ci, ((op, mat, x, plus, minimum, label), (cr, cm, cx)) in enumerate(zip(cases, expected)):
        n = len(x)
        rank = int(next(out))
        am = np.array([float(next(out)) for _ in range(n * n)]).reshape(n, n)
        ax = np.array([float(next(out)) for _ in range(n)])
        comparisons += 1 + n * n + n
        by_op[str(op)] = by_op.get(str(op), 0) + 1
        for name, got, want in [('matrix', am, cm), ('workspace', ax, cx)]:
            if got.size:
                err = np.abs(got - want)
                scaled = err / (1 + np.abs(want))
                max_abs = max(max_abs, float(err.max()))
                max_scaled = max(max_scaled, float(scaled.max()))
            if not np.allclose(got, want, rtol=2e-12, atol=2e-13):
                failures.append({'case': ci, 'label': label, 'field': name})
        if rank != cr:
            failures.append({'case': ci, 'label': label, 'rank': [rank, int(cr)]})
        if not np.array_equal(am[np.triu_indices(n, 1)], mat[np.triu_indices(n, 1)]):
            failures.append({'case': ci, 'field': 'upper triangle'})
        if label == 'zero_noop' and (rank != n or not np.array_equal(mat, am) or (not np.array_equal(x, ax))):
            failures.append({'case': ci, 'field': 'no-op'})
        if n and label in ['solve', 'update', 'downdate_spd', 'spd']:
            if op == 0:
                target = np.tril(mat) + np.tril(mat, -1).T
                got = np.tril(am) @ np.tril(am).T
            elif op == 1:
                target = x
                got = np.tril(mat) @ (np.tril(mat).T @ ax)
            else:
                target = np.tril(mat) @ np.tril(mat).T + (1 if plus else -1) * np.outer(x, x)
                got = np.tril(am) @ np.tril(am).T
            residual = float(np.linalg.norm(got - target) / max(1.0, np.linalg.norm(target)))
            residual_max = max(residual_max, residual)
            if residual > 2e-12:
                failures.append({'case': ci, 'field': 'reconstruction', 'residual': residual})
    if next(out, None) is not None:
        raise RuntimeError('Unexpected trailing output')
    root = pathlib.Path(__file__).resolve().parents[1]
    report = {'reference': mujoco.__version__, 'seed': 20260928, 'cases': len(cases), 'by_operation': by_op, 'comparisons': comparisons, 'max_absolute_difference': max_abs, 'max_scaled_difference': max_scaled, 'max_relative_reconstruction_residual': residual_max, 'failures': failures, 'probe_sha256': hashlib.sha256(pathlib.Path(a.probe).read_bytes()).hexdigest(), 'source_sha256': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(root.glob('src/*.ad?'))}}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'source_sha256'}, indent=2))
    return bool(failures)
if __name__ == '__main__':
    raise SystemExit(main())
