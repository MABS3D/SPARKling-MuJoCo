"""Owned shell metadata -> signed endpoint after releasing the source Model."""
import argparse
import hashlib
import json
from pathlib import Path
import resource
import subprocess

import mujoco
import numpy as np
from compare_node_weights import reference


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--fixtures', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK, (128 * 1024**2, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    lib = reference(a.root, a.out)
    rng = np.random.default_rng(2026100346)
    records = []
    for model_path in sorted(a.fixtures.glob('*/*.mjb')):
        if model_path.name.endswith('-core.mjb'):
            continue
        name = model_path.stem
        m = mujoco.MjModel.from_binary_path(str(model_path))
        shells = np.flatnonzero(m.flex_interp < 0)
        if len(shells) != 1:
            raise RuntimeError('expected one shell per fixture')
        f = int(shells[0])
        nv, start = int(m.flex_vertnum[f]), int(m.flex_vertadr[f])
        nad, nn = int(m.flex_nodeadr[f]), int(m.flex_nodenum[f])
        node_bodies = np.ascontiguousarray(m.flex_nodebodyid[nad:nad+nn], dtype=np.int32)
        grid = np.ascontiguousarray(m.flex_cellnum[f], dtype=np.int32)
        cases = []

        def add(label, flex, count, ids, weights, status='SUCCESS'):
            cases.append(dict(label=label, flex=flex, count=count, ids=list(map(int, ids)),
                              weights=list(map(float, weights)), status=status))

        add('empty-invalid-inactive-ids', f, 0, [nv+1]*4, [0.]*4)
        add('invalid-flex', int(m.nflex), 0, [0]*4, [0.]*4, 'INVALID_INPUT')
        add('invalid-vertex', f, 1, [nv,0,0,0], [1.,0,0,0], 'INVALID_INPUT')
        for ordinary in np.flatnonzero(m.flex_interp == 0):
            add('ordinary-refusal', int(ordinary), 1, [0]*4, [1.,0,0,0], 'UNSUPPORTED_FEATURE')
        for sample in range(64):
            count = sample % 4 + 1
            ids = rng.integers(0,nv,4)
            weights = np.zeros(4)
            weights[:count] = rng.dirichlet(np.ones(count))
            if sample % 2:
                weights = -weights
            if sample % 7 == 0:
                ids[:] = ids[0]
            add('sample-' + str(sample), f, count, ids, weights)
        payload = str(len(cases)) + '\n' + '\n'.join(' '.join(map(str,
            [c['flex'],c['count'],*c['ids'],*c['weights']])) for c in cases) + '\n'
        (a.out / (name + '.input')).write_text(payload)
        (a.out / (name + '.requests.json')).write_text(json.dumps(cases,indent=2)+'\n')
        expected = []
        for c in cases:
            bodies = np.zeros(729,dtype=np.int32)
            weights = np.zeros(729)
            nb = 0
            if c['status'] == 'SUCCESS' and c['count']:
                points = np.zeros((4,3))
                points[:c['count']] = m.flex_vert0[start + np.array(c['ids'][:c['count']])]
                coord = np.zeros(3)
                nb = lib.weights(int(m.flex_interp[f]), grid, points,
                    np.array(c['weights']), c['count'], node_bodies, bodies, weights, coord)
            expected.append(dict(status=c['status'],bodies=bodies[:nb].tolist(),
                                 bits=weights[:nb].view(np.uint64).tolist()))
        (a.out / (name + '.expected.json')).write_text(json.dumps(expected,indent=2)+'\n')
        r = subprocess.run([str(a.binary),str(model_path)], input=payload, text=True,
                           capture_output=True, timeout=120)
        (a.out / (name + '.output')).write_text(r.stdout+r.stderr)
        actual = []
        for line in r.stdout.splitlines():
            if line.startswith('case '):
                actual.append(dict(status=line.split()[1]))
            elif actual:
                key, _, values = line.partition(' ')
                actual[-1][key] = np.fromstring(values, sep=' ', dtype=np.uint64 if key == 'bits'
                    else np.int32 if key == 'bodies' else np.float64)
        checks = []
        for c, want, got in zip(cases,expected,actual):
            ok = want['status'] == got.get('status')
            for key in ('bodies','bits'):
                x = np.array(want[key],dtype=np.int32 if key == 'bodies' else np.uint64)
                y = got.get(key,np.array([]))
                ok = ok and x.shape == y.shape and np.array_equal(x,y)
            checks.append(dict(label=c['label'],passed=bool(ok)))
        records.append(dict(model=name,model_path=str(model_path),
            model_sha256=hashlib.sha256(model_path.read_bytes()).hexdigest(),exit=r.returncode,
            cases=len(cases),actual=len(actual),exact=sum(x['passed'] for x in checks),
            passed=r.returncode == 0 and len(actual) == len(cases) and all(x['passed'] for x in checks),
            checks=checks,max_bodies=max(len(x['bodies']) for x in expected)))
        print(name,records[-1]['exact'],len(cases),r.returncode,flush=True)
    if not records:
        raise RuntimeError('no shell fixture')
    result = dict(passed=all(r['passed'] for r in records),records=records,
        cases=sum(r['cases'] for r in records),exact=sum(r['exact'] for r in records),
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        scope='Owned signed endpoint only; no Jacobian, solver, elasticity or dynamics admission.')
    (a.out / 'results.json').write_text(json.dumps(result,indent=2)+'\n')
    raise SystemExit(not result['passed'])


if __name__ == '__main__':
    main()
