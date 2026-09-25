#!/usr/bin/env python3
"""Compare dense matrix kernels with pinned MuJoCo C, preserving FP order."""
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

def cases():
    rng = random.Random(20260924)
    dims = [(0,0,0), (0,3,2), (3,0,2), (2,3,0), (1,1,1), (3,3,3),
            (2,3,5), (5,2,3), (4,4,4), (7,8,9), (9,7,5), (17,17,3), (3,33,5)]
    rows = []
    def add(shape, sample):
        nr,nc,nk=shape
        arrays = [[sample(i) for i in range(n)] for n in [nr*nc,nc*nk,nk*nc,nr*nk,nc,nr,nr]]
        ind = [nr-1,0,nr-1] if nr else []
        rows.append((nr,nc,nk,*arrays,ind))
    for shape in dims:
        for value in [0.0,-0.0,1.0,-1.0,1e10,-1e10,1e-300,5e-324]:
            add(shape,lambda i,v=value:v)
        add(shape,lambda i: [1e10,1.0,-1e10,1.0][i%4])
        add(shape,lambda i: float(i%7-3))
    for _ in range(240):
        shape=rng.choice(dims+[(rng.randrange(1,18),rng.randrange(1,18),rng.randrange(1,18))])
        add(shape,lambda i: 0.0 if rng.randrange(4)==0 else rng.uniform(-1,1)*10.0**rng.randint(-300,10))
    # Cancellation makes sequential and four-lane reductions observably different.
    nr,nc,nk=1,4,1
    rows.append((nr,nc,nk,[1e10,1,-1e10,1],[1e10,1,1e10,1],
                 [1e10,1,1e10,1],[2],[1e10,1,1e10,1],[3],[1],[0]))
    # Explicit short-row dispatch boundaries, including empty and rectangular
    # outputs. Append after existing cases to preserve the historical corpus.
    for shape in [(7,0,11), (7,1,11), (7,2,11), (7,3,11), (16,3,7), (0,2,5), (7,4,11), (16,4,7)]:
        for value in [0.0,-0.0,1.0,-1.0,1e10,-1e10,1e-300,5e-324]:
            add(shape, lambda i,v=value:v)
        add(shape, lambda i: [1e10,1.0,-1e10,1.0][i%4])
        add(shape, lambda i: float(i%7-3))
    # Transpose dispatch: short-row, pair, vector-core and general-core edges.
    for shape in [(1,0,1), (2,0,1), (3,0,1), (4,0,1), (4,7,1), (5,7,1),
                  (15,7,1), (16,7,1), (17,7,1), (15,16,1), (16,16,1),
                  (17,16,1), (63,16,1), (64,16,1), (1,64,1), (8,64,1),
                  (0,16,1), (16,0,1), (5,0,1), (6,0,1), (6,7,1)]:
        for value in [0.0, -0.0, 1e10, 5e-324]:
            add(shape, lambda i,v=value: v if i % 2 else -v)
    return rows

def transpose_cases():
    # Cross the vector/general boundary and reach the largest timing dimension.
    # Distinct cell values detect permutations that a sum checksum cannot detect.
    # Only this kernel runs: runtime Gram contracts at 128 are unnecessarily
    # expensive for a transpose regression test.
    rows = []
    def add(shape, sample):
        nr,nc,nk=shape
        arrays = [[sample(i) for i in range(n)] for n in [nr*nc,nc*nk,nk*nc,nr*nk,nc,nr,nr]]
        rows.append((nr,nc,nk,*arrays,[]))
    for shape in [(64,64,1), (65,16,1), (65,65,1), (128,128,1),
                  (1,128,1), (8,128,1), (32,32,1), (48,48,1)]:
        for value in [0.0, -0.0, 1e10, 5e-324]:
            add(shape, lambda i,v=value: v if i % 2 else -v)
        add(shape, lambda i: float(i - 8192) / 16.0)
    return rows

def layout(row):
    nr,nc,nk,*_=row
    out=[("MulMatVec",nr),("MulMatTVec",nc),("Transpose",nr*nc),("Eye",nc*nc),
         ("CopyRows",nr*nc),("MulMatMat",nr*nk),("MulMatMatT",nr*nk),
         ("MulMatTMat",nc*nk),("Gram",nc*nc),("Gram.lower",nc*nc),
         ("WeightedGram",nc*nc),("WeightedGram.lower",nc*nc)]
    if nr==nc: out += [("Symmetrize",nr*nc),("MulVecMatVec",1)]
    if nr==nc==nk==3:
        out += [("Copy9",9),("MulMatVec3",3),("MulMatTVec3",3),
                ("MulMatMat3",9),("MulMatTMat3",9),("MulMatMatT3",9)]
    return out

def serialize(rows):
    data=[]
    for nr,nc,nk,a,b,c,e,v,u,d,ind in rows:
        data.append(f"{nr} {nc} {nk} {len(ind)} " +
                    " ".join(format(x,".17g") for x in [*a,*b,*c,*e,*v,*u,*d]) +
                    " " + " ".join(map(str,ind)) + "\n")
    return "".join(data)

def compare(rows, actual, expected, transpose_only=False):
    aa=[list(map(float,line.split())) for line in actual.splitlines()]
    cc=[list(map(float,line.split())) for line in expected.splitlines()]
    if len(aa)!=len(rows) or len(cc)!=len(rows):
        raise ValueError("matrix probe returned an incomplete result set")
    total=0
    for case,(row,ada,ref) in enumerate(zip(rows,aa,cc)):
        cols=[("Transpose",row[0]*row[1])] if transpose_only else layout(row)
        if len(ada)!=sum(n for _,n in cols) or len(ref)!=len(ada):
            raise ValueError(f"case {case}: incorrect matrix output count")
        offset=0
        for name,n in cols:
            for i,(x,y) in enumerate(zip(ada[offset:offset+n],ref[offset:offset+n])):
                if not math.isfinite(x) or not math.isfinite(y) or x!=y:
                    raise ValueError(f"case {case}, {name}[{i}]: Ada={x}, C={y}")
            offset+=n
        total+=offset
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
        ada = RUNNER.checked_executables(build / "bin", ["matrix_probe"], started, suffix)[0]
        ref = build / "bin" / ("matrix_reference" + suffix)
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gcc", "-std=gnu11", "-O2", "-ffp-contract=off", "-ffunction-sections",
                       "-fdata-sections", "-I", "mujoco/include", "-I", "mujoco/src",
                       "tests/matrix_reference.c", "mujoco/src/engine/engine_util_blas.c",
                       "-Wl,--gc-sections", "-lm", "-o", str(ref)]),
                       cwd=ROOT, env=env, check=True)
        RUNNER.checked_executables(build / "bin", ["matrix_reference"], started, suffix)
        rows = cases()
        data = serialize(rows)
        outputs = [subprocess.run([str(p)], input=data, capture_output=True, text=True,
                                 cwd=ROOT, env=env, timeout=60, check=True).stdout for p in [ada, ref]]
        count = compare(rows, *outputs)
        print(f"MATRICES {args.mode}: {len(rows)} cases, {count} scalar comparisons passed "
              "against MuJoCo C (seed 20260924; exact finite numeric equality)")
        rows = transpose_cases()
        data = serialize(rows)
        outputs = [subprocess.run([str(p), "--transpose-only"], input=data,
                                 capture_output=True, text=True, cwd=ROOT, env=env,
                                 timeout=60, check=True).stdout for p in [ada, ref]]
        count = compare(rows, *outputs, transpose_only=True)
        print(f"TRANSPOSE {args.mode}: {len(rows)} large/boundary cases, {count} "
              "exact finite scalar comparisons passed against MuJoCo C")
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"MATRIX COMPARISON FAILED: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
