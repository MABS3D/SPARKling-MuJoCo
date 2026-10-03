"""Compare controller expmap with the exact public C operations it composes.

The controller divides each axis component by the norm.  This intentionally
does not use mju_quatIntegrate, whose reciprocal/tiny-axis semantics differ.
"""
import argparse
import ctypes
import hashlib
import json
import subprocess
from pathlib import Path

import mujoco
import numpy as np


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
    c_api = ctypes.CDLL(str(library))
    vector_type = ctypes.c_double * 3
    c_api.mju_norm3.argtypes = [ctypes.POINTER(ctypes.c_double)]
    c_api.mju_norm3.restype = ctypes.c_double

    angles = [0., 1.e-100, 1.e-18, np.nextafter(1.e-15, 0.), 1.e-15,
              np.nextafter(1.e-15, np.inf), 1.e-14]
    for edge in [2.**-26, 2.**-25, 2.1e-8, 2.5e-8, 2.9e-8, 3.e-8, 4.e-8]:
        angles.extend([np.nextafter(edge, 0.), edge, np.nextafter(edge, np.inf)])
    angles.extend(np.linspace(2.e-8, 4.e-8, 257))
    directions = [[1., 0., 0.], [-1., 0., 0.], [0., -1., 0.],
                  [0., 0., 1.], [.6, .8, 0.], [-.6, .8, -0.]]
    vectors = [(np.array(axis)*angle).tolist() for angle in angles for axis in directions]
    targeted = len(vectors)
    rng = np.random.default_rng(3141004)
    vectors.extend(rng.uniform(-3., 3., (512, 3)).tolist())
    lines, expected = [], []
    for vector in vectors:
        values = [0.] * 128
        values[0] = values[7] = 1.
        values[11:14] = vector
        lines.append('7 ' + ' '.join(format(value, '.17g') for value in values))
        norm = c_api.mju_norm3(vector_type(*vector))
        result = np.array([1., 0., 0., 0.])
        if norm >= 1.e-15:
            axis = np.array([value/norm for value in vector])
            mujoco.mju_axisAngle2Quat(result, axis, norm)
        expected.append(result)
    inputs = '\n'.join(lines) + '\n'
    (args.out/'input.txt').write_text(inputs)
    process = subprocess.run([str(args.binary)], input=inputs, text=True,
                             capture_output=True, timeout=30)
    (args.out/'output.txt').write_text(process.stdout)
    (args.out/'stderr.txt').write_text(process.stderr)
    assert process.returncode == 0, (process.returncode, process.stderr)
    rows = process.stdout.splitlines()
    assert len(rows) == len(vectors), (len(rows), len(vectors))
    records = []
    for index, (row, wanted) in enumerate(zip(rows, expected)):
        actual = np.array(list(map(float, row.split()))[13:17])
        assert actual.shape == (4,)
        records.append(dict(index=index, vector=vectors[index], targeted=index < targeted,
                            actual=actual.tolist(), expected=wanted.tolist(),
                            exact=bool(np.array_equal(actual, wanted)),
                            bit_exact=actual.tobytes() == wanted.tobytes(),
                            max_abs=float(np.max(np.abs(actual-wanted)))))
    sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
    report = dict(reference=mujoco.__version__, library_sha256=sha(library),
                  driver_sha256=sha(__file__), binary_sha256=sha(args.binary),
                  input_sha256=sha(args.out/'input.txt'), cases=len(records),
                  exact=sum(record['exact'] for record in records),
                  bit_exact=sum(record['bit_exact'] for record in records),
                  targeted_cases=targeted,
                  targeted_exact=sum(record['exact'] for record in records[:targeted]),
                  records=records)
    (args.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print({key: value for key, value in report.items() if key != 'records'})
    raise SystemExit(report['exact'] != report['cases'])


if __name__ == '__main__':
    main()
