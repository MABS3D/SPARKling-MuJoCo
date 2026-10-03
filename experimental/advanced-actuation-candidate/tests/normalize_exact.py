"""Check Normalize against mju_normalize4 at branch boundaries and wide scales."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    magnitudes = [0., 1.e-300, 1.e-160, 1.e-100, 1.e-18, 1.e-10, .5, 2., 1.e10]
    for edge in [1.e-15, 1.-1.e-15, 1., 1.+1.e-15]:
        value = edge
        for _ in range(12):
            value = np.nextafter(value, -np.inf)
        for _ in range(25):
            magnitudes.append(float(value))
            value = np.nextafter(value, np.inf)
    directions = [[1., 0., 0., 0.], [-1., -0., 0., -0.],
                  [0., 1., 0., 0.], [0., 0., -1., 0.], [0., 0., 0., 1.],
                  [.6, .8, 0., 0.], [-.6, .8, -0., 0.], [.5, .5, .5, .5]]
    quaternions = [(np.array(axis)*magnitude).tolist()
                   for magnitude in magnitudes for axis in directions]
    targeted = len(quaternions)
    rng = np.random.default_rng(3141005)
    axes = rng.normal(size=(4096, 4))
    axes /= np.linalg.norm(axes, axis=1)[:, None]
    scales = 10.**rng.uniform(-30., 10., 4096)
    quaternions.extend((axes*scales[:, None]).tolist())
    lines, expected = [], []
    for quaternion in quaternions:
        values = [0.] * 128
        values[0:4] = quaternion
        values[7] = 1.
        lines.append('7 ' + ' '.join(format(value, '.17g') for value in values))
        wanted = np.array(quaternion)
        mujoco.mju_normalize4(wanted)
        expected.append(wanted)
    inputs = '\n'.join(lines) + '\n'
    (args.out/'input.txt').write_text(inputs)
    run = subprocess.run([str(args.binary)], input=inputs, text=True,
                         capture_output=True, timeout=30)
    (args.out/'output.txt').write_text(run.stdout)
    (args.out/'stderr.txt').write_text(run.stderr)
    assert run.returncode == 0, (run.returncode, run.stderr)
    rows = run.stdout.splitlines()
    assert len(rows) == len(quaternions)
    records = []
    for index, (row, wanted) in enumerate(zip(rows, expected)):
        actual = np.array(list(map(float, row.split()))[:4])
        records.append(dict(index=index, quaternion=quaternions[index],
                            targeted=index < targeted, actual=actual.tolist(),
                            expected=wanted.tolist(), exact=bool(np.array_equal(actual, wanted)),
                            bit_exact=actual.tobytes() == wanted.tobytes(),
                            max_abs=float(np.max(np.abs(actual-wanted)))))
    sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
    report = dict(reference=mujoco.__version__, library_sha256=sha(library),
                  driver_sha256=sha(__file__), binary_sha256=sha(args.binary),
                  input_sha256=sha(args.out/'input.txt'), cases=len(records),
                  targeted_cases=targeted, exact=sum(r['exact'] for r in records),
                  bit_exact=sum(r['bit_exact'] for r in records), records=records)
    (args.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print({key: value for key, value in report.items() if key != 'records'})
    raise SystemExit(report['bit_exact'] != report['cases'])


if __name__ == '__main__':
    main()
