"""Compare ordered Gram rows bitwise with actual SIMD C 3.15 sparse assembly."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--reference", type=Path, required=True)
    args = parser.parse_args()
    assert mujoco.__version__ == "3.15.0"
    args.out.mkdir(parents=True, exist_ok=False)
    library = Path(mujoco.__file__).parent / "libmujoco.so.3.15.0"
    lib = ctypes.CDLL(str(library))
    fp = ctypes.POINTER(ctypes.c_double)
    ip = ctypes.POINTER(ctypes.c_int)
    numeric = lib.mju_sqrMatTDSparseNumeric
    numeric.argtypes = [fp, ctypes.c_int, ip, ip, ip, ip,
                        fp, ip, ip, ip, fp, ip, ip, ip, ip, fp, ctypes.c_void_p]
    numeric.restype = None
    model = mujoco.MjModel.from_xml_string('<mujoco><size memory="4M"/></mujoco>')
    data = mujoco.MjData(model)
    rng = np.random.default_rng(2026100801)
    cases = []
    for n in [1, 2, 3, 4, 6, 12, 36, 64, 128]:
        for width in sorted({0, 1, n//2, n}):
            columns = np.sort(rng.choice(n, width, replace=False)).astype(np.int32)
            for magnitude, weight in [(0., 1.), (1e-60, 1e-15), (1., 0.), (1., 1.),
                                      (1e6, 1e15), (1e55, 1e15), (1e60, 1.)]:
                values = (rng.uniform(-1, 1, width)*magnitude).astype(np.float64)
                if width > 1:
                    values[0] = -0.0
                cases.append(dict(n=n, columns=columns, values=values, weight=weight, previous=0.))
    # Exercise sign preservation for zero scales, partial failure and the
    # Operand boundary. Nonzero initial H uses the ordered scalar model.
    for previous in [0., -0., 1., -1., 1e120, -1e120]:
        for weight in [0., 1., 1e15]:
            for values in [[-0., 0., 1.], [1e60, 1e60, -1e60], [1e-60, -1e-60, 0.],
                           [6.*2.**437, -6.*2.**437, 1.], [1., 6.*2.**437, -1.],
                           [np.nextafter(0., 1.), np.nextafter(0., -1.), np.finfo(np.float64).tiny],
                           [1e-310, -1e-310, 0.]]:
                cases.append(dict(n=4, columns=np.array([0, 2, 3], dtype=np.int32),
                                  values=np.array(values, dtype=np.float64), weight=weight, previous=previous))
    cases = [dict(case, packed=packed) for case in cases for packed in [True, False]]
    inputs = [str(len(cases))]
    expected, accepts, c_refs = [], [], []
    for case in cases:
        n, columns, values = case["n"], case["columns"], case["values"]
        vector = values if case["packed"] else np.zeros(n, dtype=np.float64)
        if not case["packed"]:
            vector[columns] = values
        fields = [n, len(columns), int(case["packed"]), case["weight"], case["previous"],
                  *[int(x)+1 for x in columns], *vector]
        inputs.append(" ".join(format(x, ".17g") for x in fields))
        h = np.full((n, n), case["previous"], dtype=np.float64)
        accepted = True
        for pi, p in enumerate(columns):
            scale = np.float64(case["weight"])*values[pi]
            if scale == 0:
                continue
            for qi in range(pi+1):
                q = columns[qi]
                h[p, q] = h[p, q] + scale*values[qi]
                if not -1e120 <= h[p, q] <= 1e120:
                    accepted = False
                    break
            if not accepted:
                break
        expected.append(h); accepts.append(accepted)
        c_expected = None
        if case["previous"] == 0. and not np.signbit(case["previous"]):
            rn = np.arange(1, n+1, dtype=np.int32)
            ra = np.r_[0, np.cumsum(rn[:-1])].astype(np.int32)
            ci = np.concatenate([np.arange(r+1, dtype=np.int32) for r in range(n)])
            result = np.zeros(ci.size, dtype=np.float64)
            mn = np.array([len(columns)], dtype=np.int32); ma = np.array([0], dtype=np.int32)
            tn = np.zeros(n, dtype=np.int32); tn[columns] = 1
            ta = np.r_[0, np.cumsum(tn[:-1])].astype(np.int32)
            ti = np.zeros(len(columns), dtype=np.int32)
            diagonal = np.array([case["weight"]], dtype=np.float64)
            f = lambda x: x.ctypes.data_as(fp)
            i = lambda x: x.ctypes.data_as(ip)
            numeric(f(result), n, i(rn), i(ra), i(ci), None,
                    f(values), i(mn), i(ma), i(columns), f(values), i(tn), i(ta), i(ti),
                    None, f(diagonal), data._address)
            c_expected = np.zeros((n, n), dtype=np.float64)
            for r in range(n):
                c_expected[r, :r+1] = result[ra[r]:ra[r]+rn[r]]
            if accepted:
                assert np.array_equal(h.view(np.uint64), c_expected.view(np.uint64))
        c_refs.append(c_expected)
    input_path = args.out / "input.txt"
    input_path.write_text("\n".join(inputs) + "\n")
    output_path = args.out / "output.txt"
    with input_path.open() as stream, output_path.open("w") as target:
        subprocess.run([str(args.binary)], stdin=stream, stdout=target, check=True, timeout=120)
    lines = output_path.read_text().splitlines(); assert len(lines) == len(cases)
    records = []
    for case, line, h, accepted, c_expected in zip(cases, lines, expected, accepts, c_refs, strict=True):
        parts = line.split(); actual_accepted = int(parts[0]) == 1
        actual = np.array([float(x) for x in parts[1:]], dtype=np.float64).reshape(h.shape)
        passed = actual_accepted == accepted and np.array_equal(actual.view(np.uint64), h.view(np.uint64))
        c_passed = None
        if c_expected is not None and accepted:
            c_passed = bool(np.array_equal(actual.view(np.uint64), c_expected.view(np.uint64)))
            passed = passed and c_passed
        records.append(dict(n=case["n"], width=len(case["columns"]), packed=case["packed"],
                            accepted=accepted, previous=case["previous"], weight=case["weight"],
                            passed=bool(passed), actual_c_bitwise=c_passed))
    receipt = dict(reference=mujoco.__version__, cases=len(records), passed=sum(r["passed"] for r in records),
                   c_bitwise_cases=sum(r["actual_c_bitwise"] is True for r in records),
                   binary_sha256=sha(args.binary), runner_sha256=sha(Path(__file__)),
                   library_sha256=sha(library), reference_source_sha256=sha(args.reference / "src/engine/engine_util_sparse.c"),
                   input_sha256=sha(input_path), output_sha256=sha(output_path), records=records,
                   scope="Actual scalar/sparse SIMD C path for zero-initialized accepted rows; ordered scalar model for nonzero seeds and partial Numeric_Limit rejection. Not a global assembly proof.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2)+"\n")
    print(json.dumps({key: receipt[key] for key in ["cases", "passed", "c_bitwise_cases"]}))
    assert receipt["passed"] == receipt["cases"]


if __name__ == "__main__":
    main()
