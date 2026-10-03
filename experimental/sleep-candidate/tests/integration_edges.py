#!/usr/bin/env python3
"""Check native failure preservation and retry against an error-free C step."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path
import mujoco
import numpy as np
from integration import xml, oracle


def run(binary, model, ops, stem):
    data = str(len(ops))+'\n'+'\n'.join(' '.join(map(str, op)) for op in ops)+'\n'
    stem.with_suffix('.input').write_text(data)
    p = subprocess.run([str(binary), str(model)], input=data, text=True,
                       capture_output=True, timeout=60)
    stem.with_suffix('.output').write_text(p.stdout+p.stderr)
    if p.returncode:
        raise RuntimeError(p.stdout+p.stderr)
    return [np.array([float(x) for x in re.findall(
        r'[+-]?(?:\d+\.\d+(?:[Ee][+-]?\d+)?|\d+)', line)])
        for line in p.stdout.splitlines()]


def same(a, b, model):
    stop = 3+model.nq+model.nv
    return (a.shape == b.shape and np.array_equal(a[:2], b[:2])
            and np.array_equal(a[stop:], b[stop:])
            and np.allclose(a[2:stop], b[2:stop], atol=2e-10, rtol=2e-10))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    records = []
    for kind in ['slide', 'hinge', 'ball', 'free']:
        for n in [1, 4, 16]:
            name = f'{kind}-{n}'
            source = xml(kind, n, policy='init')
            m = mujoco.MjModel.from_xml_string(source)
            path = args.out/(name+'.mjb')
            mujoco.mj_saveModel(m, str(path))
            path.with_suffix('.xml').write_text(source)
            q = m.qpos0.copy()
            if kind == 'ball':
                q[:4] = [np.cos(.05), np.sin(.05), 0, 0]
            else:
                q[0] += .1
            v = np.zeros(m.nv)
            ordinary = [[1, 0., *q, *v], [0]]
            # The port admits time <= mjMAXVAL. The first step fails after
            # detecting the pose change; correcting time must preserve the wake.
            failed = [[1, 1e10, *q, *v], [0], *ordinary]
            actual = run(args.binary, path, failed, args.out/(name+'-failure'))
            baseline = run(args.binary, path, ordinary, args.out/(name+'-baseline'))
            expected = oracle(m, ordinary)
            statuses = [int(row[0]) for row in actual]
            atomic = np.array_equal(actual[0][1:], actual[1][1:])
            retry = same(actual[-1], baseline[-1], m)
            c_match = same(baseline[-1], expected[-1], m)
            passed = statuses == [0, 10, 0, 0] and atomic and retry and c_match
            records.append(dict(name=name, passed=passed, statuses=statuses,
                failure_atomic=atomic, retry_matches_baseline=retry,
                baseline_matches_c=c_match, actual=actual[-1].tolist(),
                expected=expected[-1].tolist()))
            print(name, 'PASS' if passed else 'FAIL', flush=True)
    files = [args.binary, Path(__file__), Path(__file__).with_name('integration.py')]
    result = dict(cases=len(records), passed=sum(x['passed'] for x in records),
        reference='3.14.0', scope='Port numeric-limit rollback; successful retry compared with C',
        hashes={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}, records=records)
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print('RESULT', result['passed'], result['cases'])
    raise SystemExit(result['passed'] != result['cases'])

if __name__ == '__main__':
    main()
