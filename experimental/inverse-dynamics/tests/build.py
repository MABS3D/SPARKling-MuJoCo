"""Freeze the input closure before compiling; never build in the shared checkout."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
           'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
           'experimental/rigid-collision-candidate/src', 'experimental/constraint-assembly-candidate/src',
           'experimental/constraint-solvers-candidate/src', 'experimental/joint-limit-candidate/src',
           'experimental/frictionless-contact-candidate/src', 'experimental/constrained-step/src',
           'experimental/inverse-dynamics/src', 'experimental/inverse-dynamics/tests']

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
    parser.add_argument('--dependencies', type=Path,
                        help='An immutable repository-shaped dependency snapshot; new inverse files still come from this checkout')
    parser.add_argument('--resume', action='store_true', help='Refresh only inverse files in an existing frozen closure')
    parser.add_argument('--working-dependencies', action='store_true',
                        help='On resume, also refresh the explicitly selected dependency closure')
    parser.add_argument('--snapshot-only', action='store_true')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=args.resume)
    snap = args.out / 'source'
    hashes = json.loads((args.out / 'manifest.json').read_text())['sources'] if args.resume else {}
    for folder in (FOLDERS[-2:] if args.resume and not args.working_dependencies else FOLDERS):
        origin = ROOT if folder.startswith('experimental/inverse-dynamics/') else (args.dependencies or ROOT)
        for f in (origin / folder).iterdir():
            if f.is_file() and f.suffix in ('.ads', '.adb', '.py', '.c'):
                data = f.read_bytes()
                target = snap / f.relative_to(origin)
                target.parent.mkdir(parents=True, exist_ok=True)
                if not target.exists() or target.read_bytes()!=data: target.write_bytes(data)
                hashes[str(f.relative_to(origin))] = hashlib.sha256(data).hexdigest()
    project = snap / 'experimental/inverse-dynamics/inverse.gpr'
    data=(HERE / 'inverse.gpr').read_bytes()
    if not project.exists() or project.read_bytes()!=data: project.write_bytes(data)
    hashes['experimental/inverse-dynamics/inverse.gpr'] = hashlib.sha256(project.read_bytes()).hexdigest()
    # Refresh only changed files before accepting the immutable closure. A
    # busy shared checkout must never silently mix proof/build source revisions.
    for attempt in range(8):
        changed = []
        for name, digest in hashes.items():
            origin = ROOT if name.startswith('experimental/inverse-dynamics/') else (snap if args.resume and not args.working_dependencies else (args.dependencies or ROOT))
            if hashlib.sha256((origin / name).read_bytes()).hexdigest() != digest:
                changed.append(name)
        if not changed:
            break
        for name in changed:
            origin = ROOT if name.startswith('experimental/inverse-dynamics/') else (snap if args.resume and not args.working_dependencies else (args.dependencies or ROOT))
            data = (origin / name).read_bytes()
            (snap / name).write_bytes(data)
            hashes[name] = hashlib.sha256(data).hexdigest()
    else:
        raise RuntimeError('Concurrent source changes while freezing: ' + repr(changed))
    env = environment()
    env['INVERSE_BUILD_ROOT'] = str(args.out / 'build')
    env['INVERSE_MODE'] = args.mode
    command = ['gprbuild', '-P', str(project), '-j1']
    (args.out / 'manifest.json').write_text(json.dumps(dict(sources=hashes, mode=args.mode,
                                                         dependency_origin=str(args.dependencies or ROOT),
                                                         command=command), indent=2) + '\n')
    if args.snapshot_only:
        print(args.out / 'manifest.json', flush=True)
        return
    with (args.out / 'build.log').open('w') as log:
        run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '3000',
                              '--timeout', '360', '--', *command], env=env,
                             stdout=log, stderr=subprocess.STDOUT)
    print(args.out / 'build.log', flush=True)
    raise SystemExit(run.returncode)

if __name__ == '__main__':
    main()
