#!/usr/bin/env python3
"""Compare every dense vector kernel with pinned MuJoCo C implementations."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import random
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("test_runner", ROOT / "tests/run.py")
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


def cases() -> list[tuple[int, list[float], list[float], float]]:
    rows = []
    sizes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 16, 17, 31, 32, 33, 127, 128, 129, 257]
    for n in sizes:
        for first in [0, 7, 2**31 - max(1, n)]:
            for x in [0.0, -0.0, 1e-300, 1e-15, 1.0, -1.0, 1e10, -1e10]:
                rows.append((first, [x] * n, [-x] * n, x))
    for n in [1, 2, 3, 4, 5, 8]:
        for x in [math.nextafter(1e-15, 0.0), 1e-15, math.nextafter(1e-15, math.inf),
                  math.nextafter(1.0, 0.0), 1.0, math.nextafter(1.0, math.inf),
                  1.0 + 4 * sys.float_info.epsilon, 1.0 + 8 * sys.float_info.epsilon]:
            rows.append((5, [x] + [0.0] * (n-1), [0.0] * n, -1.0))
    rows += [(11, [3.0, 4.0, 0.0], [0.0, 0.0, 5.0], 2.0),
             (0, [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], 1.0)]
    # Four-lane association differs from a left-to-right reduction here.
    for n in [4, 5, 6, 7, 8, 9, 17, 33]:
        a = ([1e10, 1.0, -1e10, 1.0] * ((n+3)//4))[:n]
        rows.append((3, a, [1e10] * n, 1.0))
    # Strict equal3 threshold: below, at, and above mjMINVAL.
    for x in [math.nextafter(1e-15, 0.0), 1e-15, math.nextafter(1e-15, math.inf)]:
        rows.append((0, [0.0, 0.0, 0.0], [x, 0.0, 0.0], 1.0))
    rng = random.Random(20260923)
    for _ in range(1000):
        n = rng.choice(sizes)
        a, b = [[rng.uniform(-1, 1) * 10.0 ** rng.randint(-300, 10)
                 for _ in range(n)] for _ in range(2)]
        if rng.randrange(5) == 0:
            b = a[:]
        rows.append((rng.choice([0, 19, 2**31 - max(1, n)]), a, b,
                     rng.uniform(-1, 1) * 10.0 ** rng.randint(-150, 10)))
    return rows


def layout(row):
    """(operation, count, roundoff scale, multiplier); None means exact."""
    _, a, b, s = row
    n = len(a)
    pair = [abs(x) + abs(y) for x, y in zip(a, b)]
    scaled = [abs(x) + abs(y*s) for x, y in zip(a, b)]
    reduction = 16 * (n + 1)
    result = [
        ("Zero", n, None, 0), ("Fill", n, None, 0), ("Copy", n, None, 0),
        ("Scl", n, [abs(x*s) for x in a], 8),
        ("Add", n, pair, 8), ("Sub", n, pair, 8),
        ("AddTo", n, pair, 8), ("SubFrom", n, pair, 8),
        ("AddToScl", n, scaled, 8), ("AddScl", n, scaled, 8),
        ("Sum", 1, [sum(map(abs, a))], reduction),
        ("L1", 1, [sum(map(abs, a))], reduction),
        ("Dot", 1, [sum(abs(x*y) for x, y in zip(a,b))], reduction),
        ("Norm", 1, "relative", reduction),
        ("Normalize", n, "relative", reduction),
        ("Normalize.length", 1, "relative", reduction),
    ]
    if n == 3:
        cross = [abs(a[i]*b[j]) + abs(a[j]*b[i]) for i,j in [(1,2),(2,0),(0,1)]]
        result += [
            ("Zero3", 3, None, 0), ("Copy3", 3, None, 0), ("Equal3", 1, None, 0),
            ("Add3", 3, pair, 8), ("Sub3", 3, pair, 8),
            ("Scl3", 3, [abs(x*s) for x in a], 8), ("AddScl3", 3, scaled, 8),
            ("AddTo3", 3, pair, 8), ("SubFrom3", 3, pair, 8),
            ("AddToScl3", 3, scaled, 8), ("Cross3", 3, cross, 8),
            ("Norm3", 1, "relative", 64), ("Dist3", 1, "relative", 64),
            ("Normalize3", 3, "relative", 64), ("Normalize3.length", 1, "relative", 64),
        ]
    if n == 4:
        result += [("Zero4", 4, None, 0), ("Unit4", 4, None, 0), ("Copy4", 4, None, 0),
                   ("Norm4", 1, "relative", 80), ("Normalize4", 4, "relative", 80),
                   ("Normalize4.length", 1, "relative", 80)]
    return result


def compare(rows, actual: str, expected: str) -> int:
    aa = [list(map(float, line.split())) for line in actual.splitlines()]
    cc = [list(map(float, line.split())) for line in expected.splitlines()]
    if len(aa) != len(rows) or len(cc) != len(rows):
        raise ValueError("vector probe returned an incomplete result set")
    total = 0
    for case, (row, ada, ref) in enumerate(zip(rows, aa, cc)):
        columns = layout(row)
        count = sum(n for _, n, _, _ in columns)
        if len(ada) != count or len(ref) != count:
            raise ValueError(f"case {case}: expected {count} vector outputs")
        slices = {}
        offset = 0
        for operation, n, bound, multiplier in columns:
            av, cv = ada[offset:offset+n], ref[offset:offset+n]
            slices[operation] = (av, cv)
            for i, (x, y) in enumerate(zip(av, cv)):
                scale = abs(y) if bound == "relative" else bound[i] if bound is not None else 0
                tolerance = multiplier * sys.float_info.epsilon * scale + (1e-300 if multiplier else 0)
                if not (math.isfinite(x) and math.isfinite(y)) or abs(x-y) > tolerance:
                    raise ValueError(f"case {case}, {operation}[{i}]: Ada={x}, C={y}, tolerance={tolerance}")
            offset += n
        # Branches are observable semantics, not a roundoff allowance.
        for name in ["Normalize", "Normalize3", "Normalize4"]:
            if name not in slices:
                continue
            av, cv = slices[name]
            length = slices[name + ".length"][1][0]
            if length < 1e-15 or (name == "Normalize4" and abs(length-1.0) <= 1e-15):
                if av != cv:
                    raise ValueError(f"case {case}: {name} fallback/near-unit branch differs")
        total += count
    return total


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=["development", "validation", "release"], default="validation")
    parser.add_argument("--alire", action="store_true")
    args = parser.parse_args()
    env = os.environ.copy()
    build = Path(env.get("SPARKLING_BUILD_ROOT", str(ROOT))).resolve()
    env["SPARKLING_BUILD_ROOT"] = str(build)
    prefix = ["alr", "exec", "--"] if args.alire else []
    suffix = ".exe" if os.name == "nt" else ""
    try:
        reference = json.loads((ROOT / "tools/blas-reference.json").read_text())
        for path, digest in reference["sha256_lf"].items():
            content = (ROOT / "mujoco" / path).read_bytes().replace(b"\r\n", b"\n")
            if hashlib.sha256(content).hexdigest() != digest:
                raise ValueError(f"C reference differs from pinned MuJoCo: {path}")
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gprbuild", "-P", "tests/differential.gpr",
                       f"-XSPARKLING_BUILD_MODE={args.mode}", "-f", "-p", "-j2", "-q"]),
                       cwd=ROOT, env=env, check=True)
        ada = RUNNER.checked_executables(build / "bin", ["vector_probe"], started, suffix)[0]
        ref = build / "bin" / ("vector_reference" + suffix)
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gcc", "-std=gnu11", "-O2", "-ffp-contract=off", "-ffunction-sections",
                       "-fdata-sections", "-I", "mujoco/include", "-I", "mujoco/src",
                       "tests/vector_reference.c", "mujoco/src/engine/engine_util_blas.c",
                       "mujoco/src/engine/engine_util_spatial.c", "-Wl,--gc-sections", "-lm", "-o", str(ref)]),
                       cwd=ROOT, env=env, check=True)
        RUNNER.checked_executables(build / "bin", ["vector_reference"], started, suffix)
        rows = cases()
        data = "".join(f"{len(a)} {first} " + " ".join(format(x, ".17g") for x in [*a, *b, s]) + "\n"
                       for first, a, b, s in rows)
        outputs = [subprocess.run([str(p)], input=data, capture_output=True, text=True,
                                 cwd=ROOT, env=env, timeout=60, check=True).stdout for p in [ada, ref]]
        count = compare(rows, *outputs)
        print(f"VECTORS {args.mode}: {len(rows)} cases, {count} scalar comparisons passed "
              "against MuJoCo C (seed 20260923)")
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"VECTOR COMPARISON FAILED: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
