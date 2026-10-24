"""Prepare, generate and verify the coordinated official MuJoCo 3.17 foundation.

Phases are separate so that source preparation never starts a build or proof.
The production reference and historical 3.14/3.15 snapshots are not relabelled.
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
REFERENCE = "3.17.0"
COMMIT = "800a109a4bdd02cb60404d565db4ae16fb04a53b"
SCHEMA = dict(version=3_017_000, nsize=98, nptr=485, mjNEQDATA=12)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_map(source):
    return {str(path.relative_to(source)): digest(path)
            for path in sorted(source.rglob("*"))
            if path.is_file() and "__pycache__" not in path.parts}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def prepare(args):
    assert args.reference_root is not None, "prepare requires --reference-root"
    upstream = args.reference_root.resolve()
    actual = subprocess.check_output(["git", "-C", str(upstream), "rev-parse", "HEAD"], text=True).strip()
    assert actual == COMMIT, (actual, COMMIT)
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.out / "source"
    source.mkdir()
    originals = {}
    for folder in ("src", "tests/support", "tests/gen", "tests/fixtures", "experimental/alignment-3.17"):
        for path in (ROOT / folder).rglob("*"):
            if path.is_file() and "__pycache__" not in path.parts:
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                originals[str(path.relative_to(ROOT))] = digest(path)
    for folder in ("tools", "tests"):
        for path in (ROOT / folder).iterdir():
            if path.is_file() and path.suffix in (".py", ".c", ".txt", ".json", ".adb", ".gpr"):
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                originals[str(path.relative_to(ROOT))] = digest(path)
    project = ROOT / "sparkling_mujoco.gpr"
    shutil.copyfile(project, source / project.name)
    originals[project.name] = digest(project)
    # Old projects can be reproduced without inheriting unchecked release flags.
    # An already corrected project is accepted without pretending these were present.
    candidate = source / project.name
    before = candidate.read_text()
    after = before
    for flag in ("-gnatp", "-ffinite-math-only", "-fno-trapping-math", "-fno-math-errno"):
        after = after.replace(', "' + flag + '"', "").replace('"' + flag + '", ', "")
    candidate.write_text(after)
    transformations = []
    if before != after:
        transformations.append(dict(file=project.name, original_sha256=originals[project.name],
            candidate_sha256=digest(candidate), change="Retain runtime checks and finite-value semantics in release builds"))
    assert all(digest(ROOT / name) == value for name, value in originals.items()), "Live inputs changed while freezing"
    target = source / "mujoco"
    target.mkdir()
    archive = args.out / "upstream.tar"
    with archive.open("wb") as stream:
        subprocess.run(["git", "-C", str(upstream), "archive", COMMIT,
                        "include", "src/engine", "model", "test/testdata"], stdout=stream, check=True)
    subprocess.run(["tar", "-xf", str(archive), "-C", str(target)], check=True)
    archive.unlink()
    manifest = dict(reference=REFERENCE, commit=COMMIT, phase="prepared", original_sources=originals,
        candidate_sources=source_map(source), transformations=transformations, production_applied=False,
        runner_sha256=digest(Path(__file__)), scope="Frozen foundation sources; generation/build/proof not yet executed")
    write_json(args.out / "manifest.json", manifest)
    print(json.dumps(dict(phase="prepared", reference=REFERENCE, files=len(manifest["candidate_sources"]))))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", choices=("prepare", "generate", "verify"), required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--reference-root", type=Path)
    parser.add_argument("--python", type=Path)
    parser.add_argument("--mode", choices=("validation", "release"), default="validation")
    args = parser.parse_args()
    args.out = args.out.resolve()
    assert not args.out.is_relative_to(ROOT), "Build and evidence must be outside the checkout"
    if args.phase == "prepare":
        prepare(args)
        return
    assert args.python is not None, "generate/verify require --python for the actual official wheel"
    # Preserve a venv's interpreter path: resolving its symlink would run the
    # system Python without the pinned official wheel.
    args.python = args.python.absolute()
    source = args.out / "source"
    manifest_path = args.out / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    assert manifest["reference"] == REFERENCE and manifest["commit"] == COMMIT
    assert source_map(source) == manifest["candidate_sources"], "Frozen source closure changed"
    env = os.environ.copy()
    toolchain = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild", "gnatprove")
        for path in (toolchain / name).glob("*/bin")) + ":" + env["PATH"]
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    env["SPARKLING_BUILD_ROOT"] = str(args.out / "build" / args.mode)
    label_prefix = args.phase + "-" + args.mode
    logroot = args.out / label_prefix
    logroot.mkdir(exist_ok=False)
    commands = []

    def run(command, label, timeout=600):
        wrapped = [str(args.python), str(source / "tools/guarded.py"),
                   "--cap-mb", "3000", "--timeout", str(timeout), "--", *map(str, command)]
        log = logroot / (label + ".log")
        start = time.monotonic()
        with log.open("w") as stream:
            result = subprocess.run(wrapped, cwd=source, env=env, stdout=stream, stderr=subprocess.STDOUT)
        commands.append(dict(label=label, command=wrapped, exit=result.returncode,
                             seconds=time.monotonic()-start, log_sha256=digest(log)))
        write_json(logroot / "commands.json", commands)
        print(label, result.returncode, flush=True)
        assert result.returncode == 0, "failed " + label + "; see " + str(log)

    run([args.python, "-c", "import mujoco; assert mujoco.__version__ == '3.17.0' and mujoco.mj_version() == 3017000; print(mujoco.__version__)"], "actual-wheel", 30)
    if args.phase == "generate":
        assert manifest["phase"] == "prepared"
        for name, table in (("xmacro_dump", "fields.txt"), ("layout_dump", "layout.txt")):
            executable = args.out / name
            run(["gcc", "-std=c11", "-Wall", "-Wextra", "-I", source / "mujoco/include",
                 source / "tools" / (name + ".c"), "-o", executable], name + "-build")
            run([executable, source / "tools" / table], name + "-run", 30)
        meta = dict((parts[1], int(parts[2])) for line in (source / "tools/fields.txt").read_text().splitlines()
                    if (parts := line.split()) and parts[0] == "META")
        assert all(meta[key] == value for key, value in SCHEMA.items()), meta
        run([args.python, source / "tools/gen.py"], "generate", 60)
        overlay = source / "experimental/alignment-3.17/overlays/validation.patch"
        assert overlay.is_file(), "The coordinated 3.17 validation overlay is required"
        run(["patch", "--batch", "--fuzz=0", "-p1", "-i", overlay], "validation-overlay", 30)
        manifest["transformations"].append(dict(file=str(overlay.relative_to(source)), sha256=digest(overlay),
            change="3.17 texture/reference/CSR validation semantics; production 3.14 files retained"))
        oracle = source / "tools/oracle.py"
        before = oracle.read_text()
        assert 'mujoco.__version__ == "3.14.0"' in before
        oracle.write_text(before.replace("3.14.0", REFERENCE))
        reference_path = source / "tools/blas-reference.json"
        reference = json.loads(reference_path.read_text())
        reference.update(version=REFERENCE, commit=COMMIT)
        reference["sha256_lf"] = {name: hashlib.sha256((source / "mujoco" / name).read_bytes().replace(b"\r\n", b"\n")).hexdigest()
                                  for name in reference["sha256_lf"]}
        write_json(reference_path, reference)
        run([args.python, oracle, "corpus"], "compile-corpus")
        listing = (source / "tests/corpus_expected.txt").read_text().splitlines()
        assert listing and not any(line.startswith("SKIP ") for line in listing), \
            "Official corpus contains compilation failures; resolve them explicitly before acceptance"
        run([args.python, source / "experimental/alignment-3.17/tests/fixtures.py",
             "--out", args.out / "abi-fixtures"], "compile-abi-fixtures", 60)
        manifest.update(phase="generated", candidate_sources=source_map(source), metadata=meta,
            generated_by_sha256=digest(Path(__file__)), scope="Actual 3.17 ABI regeneration and C-compiled corpus; Ada verification/proofs pending")
        write_json(manifest_path, manifest)
        write_json(logroot / "results.json", dict(complete=True, generated=True, commands=commands,
                   manifest_sha256=digest(manifest_path), source_hashes_unchanged=True,
                   scope=manifest["scope"]))
        return
    assert manifest["phase"] == "generated"
    frozen = manifest["candidate_sources"]
    run(["gprbuild", "-P", "tests/tests.gpr", "-XSPARKLING_BUILD_MODE="+args.mode, "-j1", "-p"], "build-tests")
    binaries = args.out / "build" / args.mode / "bin"
    for name in ("test_types", "test_model_alloc", "test_bytes", "test_parse_raw", "test_corpus_raw",
                 "test_validate", "test_validity", "test_corpus", "test_vectors", "test_matrices"):
        run([binaries / name], name)
    run(["gprbuild", "-P", "experimental/alignment-3.17/tests/foundation_abi.gpr",
         "-XSPARKLING_BUILD_MODE="+args.mode, "-j1", "-p"], "build-abi")
    run([binaries / "reference_probe"], "reference-wide-bounds", 30)
    run([args.python, source / "experimental/alignment-3.17/tests/check_abi.py",
         "--binary", binaries / "abi_probe", "--fixtures", args.out / "abi-fixtures",
         "--out", logroot / "abi"], "abi-compare")
    run([args.python, source / "tools/check_gen.py"], "check-generation")
    run([args.python, "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py"], "python-tests")
    unchanged = source_map(source) == frozen
    result = dict(reference=REFERENCE, commit=COMMIT, mode=args.mode, complete=True,
        passed=unchanged, source_hashes_unchanged=unchanged, manifest_sha256=digest(manifest_path),
        runner_sha256=digest(Path(__file__)), commands=commands,
        scope="Foundation ABI/corpus/negative tests; engine migration, complete Gold and integrated performance remain pending")
    write_json(logroot / "results.json", result)
    assert unchanged, "Frozen sources changed during verification"
    print(json.dumps(dict(complete=True, passed=True, mode=args.mode)))


if __name__ == "__main__":
    main()
