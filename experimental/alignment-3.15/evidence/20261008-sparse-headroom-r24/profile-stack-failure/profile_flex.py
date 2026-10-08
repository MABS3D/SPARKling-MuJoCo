"""Profile a frozen FLEX release; instrumented times are not acceptance timings."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

import mujoco
import numpy as np

ROOT = Path(__file__).resolve().parents[3]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--engine", type=Path, required=True)
    parser.add_argument("--cases", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--model", default="element_elastic_cross_elliptic_6")
    parser.add_argument("--batches", type=int, default=1000)
    parser.add_argument("--cpu", type=int, default=0)
    args = parser.parse_args()
    assert args.batches > 0 and args.cpu in os.sched_getaffinity(0)
    engine = args.engine.resolve()
    source = engine / "source"
    manifest_path = engine / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    assert manifest["reference"] == mujoco.__version__ == "3.15.0"
    assert manifest["mode"] == "release"
    assert json.loads((engine / "results.json").read_text())["complete"]

    def matches():
        return all(digest(source / name) == value
                   for name, value in manifest["sources"].items())

    assert matches()
    args.out.mkdir(parents=True, exist_ok=False)
    out = args.out.resolve()
    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild")
                             for path in (toolchain / name).glob("*/bin")) + ":" + env["PATH"]
    env.update(FLEX_BUILD_ROOT=str(out / "build"), FLEX_MODE="release")
    project = source / "experimental/flex-elasticity-integration/flex_constrained.gpr"
    command = ["gprbuild", "-P", str(project), "-j1", "-cargs:Ada", "-pg", "-g", "-largs", "-pg"]
    receipt = dict(reference=mujoco.__version__, manifest_sha256=digest(manifest_path),
                   runner_sha256=digest(Path(__file__)), guard_sha256=digest(ROOT / "tools/guarded.py"),
                   project_flags=project.read_text(), command=command, cpu=args.cpu,
                   model=args.model, batches=args.batches, complete=False,
                   scope="Instrumented full-process cost attribution; no release timing or proof claim")

    def save():
        (out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")

    save()
    start = time.monotonic()
    with (out / "build.log").open("w") as target:
        run = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "3000",
                              "--timeout", "600", "--", *command], cwd=source, env=env,
                             stdout=target, stderr=subprocess.STDOUT)
    receipt.update(build_exit=run.returncode, build_seconds=time.monotonic() - start,
                   build_log_sha256=digest(out / "build.log"))
    save()
    assert run.returncode == 0
    binary = out / "build/release/bin/flex_constrained_probe"
    model_path = out / (args.model + ".mjb")
    shutil.copyfile(args.cases / model_path.name, model_path)
    original = args.cases / (args.model + ".input")
    header, body = original.read_text().split("\n", 1)
    count, steps = map(int, header.split())
    m = mujoco.MjModel.from_binary_path(str(model_path))
    stride = 1 + m.nq + 2*m.nv + m.nu + m.na
    values = np.fromstring(body, sep=" ")
    assert count > 0 and steps > 0 and values.size == count*stride
    sample = values[:stride]
    assert sample[0] == 0
    line = " ".join(format(value, ".17g") for value in sample) + "\n"
    input_path = out / "trajectory.input"
    input_path.write_text(f"{args.batches} {steps}\n" + line*args.batches)
    os.sched_setaffinity(0, {args.cpu})
    receipt["run_command"] = [str(binary), str(model_path), "benchmark"]
    save()
    with input_path.open() as stream, (out / "trajectory.output").open("w") as target:
        subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "3000",
                        "--timeout", "240", "--", *receipt["run_command"]],
                       cwd=out, env=env, stdin=stream, stdout=target, stderr=subprocess.STDOUT, check=True)
    lines = (out / "trajectory.output").read_text().splitlines()
    assert len(lines) == 2*args.batches and all(x.startswith("seconds ") for x in lines[::2])
    actual = np.array([np.fromstring(x.removeprefix("state "), sep=" ") for x in lines[1::2]])
    d = mujoco.MjData(m)
    first = 1
    for array in (d.qpos, d.qvel, d.qfrc_applied, d.ctrl, d.act):
        array[:] = sample[first:first + len(array)]
        first += len(array)
    assert first == stride
    mujoco.mj_step(m, d, nstep=steps)
    expected = np.r_[d.qpos, d.qvel, d.time, d.act]
    assert actual.shape == (args.batches, expected.size)
    receipt["trajectory_max_abs"] = float(np.max(abs(actual - expected)))
    receipt["trajectory_matches"] = bool(np.allclose(actual, expected, atol=2e-9, rtol=2e-9))
    with (out / "gprof.txt").open("w") as target:
        subprocess.run(["gprof", str(binary), str(out / "gmon.out")], stdout=target, check=True)
    receipt.update(binary_sha256=digest(binary), model_sha256=digest(model_path),
                   original_input_sha256=digest(original), input_sha256=digest(input_path),
                   output_sha256=digest(out / "trajectory.output"), gmon_sha256=digest(out / "gmon.out"),
                   gprof_sha256=digest(out / "gprof.txt"), source_hashes_unchanged=matches(),
                   runner_source_unchanged=digest(Path(__file__)) == receipt["runner_sha256"],
                   guard_source_unchanged=digest(ROOT / "tools/guarded.py") == receipt["guard_sha256"])
    receipt["complete"] = all(receipt[key] for key in (
        "trajectory_matches", "source_hashes_unchanged", "runner_source_unchanged", "guard_source_unchanged"))
    save()
    print(json.dumps({key: receipt[key] for key in ("complete", "trajectory_max_abs", "batches")}))
    assert receipt["complete"]


if __name__ == "__main__":
    main()
