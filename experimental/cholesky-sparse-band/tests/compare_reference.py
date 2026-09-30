#!/usr/bin/env python3
"""Seeded differential tests against MuJoCo 3.14.0, not a proof or benchmark.

Sparse solve is hidden in the shared library. Compile its exact upstream body
and original AVX header into a tiny bridge; all other calls use the stock library.
No rewritten reference algorithm is used.
"""
import argparse
import ctypes as ct
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import time

import mujoco
import numpy as np

HERE = Path(__file__).resolve().parents[1]
REPO = HERE.parents[1]
DP = ct.POINTER(ct.c_double)
IP = ct.POINTER(ct.c_int)


def ptr(a):
    return a.ctypes.data_as(DP if a.dtype == np.float64 else IP)


def configure(lib):
    signatures = {
        "mju_cholFactorBand": (ct.c_double, [DP, ct.c_int, ct.c_int, ct.c_int, ct.c_double, ct.c_double]),
        "mju_cholSolveBand": (None, [DP, DP, DP, ct.c_int, ct.c_int, ct.c_int]),
        "mju_band2Dense": (None, [DP, DP, ct.c_int, ct.c_int, ct.c_int, ct.c_bool]),
        "mju_dense2Band": (None, [DP, DP, ct.c_int, ct.c_int, ct.c_int]),
        "mju_bandMulMatVec": (None, [DP, DP, DP, ct.c_int, ct.c_int, ct.c_int, ct.c_int, ct.c_bool]),
        "mju_cholFactorSparse": (ct.c_int, [DP, ct.c_int, ct.c_double, IP, IP, IP, ct.c_void_p]),
        "mju_cholFactorSymbolic": (ct.c_int, [IP, IP, IP, IP, IP, IP, IP, IP, IP, IP, ct.c_int, ct.c_void_p]),
        "mju_cholFactorNumeric": (ct.c_int, [DP, ct.c_int, ct.c_double, IP, IP, IP, IP, IP, IP, IP, DP, IP, IP, IP, DP]),
        "mju_cholUpdateSparse": (ct.c_int, [DP, DP, ct.c_int, ct.c_int, IP, IP, IP, ct.c_int, IP, DP]),
    }
    for name, (result, args) in signatures.items():
        fn = getattr(lib, name)
        fn.restype, fn.argtypes = result, args


def bridge(library, build):
    source = REPO / "mujoco/src/engine/engine_util_solve.c"
    code = source.read_text()
    first = code.index("void mju_cholSolveSparse(")
    last = code.index("\n\n", code.index("\n}", first) + 2)
    body = code[first:last]
    target = build / "sparse_solve_bridge.c"
    target.write_text('#include "engine/engine_util_blas.h"\n'
                      '#include "engine/engine_util_sparse.h"\n'
                      '#include "engine/engine_util_solve.h"\n' + body + '\n')
    shared = build / "sparse_solve_bridge.so"
    subprocess.run([os.environ.get("CC", "gcc"), "-O3", "-march=native", "-ffp-contract=off",
                    "-shared", "-fPIC", "-I" + str(REPO / "mujoco/include"),
                    "-I" + str(REPO / "mujoco/src"), str(target), str(library),
                    "-Wl,-rpath," + str(library.parent), "-o", str(shared)], check=True)
    lib = ct.CDLL(str(shared))
    fn = lib.mju_cholSolveSparse
    fn.argtypes = [DP, DP, DP, ct.c_int, IP, IP, IP]
    fn.restype = None
    return lib, hashlib.sha256(body.encode()).hexdigest()


def csr(a, upper=False):
    counts, adr, cols, vals = [], [], [], []
    for r in range(len(a)):
        adr.append(len(cols))
        js = [c for c in range(len(a)) if (c >= r if upper else c <= r)
              and (c == r or a[r, c] != 0)]
        counts.append(len(js)); cols.extend(js); vals.extend(a[r, js])
    return (np.array(counts, np.int32), np.array(adr, np.int32),
            np.array(cols, np.int32), np.array(vals, np.float64))


def symbolic(lib, a):
    n = len(a)
    hc, ha, hi, _ = csr(a, upper=True)
    c, adr, tc, ta = [np.zeros(n, np.int32) for _ in range(4)]
    nnz = lib.mju_cholFactorSymbolic(None, ptr(c), ptr(adr), None, ptr(tc), ptr(ta),
                                    None, ptr(hc), ptr(ha), ptr(hi), n, None)
    col, ti, mapping = [np.zeros(nnz, np.int32) for _ in range(3)]
    returned = lib.mju_cholFactorSymbolic(ptr(col), ptr(c), ptr(adr), ptr(ti), ptr(tc),
                                        ptr(ta), ptr(mapping), ptr(hc), ptr(ha), ptr(hi), n, None)
    assert returned == 0  # C returns a count only during the counting pass.
    return hc, ha, hi, c, adr, col, tc, ta, ti, mapping


class Suite:
    def __init__(self):
        self.inputs, self.expected, self.labels = [], [], []
        self.independent = 0

    def case(self, label, tokens, expected):
        def flatten(xs):
            for x in xs:
                if isinstance(x, np.ndarray):
                    yield from x.flat
                else:
                    yield x
        self.inputs.append(" ".join(str(x) for x in flatten(tokens)))
        self.expected.append(np.concatenate([np.atleast_1d(x).ravel() for x in expected]))
        self.labels.append(label)

    def check_residual(self, a, x, b):
        error = np.linalg.norm(a @ x - b, np.inf)
        scale = max(1.0, np.linalg.norm(a, np.inf) * np.linalg.norm(x, np.inf), np.linalg.norm(b, np.inf))
        assert error <= 5e-13 * scale, (error, scale)
        self.independent += 1

    def run(self, executable, profile):
        result = subprocess.run([str(executable)], input="\n".join(self.inputs) + "\n0\n",
                                capture_output=True, text=True, check=False, timeout=180)
        lines = result.stdout.splitlines()
        if result.returncode:
            position = len(lines)
            raise RuntimeError((profile, position, self.labels[position],
                                self.inputs[position], result.stderr))
        assert len(lines) == len(self.inputs), (len(lines), len(self.inputs), result.stderr)
        exact = 0; worst = 0.0
        by_family = {}
        for label, line, expected in zip(self.labels, lines, self.expected):
            got = np.fromstring(line, sep=" ")
            assert got.shape == expected.shape, (label, got.shape, expected.shape)
            if not np.allclose(got, expected, rtol=2e-13, atol=2e-14):
                delta = np.abs(got - expected)
                raise AssertionError((label, np.argmax(delta), got, expected))
            same = np.array_equal(got.view(np.uint64), expected.astype(np.float64).view(np.uint64))
            exact += same
            if got.size: worst = max(worst, float(np.max(np.abs(got - expected))))
            by_family[label] = by_family.get(label, 0) + 1
        manual = {"band_numeric_limit", "sparse_empty", "sparse_factor_empty",
                  "sparse_solve_empty", "sparse_update_empty", "sparse_numeric_empty", "rejection_paths"}
        manual_count = sum(label in manual for label in self.labels)
        return dict(profile=profile, cases=len(lines), reference_comparisons=len(lines)-manual_count,
                    boundary_expectation_cases=manual_count, exact_binary64_cases=exact,
                    worst_absolute_difference=worst, by_family=by_family,
                    residual_checks_on_reference_outputs=self.independent)


def band_cases(suite, lib, rng):
    for n in [0, 1, 2, 3, 4, 5, 8, 9, 15, 16, 24, 31, 48]:
        for dense in sorted({0, n // 3, n}):
            for band in sorted({1, 2, 5, n + 2} if dense < n else {0, 1, n + 2}):
                sparse = n - dense
                a = np.zeros((n, n), np.float64)
                for i in range(n):
                    start = max(0, i - band + 1) if i < sparse else 0
                    for j in range(start, i):
                        a[i, j] = a[j, i] = rng.uniform(-0.3, 0.3)
                for i in range(n): a[i, i] = np.abs(a[i]).sum() + 1.0
                packed = np.full(sparse * band + dense * n, 13.25, np.float64)
                lib.mju_dense2Band(ptr(packed), ptr(a), n, band, dense)
                suite.case("band_from_dense", [4, n, band, dense, np.full(len(packed), 13.25), a], [packed])
                for sym in [0, 1]:
                    out = np.empty(n * n, np.float64)
                    lib.mju_band2Dense(ptr(out), ptr(packed), n, band, dense, sym)
                    suite.case("band_to_dense", [3, n, band, dense, packed, sym], [out])
                    v = rng.uniform(-1, 1, (3, n)).astype(np.float64)
                    result = np.empty_like(v)
                    lib.mju_bandMulMatVec(ptr(result), ptr(packed), ptr(v), n, band, dense, 3, sym)
                    np.testing.assert_allclose(result, v @ (a if sym else np.tril(a)).T, rtol=2e-14, atol=2e-14)
                    suite.case("band_multiply", [5, n, band, dense, packed, 3, sym, v], [0, result])
                for add, mul in [(0., 0.), (0.2, 0.1)]:
                    factor = packed.copy()
                    pivot = lib.mju_cholFactorBand(ptr(factor), n, band, dense, add, mul)
                    suite.case("band_factor", [1, n, band, dense, packed, add, mul], [0, pivot, factor])
                    if n:
                        l = np.empty(n * n, np.float64)
                        lib.mju_band2Dense(ptr(l), ptr(factor), n, band, dense, False)
                        original = a.copy()
                        original.flat[::n + 1] += add + mul * np.diag(a)
                        np.testing.assert_allclose(l.reshape(n, n) @ l.reshape(n, n).T, original,
                                                   rtol=3e-14, atol=3e-14)
                        suite.independent += 1
                    for zero in [False, True]:
                        rhs = np.zeros(n) if zero else rng.uniform(-1, 1, n).astype(np.float64)
                        solution = np.empty(n, np.float64)
                        lib.mju_cholSolveBand(ptr(solution), ptr(factor), ptr(rhs), n, band, dense)
                        suite.case("band_solve", [2, n, band, dense, factor, rhs], [0, solution])
                        if n: suite.check_residual(original, solution, rhs)
    for diag in [-1., 0., 0.5e-15, 1e-15]:
        a = np.array([diag], np.float64); factor = a.copy()
        pivot = lib.mju_cholFactorBand(ptr(factor), 1, 1, 0, 0., 0.)
        suite.case("band_pivot_boundary", [1, 1, 1, 0, a, 0, 0], [int(pivot == 0), pivot, factor])
    suite.case("band_numeric_limit", [1, 1, 1, 0, np.array([1e100]), 1e100, 1e100], [5, -1, 1e100])


def sparse_cases(suite, lib, solve_lib, rng):
    for n in [1, 2, 3, 4, 5, 8, 9, 16, 24, 40, 64]:
        for density in [0., 0.07, 0.25, 1.]:
            a = rng.uniform(-0.25, 0.25, (n, n))
            a *= rng.uniform(0, 1, (n, n)) < density
            a = np.tril(a, -1); a += a.T
            for i in range(n): a[i, i] = np.abs(a[i]).sum() + 1.0
            hc, ha, hi, c, adr, col, tc, ta, ti, mapping = symbolic(lib, a)
            nnz = len(col)
            suite.case("sparse_symbolic", [6, n, len(hi), hc, ha, hi],
                       [0, nnz, c, adr, col, tc, ta, ti, mapping])
            hcount, hadr, hcol, h = csr(a)
            factor = np.zeros(nnz, np.float64); work = np.zeros(n, np.float64)
            rank = lib.mju_cholFactorNumeric(ptr(factor), n, 1e-15, ptr(c), ptr(adr), ptr(col),
                                            ptr(tc), ptr(ta), ptr(ti), ptr(mapping), ptr(h),
                                            ptr(hcount), ptr(hadr), ptr(hcol), ptr(work))
            assert rank == n and not np.any(work)
            suite.case("sparse_numeric", [10, n, nnz, c, adr, col, np.zeros(nnz), tc, ta, ti, mapping,
                       len(h), hcount, hadr, hcol, h, 1e-15, np.full(n, 3.75)], [0, rank, factor, work])
            lower = np.zeros((n, n))
            for r in range(n): lower[r, col[adr[r]:adr[r]+c[r]]] = factor[adr[r]:adr[r]+c[r]]
            np.testing.assert_allclose(lower.T @ lower, a, rtol=3e-14, atol=3e-14)
            suite.independent += 1
            # Dynamic fill: each row has only r+1 capacity, not a dense matrix.
            dyn_adr = np.array([r*(r+1)//2 for r in range(n)], np.int32)
            size = n*(n+1)//2
            dyn_col = np.zeros(size, np.int32); dyn_a = np.full(size, 13.25)
            for r in range(n):
                dest = slice(dyn_adr[r], dyn_adr[r] + hcount[r]); src = slice(hadr[r], hadr[r] + hcount[r])
                dyn_col[dest], dyn_a[dest] = hcol[src], h[src]
            counts = hcount.copy(); ci = dyn_col.copy(); cf = dyn_a.copy()
            rank = lib.mju_cholFactorSparse(ptr(cf), n, 1e-15, ptr(counts), ptr(dyn_adr), ptr(ci), None)
            suite.case("sparse_factor_fill", [7, n, size, hcount, dyn_adr, dyn_col, dyn_a, 1e-15],
                       [0, rank, counts, ci, cf])
            for zero in [False, True]:
                rhs = np.zeros(n) if zero else rng.uniform(-1, 1, n).astype(np.float64)
                x = np.empty(n, np.float64)
                solve_lib.mju_cholSolveSparse(ptr(x), ptr(factor), ptr(rhs), n, ptr(c), ptr(adr), ptr(col))
                suite.case("sparse_solve", [8, n, nnz, c, adr, col, factor, rhs], [0, x])
                suite.check_residual(a, x, rhs)
            # Dense structural pattern admits every rank-one update. Diagonal
            # sparse patterns admit one-entry updates without structural fill.
            if density in [0., 1.]:
                for plus in [0, 1]:
                    for entries in [0, 1, n] if density == 1. else [0, 1]:
                        xc = np.arange(n-entries, n, dtype=np.int32)
                        xv = rng.uniform(-0.03, 0.03, entries).astype(np.float64)
                        updated = factor.copy(); scratch = np.full(n, 3.75)
                        rank = lib.mju_cholUpdateSparse(ptr(updated), ptr(xv), n, plus, ptr(c), ptr(adr),
                                                      ptr(col), entries, ptr(xc), ptr(scratch))
                        suite.case("sparse_update" if plus else "sparse_downdate",
                                   [9, n, nnz, c, adr, col, factor, entries, xc, xv, plus, np.full(n, 3.75)],
                                   [0, rank, updated, scratch])
                        u = np.zeros(n); u[xc] = xv
                        for r in range(n): lower[r, col[adr[r]:adr[r]+c[r]]] = updated[adr[r]:adr[r]+c[r]]
                        np.testing.assert_allclose(lower.T @ lower, a + (1 if plus else -1)*np.outer(u,u),
                                                   rtol=3e-14, atol=3e-14)
                        suite.independent += 1
    # Empty sparse pattern: avoid C's symbolic n=0 out-of-bounds access.
    suite.case("sparse_empty", [6, 0, 0], [0, 0])
    suite.case("sparse_factor_empty", [7, 0, 0, 1e-15], [0, 0])
    suite.case("sparse_solve_empty", [8, 0, 0], [0])
    suite.case("sparse_update_empty", [9, 0, 0, 0, 1], [0, 0])
    suite.case("sparse_numeric_empty", [10, 0, 0, 0, 1e-15], [0, 0])
    suite.case("rejection_paths", [11, 0], [2, 3, 0, 1, 0, 2])
    # Nonempty update below the end must preserve workspace above its start.
    c=np.array([1, 1, 1],np.int32); adr=np.array([0,1,2],np.int32); col=adr.copy()
    a=np.array([1.,2.,3.]); xv=np.array([0.1]); xc=np.array([0],np.int32)
    f=a.copy(); w=np.full(3,3.75)
    rank=lib.mju_cholUpdateSparse(ptr(f),ptr(xv),3,1,ptr(c),ptr(adr),ptr(col),1,ptr(xc),ptr(w))
    suite.case("sparse_update_workspace_frame", [9,3,3,c,adr,col,a,1,xc,xv,1,np.full(3,3.75)], [0,rank,f,w])
    for diag in [-1., 0., 0.5e-15, 1e-15]:
        count = np.array([1], np.int32); adr = np.array([0], np.int32); col = adr.copy()
        original = np.array([diag]); factor = original.copy()
        rank = lib.mju_cholFactorSparse(ptr(factor), 1, 1e-15, ptr(count), ptr(adr), ptr(col), None)
        suite.case("sparse_clamp", [7, 1, 1, count, adr, col, original, 1e-15], [0, rank, count, col, factor])
        factor = np.zeros(1); scratch = np.zeros(1)
        rank = lib.mju_cholFactorNumeric(ptr(factor), 1, 1e-15, ptr(count), ptr(adr), ptr(col),
                                        ptr(count), ptr(adr), ptr(col), ptr(col), ptr(original),
                                        ptr(count), ptr(adr), ptr(col), ptr(scratch))
        suite.case("sparse_numeric_clamp", [10, 1, 1, count, adr, col, np.zeros(1), count, adr, col, col,
                    1, count, adr, col, original, 1e-15, np.full(1, 3.75)], [0, rank, factor, scratch])
    # C's two factor functions deliberately differ on clamped off-diagonals.
    a = np.array([[1., 0.2], [0.2, -1.]])
    hc, ha, hi, c, adr, col, tc, ta, ti, mapping = symbolic(lib, a)
    hcount, hadr, hcol, h = csr(a); nnz = len(col)
    f = np.zeros(nnz); w = np.zeros(2)
    rank = lib.mju_cholFactorNumeric(ptr(f), 2, 0.5, ptr(c), ptr(adr), ptr(col), ptr(tc), ptr(ta), ptr(ti),
                                    ptr(mapping), ptr(h), ptr(hcount), ptr(hadr), ptr(hcol), ptr(w))
    suite.case("sparse_numeric_clamp_offdiagonal", [10, 2, nnz, c, adr, col, np.zeros(nnz), tc, ta, ti, mapping,
               len(h), hcount, hadr, hcol, h, 0.5, np.zeros(2)], [0, rank, f, w])
    f = h.copy(); count = hcount.copy(); ci = hcol.copy()
    rank = lib.mju_cholFactorSparse(ptr(f), 2, 0.5, ptr(count), ptr(hadr), ptr(ci), None)
    suite.case("sparse_factor_clamp_offdiagonal", [7, 2, len(h), hcount, hadr, hcol, h, 0.5], [0, rank, count, ci, f])
    # Failed downdate regularizes as C does and reports the reduced rank.
    f = np.array([1.]); xv = np.array([2.]); ci = np.array([0],np.int32); cc=np.array([1],np.int32)
    w = np.full(1, 3.75); rank = lib.mju_cholUpdateSparse(ptr(f), ptr(xv), 1, 0, ptr(cc), ptr(ci), ptr(ci), 1, ptr(ci), ptr(w))
    suite.case("sparse_downdate_clamp", [9,1,1,cc,ci,ci,np.array([1.]),1,ci,xv,0,np.full(1,3.75)], [0,rank,f,w])
    # Source rows may omit their diagonal entirely; the symbolic pattern
    # supplies it. An empty H regularizes to sqrt(MinVal)*I, as C does.
    n=3; hc=np.zeros(n,np.int32); ha=hc.copy(); hi=np.empty(0,np.int32); h=np.empty(0,np.float64)
    c=np.ones(n,np.int32); adr=np.arange(n,dtype=np.int32); col=adr.copy()
    f=np.full(n,13.25); work=np.zeros(n)
    rank=lib.mju_cholFactorNumeric(ptr(f),n,1e-15,ptr(c),ptr(adr),ptr(col),ptr(c),ptr(adr),ptr(col),ptr(col),
                                 ptr(h),ptr(hc),ptr(ha),ptr(hi),ptr(work))
    suite.case("sparse_numeric_implicit_diagonal", [10,n,n,c,adr,col,np.full(n,13.25),c,adr,col,col,
               0,hc,ha,hi,h,1e-15,np.full(n,3.75)], [0,rank,f,work])
    suite.case("sparse_symbolic_implicit_diagonal", [6,n,0,hc,ha,hi], [0,n,c,adr,col,c,adr,col,col])
    # Fixed-pattern values in gaps and spare capacity must remain unchanged.
    a=np.array([[2.,0.1,0.2],[0.1,2.,0.3],[0.2,0.3,2.]])
    hc,ha,hi,c,old_adr,old_col,tc,ta,ti,old_map=symbolic(lib,a)
    hcount,hadr,hcol,h=csr(a); adr=np.array([0,3,7],np.int32); length=12
    col=np.zeros(length,np.int32); remap=np.zeros(len(old_col),np.int32)
    for r in range(n):
        for k in range(c[r]):
            col[adr[r]+k]=old_col[old_adr[r]+k]; remap[old_adr[r]+k]=adr[r]+k
    tcol=np.zeros(length,np.int32); mapping=np.zeros(length,np.int32)
    tcol[:len(ti)]=ti; mapping[:len(old_map)]=remap[old_map]
    initial=np.full(length,13.25); f=initial.copy(); work=np.zeros(n)
    rank=lib.mju_cholFactorNumeric(ptr(f),n,1e-15,ptr(c),ptr(adr),ptr(col),ptr(tc),ptr(ta),ptr(tcol),ptr(mapping),
                                 ptr(h),ptr(hcount),ptr(hadr),ptr(hcol),ptr(work))
    suite.case("sparse_numeric_padding_frame", [10,n,length,c,adr,col,initial,tc,ta,tcol,mapping,
               len(h),hcount,hadr,hcol,h,1e-15,np.full(n,3.75)], [0,rank,f,work])


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--build-root", type=Path,
        default=Path("/var/tmp/sparkling-cholesky-sparse-band-20260930")); args = ap.parse_args()
    assert mujoco.__version__ == "3.14.0", mujoco.__version__
    args.build_root.mkdir(parents=True, exist_ok=True)
    library = next(Path(mujoco.__file__).parent.glob("libmujoco.so*"))
    lib = ct.CDLL(str(library)); configure(lib)
    solve_lib, bridge_hash = bridge(library, args.build_root)
    suite = Suite(); rng = np.random.default_rng(20260930)
    band_cases(suite, lib, rng); sparse_cases(suite, lib, solve_lib, rng)
    results = [suite.run(args.build_root / "bin" / profile / "cholesky_sb_probe", profile)
               for profile in ["validation", "release"]]
    hashes = {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted((HERE / "src").glob("*.ad?"))}
    report = dict(reference="MuJoCo 3.14.0", reference_commit="9ecbb9d7b5ee623f54745638d36799ff90e6f7cd",
                  seed=20260930, timestamp=time.time(), library=str(library),
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  bridge_compiler=subprocess.run([os.environ.get("CC", "gcc"), "--version"],
                      capture_output=True, text=True, check=True).stdout.splitlines()[0],
                  platform=platform.platform(),
                  harness_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  sparse_solve_body_sha256=bridge_hash, sources_sha256=hashes, results=results,
                  note="Differential correctness tests, no timing or universal equivalence claim")
    target = args.build_root / "differential.json"; target.write_text(json.dumps(report, indent=2)+"\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__": main()
