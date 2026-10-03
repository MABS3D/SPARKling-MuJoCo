"""Build an isolated adhesion overlay on the captured constrained engine."""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import zipfile

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]


def environment():
    env = os.environ.copy()
    tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(p) for name in ('gnat', 'gprbuild', 'gnatprove')
                           for p in (tc / name).glob('*/bin')) + ':' + env['PATH']
    return env


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--mode', choices=['validation', 'release'], default='validation')
    parser.add_argument('--resume', action='store_true')
    parser.add_argument('--working-dependencies', action='store_true')
    parser.add_argument('--frozen', action='store_true', help='Build the saved immutable closure without refreshing inputs')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=args.resume or args.frozen)
    snapshot = args.out / 'source'
    if args.frozen:
        saved = json.loads((args.out/'manifest.json').read_text())
        changed = [name for name, digest in saved['sources'].items()
            if not (snapshot/name).is_file() or hashlib.sha256((snapshot/name).read_bytes()).hexdigest() != digest]
        if changed: raise RuntimeError('Frozen sources changed: '+repr(changed))
        project = snapshot/'experimental/constrained-step/constrained.gpr'
        env = environment(); env['CONSTRAINED_BUILD_ROOT'] = str(args.out/'build')
        env['CONSTRAINED_MODE'] = args.mode
        command = ['gprbuild', '-P', str(project), '-j1']
        receipt = dict(sources=saved['sources'], mode=args.mode, command=command, frozen=True)
        with (args.out/('build-'+args.mode+'.log')).open('w') as log:
            run = subprocess.run(['python3', str(ROOT/'tools/guarded.py'), '--cap-mb', '3000',
                '--timeout', '360', '--', *command], env=env, stdout=log, stderr=subprocess.STDOUT)
        receipt['exit'] = run.returncode
        (args.out/('build-'+args.mode+'-manifest.json')).write_text(json.dumps(receipt,indent=2)+'\n')
        print(args.out/('build-'+args.mode+'.log'), flush=True)
        raise SystemExit(run.returncode)
    productive = args.working_dependencies and (ROOT/'experimental/constrained-step/src/mj-adhesion.ads').exists()
    if args.working_dependencies:
        folders = ['src', 'src/gen', 'experimental/smooth/src',
            'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
            'experimental/rigid-collision-candidate/src', 'experimental/constraint-assembly-candidate/src',
            'experimental/constraint-solvers-candidate/src', 'experimental/joint-limit-candidate/src',
            'experimental/frictionless-contact-candidate/src', 'experimental/constrained-step/src',
            'experimental/constrained-step/tests']
        dependencies = {}
        for folder in folders:
            for file in (ROOT/folder).iterdir():
                if file.is_file() and file.suffix in ('.ads','.adb','.py'):
                    name = str(file.relative_to(ROOT));data = file.read_bytes()
                    dest = snapshot/name;dest.parent.mkdir(parents=True,exist_ok=True)
                    if not dest.exists() or dest.read_bytes()!=data:dest.write_bytes(data)
                    dependencies[name] = hashlib.sha256(data).hexdigest()
        changed = [name for name,digest in dependencies.items()
            if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=digest]
        if changed:raise RuntimeError('Dependencies changed during snapshot: '+repr(changed))
        patch = HERE/'integration/current-core.patch'
        if not productive:
            subprocess.run(['git','apply','--check',str(patch)],cwd=snapshot,check=True)
            subprocess.run(['git','apply',str(patch)],cwd=snapshot,check=True)
        (args.out/'dependency-inputs.json').write_text(json.dumps(dependencies,indent=2)+'\n')
        if not productive: shutil.copyfile(patch,args.out/'applied-core.patch')
    else:
        if not args.resume:
            with zipfile.ZipFile(HERE / 'baseline-source.zip') as archive:
                archive.extractall(snapshot)
        for file in (HERE / 'overlay').rglob('*'):
            if file.is_file():
                target = snapshot / file.relative_to(HERE / 'overlay')
                target.parent.mkdir(parents=True, exist_ok=True)
                if not target.exists() or target.read_bytes() != file.read_bytes():
                    shutil.copyfile(file, target)
    for folder in (('tests',) if productive else ('src', 'tests')):
        origin = HERE/folder
        if folder == 'src' and not origin.exists(): origin = HERE/'integration/recovered-sources'
        for file in origin.iterdir():
            if file.is_file() and file.suffix in ('.ads', '.adb', '.py'):
                target = snapshot / 'experimental/adhesion-contact-integration' / folder / file.name
                target.parent.mkdir(parents=True, exist_ok=True)
                if not target.exists() or target.read_bytes() != file.read_bytes():
                    shutil.copyfile(file, target)
    project = snapshot / 'experimental/constrained-step/constrained.gpr'
    if args.working_dependencies:
        project_text = (ROOT/'experimental/constrained-step/constrained.gpr').read_text()
    else:
        with zipfile.ZipFile(HERE / 'baseline-source.zip') as archive:
            project_text = archive.read('experimental/constrained-step/constrained.gpr').decode()
    project_text = re.sub(r'for Main use \([^;]+;', 'for Main use ("adhesion_contact_probe.adb");', project_text)
    final_project = project_text.replace(
        'for Source_Dirs use ("src", "tests",',
        'for Source_Dirs use (' + ('' if productive else '"../adhesion-contact-integration/src", ')
        + '"../adhesion-contact-integration/tests", "src", "tests",').replace(
        'project Constrained is', 'project Constrained is')
    if not project.exists() or project.read_text() != final_project:
        project.write_text(final_project)
    hashes = {str(p.relative_to(snapshot)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in snapshot.rglob('*') if p.is_file()}
    env = environment()
    env['CONSTRAINED_BUILD_ROOT'] = str(args.out / 'build')
    env['CONSTRAINED_MODE'] = args.mode
    command = ['gprbuild', '-P', str(project), '-j1']
    (args.out / 'manifest.json').write_text(json.dumps(dict(
        sources=hashes, mode=args.mode, command=command,
        working_dependencies=args.working_dependencies, productive_common=productive,
        baseline_sha256=None if args.working_dependencies else hashlib.sha256((HERE / 'baseline-source.zip').read_bytes()).hexdigest()), indent=2) + '\n')
    with (args.out / ('build-' + args.mode + '.log')).open('w') as log:
        run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'),
                              '--cap-mb', '3000', '--timeout', '360', '--', *command],
                             env=env, stdout=log, stderr=subprocess.STDOUT)
    print(args.out / ('build-' + args.mode + '.log'), flush=True)
    raise SystemExit(run.returncode)


if __name__ == '__main__':
    main()
