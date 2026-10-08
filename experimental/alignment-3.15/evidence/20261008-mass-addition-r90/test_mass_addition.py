"""Bitwise flat mass addition and dense frame against actual C mju_addToMatSparse."""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--reference', type=Path, required=True)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.15.0'
    args.out.mkdir(parents=True, exist_ok=False)
    library = Path(mujoco.__file__).parent / 'libmujoco.so.3.15.0'
    lib = ct.CDLL(str(library))
    ip, dp = ct.POINTER(ct.c_int), ct.POINTER(ct.c_double)
    symbolic = lib.mju_cholFactorSymbolic
    symbolic.argtypes = [ip]*10 + [ct.c_int, ct.c_void_p]
    symbolic.restype = ct.c_int
    add = lib.mju_addToMatSparse
    add.argtypes = [dp, ip, ip, ip, ct.c_int, dp, ip, ip, ip]
    add.restype = None
    rng = np.random.default_rng(2026100806)
    cases = []
    for n in [1, 2, 3, 5, 8, 17, 32, 65, 128]:
        for pattern in ['diagonal', 'chain', 'tree', 'random', 'dense']:
            mask = np.eye(n, dtype=bool)
            for r in range(n):
                if pattern == 'chain' and r: mask[r-1, r] = True
                if pattern == 'tree' and r: mask[(r-1)//2, r] = True
                if pattern == 'random': mask[:r, r] = rng.random(r) < .2
                if pattern == 'dense': mask[:r, r] = True
            for kind in ['normal', 'boundary', 'signed-zero', 'tiny']:
                h = rng.uniform(-1, 1, (n, n))
                m = rng.uniform(-1, 1, (n, n))
                if kind == 'boundary':
                    h = rng.choice([-1e100, 1e100], (n, n))
                    m = rng.choice([-1e100, 1e100], (n, n))
                elif kind == 'signed-zero':
                    h = rng.choice([-0., 0.], (n, n))
                    m = rng.choice([-0., 0.], (n, n))
                elif kind == 'tiny':
                    h *= 1e-300
                    m *= 1e-300
                cases.append((n, pattern, kind, mask, h, m))
    payload = ''.join(str(n)+' '+ ' '.join(str(int(x)) for x in mask.ravel())+' '+
                      ' '.join(format(x, '.17g') for x in np.r_[h.ravel(), m.ravel()])+'\n'
                      for n, pattern, kind, mask, h, m in cases)
    (args.out/'input.txt').write_text(payload)
    run = subprocess.run([str(args.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (args.out/'output.txt').write_text(run.stdout+run.stderr)
    if run.returncode: raise RuntimeError(run.stderr+run.stdout[-1000:])
    lines = run.stdout.splitlines()
    assert len(lines) == len(cases)
    ptr = lambda x, t: x.ctypes.data_as(t)
    records = []
    for line, (n, pattern, kind, mask, h, mass) in zip(lines, cases, strict=True):
        hn = mask.sum(axis=1).astype(np.int32)
        ha = np.r_[0, np.cumsum(hn[:-1])].astype(np.int32)
        hi = np.where(mask)[1].astype(np.int32)
        ln, la, tn, ta = [np.zeros(n, np.int32) for _ in range(4)]
        count = symbolic(None, ptr(ln, ip), ptr(la, ip), None, ptr(tn, ip), ptr(ta, ip),
                         None, ptr(hn, ip), ptr(ha, ip), ptr(hi, ip), n, None)
        li, ti, tm = [np.zeros(count, np.int32) for _ in range(3)]
        symbolic(ptr(li, ip), ptr(ln, ip), ptr(la, ip), ptr(ti, ip), ptr(tn, ip), ptr(ta, ip),
                 ptr(tm, ip), ptr(hn, ip), ptr(ha, ip), ptr(hi, ip), n, None)
        expected = h.copy()
        values = np.concatenate([h[r, li[la[r]:la[r]+ln[r]]] for r in range(n)])
        source = np.concatenate([mass[r, li[la[r]:la[r]+ln[r]]] for r in range(n)])
        before_lengths, before_addresses, before_columns = ln.copy(), la.copy(), li.copy()
        add(ptr(values, dp), ptr(ln, ip), ptr(la, ip), ptr(li, ip), n, ptr(source, dp),
            ptr(before_lengths, ip), ptr(before_addresses, ip), ptr(before_columns, ip))
        unchanged_layout = (np.array_equal(ln, before_lengths) and np.array_equal(la, before_addresses)
                            and np.array_equal(li, before_columns))
        for r in range(n): expected[r, li[la[r]:la[r]+ln[r]]] = values[la[r]:la[r]+ln[r]]
        fields = line.split()
        actual = np.asarray(fields[1:], float).reshape(n, n)
        passed = bool(int(fields[0]) == count and unchanged_layout and
                      np.array_equal(actual.view(np.uint64), expected.view(np.uint64)))
        records.append(dict(n=n, pattern=pattern, kind=kind, passed=passed, layout_unchanged=unchanged_layout))
    result = dict(reference='3.15.0', function='mju_addToMatSparse', cases=len(cases),
                  passed=sum(row['passed'] for row in records), records=records,
                  failures=[r for r in records if not r['passed']],
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  reference_library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  reference_sources={n:hashlib.sha256((args.reference/'src/engine'/n).read_bytes()).hexdigest()
                                     for n in ['engine_util_sparse.c', 'engine_util_solve.c']},
                  scope='Same fixed CSR support in both operands; all other dense cells preserve exact input bits. Not general sparse union or full assembly parity.')
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(result['passed'], '/', result['cases'], 'bitwise C mass additions and dense frame')
    raise SystemExit(bool(result['failures']))


if __name__ == '__main__':
    main()
