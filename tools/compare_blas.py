#!/usr/bin/env python3
"""Compare bounded 3D SPARK kernels with the pinned, compiled MuJoCo C source."""
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


def cases() -> list[list[float]]:
    values = [0.0, -0.0, 1.0, -1.0, 1e10, -1e10, 1e-15, -1e-15, 1e-300, -1e-300]
    rows = [[x, -x, x, -x, x, x, s] for x in values for s in values]
    rows += [[1e10, 1.0, 1e10, 1e10, 1.0, -1e10, 1.0],
             [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0]]
    rng = random.Random(20260922)
    for _ in range(2000):
        rows.append([rng.uniform(-1.0, 1.0) * 10.0 ** rng.randint(-150, 10)
                     for _ in range(7)])
    return rows


def compare(rows: list[list[float]], actual: str, expected: str) -> int:
    ada = [list(map(float, line.split())) for line in actual.splitlines()]
    ref = [list(map(float, line.split())) for line in expected.splitlines()]
    if len(ada) != len(rows) or len(ref) != len(rows):
        raise ValueError("probe returned an incomplete result set")
    for index, (inputs, aa, cc) in enumerate(zip(rows, ada, ref)):
        if len(aa) != 10 or len(cc) != 10:
            raise ValueError(f"case {index}: expected ten outputs")
        a, b, scale = inputs[:3], inputs[3:6], inputs[6]
        bounds = [abs(x) + abs(y) for x, y in zip(a, b)] * 2
        bounds += [abs(x * scale) for x in a]
        bounds += [sum(abs(x * y) for x, y in zip(a, b))]
        for column, (x, y, bound) in enumerate(zip(aa, cc, bounds)):
            # An operation-scale bound also covers cancellation and FMA rounding.
            tolerance = 8 * sys.float_info.epsilon * bound + 1e-300
            if not (math.isfinite(x) and math.isfinite(y)) or abs(x - y) > tolerance:
                raise ValueError(f"case {index}, output {column}: Ada={x}, C={y}, "
                                 f"tolerance={tolerance}; input={inputs}")
    return len(rows) * 10


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
        for path, expected in reference["sha256_lf"].items():
            content = (ROOT / "mujoco" / path).read_bytes().replace(b"\r\n", b"\n")
            if hashlib.sha256(content).hexdigest() != expected:
                raise ValueError(f"C reference differs from pinned MuJoCo: {path}")
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gprbuild", "-P", "tests/differential.gpr",
                       f"-XSPARKLING_BUILD_MODE={args.mode}", "-f", "-p", "-j2", "-q"]),
                       cwd=ROOT, env=env, check=True)
        ada = RUNNER.checked_executables(build / "bin", ["blas_probe"], started, suffix)[0]
        ref = build / "bin" / ("blas_reference" + suffix)
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gcc", "-std=c11", "-O2", "-ffunction-sections",
                       "-fdata-sections", "-I", "mujoco/include", "-I", "mujoco/src",
                       "tests/blas_reference.c", "mujoco/src/engine/engine_util_blas.c",
                       "-Wl,--gc-sections", "-lm", "-o", str(ref)]), cwd=ROOT, env=env, check=True)
        RUNNER.checked_executables(build / "bin", ["blas_reference"], started, suffix)
        rows = cases()
        text = "".join(" ".join(format(x, ".17g") for x in row) + "\n" for row in rows)
        outputs = [subprocess.run([str(p)], input=text, capture_output=True, text=True,
                                 cwd=ROOT, env=env, timeout=30, check=True).stdout for p in [ada, ref]]
        count = compare(rows, *outputs)
        print(f"BLAS {args.mode}: {len(rows)} cases, {count} scalar comparisons passed "
              "against MuJoCo C (seed 20260922)")
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"BLAS COMPARISON FAILED: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
