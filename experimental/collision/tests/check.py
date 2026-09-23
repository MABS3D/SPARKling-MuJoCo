#!/usr/bin/env python3
"""Isolated Linux/WSL checks for the first collision primitives (tools on PATH)."""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
GUARD = ROOT / "tools/guarded.py"
SEED = 20260923


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot() -> dict[str, str]:
    paths = [ROOT / "src/mj.ads", ROOT / "src/mj-types.ads", GUARD]
    paths += [HERE / "collision.gpr"]
    paths += [p for directory in (HERE / "src", HERE / "tests") for p in directory.rglob("*") if p.is_file()
              and p.suffix in {".ads", ".adb", ".gpr", ".py", ".c", ".json"}]
    reference = json.loads((HERE / "tests/reference.json").read_text())
    paths += [ROOT / "mujoco" / path for path in reference["sha256_lf"]]
    return {str(p.relative_to(ROOT)): digest(p) for p in sorted(paths)}


def run(command: list[str], build: Path, label: str, *, guarded: bool = True,
        data: str | None = None) -> str:
    if guarded:
        command = [sys.executable, str(GUARD), "--cap-mb", "4000", "--timeout", "180",
                   "--", *command]
    print(label, flush=True)
    result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), text=True,
                            input=data, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=200)
    (build / (label + ".log")).write_text(result.stdout)
    if result.returncode:
        raise RuntimeError(f"{label} failed ({result.returncode}):\n{result.stdout[-8000:]}")
    return result.stdout


def proof(build: Path, sources: dict[str, str]) -> dict:
    common = ["gnatprove", "-P", str(HERE / "collision.gpr"), "-u", "mj-collision.adb",
              "--level=2", "--timeout=5", "-j1", "--checks-as-errors=on",
              "--report=all", "--counterexamples=off"]
    # Diagnose each body separately before the complete-unit evidence run.
    for filename, names in [("mj-collision.ads", ["Is_Unit", "In_Tier0", "Packed_Model", "Capsule_Model"]),
                            ("mj-collision.adb", ["Projected_Distance", "Pack_Contacts", "Plane_Sphere",
                                                  "Endpoint", "Capsule_End", "Plane_Capsule"])]:
        content = (HERE / "src" / filename).read_text()
        for name in names:
            match = re.search(r"^   function " + name + r"\b", content, re.M)
            if match is None:
                raise ValueError(f"missing proof target {name}")
            line = content.count("\n", 0, match.start()) + 1
            run([*common, f"--limit-subp={filename}:{line}"], build, "fragment-" + name)

    report = build / "obj/gnatprove/mj-collision.spark"
    report.unlink(missing_ok=True)
    started = time.time()
    run(common, build, "complete-unit")
    if report.stat().st_mtime < started - 2:
        raise ValueError("stale complete-unit proof report")
    payload = json.loads(report.read_text())
    if (payload["progress"] != "PROGRESS_PROOF"
            or payload["stop_reason"] != "STOP_REASON_NONE"
            or any(payload[s] for s in ("skip_proof", "skip_flow_proof", "pragma_assume"))):
        raise ValueError("incomplete, skipped or assumed proof")
    entities = payload["entities"]
    names = {entities[key]["name"].split(".")[-1].lower()
             for key, mode in payload["spark"].items() if mode == "all"}
    declared = {name.lower() for path in (HERE / "src").glob("*.ad?")
                for name in re.findall(r"^   (?:function|procedure) (\w+)", path.read_text(), re.M)}
    if not declared <= names:
        raise ValueError("missing collision subprogram body")
    if any(mode != "all" for mode in payload["spark"].values()):
        raise ValueError("collision body outside SPARK")
    entries = [entry for section in ("flow", "proof", "warn_error") for entry in payload[section]]
    if any(entry.get("severity") != "info" for entry in entries):
        raise ValueError("unproved check or unreviewed warning in collision report")
    if sources != snapshot():
        raise ValueError("source changed during verification")
    summary = {"scope": "MJ.Collision only", "command": common,
               "checks": len(payload["flow"]) + len(payload["proof"]),
               "unproved": 0, "warnings": 0, "source_sha256": sources,
               "report_sha256": digest(report), "started": started}
    (build / "proof-receipt.json").write_text(json.dumps(summary, indent=2) + "\n")
    return summary


def cases() -> tuple[list[list[float]], dict[int, list[float]]]:
    rows = []
    analytic = {}
    def add(kind, z, radius=1.0, half=1.0, margin=0.0, axis=(0.0, 0.0, 1.0)):
        rows.append([kind, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
                     0.0, 0.0, z, *axis, radius, half, margin])
    def contact(depth, z, tangent=(0.0, 0.0, 0.0)):
        return [depth, 0.0, 0.0, z, 0.0, 0.0, 1.0, *tangent]
    add(0, 2.0)
    analytic[0] = [0] + [0.0] * 20
    add(0, 1.0)
    analytic[1] = [1] + contact(0.0, 0.0) + [0.0] * 10
    add(0, 0.0)
    analytic[2] = [1] + contact(-1.0, -0.5) + [0.0] * 10
    add(1, 1.5)
    analytic[3] = [1] + contact(-0.5, -0.25, (0.0, 0.0, 1.0)) + [0.0] * 10
    add(1, 1.5, axis=(0.0, 0.0, -1.0))
    analytic[4] = [1] + contact(-0.5, -0.25, (0.0, 0.0, -1.0)) + [0.0] * 10
    add(1, 0.0)
    analytic[5] = [2] + contact(0.0, 0.0, (0.0, 0.0, 1.0)) + contact(-2.0, -1.0, (0.0, 0.0, 1.0))
    add(1, 0.0, half=0.0)
    analytic[6] = [2] + contact(-1.0, -0.5, (0.0, 0.0, 1.0)) * 2
    add(1, 4.0)
    analytic[7] = [0] + [0.0] * 20
    add(0, 1.5, margin=0.5)
    analytic[8] = [1] + contact(0.5, 0.25) + [0.0] * 10
    # 1 - 2**-54 is halfway to the predecessor of 1 in binary64 and rounds
    # to 1 (ties to even). The C predicate therefore accepts this contact,
    # although its zero distance is greater than the negative margin.
    add(0, 1.0, margin=-(2.0**-54))
    analytic[9] = [1] + contact(0.0, 0.0) + [0.0] * 10
    # Adjacent floating values on both sides of every axis-aligned threshold.
    for kind in (0, 1):
        for radius in (0.0, 1e-300, 1e-15, 1.0, 1e10):
            for margin in (-1.0, 0.0, 1.0):
                for half in (0.0, 1.0):
                    for endpoint in ((0.0,) if kind == 0 else (-half, half)):
                        threshold = (margin + radius) - endpoint
                        for z in (math.nextafter(threshold, -math.inf), threshold,
                                  math.nextafter(threshold, math.inf)):
                            if abs(z) <= 1e10:
                                add(kind, z, radius, half, margin)
    rng = random.Random(SEED)
    def unit():
        values = [rng.uniform(-1.0, 1.0) for _ in range(3)]
        norm = math.sqrt(sum(x*x for x in values))
        return [x/norm for x in values]
    for i in range(5000):
        scale = 10.0 ** rng.choice([-300, -150, -15, -6, 0, 4, 10])
        plane = [rng.uniform(-1.0, 1.0)*scale for _ in range(3)]
        center = [rng.uniform(-1.0, 1.0)*scale for _ in range(3)]
        rows.append([i % 2, *plane, *unit(), *center, *unit(),
                     rng.random()*scale, rng.random()*scale, rng.uniform(-0.5, 0.5)*scale])
    # The capsule endpoint range reaches +/-2e10 at these input corners.
    for sign in (-1.0, 1.0):
        rows.append([1, *([sign*2e10]*3), 0, 0, sign,
                     *([sign*1e10]*3), 0, 0, sign, 1e10, 1e10, 1e10])
        rows.append([0, *([-sign*2e10]*3), 0, 0, sign,
                     *([sign*2e10]*3), 0, 0, sign, 1e10, 0, -1e10])
    return rows, analytic


def numerical(build: Path) -> dict:
    reference = json.loads((HERE / "tests/reference.json").read_text())
    for path, expected in reference["sha256_lf"].items():
        actual = (ROOT / "mujoco" / path).read_bytes().replace(b"\r\n", b"\n")
        if hashlib.sha256(actual).hexdigest() != expected:
            raise ValueError(f"reference differs from pinned commit: {path}")
    c_sources = [str(HERE / "tests/collision_reference.c"),
                 "mujoco/src/engine/engine_collision_primitive.c",
                 "mujoco/src/engine/engine_util_blas.c"]
    includes = ["-I", "mujoco/include", "-I", "mujoco/src"]
    dependencies = run(["gcc", "-MM", *includes, *c_sources], build, "reference-dependencies")
    deps = {word.removeprefix("mujoco/") for word in dependencies.replace("\\\n", " ").split()
            if word.startswith("mujoco/")}
    if deps != set(reference["sha256_lf"]):
        raise ValueError("reference dependency set changed")
    ref = build / "bin/collision_reference"
    run(["gprbuild", "-P", str(HERE / "tests/tests.gpr"), "-p", "-f", "-j1", "-q"],
        build, "build-debug")
    run(["gcc", "-std=c11", "-O2", "-ffp-contract=off", "-ffunction-sections", "-fdata-sections",
         *includes, *c_sources, "-Wl,--gc-sections", "-lm", "-o", str(ref)], build, "build-reference")
    rows, analytic = cases()
    data = "".join(" ".join(format(x, ".17g") for x in row) + "\n" for row in rows)
    expected = run([str(ref)], build, "reference-results", guarded=False, data=data)
    expected = [list(map(float, line.split())) for line in expected.splitlines()]
    counts = Counter()
    for optimization in ("debug", "optimized"):
        if optimization == "optimized":
            run(["gprbuild", "-P", str(HERE / "tests/tests.gpr"), "-f", "-j1", "-q",
                 "-cargs:Ada", "-O2"], build, "build-optimized")
        actual = run([str(build / "bin/collision_probe")], build, optimization + "-results",
                     guarded=False, data=data)
        actual = [list(map(float, line.split())) for line in actual.splitlines()]
        if len(actual) != len(rows) or len(expected) != len(rows):
            raise ValueError("incomplete probe output")
        for i, (row, aa, cc) in enumerate(zip(rows, actual, expected)):
            if len(aa) != 21 or len(cc) != 21 or aa[0] != cc[0] or aa[0] not in (0, 1, 2):
                raise ValueError(f"contact count or output shape mismatch at {i}: {aa}, {cc}")
            if i in analytic and (aa != analytic[i] or cc != analytic[i]):
                raise ValueError(f"analytic regression {i} failed: {aa}, {cc}")
            counts[f"{optimization}:{int(row[0])}:{int(aa[0])}"] += 1
            # A scale from input operations covers cancellation, including deep
            # penetration. Count/order and the copied direction hints are exact.
            scale = max(abs(x) for x in row[1:4] + row[7:10] + row[13:15])
            for j, (a, c) in enumerate(zip(aa[1:], cc[1:])):
                tolerance = 32 * sys.float_info.epsilon * scale + 32 * math.ulp(0.0)
                if j % 10 >= 4:
                    tolerance = 0.0
                if not (math.isfinite(a) and math.isfinite(c)) or abs(a-c) > tolerance:
                    raise ValueError(f"case {i} column {j}: Ada {a}, C {c}, tolerance {tolerance}; {row}")
            # Unused Ada slots have a stronger, deterministic zero contract.
            if any(aa[1 + int(aa[0])*10:]):
                raise ValueError(f"nonzero unused contact slot at {i}")
        invalid = []
        for normal in ([0.0, 0.0, 0.0], [1.0, 1.0, 0.0]):
            row = list(rows[1])
            row[4:7] = normal
            invalid.append(row)
        row = list(rows[5])
        row[10:13] = [0.0, 0.0, 0.0]
        invalid.append(row)
        row = list(rows[5])
        row[7] = 2e10  # Within Position_3 but outside the capsule center precondition.
        invalid.append(row)
        for i, row in enumerate(invalid):
            probe = subprocess.run([str(build / "bin/collision_probe")],
                                   input=" ".join(format(x, ".17g") for x in row) + "\n",
                                   text=True, capture_output=True, timeout=10)
            (build / f"{optimization}-rejection-{i}.log").write_text(probe.stdout + probe.stderr)
            if probe.returncode == 0 or "ADA.ASSERTIONS.ASSERTION_ERROR" not in probe.stderr:
                raise ValueError(f"invalid input {i} was not rejected by the precondition")
    return {"cases_per_build": len(rows), "scalar_comparisons_per_build": len(rows)*20,
            "analytic_cases": len(analytic), "seed": SEED, "counts": dict(counts),
            "rejected_inputs_per_build": len(invalid),
            "reference_commit": reference["commit"], "reference_files": len(deps)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", choices=("proof", "tests"))
    args = parser.parse_args()
    build = Path(tempfile.mkdtemp(prefix="sparkling-collision-check-"))
    os.environ["COLLISION_BUILD_ROOT"] = str(build)
    sources = snapshot()
    print(f"Evidence: {build}", flush=True)
    result = {"source_sha256": sources, "build": str(build)}
    try:
        result["versions"] = {
            tool: subprocess.check_output([tool, "--version"], text=True, timeout=10).splitlines()[0]
            for tool in ("gnatprove", "gprbuild", "gcc")
        }
        if args.only != "tests":
            result["proof"] = proof(build, sources)
        if args.only != "proof":
            result["tests"] = numerical(build)
        if sources != snapshot():
            raise ValueError("sources changed during checks")
        result["status"] = "PASS"
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        result["status"] = "FAIL"
        result["error"] = str(error)
    (build / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    display = {k: v for k, v in result.items() if k != "source_sha256"}
    if "proof" in display:
        display["proof"] = {k: v for k, v in display["proof"].items() if k != "source_sha256"}
    print(json.dumps(display, indent=2))
    return 0 if result["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
