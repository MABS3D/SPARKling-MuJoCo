"""Check published J^T force against the native C reduction for each method."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from differential import analytic, encode, fixtures, native_problem


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    lib = ctypes.CDLL(str(library))
    dp = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
    ip = np.ctypeslib.ndpointer(dtype=np.int32, flags='C_CONTIGUOUS')
    lib.mju_mulMatTVec.argtypes = [dp, dp, dp, ctypes.c_int, ctypes.c_int]
    lib.mju_mulMatTVecSparse.argtypes = [dp, dp, dp, ctypes.c_int, ctypes.c_int, ip, ip, ip]
    lib.mju_transposeSparse.argtypes = [dp, dp, ctypes.c_int, ctypes.c_int, ip, ip, ip, ctypes.c_void_p, ip, ip, ip]
    lib.mju_mulMatVecSparse.argtypes = [dp, dp, dp, ctypes.c_int, ip, ip, ip, ctypes.c_void_p]
    cases = [native_problem(name, xml, method, jacobian=layout)[0]
             for name, xml in fixtures() for method in range(3) for layout in ['dense', 'sparse']]
    base = next(analytic())[0]
    cases += [dict(base, name='empty', method=method, J=np.zeros((0, 1)), ref=[],
                   a0=[7.], f0=[], rows=[]) for method in range(6)]
    cases += [dict(base, name='indefinite', M=[[-1.]], a0=[.7], f0=[.8])]
    csr = dict(layout='sparse', rowadr=[0], rownnz=[1], colind=[0], values=[1.])
    for name, changes in [('offset', dict(rowadr=[2])), ('width', dict(rownnz=[2])),
                          ('column', dict(colind=[1])), ('value', dict(values=[1e11]))]:
        cases.append(dict(base, name='reject-'+name, a0=[.7], f0=[.8],
                          native_jacobian=dict(csr, **changes)))
    a.out.mkdir(parents=True, exist_ok=False)
    payload = ''.join(map(encode, cases))
    (a.out/'input.txt').write_text(payload)
    run = subprocess.run([str(a.binary), '--with-force'], input=payload, text=True,
                         capture_output=True, timeout=120)
    (a.out/'output.txt').write_text(run.stdout+run.stderr)
    assert run.returncode == 0, run.stderr
    lines = run.stdout.splitlines()
    assert len(lines) == len(cases)
    records = []
    for p, line in zip(cases, lines):
        n, k = len(p['free']), len(p['ref'])
        s = line.split(); values = np.array(s[9:], dtype=np.float64)
        acc, force, got = values[:n], values[n:n+k], values[n+k:]
        assert len(got) == n
        expected = np.zeros(n)
        if s[0] in ['INVALID_INPUT', 'NOT_POSITIVE_DEFINITE', 'NUMERIC_LIMIT']:
            expected[:] = .375
            ok = np.array_equal(acc, p['a0']) and np.array_equal(force, p['f0'])
        else:
            ok = True
            if k and 'native_jacobian' not in p:
                lib.mju_mulMatTVec(expected, np.asarray(p['J']).ravel(), force, k, n)
            elif k:
                j = p['native_jacobian']
                offsets = np.array(j['rowadr'], dtype=np.int32)
                widths = np.array(j['rownnz'], dtype=np.int32)
                columns = np.array(j['colind'], dtype=np.int32)
                data = np.array(j['values'], dtype=np.float64)
                if p['method'] % 3 == 0:
                    lib.mju_mulMatTVecSparse(expected, data, force, k, n, widths, offsets, columns)
                else:
                    count = int(sum(widths)); tw = np.zeros(n, dtype=np.int32)
                    to = np.zeros(n, dtype=np.int32); tc = np.zeros(count, dtype=np.int32)
                    tv = np.zeros(count); first = int(offsets[0])
                    lib.mju_transposeSparse(tv, data[first:], k, n, tw, to, tc, None, widths, offsets, columns[first:])
                    lib.mju_mulMatVecSparse(expected, tv, force, n, tw, to, tc, None)
        ok = bool(ok and np.array_equal(got.view(np.uint64), expected.view(np.uint64)))
        records.append(dict(name=p['name'], method=p['method'], passed=ok,
                            status=s[0], error=float(np.max(np.abs(got-expected), initial=0))))
    failures = [r for r in records if not r['passed']]
    report = dict(reference=mujoco.__version__, cases=len(cases), passed=len(cases)-len(failures),
                  records=records, failures=failures, invalid_output_shape_checked_for_every_case=True,
                  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(report['passed'], '/', report['cases'], 'bitwise force publication and rejection atomicity')
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
