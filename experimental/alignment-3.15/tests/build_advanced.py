"""Freeze the owned advanced actuator adapter against the actual 3.15 ABI.

The 3.15-only overlay corrects world site quaternion composition. Production
3.14 files are unchanged. The regression option freezes their original ABI and
behavior. The optional scalar-site overlay adds owned point geometry and
transmission to the shared smooth/constrained controller. Proof completion and
performance are separate acceptance gates.
"""
import argparse
import hashlib
import importlib.util
import json
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
    parser.add_argument("--freeze-only", action="store_true")
    parser.add_argument("--production-regression", action="store_true")
    parser.add_argument("--scalar-site", action="store_true",
                        help="Apply the 3.15 owned scalar-site integration candidate")
    parser.add_argument("--constrained", action="store_true",
                        help="Exercise the shared controller through the owned constrained adapter")
    parser.add_argument("--only")
    parser.add_argument("--samples", type=int, default=2)
    parser.add_argument("--steps", type=int, default=100)
    args = parser.parse_args()
    if args.production_regression and args.scalar_site:
        parser.error("--scalar-site is a 3.15 candidate; production regression retains its original behavior")
    if args.only is None:
        args.only = "scalar_site_" if args.scalar_site else "so3_"
    assert args.samples > 0 and args.steps > 0
    args.out = args.out.resolve()
    args.out.mkdir(parents=True, exist_ok=False)
    foundation = args.foundation.resolve()
    prior = json.loads((foundation / "manifest.json").read_text())
    reference = "3.14.0" if args.production_regression else "3.15.0"
    assert prior["reference"] == reference
    assert json.loads((foundation / "results.json").read_text())["complete"]
    for name, expected in prior["candidate_sources"].items():
        assert digest(foundation / "source" / name) == expected, name
    builder_path = ROOT / "experimental/advanced-step/tests/build.py"
    spec = importlib.util.spec_from_file_location("advanced_builder", builder_path)
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    source = args.out / "source"
    shutil.copytree(foundation / "source/src", source / "src")
    original = {}
    folders = list(builder.FOLDERS)
    if args.constrained:
        folders += ["experimental/" + name + "/src" for name in (
            "constrained-step", "rigid-collision-candidate", "constraint-assembly-candidate",
            "constraint-solvers-candidate", "joint-limit-candidate", "frictionless-contact-candidate")]
        folders.append("experimental/constrained-step/tests")
    for folder in folders:
        if folder in ("src", "src/gen"):
            continue
        for path in (ROOT / folder).iterdir():
            if path.is_file() and path.suffix in (".ads", ".adb", ".py", ".c"):
                name = str(path.relative_to(ROOT))
                target = source / name
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                original[name] = digest(path)
    project_name = "experimental/advanced-step/" + (
        "constrained_advanced.gpr" if args.constrained else "advanced.gpr")
    shutil.copyfile(ROOT / project_name, source / project_name)
    original[project_name] = digest(ROOT / project_name)
    if args.scalar_site:
        proof_project = "experimental/advanced-step/site_kinematics_proof.gpr"
        shutil.copyfile(ROOT / proof_project, source / proof_project)
        original[proof_project] = digest(ROOT / proof_project)
    assert all(digest(ROOT / name) == value for name, value in original.items())
    transformations = []
    tests = source / "experimental/advanced-step/tests"
    if not args.production_regression:
        overlay = ROOT / "experimental/alignment-3.15/overlays/site-world-quaternion.patch"
        subprocess.run(["git", "apply", "--check", str(overlay)], cwd=source, check=True)
        subprocess.run(["git", "apply", str(overlay)], cwd=source, check=True)
        original[str(overlay.relative_to(ROOT))] = digest(overlay)
        transformations.append(dict(file=str(overlay.relative_to(ROOT)),
            sha256=digest(overlay), change="Both world site quaternions use body*local, as C 3.15"))
        if args.scalar_site:
            scalar_overlay = ROOT / "experimental/alignment-3.15/overlays/scalar-site-transmission.patch"
            subprocess.run(["git", "apply", "--check", str(scalar_overlay)], cwd=source, check=True)
            subprocess.run(["git", "apply", str(scalar_overlay)], cwd=source, check=True)
            original[str(scalar_overlay.relative_to(ROOT))] = digest(scalar_overlay)
            transformations.append(dict(file=str(scalar_overlay.relative_to(ROOT)),
                sha256=digest(scalar_overlay), change="Owned scalar site/refsite poses, point Jacobians, transmission and servo wrapping"))
        additions = Path(__file__).with_name("advanced_fixtures.py")
        shutil.copyfile(additions, tests / additions.name)
        original[str(additions.relative_to(ROOT))] = digest(additions)
        compare = tests / "compare.py"
        text = compare.read_text()
        assert text.count("3.14.0") == 2
        text = text.replace("3.14.0", "3.15.0")
        assert text.count("def fixtures():") == 1
        text = text.replace("def fixtures():", "def legacy_fixtures():")
        wrapper = ("from advanced_fixtures import additional_fixtures, verify_distinguishing_cases\n\n"
                   "def fixtures():\n    yield from legacy_fixtures()\n"
                   "    yield from additional_fixtures(model)\n\n")
        if args.scalar_site:
            scalar_fixtures = Path(__file__).with_name("scalar_site_fixtures.py")
            shutil.copyfile(scalar_fixtures, tests / scalar_fixtures.name)
            original[str(scalar_fixtures.relative_to(ROOT))] = digest(scalar_fixtures)
            wrapper = ("from scalar_site_fixtures import additional_scalar_fixtures, set_scalar_inputs, audit_native_scalar_geometry\n"
                       + wrapper.replace("    yield from additional_fixtures(model)\n",
                                         "    yield from additional_fixtures(model)\n"
                                         "    yield from additional_scalar_fixtures(model)\n"))
            input_anchor = "            d.qfrc_applied[:]=rng.uniform(-.002,.002,m.nv);d.xfrc_applied[:]=rng.uniform(-.001,.001,(m.nbody,6));d.time=.125"
            assert text.count(input_anchor) == 1
            text = text.replace(input_anchor, "            set_scalar_inputs(name, m, d)\n" + input_anchor)
        assert text.count("def main():") == 1
        text = text.replace("def main():", wrapper + "def main():")
        needle = "    rng=np.random.default_rng(261002);records=[];failures=[];models=0"
        assert text.count(needle) == 1
        text = text.replace(needle, "    verify_distinguishing_cases(model, args.out/'quaternion-order.json')\n" + needle)
        if args.scalar_site:
            text = text.replace(needle, "    audit_native_scalar_geometry(model, args.out/'scalar-geometry.json')\n" + needle)
        compare.write_text(text)
        transformations.append(dict(file=str(compare.relative_to(source)),
            change="Actual 3.15 oracle, six quaternion-order cases, and optional scalar-site fixtures; preserve legacy RNG order"))
    inputs = {str(path.relative_to(source)): digest(path)
              for path in source.rglob("*") if path.is_file()}
    runner_hash = digest(Path(__file__))
    manifest = dict(reference=reference, commit=prior["commit"], sources=inputs,
        original_sources=original, transformations=transformations,
        foundation_manifest_sha256=digest(foundation / "manifest.json"),
        runner_sha256=runner_hash, mode=args.mode, scalar_site=args.scalar_site,
        constrained=args.constrained, production_applied=False)
    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    if args.freeze_only:
        print(json.dumps(dict(frozen=True, runtime_validated=False)))
        return
    env = builder.environment()
    env.update(ADVANCED_BUILD_ROOT=str(args.out / "build"), ADVANCED_MODE=args.mode)
    commands = []

    def run(command, label, inspect_admission=False):
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
        if result.returncode and not (inspect_admission and result.returncode == 1):
            raise RuntimeError("failed " + label + "; see " + str(log))

    probe = "constrained_advanced_probe" if args.constrained else "advanced_probe"
    run(["gprbuild", "-P", str(source / project_name), "-j1", probe + ".adb"], "build")
    binary = args.out / "build" / args.mode / "bin" / probe
    comparison_driver = "compare_constrained.py" if args.constrained else "compare.py"
    command = [str(args.python), str(tests / comparison_driver), "--binary", str(binary),
         "--out", str(args.out / "comparison"), "--samples", str(args.samples),
         "--steps", str(args.steps), "--only", args.only]
    if args.constrained:
        command += ["--contact-mobility", "free-carrier", "--solver", "Newton", "--jacobian", "sparse"]
    run(command, "comparison", inspect_admission=args.scalar_site and args.constrained)
    comparison = json.loads((args.out / "comparison/results.json").read_text())
    assert comparison["models"] > 0 and comparison["cases"] > 0
    expected_admission = []
    if args.scalar_site and args.constrained and comparison["failures"]:
        # Preserve the raw comparison and its failure exit. The constrained
        # engine already requires Nv>=1, independently of site transmission.
        assert comparison["failures"] == [dict(model="scalar_site_static_world",
            error="create CAPACITY_EXCEEDED\n")], comparison["failures"]
        geometry = json.loads((args.out / "comparison/scalar-geometry.json").read_text())
        assert any(r["model"] == "scalar_site_static_world" and r["nv"] == 0
                   for r in geometry["records"])
        expected_admission = [dict(model="scalar_site_static_world", nv=0,
            status="CAPACITY_EXCEEDED", checked=True,
            reason="The unchanged constrained Create_Core domain requires Nv in 1..Max_V")]
    else:
        assert not comparison["failures"]
    assert commands[-1]["exit"] == (1 if expected_admission else 0)
    assert comparison["cases"] == args.samples * (comparison["models"] - len(expected_admission))
    assert comparison["passed"] == comparison["cases"]
    assert all(digest(source / name) == value for name, value in inputs.items())
    assert digest(Path(__file__)) == runner_hash
    receipt = dict(reference=reference, commit=prior["commit"], commands=commands,
        manifest_sha256=digest(args.out / "manifest.json"), source_hashes_unchanged=True,
        binary_sha256=digest(binary), complete=True, scalar_site=args.scalar_site,
        constrained=args.constrained,
        differential_cases=comparison["cases"], differential_passed=comparison["passed"],
        expected_admission_rejections=expected_admission,
        scope="Selected owned advanced-actuator trajectories, including scalar-site integration only when enabled; no global Gold or timing claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt))


if __name__ == "__main__":
    main()
