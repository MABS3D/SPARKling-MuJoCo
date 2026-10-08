"""Attribute the cost of a verified FLEX trajectory using a separate gprof build.

Instrumentation timings are diagnostic, never used for C performance acceptance.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import subprocess
import time
import numpy as np
import mujoco

ROOT = Path(__file__).resolve().parents[3]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--engine", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--model", default="element_elastic_cross_elliptic_6")
    parser.add_argument("--batches", type=int, default=200)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--reuse-profile", type=Path,
                        help="Reuse an identical instrumented build after a harness failure")
    args = parser.parse_args()
    assert mujoco.__version__ == "3.15.0" and args.batches > 0
    args.out.mkdir(parents=True, exist_ok=False)
    origin = args.engine.resolve()
    manifest = json.loads((origin / "manifest.json").read_text())
    assert manifest["reference"] == "3.15.0" and manifest["mode"] == "release"
    assert json.loads((origin / "results.json").read_text())["complete"]
    assert all(sha(origin / "source" / name) == value for name, value in manifest["sources"].items())
    source = args.out / "source"
    shutil.copytree(origin / "source", source, ignore=shutil.ignore_patterns("__pycache__"))
    project = source / "experimental/flex-elasticity-integration/flex_constrained.gpr"
    text = project.read_text()
    assert text.count('"-O3", "-gnatn", "-march=native"') == 1
    assert text.count('("-lm")') == 1
    text = text.replace('"-O3", "-gnatn", "-march=native"',
                        '"-O3", "-gnatn", "-march=native", "-pg", "-g"')
    text = text.replace('("-lm")', '("-lm", "-pg")')
    project.write_text(text)
    sources = {name: sha(source / name) for name in manifest["sources"]}
    assert [name for name, value in sources.items() if value != manifest["sources"][name]] == [str(project.relative_to(source))]
    receipt = dict(reference=manifest["reference"], source_manifest_sha256=sha(origin / "manifest.json"),
                   runner_sha256=sha(Path(__file__)), sources=sources, cpu=args.cpu,
                   model=args.model, batches=args.batches, complete=False,
                   scope="Instrumented full-process cost attribution; no timing acceptance or proof claim")
    (args.out / "manifest.json").write_text(json.dumps(receipt, indent=2) + "\n")
    env = os.environ.copy()
    tc = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(p) for name in ("gnat", "gprbuild")
                             for p in (tc / name).glob("*/bin")) + ":" + env["PATH"]
    env.update(FLEX_BUILD_ROOT=str(args.out / "build"), FLEX_MODE="release")
    commands = []

    def run(command, label, limit=600):
        start = time.monotonic()
        with (args.out / (label + ".log")).open("w") as log:
            result = subprocess.run(["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", "3000",
                                     "--timeout", str(limit), "--", *command], env=env,
                                    cwd=source, stdout=log, stderr=subprocess.STDOUT)
        commands.append(dict(command=command, label=label, exit=result.returncode,
                             seconds=time.monotonic()-start, log_sha256=sha(args.out / (label + ".log"))))
        (args.out / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
        print(label, result.returncode, flush=True)
        assert result.returncode == 0

    binary = args.out / "build/release/bin/flex_constrained_probe"
    if args.reuse_profile:
        prior = args.reuse_profile.resolve()
        previous = json.loads((prior / "manifest.json").read_text())
        assert previous["sources"] == sources
        assert all(sha(prior / "source" / name) == value for name, value in sources.items())
        assert any(c["label"] == "build" and c["exit"] == 0
                   for c in json.loads((prior / "commands.json").read_text()))
        binary = prior / "build/release/bin/flex_constrained_probe"
        receipt["reused_build_manifest_sha256"] = sha(prior / "manifest.json")
        receipt["reused_binary_sha256"] = sha(binary)
    else:
        run(["gprbuild", "-P", str(project), "-j1"], "build")
    cases = origin / "constrained"
    model = cases / (args.model + ".mjb")
    header, body = (cases / (args.model + ".input")).read_text().split("\n", 1)
    count, steps = map(int, header.split())
    m = mujoco.MjModel.from_binary_path(str(model))
    stride = 1 + m.nq + 2*m.nv + m.nu + m.na
    values = np.fromstring(body, sep=" ")
    assert count >= 2 and values.size == count*stride
    sample = values[stride:2*stride]
    line = " ".join(format(x, ".17g") for x in sample) + "\n"
    input_path = args.out / "trajectory.input"
    input_path.write_text(f"{args.batches} {steps}\n" + line*args.batches)
    # Match the already validated benchmark's stack envelope. This changes
    # the harness resource limit, not the instrumented engine or trajectory.
    resource.setrlimit(resource.RLIMIT_STACK,
                       (128*1024*1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    os.sched_setaffinity(0, {args.cpu})
    with input_path.open() as stdin, (args.out / "trajectory.output").open("w") as stdout:
        result = subprocess.run([str(binary), str(model), "benchmark"], stdin=stdin, stdout=stdout,
                                stderr=subprocess.STDOUT, cwd=args.out, timeout=240)
    assert result.returncode == 0
    rows = (args.out / "trajectory.output").read_text().splitlines()
    assert len(rows) == 2*args.batches
    expected = np.array(json.loads((cases / (args.model + ".expected.json")).read_text())[1]["state"])
    assert all(np.allclose(np.fromstring(row[6:], sep=" "), expected, rtol=2e-9, atol=2e-9)
               for row in rows[1::2])
    for flags, label in [(["-b"], "gprof"), (["-b", "--no-demangle"], "gprof-symbols")]:
        with (args.out / (label + ".txt")).open("w") as stdout:
            subprocess.run(["gprof", *flags, str(binary), str(args.out / "gmon.out")],
                           stdout=stdout, check=True)
    receipt.update(complete=True, commands=commands, binary_sha256=sha(binary),
                   model_sha256=sha(model), input_sha256=sha(input_path),
                   output_sha256=sha(args.out / "trajectory.output"),
                   gprof_sha256=sha(args.out / "gprof.txt"),
                   source_hashes_unchanged=all(sha(source / name) == value for name, value in sources.items()),
                   trajectory_matches=True)
    assert receipt["source_hashes_unchanged"]
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({k: receipt[k] for k in ("complete", "trajectory_matches", "scope")}))


if __name__ == "__main__":
    main()
