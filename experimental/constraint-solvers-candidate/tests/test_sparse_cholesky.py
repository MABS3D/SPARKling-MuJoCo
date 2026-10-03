"""Exact C 3.14 symbolic, numeric reverse factor and normal AVX sparse solve."""
import argparse
import ctypes as ct
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
    ap.add_argument('--reference', type=Path, default=Path('/var/tmp/sparkling-movement-c/source'))
    a = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True, exist_ok=False)
    package = Path(mujoco.__file__).parent
    libpath = package/'libmujoco.so.3.14.0'
    lib = ct.CDLL(str(libpath))
    ip = ct.POINTER(ct.c_int)
    dp = ct.POINTER(ct.c_double)
    sym = lib.mju_cholFactorSymbolic
    sym.argtypes = [ip]*10 + [ct.c_int, ct.c_void_p]
    sym.restype = ct.c_int
    num = lib.mju_cholFactorNumeric
    num.argtypes = [dp, ct.c_int, ct.c_double] + [ip]*7 + [dp] + [ip]*3 + [dp]
    num.restype = ct.c_int
    # This internal solve is not exported by the wheel. Compile its unchanged
    # official body with the official normal AVX dotSparse headers.
    source = a.reference/'src/engine/engine_util_solve.c'
    body = source.read_text().split('void mju_cholSolveSparse(', 1)[1].split(
        '// sparse reverse-order Cholesky rank-one update', 1)[0]
    helper = a.out/'reference.c'
    helper.write_text('#include "engine/engine_util_blas.h"\n'
                      '#include "engine/engine_util_sparse.h"\nvoid reference_solve(' + body)
    command = ['gcc', '-shared', '-fPIC', '-O3', '-march=native', '-DmjUSEPLATFORMSIMD',
               '-ffp-contract=off', '-I'+str(a.reference/'src'), '-I'+str(package/'include'),
               str(helper), str(libpath), '-Wl,-rpath,'+str(package), '-o', str(a.out/'reference.so')]
    subprocess.run(command, check=True, capture_output=True, text=True)
    solve = ct.CDLL(str(a.out/'reference.so')).reference_solve
    solve.argtypes = [dp, dp, dp, ct.c_int, ip, ip, ip]
    def ptr(x, dtype):
        return x.ctypes.data_as(dtype)
    def csr(mask, matrix):
        lengths = mask.sum(axis=1).astype(np.int32)
        starts = np.r_[0, np.cumsum(lengths[:-1])].astype(np.int32)
        columns = np.where(mask)[1].astype(np.int32)
        values = np.ascontiguousarray(matrix[mask])
        return values, lengths, starts, columns
    rng = np.random.default_rng(314031003)
    cases = []
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128]:
        for pattern in ['diagonal', 'chain', 'tree', 'random', 'dense']:
            lower = np.zeros((n, n), dtype=bool)
            for i in range(n):
                lower[i, i] = True
                if pattern == 'chain' and i: lower[i, i-1] = True
                if pattern == 'tree' and i: lower[i, (i-1)//2] = True
                if pattern == 'random': lower[i, :i] = rng.random(i) < .13
                if pattern == 'dense': lower[i, :i] = True
            mask = lower | lower.T
            raw = rng.uniform(-1, 1, (n, n))*mask
            raw = np.tril(raw) + np.tril(raw, -1).T
            # Preserve structural zeros as well as ordinary nonzero entries.
            zeros = rng.random((n, n)) < .2
            raw[np.tril(zeros, -1) | np.tril(zeros, -1).T] = 0
            raw[np.diag_indices(n)] = np.sum(np.abs(raw), axis=1)+1
            for kind, scale in [('spd', 1.), ('small', 1e-20), ('large', 1e20), ('mixed', 1.)]:
                h = raw.copy()*scale
                if kind == 'mixed': h[np.arange(0, n, 3), np.arange(0, n, 3)] = -1
                cases.append((pattern+'-'+kind, mask, h, rng.uniform(-1, 1, n)))
    for value in [-1., 0., np.nextafter(1e-15, 0.), 1e-15, np.nextafter(1e-15, np.inf)]:
        cases.append(('pivot-neighbor', np.ones((1, 1), bool), np.array([[value]]), np.zeros(1)))
    for n in [5, 6, 7, 8, 9]:
        for sign in [1., -1.]:
            h = np.full((n, n), -0.)
            np.fill_diagonal(h, 1.)
            cases.append(('signed-zero', np.ones((n, n), bool), h, np.zeros(n)*sign))
    payload = ''.join(f'{len(h)} 1e-15 ' + ' '.join(str(int(x)) for x in mask.ravel())+' '+
                      ' '.join(format(x, '.17g') for x in np.r_[h.ravel(), rhs])+'\n'
                      for name, mask, h, rhs in cases)
    run = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (a.out/'input.txt').write_text(payload)
    (a.out/'output.txt').write_text(run.stdout+run.stderr)
    if run.returncode: raise RuntimeError(run.stdout[-1000:]+run.stderr)
    lines = run.stdout.splitlines()
    assert len(lines) == 2*len(cases)
    records = []
    for index, (name, mask, h, rhs) in enumerate(cases):
        n = len(h)
        _, hn, ha, hi = csr(np.triu(mask), h)
        ln, la, tn, ta = [np.zeros(n, np.int32) for _ in range(4)]
        count = sym(None, ptr(ln, ip), ptr(la, ip), None, ptr(tn, ip), ptr(ta, ip),
                    None, ptr(hn, ip), ptr(ha, ip), ptr(hi, ip), n, None)
        li, ti, tm = [np.zeros(count, np.int32) for _ in range(3)]
        sym(ptr(li, ip), ptr(ln, ip), ptr(la, ip), ptr(ti, ip), ptr(tn, ip), ptr(ta, ip),
            ptr(tm, ip), ptr(hn, ip), ptr(ha, ip), ptr(hi, ip), n, None)
        expected_symbolic = ['SUCCESS']
        for r in range(n):
            expected_symbolic += [str(ln[r])]+[str(c+1) for c in li[la[r]:la[r]+ln[r]]]
            expected_symbolic += [str(tn[r])]
            for k in range(ta[r], ta[r]+tn[r]):
                expected_symbolic += [str(ti[k]+1), str(tm[k]-la[ti[k]]+1)]
        hv, hn, ha, hi = csr(np.tril(mask), h)
        lv = np.zeros(count)
        scratch = np.zeros(n)
        rank = num(ptr(lv, dp), n, 1e-15, ptr(ln, ip), ptr(la, ip), ptr(li, ip),
                   ptr(tn, ip), ptr(ta, ip), ptr(ti, ip), ptr(tm, ip), ptr(hv, dp),
                   ptr(hn, ip), ptr(ha, ip), ptr(hi, ip), ptr(scratch, dp))
        dense = np.zeros((n, n))
        for r in range(n): dense[r, li[la[r]:la[r]+ln[r]]] = lv[la[r]:la[r]+ln[r]]
        x = np.zeros(n)
        solve(ptr(x, dp), ptr(lv, dp), ptr(rhs, dp), n, ptr(ln, ip), ptr(la, ip), ptr(li, ip))
        cols = lines[2*index+1].split()
        end = 2+n*n
        got = np.asarray(cols[2:end], float).reshape(n, n)
        answer = np.asarray(cols[end+1:], float)
        symbolic_ok = lines[2*index].split() == expected_symbolic
        passed = symbolic_ok and cols[0] == 'SUCCESS' and int(cols[1]) == rank
        passed = passed and np.array_equal(got.view(np.uint64), dense.view(np.uint64))
        passed = bool(passed and cols[end] == 'SUCCESS' and
                      np.array_equal(answer.view(np.uint64), x.view(np.uint64)))
        records.append(dict(name=name, n=n, passed=passed, symbolic=symbolic_ok,
                            rank=rank, ada_rank=int(cols[1]),
                            factor_error=float(np.max(np.abs(got-dense))),
                            solve_error=float(np.max(np.abs(answer-x)))))
    failures = [r for r in records if not r['passed']]
    result = dict(reference=mujoco.__version__, cases=len(cases), passed=len(cases)-len(failures),
                  failures=failures, records=records, native_compile_command=command,
                  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  reference_source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                  reference_library_sha256=hashlib.sha256(libpath.read_bytes()).hexdigest(),
                  reference_headers={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in
                    [a.reference/'src/engine/engine_util_sparse.h',
                     a.reference/'src/engine/engine_util_sparse_avx.h']})
    (a.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(result['passed'], '/', result['cases'], 'exact symbolic structures, factors, ranks and solves')
    raise SystemExit(bool(failures))


if __name__ == '__main__': main()
