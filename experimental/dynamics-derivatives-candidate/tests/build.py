"""Freeze all sources; leave shared builds and source files untouched."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
    'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
    'experimental/constrained-step/src', 'experimental/rigid-collision-candidate/src',
    'experimental/constraint-assembly-candidate/src', 'experimental/constraint-solvers-candidate/src',
    'experimental/joint-limit-candidate/src', 'experimental/frictionless-contact-candidate/src',
    'experimental/inverse-dynamics/src',
    'experimental/dynamics-derivatives-candidate/src', 'experimental/dynamics-derivatives-candidate/tests']
def environment():
    env = os.environ.copy(); tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(next((tc/n).glob('*/bin')))
        for n in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    return env
def main():
    p = argparse.ArgumentParser(); p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation','release'], default='validation')
    p.add_argument('--resume', action='store_true')
    p.add_argument('--working-dependencies', action='store_true',
        help='On resume, refresh the full current closure instead of only owned sources')
    a = p.parse_args()
    a.out = a.out.resolve(); a.out.mkdir(parents=True, exist_ok=a.resume)
    snap = a.out/'source'; manifest = a.out/'sources.json'
    hashes = json.loads(manifest.read_text()) if a.resume else {}
    refreshed = []
    for folder in (FOLDERS[-2:] if a.resume and not a.working_dependencies else FOLDERS):
        for f in (ROOT/folder).iterdir():
            if f.is_file() and f.suffix in ('.ads','.adb','.py'):
                data = f.read_bytes(); rel = f.relative_to(ROOT)
                dest = snap/rel; dest.parent.mkdir(parents=True, exist_ok=True)
                if not dest.exists() or dest.read_bytes() != data: dest.write_bytes(data)
                hashes[str(rel)] = hashlib.sha256(data).hexdigest(); refreshed.append(str(rel))
    rel = HERE.relative_to(ROOT)/'derivatives.gpr'; data = (ROOT/rel).read_bytes()
    if not (snap/rel).exists() or (snap/rel).read_bytes()!=data: (snap/rel).write_bytes(data)
    hashes[str(rel)] = hashlib.sha256(data).hexdigest(); refreshed.append(str(rel))
    changed = [f for f,h in hashes.items()
        if hashlib.sha256(((ROOT if f in refreshed else snap)/f).read_bytes()).hexdigest()!=h]
    if changed: raise RuntimeError('Concurrent changes during snapshot: '+repr(changed))
    manifest.write_text(json.dumps(hashes, indent=2)+'\n')
    env = environment(); env['DERIVATIVES_BUILD_ROOT'] = str(a.out/'build')
    env['DERIVATIVES_MODE'] = a.mode
    cmd = ['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--',
           'gprbuild','-P',str(snap/rel),'-j1']
    with (a.out/('build-'+a.mode+'.log')).open('w') as log:
        r = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT)
    if r.returncode:
        print((a.out/('build-'+a.mode+'.log')).read_text()[-5500:])
    else: print(a.out/'build'/a.mode/'bin/derivatives_probe')
    raise SystemExit(r.returncode)
if __name__ == '__main__': main()
