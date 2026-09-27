#!/usr/bin/env python3
"""Build current Ada, frozen baseline Ada and upstream C in one timing binary."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-root", type=Path, default=HERE / "build")
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
            raise ValueError(f"shared dependency changed; refresh the comparison baseline: {name}")

    # Renaming keeps the old implementation independent of the current one.
    # Both use the same unchanged scalar, storage and ghost-model dependencies.
    for extension in ("ads", "adb"):
        source = (HERE / "baseline" / f"mj-matrices.{extension}").read_text()
        (generated / f"mj-matrices_baseline.{extension}").write_text(
            source.replace("MJ.Matrices", "MJ.Matrices_Baseline"))
        wrapper = (HERE / f"bench_ada.{extension}").read_text()
        wrapper = wrapper.replace("Bench_Ada", "Bench_Ada_Baseline")
        wrapper = wrapper.replace("bench_ada_run", "bench_ada_baseline_run")
        wrapper = wrapper.replace("MJ.Matrices", "MJ.Matrices_Baseline")
        (generated / f"bench_ada_baseline.{extension}").write_text(wrapper)

    reference = json.loads((ROOT / "tools/blas-reference.json").read_text())
    for name, expected in reference["sha256_lf"].items():
        data = (ROOT / "mujoco" / name).read_bytes().replace(b"\r\n", b"\n")
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f"C reference differs from pinned MuJoCo: {name}")

    files = [*HERE.glob("*.ad?"), HERE / "bench_c.c", HERE / "benchmark.gpr",
             HERE / "build.py", HERE / "compare_builds.py",
             *HERE.glob("*-cases.json"), *HERE.glob("baseline/*"),
             *ROOT.glob("src/mj*.ad?"), ROOT / "tools/blas-reference.json"]
    files.extend(ROOT / "mujoco" / name for name in reference["sha256_lf"])
    sources = {str(path.relative_to(ROOT)): digest(path) for path in files}
    generated_hashes = {path.name: digest(path) for path in generated.glob("*.ad?")}
    env = os.environ.copy()
    env["MATRIX_BENCH_ROOT"] = str(build)
    command = ["gprbuild", "-f", "-p", "-P", str(HERE / "benchmark.gpr"), "-j2", "-q"]
    subprocess.run([sys.executable, str(ROOT / "tools/guarded.py"),
                    "--cap-mb", "4000", "--timeout", "300", "--", *command],
                   env=env, cwd=ROOT, check=True)
    for name, expected in sources.items():
        if digest(ROOT / name) != expected:
            raise RuntimeError(f"source changed during build: {name}")
    for name, expected in generated_hashes.items():
        if digest(generated / name) != expected:
            raise RuntimeError(f"generated source changed during build: {name}")
    binary = build / "bin/bench_main"
    report = {
        "complete": True, "command": command, "build_root": str(build),
        "binary": str(binary), "binary_sha256": digest(binary),
        "source_sha256": sources, "generated_sha256": generated_hashes,
        "baseline": baseline, "reference": reference,
        "backends": {"0": "upstream C", "1": "current Ada", "2": "baseline Ada"},
        "gcc": subprocess.check_output(["gcc", "--version"], text=True),
        "gprbuild": subprocess.check_output(["gprbuild", "--version"], text=True),
        "scope": "per-operation timing wrappers; not an end-to-end engine workload",
    }
    (build / "metadata.json").write_text(json.dumps(report, indent=2) + "\n")
    print(binary)


if __name__ == "__main__":
    main()
