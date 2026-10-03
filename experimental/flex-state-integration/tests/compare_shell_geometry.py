"""Ordered interior reconstruction against the unchanged native shell utility."""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np

PIN = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    ref = a.root / 'mujoco'
    if (mujoco.__version__ != '3.14.0' or subprocess.check_output(
            ['git', '-C', str(ref), 'rev-parse', 'HEAD'], text=True).strip() != PIN):
        raise RuntimeError('wrong C reference')
    sources = {}
    for name in ('src/engine/engine_util_misc.c', 'src/engine/engine_util_misc.h'):
        actual = (ref / name).read_bytes()
        pinned = subprocess.check_output(['git', '-C', str(ref), 'show', PIN + ':' + name])
        if actual.replace(b'\r\n', b'\n') != pinned.replace(b'\r\n', b'\n'):
            raise RuntimeError('changed C reference: ' + name)
        sources[name] = dict(raw_sha256=hashlib.sha256(actual).hexdigest(),
                             pinned_raw_sha256=hashlib.sha256(pinned).hexdigest(),
                             comparison='CRLF/LF normalized')
    library = Path(mujoco.__file__).parent / 'libmujoco.so.3.14.0'
    lib = ct.CDLL(str(library))
    lib.mju_shellTrackInterior.argtypes = [np.ctypeslib.ndpointer(
        dtype=np.float64, flags='C_CONTIGUOUS')] + [ct.c_int] * 3
    lib.mju_shellTrackInterior.restype = None
    (a.out / 'reference.json').write_text(json.dumps(dict(
        commit=PIN, version=mujoco.__version__, sources=sources, library=str(library),
        library_sha256=digest(library), symbol='mju_shellTrackInterior',
        patch_applied=False), indent=2) + '\n')
    rng = np.random.default_rng(2026100331)
    fixtures = []
    for grid in ((2, 3, 4), (4, 2, 3), (3, 4, 2), (3, 3, 3), (4, 5, 6), (9, 5, 7)):
        ijk = np.indices(grid).reshape(3, -1).T
        boundary = np.any((ijk == 0) | (ijk == np.array(grid) - 1), axis=1)
        for n in range(36):
            if n == 0:
                values = np.zeros((len(ijk), 3))
            elif n == 1:
                values = np.full((len(ijk), 3), -0.0)
            elif n == 2:
                values = np.full((len(ijk), 3), 1e11)
            elif n == 3:
                values = np.full((len(ijk), 3), -1e11)
            elif n == 4:
                values = (ijk / (np.array(grid) - 1)) @ rng.uniform(-1, 1, (3, 3))
            elif n == 5:
                values = rng.choice([0.0, -0.0, np.nextafter(0., 1.), -np.nextafter(0., 1.)],
                                    (len(ijk), 3))
            else:
                scale = (1e-11, 1.0, 1e10, 1e11)[n % 4]
                values = rng.uniform(-scale, scale, (len(ijk), 3))
            fixtures.append(dict(name=f'{grid}-{n}', grid=grid, nodes=values.tolist(),
                                 boundary=boundary.tolist()))
    payload = str(len(fixtures)) + '\n' + '\n'.join(' '.join(map(str,
        [*f['grid'], *np.array(f['nodes']).ravel()])) for f in fixtures) + '\n'
    (a.out / 'input.txt').write_text(payload)
    (a.out / 'fixtures.json').write_text(json.dumps(fixtures) + '\n')
    expected = []
    guards_ok = True
    for f in fixtures:
        source = np.array(f['nodes'], dtype=np.float64).ravel()
        guarded = np.concatenate(([1729.0] * 3, source, [-1729.0] * 3))
        lib.mju_shellTrackInterior(guarded[3:-3], *f['grid'])
        guards_ok &= bool(np.array_equal(guarded[:3], [1729.0] * 3)
                          and np.array_equal(guarded[-3:], [-1729.0] * 3))
        expected.append(guarded[3:-3].copy())
    (a.out / 'expected.json').write_text(json.dumps([x.view(np.uint64).tolist()
                                                   for x in expected]) + '\n')
    r = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (a.out / 'output.txt').write_text(r.stdout)
    (a.out / 'stderr.txt').write_text(r.stderr)
    actual = [np.fromstring(line[5:], sep=' ', dtype=np.uint64)
              for line in r.stdout.splitlines() if line.startswith('bits ')]
    records = []
    for f, want, got in zip(fixtures, expected, actual):
        equal = want.shape == got.shape and np.array_equal(want.view(np.uint64), got)
        boundary = np.repeat(f['boundary'], 3)
        initial = np.array(f['nodes']).ravel().view(np.uint64)
        frame = want.shape == got.shape and np.array_equal(got[boundary], initial[boundary])
        records.append(dict(name=f['name'], passed=bool(equal and frame),
                            exact=bool(equal), boundary_preserved=bool(frame),
                            mismatched=int(np.count_nonzero(want.view(np.uint64) != got))
                            if want.shape == got.shape else None))
    ok = (guards_ok and r.returncode == 0 and len(records) == len(fixtures)
          and all(x['passed'] for x in records))
    receipt = dict(passed=ok, exit=r.returncode, expected=len(fixtures),
                   exact=sum(x['passed'] for x in records), reference_guards=guards_ok,
                   records=records, binary_sha256=digest(a.binary),
                   input_sha256=hashlib.sha256(payload.encode()).hexdigest(),
                   scope='Standalone reconstruction from original boundary nodes; no FS admission or dynamics.')
    (a.out / 'results.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('RESULT', receipt['exact'], receipt['expected'], ok, flush=True)
    raise SystemExit(not ok)


if __name__ == '__main__':
    main()
