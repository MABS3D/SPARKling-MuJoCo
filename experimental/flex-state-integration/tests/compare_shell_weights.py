"""Bitwise signed shell expansion against the unchanged official C symbol."""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np

PIN = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    ref = a.root / 'mujoco'
    if (mujoco.__version__ != '3.14.0'
            or subprocess.check_output(['git', '-C', str(ref), 'rev-parse', 'HEAD'], text=True).strip() != PIN):
        raise RuntimeError('wrong C reference')
    hashes = {}
    for name in ('src/engine/engine_util_misc.c', 'src/engine/engine_util_misc.h'):
        actual = (ref / name).read_bytes()
        pinned = subprocess.check_output(['git', '-C', str(ref), 'show', PIN + ':' + name])
        if actual.replace(b'\r\n', b'\n') != pinned.replace(b'\r\n', b'\n'):
            raise RuntimeError('changed C reference ' + name)
        hashes[name] = dict(raw_sha256=hashlib.sha256(actual).hexdigest(),
                            pinned_raw_sha256=hashlib.sha256(pinned).hexdigest(),
                            comparison='CRLF/LF normalized')
    library = Path(mujoco.__file__).parent / 'libmujoco.so.3.14.0'
    lib = ct.CDLL(str(library))
    ip = np.ctypeslib.ndpointer(dtype=np.int32, flags='C_CONTIGUOUS')
    fp = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
    lib.mju_shellTFIWeights.argtypes = [ct.c_int] * 6 + [ct.c_double, ct.POINTER(ct.c_int), ip, fp, ip, ct.c_int]
    lib.mju_shellTFIWeights.restype = None
    (a.out / 'reference.json').write_text(json.dumps(dict(
        commit=PIN, version=mujoco.__version__, sources=hashes, library=str(library),
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        symbol='mju_shellTFIWeights', patch_applied=False), indent=2) + '\n')

    rng = np.random.default_rng(202610039)
    fixtures = []
    for grid in ((3, 3, 3), (4, 5, 6), (9, 5, 7)):
        total = int(np.prod(grid))
        for mode in ('distinct', 'duplicates', 'world'):
            bodies = (np.arange(total, dtype=np.int32) + 2000 if mode == 'distinct' else
                      (rng.integers(0, 7, total, dtype=np.int32) if mode == 'duplicates' else
                       np.zeros(total, dtype=np.int32)))
            weights = [0.0, -0.0, 1.0, -1.0, 64.0, -64.0, 1e-5,
                       np.nextafter(0.0, 1.0), -np.nextafter(0.0, 1.0)]
            for n in range(36):
                point = tuple(int(rng.integers(1, dim - 1)) for dim in grid)
                weight = weights[n % len(weights)] if n < 18 else float(rng.uniform(-64, 64))
                seed = [] if n % 3 == 0 else [(int(bodies[0]), 0.125), (int(bodies[-1]), -0.25)]
                fixtures.append(dict(name=f'{grid}-{mode}-{n}', grid=grid,
                                     bodies=bodies.tolist(), seed=seed, calls=[(*point, weight)]))
            calls = [(*(int(rng.integers(1, dim - 1)) for dim in grid),
                      float(rng.uniform(-1, 1))) for _ in range(27)]
            fixtures.append(dict(name=f'{grid}-{mode}-27-expansions', grid=grid,
                                 bodies=bodies.tolist(), seed=[], calls=calls))
    fixtures.append(dict(name='capacity-729', grid=(3, 3, 3),
                         bodies=list(range(2000, 2027)), seed=[(i, 0.25) for i in range(703)],
                         calls=[(1, 1, 1, -1.0)]))
    # One interior-node expansion already admits weights +4 and -3 when
    # faces/corners share one body and edges share another. A +/-2 contract
    # from the positive-order adapter cannot describe this shell endpoint.
    shells = [12 if sum(x == 1 for x in (i, j, k)) == 1 else 11
              for i in range(3) for j in range(3) for k in range(3)]
    fixtures.append(dict(name='signed-magnitude-above-two', grid=(3, 3, 3),
                         bodies=shells, seed=[], calls=[(1, 1, 1, 1.0)]))
    fixtures.append(dict(name='empty-preserves-full-endpoint', grid=(3, 3, 3),
                         bodies=list(range(27)), seed=[(i, -0.25) for i in range(729)], calls=[]))
    # Preserve every input before entering native code.
    lines = []
    for f in fixtures:
        values = [*f['grid'], len(f['calls']), len(f['seed'])]
        values += [v for pair in f['seed'] for v in pair]
        values += f['bodies'] + [v for call in f['calls'] for v in call]
        lines.append(' '.join(map(str, values)))
    payload = str(len(fixtures)) + '\n' + '\n'.join(lines) + '\n'
    (a.out / 'input.txt').write_text(payload)
    (a.out / 'fixtures.json').write_text(json.dumps(fixtures, indent=2) + '\n')
    expected = []
    for f in fixtures:
        bodies = np.array(f['bodies'], dtype=np.int32)
        ids = np.zeros(729, dtype=np.int32)
        weights = np.zeros(729)
        count = ct.c_int(len(f['seed']))
        for j, (body, weight) in enumerate(f['seed']):
            ids[j], weights[j] = body, weight
        for x, y, z, weight in f['calls']:
            lib.mju_shellTFIWeights(*f['grid'], x, y, z, weight, ct.byref(count), ids, weights, bodies, 0)
        expected.append(dict(bodies=ids[:count.value].tolist(), weights=weights[:count.value].tolist()))
    (a.out / 'expected.json').write_text(json.dumps(expected, indent=2) + '\n')
    result = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (a.out / 'output.txt').write_text(result.stdout)
    (a.out / 'stderr.txt').write_text(result.stderr)
    actual = []
    for line in result.stdout.splitlines():
        if line == 'case':
            actual.append({})
        elif actual:
            name, _, values = line.partition(' ')
            actual[-1][name] = (values.strip() == 'TRUE' if name == 'tail' else
                                 np.fromstring(values, sep=' ', dtype=(np.int32 if name == 'bodies'
                                                                     else np.uint64 if name == 'bits' else np.float64)))
    records = []
    for f, want, got in zip(fixtures, expected, actual):
        checks = dict(tail=got.get('tail') is True)
        for name in ('bodies', 'weights'):
            x = np.array(want[name], dtype=np.int32 if name == 'bodies' else np.float64)
            y = got.get(name if name == 'bodies' else 'bits', np.array([]))
            checks[name] = bool(x.shape == y.shape and np.array_equal(
                x if name == 'bodies' else x.view(np.uint64),
                y))
        records.append(dict(name=f['name'], checks=checks, passed=all(checks.values())))
    ok = result.returncode == 0 and len(records) == len(fixtures) and all(r['passed'] for r in records)
    receipt = dict(passed=ok, exit=result.returncode, expected=len(fixtures),
                   exact=sum(r['passed'] for r in records), records=records,
                   max_bodies=max(len(x['bodies']) for x in expected),
                   max_abs_coefficient=max(abs(w) for x in expected for w in x['weights']),
                   negative_coefficients=sum(any(w < 0 for w in x['weights']) for x in expected),
                   binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                   input_sha256=hashlib.sha256(payload.encode()).hexdigest(),
                   scope='Signed TFI terms and ordered duplicate accumulation only; no state or dynamics integration.')
    (a.out / 'results.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('RESULT', receipt['exact'], receipt['expected'], ok, flush=True)
    raise SystemExit(not ok)


if __name__ == '__main__':
    main()
