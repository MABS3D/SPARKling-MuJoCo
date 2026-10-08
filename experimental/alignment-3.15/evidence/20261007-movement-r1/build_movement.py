"""Freeze the integrated engine with the verified MuJoCo 3.15 foundation.

This tests actual 3.15-compiled models and C trajectories. It does not publish
the candidate, establish formal caller proofs, or claim performance parity.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--foundation", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--python", type=Path, required=True)
    parser.add_argument("--mode", choices=("validation", "release"), default="validation")
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    foundation = args.foundation.resolve()
    manifest_path = foundation / "manifest.json"
    foundation_manifest = json.loads(manifest_path.read_text())
    assert foundation_manifest["reference"] == "3.15.0"
    assert json.loads((foundation / "results.json").read_text())["complete"]
    for name, value in foundation_manifest["candidate_sources"].items():
        assert digest(foundation / "source" / name) == value, name
    module_path = ROOT / "experimental/constrained-step/tests/build.py"
    spec = importlib.util.spec_from_file_location("constrained_builder", module_path)
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    source = args.out / "source"
    source.mkdir()
    # The foundation comes from the exact validated generated ABI, including
    # the existing source contracts. Engine inputs are frozen from the worktree.
    shutil.copytree(foundation / "source/src", source / "src")
    original = {}
    for folder in builder.FOLDERS:
        if folder in ("src", "src/gen"):
            continue
        for path in (ROOT / folder).iterdir():
            if path.is_file() and path.suffix in (".ads", ".adb", ".py", ".c"):
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                original[str(path.relative_to(ROOT))] = digest(path)
    project_name = "experimental/constrained-step/constrained.gpr"
    project = source / project_name
    shutil.copyfile(ROOT / project_name, project)
    original[project_name] = digest(ROOT / project_name)
    assert all(digest(ROOT / name) == value for name, value in original.items())
    transformations = []
    for name in ("compare.py", "compare_forces.py", "compare_assets.py", "compare_elliptic.py"):
        path = source / "experimental/constrained-step/tests" / name
        before = path.read_text()
        assert before.count("3.14.0") == 1, name
        path.write_text(before.replace("3.14.0", "3.15.0"))
        transformations.append(dict(file=str(path.relative_to(source)),
                                    change="Require actual reference wheel 3.15.0"))
    inputs = {str(path.relative_to(source)): digest(path)
              for path in source.rglob("*") if path.is_file()}
    manifest = dict(reference="3.15.0", commit=foundation_manifest["commit"],
                    foundation_manifest_sha256=digest(manifest_path),
                    original_engine_sources=original, sources=inputs,
                    transformations=transformations, mode=args.mode,
                    runner_sha256=digest(Path(__file__)), production_applied=False)
    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    env = builder.environment()
    env.update(CONSTRAINED_BUILD_ROOT=str(args.out / "build"), CONSTRAINED_MODE=args.mode)
    commands = []

    def run(command, label):
        guarded = [str(args.python), str(ROOT / "tools/guarded.py"),
                   "--cap-mb", "3000", "--timeout", "600", "--", *command]
        start = time.monotonic()
        log = args.out / (label + ".log")
        with log.open("w") as stream:
            result = subprocess.run(guarded, cwd=source, env=env,
                                    stdout=stream, stderr=subprocess.STDOUT)
        commands.append(dict(label=label, command=guarded, exit=result.returncode,
                             seconds=time.monotonic() - start, log_sha256=digest(log)))
        (args.out / "commands.json").write_text(json.dumps(commands, indent=2) + "\n")
        print(label, result.returncode, flush=True)
        if result.returncode:
            raise RuntimeError("failed " + label + "; see " + str(log))

    run(["gprbuild", "-P", str(project), "-j1"], "build")
    binary_dir = args.out / "build" / args.mode / "bin"
    tests = source / "experimental/constrained-step/tests"
    binary = binary_dir / "constrained_probe"
    run([str(args.python), str(tests / "compare.py"), "--binary", str(binary),
         "--out", str(args.out / "comparison"), "--samples", "2", "--steps", "100", "--loads"],
        "comparison")
    run([str(args.python), str(tests / "activation_edges.py"), "--binary",
         str(binary_dir / "constrained_activation_edges"), "--capacity-binary",
         str(binary_dir / "constrained_edges"), "--out", str(args.out / "activation")],
        "activation")
    run([str(args.python), str(tests / "compare_forces.py"), "--binary", str(binary),
         "--out", str(args.out / "forces"), "--samples", "1", "--steps", "100"], "forces")
    changed = [name for name, value in inputs.items() if digest(source / name) != value]
    assert not changed, changed
    receipt = dict(reference="3.15.0", commit=foundation_manifest["commit"], commands=commands,
                   manifest_sha256=digest(args.out / "manifest.json"), source_hashes_unchanged=True,
                   binaries={path.name: digest(path) for path in binary_dir.iterdir() if path.is_file()},
                   complete=True, scope="Integrated supported movement trajectories only; no global Gold or timing claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({key: receipt[key] for key in ("reference", "complete", "scope")}))


if __name__ == "__main__":
    main()
