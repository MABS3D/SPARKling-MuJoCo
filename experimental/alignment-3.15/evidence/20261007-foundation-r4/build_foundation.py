"""Freeze and verify the foundation against the official MuJoCo 3.15 ABI.

The production 3.14 reference stays intact until the engine consumers migrate.
The candidate includes regenerated readers, allocation, validation and serializer,
and a corpus compiled by the actual 3.15 wheel, rather than relabelled old MJBs.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
REFERENCE = "9ea3cdfcae93bf2cc4dc0e1a1627c5a39a1e06e5"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--python", type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.out / "source"
    source.mkdir()
    original = {}
    for folder in ("src", "tests/support", "tests/gen", "tests/fixtures"):
        for path in (ROOT / folder).rglob("*"):
            if path.is_file():
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                original[str(path.relative_to(ROOT))] = digest(path)
    for folder in ("tools", "tests"):
        for path in (ROOT / folder).iterdir():
            if path.is_file() and path.suffix in (".py", ".c", ".txt", ".json", ".adb", ".gpr"):
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                original[str(path.relative_to(ROOT))] = digest(path)
    shutil.copyfile(ROOT / "sparkling_mujoco.gpr", source / "sparkling_mujoco.gpr")
    original["sparkling_mujoco.gpr"] = digest(ROOT / "sparkling_mujoco.gpr")
    assert all(digest(ROOT / name) == value for name, value in original.items())

    upstream = source / "mujoco"
    upstream.mkdir()
    actual = subprocess.check_output(["git", "-C", str(ROOT / "mujoco"),
                                     "rev-parse", "3.15.0^{commit}"], text=True).strip()
    assert actual == REFERENCE
    archive = args.out / "upstream.tar"
    with archive.open("wb") as stream:
        subprocess.run(["git", "-C", str(ROOT / "mujoco"), "archive", REFERENCE,
                        "include", "src/engine", "model", "test/testdata"],
                       stdout=stream, check=True)
    subprocess.run(["tar", "-xf", str(archive), "-C", str(upstream)], check=True)
    archive.unlink()

    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild", "gnatprove")
                             for path in (toolchain / name).glob("*/bin")) + ":" + env["PATH"]
    env["SPARKLING_BUILD_ROOT"] = str(args.out / "build")
    commands = []

    def run(command, label, guarded=False):
        if guarded:
            command = [str(args.python), str(source / "tools/guarded.py"),
                       "--cap-mb", "4000", "--timeout", "600", "--", *command]
        start = time.monotonic()
        log = args.out / (label + ".log")
        with log.open("w") as stream:
            result = subprocess.run(command, cwd=source, env=env,
                                    stdout=stream, stderr=subprocess.STDOUT)
        commands.append(dict(label=label, command=command, exit=result.returncode,
                             seconds=time.monotonic() - start, log_sha256=digest(log)))
        (args.out / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
        print(label, result.returncode, flush=True)
        if result.returncode:
            raise RuntimeError("failed " + label + "; see " + str(log))

    for name, table in (("xmacro_dump", "fields.txt"), ("layout_dump", "layout.txt")):
        executable = args.out / name
        run(["gcc", "-std=c11", "-Wall", "-Wextra", "-I", str(upstream / "include"),
             str(source / "tools" / (name + ".c")), "-o", str(executable)], name + "-build", True)
        run([str(executable), str(source / "tools" / table)], name + "-run")
    run([str(args.python), str(source / "tools/gen.py")], "generate")
    oracle = source / "tools/oracle.py"
    oracle.write_text(oracle.read_text().replace("3.14.0", "3.15.0"))
    blas = source / "tools/blas-reference.json"
    reference = json.loads(blas.read_text())
    reference.update(version="3.15.0", commit=REFERENCE)
    reference["sha256_lf"] = {name: hashlib.sha256((upstream / name).read_bytes()
                                                   .replace(b"\r\n", b"\n")).hexdigest()
                               for name in reference["sha256_lf"]}
    blas.write_text(json.dumps(reference, indent=2) + "\n")
    run([str(args.python), str(oracle), "corpus"], "compile-corpus", True)
    inputs = {str(path.relative_to(source)): digest(path) for path in source.rglob("*")
              if path.is_file() and "__pycache__" not in path.parts}
    manifest = dict(reference="3.15.0", commit=REFERENCE, original_sources=original,
                    candidate_sources=inputs, mode="validation", production_applied=False,
                    runner_sha256=digest(Path(__file__)))
    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    run(["gprbuild", "-P", "tests/tests.gpr", "-XSPARKLING_BUILD_MODE=validation", "-j1", "-p"],
        "build-validation", True)
    tests = ["test_types", "test_model_alloc", "test_bytes", "test_parse_raw", "test_corpus_raw",
             "test_validate", "test_validity", "test_corpus", "test_vectors", "test_matrices"]
    for name in tests:
        run([str(args.out / "build/bin" / name)], name, True)
    run([str(args.python), str(source / "tools/check_gen.py")], "check-generation", True)
    run([str(args.python), "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py"],
        "python-tests", True)
    changed = [name for name, value in inputs.items() if digest(source / name) != value]
    assert not changed, changed
    receipt = dict(reference="3.15.0", commit=REFERENCE, ada_tests=len(tests),
                   commands=commands, source_hashes_unchanged=True, complete=True,
                   scope="Foundation validation and regenerated ABI; no engine, global Gold or timing claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({key: receipt[key] for key in ("reference", "ada_tests", "complete", "scope")}))


if __name__ == "__main__":
    main()
