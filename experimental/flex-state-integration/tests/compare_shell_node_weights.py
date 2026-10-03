"""Negative-order basis/TFI composition against the unchanged private C body."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import numpy as np
from compare_node_weights import reference


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    lib = reference(a.root, a.out)
    rng = np.random.default_rng(2026100342)
    fixtures = []
    for degree in (1, 2):
        for grid in ((1, 1, 1), (2, 2, 2), (3, 2, 4)):
            shape = np.array(grid) * degree + 1
            nn = int(np.prod(shape))
            points = [np.zeros(3), np.ones(3), np.full(3, .5), np.full(3, .25),
                      np.array([-.2, 1.2, .5])]
            points += [np.array([x, 0., 0.]) for x in
                       (np.nextafter(1e-5, 0.), 1e-5, np.nextafter(1e-5, 1.), 1e-6)]
            cases = [('empty', np.zeros((4, 3)), np.zeros(4), 0)]
            cases += [('point-' + str(i), np.tile(x, (4, 1)), np.array([1., 0, 0, 0]), 1)
                      for i, x in enumerate(points)]
            cases += [('signedzero', np.zeros((4, 3)), np.array([-0., 1., 0, 0]), 2)]
            for i in range(24):
                count = 1 + i % 4
                weights = np.zeros(4)
                weights[:count] = rng.dirichlet(np.ones(count))
                cases.append(('random-' + str(i), rng.uniform(0, 1, (4, 3)), weights, count))
            for mode in ('distinct', 'duplicates', 'world'):
                bodies = (np.arange(nn) + 100 if mode == 'distinct' else
                          rng.integers(0, 8, nn) if mode == 'duplicates' else np.zeros(nn, dtype=int))
                for name, vertices, weights, count in cases:
                    for sign in (1, -1):
                        fixtures.append(dict(name=f'{degree}-{grid}-{mode}-{name}-{sign}',
                            degree=-degree, grid=grid, bodies=bodies.tolist(), vertices=vertices.tolist(),
                            weights=(weights * sign).tolist(), count=count))
    # At the central quadratic node the single basis coefficient expands to
    # the native +4/-3 example after merging face/corner and edge body groups.
    body_map = [12 if sum(x == 1 for x in (i,j,k)) == 1 else 11
                for i in range(3) for j in range(3) for k in range(3)]
    for sign in (1, -1):
        fixtures.append(dict(name='signed-four-three-' + str(sign), degree=-2, grid=(1,1,1),
            bodies=body_map, vertices=np.full((4,3),.5).tolist(), weights=[sign,0,0,0], count=1))
    payload = str(len(fixtures)) + '\n' + '\n'.join(' '.join(map(str,
        [f['degree'], *f['grid'], f['count'], *np.array(f['vertices']).ravel(),
         *f['weights'], *f['bodies']])) for f in fixtures) + '\n'
    (a.out / 'input.txt').write_text(payload)
    (a.out / 'fixtures.json').write_text(json.dumps(fixtures) + '\n')
    expected = []
    for f in fixtures:
        bodies = np.zeros(729, dtype=np.int32)
        weights = np.zeros(729)
        coord = np.zeros(3)
        count = lib.weights(f['degree'], np.array(f['grid'], dtype=np.int32),
            np.array(f['vertices'], dtype=np.float64), np.array(f['weights'], dtype=np.float64),
            f['count'], np.array(f['bodies'], dtype=np.int32), bodies, weights, coord)
        expected.append(dict(coord=coord.tolist(), bodies=bodies[:count].tolist(),
                             bits=weights[:count].view(np.uint64).tolist()))
    (a.out / 'expected.json').write_text(json.dumps(expected) + '\n')
    r = subprocess.run([str(a.binary)], input=payload, text=True, capture_output=True, timeout=120)
    (a.out / 'output.txt').write_text(r.stdout)
    (a.out / 'stderr.txt').write_text(r.stderr)
    actual = []
    for line in r.stdout.splitlines():
        if line == 'case':
            actual.append({})
        elif actual:
            k, _, v = line.partition(' ')
            actual[-1][k] = np.fromstring(v, sep=' ', dtype=(np.uint64 if k == 'bits' else
                np.int32 if k == 'bodies' else np.float64))
    records = []
    for f, want, got in zip(fixtures, expected, actual):
        checks = {}
        for key in ('coord', 'bodies', 'bits'):
            x = np.array(want[key], dtype=np.float64 if key == 'coord' else
                         np.int32 if key == 'bodies' else np.uint64)
            y = got.get(key, np.array([]))
            checks[key] = x.shape == y.shape and np.array_equal(
                x.view(np.uint64) if key == 'coord' else x,
                y.view(np.uint64) if key == 'coord' else y)
        records.append(dict(name=f['name'], checks=checks, passed=all(checks.values())))
    ok = r.returncode == 0 and len(records) == len(fixtures) and all(x['passed'] for x in records)
    result = dict(passed=ok, exit=r.returncode, cases=len(fixtures),
        exact=sum(x['passed'] for x in records), records=records,
        max_bodies=max(len(x['bodies']) for x in expected),
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        input_sha256=hashlib.sha256(payload.encode()).hexdigest(),
        scope='Negative-order basis cutoff, ordered TFI and body merge; no owned FS endpoint or dynamics.')
    (a.out / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print('RESULT', result['exact'], result['cases'], ok, flush=True)
    raise SystemExit(not ok)


if __name__ == '__main__':
    main()
