"""Migrate and test the complete owned FLEX closure against actual C 3.15.

The overlay ports retired state storage, stable contact compaction and coupled
world-space forces. Explicit fixture migration retains damping and test cases;
new cases distinguish articulated bending and multi-element stiffness strides.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
FOLDERS = ["experimental/" + name + "/src" for name in (
    "smooth", "spatial-tendon-candidate", "muscle-candidate", "rigid-collision-candidate",
    "constraint-assembly-candidate", "constraint-solvers-candidate", "joint-limit-candidate",
    "frictionless-contact-candidate", "constrained-step", "advanced-collision-candidate",
    "sdf-step", "flex-state-integration", "flex-elasticity-integration")]
FOLDERS += ["experimental/flex-state-integration/tests", "experimental/flex-elasticity-integration/tests"]


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
    prior = json.loads(manifest_path.read_text())
    assert prior["reference"] == "3.15.0"
    assert json.loads((foundation / "results.json").read_text())["complete"]
    for name, value in prior["candidate_sources"].items():
        assert digest(foundation / "source" / name) == value, name
    source = args.out / "source"
    source.mkdir()
    shutil.copytree(foundation / "source/src", source / "src")
    original = {}
    for folder in FOLDERS:
        for path in (ROOT / folder).iterdir():
            if path.is_file() and path.suffix in (".ads", ".adb", ".py", ".c"):
                target = source / path.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
                original[str(path.relative_to(ROOT))] = digest(path)
    projects = ["experimental/flex-state-integration/flex_state.gpr",
                "experimental/flex-elasticity-integration/flex.gpr",
                "experimental/flex-elasticity-integration/flex_constrained.gpr"]
    for name in projects:
        shutil.copyfile(ROOT / name, source / name)
        original[name] = digest(ROOT / name)
    assert all(digest(ROOT / name) == value for name, value in original.items())
    patch = ROOT / "experimental/alignment-3.15/overlays/remove-internal-flex.patch"
    # Apply the reviewed source migration, never silently ignore missing fields.
    subprocess.run(["git", "apply", "--check", str(patch)], cwd=source, check=True)
    subprocess.run(["git", "apply", str(patch)], cwd=source, check=True)
    transformations = [dict(patch_sha256=digest(patch), change="Retired state, contact compaction/static pairs and coupled force assembly")]
    additions = Path(__file__).with_name("flex_fixtures.py")
    destination = source / "experimental/flex-elasticity-integration/tests/flex_fixtures.py"
    shutil.copyfile(additions, destination)
    original[str(additions.relative_to(ROOT))] = digest(additions)
    normalizer = '''
def _migrate_xml_315(xml):
    # This is test-fixture migration, not acceptance of obsolete user XML.
    tree = ET.fromstring(xml)
    for contact in tree.findall('.//flex/contact') + tree.findall('.//flexcomp/contact'):
        contact.attrib.pop('internal', None)
    # 3.15 rejects damping on bare leaf XYZ-slide vertex bodies. Preserve the
    # joint damping, explicit inertia and collision geometry by giving those
    # bodies a massless, noncolliding marker geom (a supported rigid+FLEX case).
    for body in tree.findall('.//body'):
        joints = body.findall('joint')
        if (joints and not body.findall('body') and not body.findall('geom')
                and all(joint.get('type', 'hinge') == 'slide' for joint in joints)
                and any(float(joint.get('damping', '0')) != 0 for joint in joints)):
            assert body.find('inertial') is not None, 'Fixture migration must preserve explicit inertia'
            ET.SubElement(body, 'geom', dict(type='sphere', size='.001', mass='0',
                contype='0', conaffinity='0', fluidcoef='0 0 0 0 0'))
    return ET.tostring(tree, encoding='unicode')

'''
    for name in ("experimental/flex-state-integration/tests/compare.py",
                 "experimental/flex-elasticity-integration/tests/compare.py",
                 "experimental/flex-elasticity-integration/tests/compare_constrained.py"):
        path = source / name
        text = path.read_text().replace("3.14.0", "3.15.0")
        # Place migration before XML is saved and before either C or Ada reads it.
        needle = "  (a.out/(name+'.xml')).write_text(xml)" if "flex-state" in name else (
            "        m=mujoco.MjModel.from_xml_string(xml)" if name.endswith("/compare.py") else
            "  (a.out/(name+'.xml')).write_text(xml)")
        assert text.count(needle) == 1, name
        indentation = "        " if name.endswith("/compare.py") and "flex-elasticity" in name else "  "
        text = text.replace(needle, indentation + "xml = _migrate_xml_315(xml)\n" + needle)
        assert text.count("def main():") == 1
        text = text.replace("def main():", normalizer + "def main():")
        if "flex-elasticity" in name:
            # Keep the old case order/RNG inputs; append distinguishing cases.
            text = text.replace("def fixtures():", "def legacy_fixtures():")
            extra = "additional_constrained_fixtures" if "constrained" in name else "additional_fixtures"
            wrapper = ("from flex_fixtures import " + extra + "\n\ndef fixtures():\n"
                       "    yield from legacy_fixtures()\n    yield from " + extra + "(fixture)\n\n")
            text = text.replace("def main():", wrapper + "def main():")
        if "constrained" in name:
            needle = "    if name.startswith('element_') and sample==0 and not any("
            assert text.count(needle) == 1
            text = text.replace(needle,
                "    retired_internal = name in ('element_internal_pyramidal_3', 'element_internal_elliptic_6', 'element_elastic_internal_pyramidal_3', 'element_elastic_internal_elliptic_6')\n"
                "    if retired_internal and d.ncon != 0:\n"
                "     failures.append(dict(model=name,error='Retired internal FLEX collision produced contacts'))\n"
                "    if name.startswith('element_') and not retired_internal and sample==0 and not any(")
            transformations.append(dict(file=name, change="Retain four retired-internal cases as zero-contact checks; compare every numerical field"))
        path.write_text(text)
        transformations.append(dict(file=name, change="Actual 3.15 reference and explicit retired-attribute fixture translation"))
    inputs = {str(path.relative_to(source)): digest(path) for path in source.rglob("*") if path.is_file()}
    manifest = dict(reference="3.15.0", commit=prior["commit"], sources=inputs,
                    foundation_manifest_sha256=digest(manifest_path), original_sources=original,
                    transformations=transformations, runner_sha256=digest(Path(__file__)),
                    mode=args.mode, production_applied=False)
    (args.out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    env = os.environ.copy()
    tc = Path("/var/tmp/sparkling-matrix-recovery/toolchains")
    env["PATH"] = ":".join(str(path) for name in ("gnat", "gprbuild", "gnatprove")
                             for path in (tc / name).glob("*/bin")) + ":" + env["PATH"]
    env.update(FLEX_STATE_BUILD_ROOT=str(args.out / "state-build"), FLEX_STATE_MODE=args.mode,
               FLEX_BUILD_ROOT=str(args.out / "force-build"), FLEX_MODE=args.mode)
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
        return result.returncode

    for project, label in zip(projects, ("state", "forces", "constrained"), strict=True):
        if run(["gprbuild", "-P", str(source / project), "-j1"], "build-" + label):
            raise RuntimeError("failed build-" + label)
    state_tests = source / "experimental/flex-state-integration/tests"
    force_tests = source / "experimental/flex-elasticity-integration/tests"
    binary = args.out / "force-build" / args.mode / "bin"
    results = []
    results.append(run([str(args.python), str(state_tests / "compare.py"), "--binary",
                        str(args.out / "state-build" / args.mode / "bin/flex_state_probe"),
                        "--out", str(args.out / "state"), "--samples", "2"], "state"))
    results.append(run([str(args.python), str(force_tests / "compare.py"), "--binary",
                        str(binary / "flex_probe"), "--out", str(args.out / "forces"),
                        "--samples", "2", "--steps", "100"], "forces"))
    results.append(run([str(args.python), str(force_tests / "compare_constrained.py"), "--binary",
                        str(binary / "flex_constrained_probe"), "--out", str(args.out / "constrained"),
                        "--samples", "2", "--steps", "100"], "constrained"))
    changed = [name for name, value in inputs.items() if digest(source / name) != value]
    assert not changed, changed
    receipt = dict(reference="3.15.0", commit=prior["commit"], commands=commands,
                   manifest_sha256=digest(args.out / "manifest.json"), source_hashes_unchanged=True,
                   complete=all(code == 0 for code in results),
                   scope="Owned FLEX metadata/state, geometric contacts and force/constraint trajectories; no global Gold or timing claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({key: receipt[key] for key in ("reference", "complete", "scope")}))
    raise SystemExit(not receipt["complete"])


if __name__ == "__main__":
    main()
