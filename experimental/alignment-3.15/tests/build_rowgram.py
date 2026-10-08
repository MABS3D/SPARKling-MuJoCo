"""Test row-buffer Hessian assembly on checked immutable 3.15 inputs."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("engine", "out", "python", "reference"):
        parser.add_argument("--" + name, type=Path, required=True)
    args = parser.parse_args()
    engine = args.engine.resolve()
    prior = json.loads((engine / "manifest.json").read_text())
    assert prior["reference"] == "3.15.0"
    assert all(sha(engine / "source" / n) == v for n, v in prior["sources"].items())
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.out / "source"
    shutil.copytree(engine / "source", source)
    folder = Path("experimental/constraint-solvers-candidate")
    for path in [ROOT / folder / "solvers.gpr", *(ROOT / folder / "tests").iterdir()]:
        if path.is_file() and path.suffix in (".gpr", ".ads", ".adb", ".py", ".c"):
            target = source / path.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, target)
    inputs = {str(p.relative_to(source)): sha(p) for p in source.rglob("*") if p.is_file()}
    manifest = dict(reference="3.15.0", sources=inputs,
                    engine_manifest_sha256=sha(engine / "manifest.json"), runner_sha256=sha(Path(__file__)))
    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    env = os.environ.copy()
    tc = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(p) for name in ("gnat", "gprbuild")
                             for p in (tc / name).glob("*/bin")) + ":" + env["PATH"]
    env.update(SOLVERS_BUILD_ROOT=str(args.out / "build"), SOLVERS_MODE="release")
    commands = []
    binaries = {}
    for name, script, extra in (
        ("row_gram_probe", "test_row_gram.py", []),
        ("mass_values_probe", "test_mass_addition.py", []),
        ("factor_values_probe", "test_sparse_cholesky.py", ["--reference-version", "3.15.0"]),
    ):
        binary = args.out / "build/release/bin" / name
        for command, label, cap, timeout in (
            (["gprbuild", "-P", str(source / folder / "solvers.gpr"), name + ".adb", "-j1"],
             "build-" + name, 3000, 600),
            ([str(args.python), str(source / folder / "tests" / script), "--binary", str(binary),
              "--out", str(args.out / name), "--reference", str(args.reference), *extra], name, 2500, 240),
        ):
            guarded = ["python3", str(ROOT / "tools/guarded.py"), "--cap-mb", str(cap),
                       "--timeout", str(timeout), "--", *command]
            start = time.monotonic()
            log = args.out / (label + ".log")
            with log.open("w") as stream:
                run = subprocess.run(guarded, cwd=source, env=env, stdout=stream, stderr=subprocess.STDOUT)
            commands.append(dict(label=label, command=guarded, exit=run.returncode,
                                 seconds=time.monotonic() - start, log_sha256=sha(log)))
            (args.out / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
            print(label, run.returncode, flush=True)
            if run.returncode:
                raise SystemExit(run.returncode)
        binaries[name] = sha(binary)
    assert all(sha(source / n) == v for n, v in inputs.items())
    assert sha(Path(__file__)) == manifest["runner_sha256"]
    receipt = dict(complete=True, reference="3.15.0", source_hashes_unchanged=True,
                   manifest_sha256=sha(args.out / "manifest.json"), runner_sha256=sha(Path(__file__)),
                   commands=commands, binaries=binaries,
                   scope="Row-buffer Gram with stable transpose map, mass load/add on fixed factor support and numeric factor. No whole solver Gold or timing claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")


if __name__ == "__main__":
    main()
