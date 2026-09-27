#!/usr/bin/env python3
"""Build one Ada version plus C, avoiding dual-package effects on LTO inlining."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

from build import HERE, ROOT, digest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variant", choices=("baseline", "current"), required=True)
    parser.add_argument("--build-root", type=Path, required=True)
    args = parser.parse_args()
    build = args.build_root.resolve()
    generated = build / "generated"
    generated.mkdir(parents=True, exist_ok=True)
    baseline = json.loads((HERE / "baseline/manifest.json").read_text())
    for name, expected in baseline["source_sha256"].items():
        if digest(HERE / "baseline" / name) != expected:
            raise ValueError(f"frozen baseline changed: {name}")
    for name, expected in baseline["shared_dependency_sha256"].items():
        if digest(ROOT / name) != expected:
            raise ValueError(f"shared dependency changed: {name}")
    reference = json.loads((ROOT / "tools/blas-reference.json").read_text())
    for name, expected in reference["sha256_lf"].items():
        data = (ROOT / "mujoco" / name).read_bytes().replace(b"\r\n", b"\n")
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f"C reference differs from pinned MuJoCo: {name}")

    sources = {}
    def read(path):
        sources[str(path.relative_to(ROOT))] = digest(path)
        return path.read_text()

    for name in ["mj.ads", "mj-types.ads", "mj-matrix_types.ads", "mj-matrix_types.adb",
                 "mj-matrix_models.ads", "mj-matrix_models.adb", "mj-vector_models.ads",
                 "mj-vector_models.adb", "mj-blas.ads", "mj-blas.adb",
                 "mj-matrices.ads", "mj-matrices.adb"]:
        path = (HERE / "baseline" if args.variant == "baseline" and
                name.startswith("mj-matrices.") else ROOT / "src") / name
        (generated / name).write_text(read(path))
    for name in ["bench_ada.ads", "bench_ada.adb"]:
        (generated / name).write_text(read(HERE / name))
    main_source = read(HERE / "bench_main.adb").replace("with Bench_Ada_Baseline;\n", "")
    (generated / "bench_main.adb").write_text(main_source)
    c = read(HERE / "bench_c.c")
    replacements = {
        "extern double bench_ada_baseline_run(int,int,int,int,int,int,void*,void*,void*,void*,void*,void*,void*);\n": "",
        "backend>2": "backend>1",
        "if(backend==2)sink=bench_ada_baseline_run(op,n,m,p,8,pattern,a,b,u,v,d,r,ind);else if(backend==1)": "if(backend==1)",
        "backend==2?bench_ada_baseline_run(op,n,m,p,reps,pattern,a,b,u,v,d,r,ind):backend==1?": "backend==1?",
    }
    for before, after in replacements.items():
        if c.count(before) != 1:
            raise ValueError("shared driver changed; review standalone generation")
        c = c.replace(before, after)
    (generated / "bench_c.c").write_text(c)
    for path in [HERE / "standalone.gpr", HERE / "build_standalone.py", HERE / "build.py",
                 HERE / "compare_builds.py", HERE / "baseline/manifest.json",
                 ROOT / "tools/blas-reference.json",
                 *(ROOT / "mujoco" / n for n in reference["sha256_lf"])]:
        sources[str(path.relative_to(ROOT))] = digest(path)
    generated_hashes = {p.name: digest(p) for p in generated.glob("*") if p.is_file()}
    command = ["gprbuild", "-f", "-p", "-P", str(HERE / "standalone.gpr"), "-j2", "-q"]
    env = {**os.environ, "MATRIX_BENCH_ROOT": str(build)}
    subprocess.run([sys.executable, str(ROOT / "tools/guarded.py"), "--cap-mb", "4000",
                    "--timeout", "300", "--", *command], env=env, cwd=ROOT, check=True)
    for name, expected in sources.items():
        if digest(ROOT / name) != expected:
            raise RuntimeError(f"source changed during build: {name}")
    for name, expected in generated_hashes.items():
        if digest(generated / name) != expected:
            raise RuntimeError(f"generated source changed during build: {name}")
    binary = build / "bin/bench_main"
    report = dict(complete=True, variant=args.variant, command=command,
                  binary=str(binary), binary_sha256=digest(binary),
                  source_sha256=sources, generated_sha256=generated_hashes,
                  baseline=baseline, reference=reference,
                  gcc=subprocess.check_output(["gcc", "--version"], text=True),
                  gprbuild=subprocess.check_output(["gprbuild", "--version"], text=True),
                  scope="one Ada implementation plus C; per-operation warm-buffer wrappers")
    (build / "metadata.json").write_text(json.dumps(report, indent=2) + "\n")
    print(binary)


if __name__ == "__main__":
    main()
