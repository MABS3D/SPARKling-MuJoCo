"""Freeze the source closure; build SDF and ordinary probes with runtime checks."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/muscle-candidate/src',
 'experimental/smooth/src', 'experimental/spatial-tendon-candidate/src',
 'experimental/rigid-collision-candidate/src', 'experimental/constraint-assembly-candidate/src',
 'experimental/constraint-solvers-candidate/src', 'experimental/joint-limit-candidate/src',
 'experimental/frictionless-contact-candidate/src', 'experimental/constrained-step/src',
 'experimental/advanced-collision-candidate/src', 'experimental/constrained-step/tests',
 'experimental/sdf-step/src', 'experimental/sdf-step/tests']
def environment():
    env = os.environ.copy()
    tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(p) for n in ('gnat', 'gprbuild', 'gnatprove')
                          for p in (tc/n).glob('*/bin')) + ':' + env['PATH']
    return env
def main():
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation', 'release'], default='validation')
    p.add_argument('--resume', action='store_true')
    p.add_argument('--own-only', action='store_true', help='Keep the frozen dependency revision')
    p.add_argument('--base',type=Path,help='Borrow a recorded frozen shared dependency closure')
    a = p.parse_args()
    if a.base and (a.resume or a.own_only):p.error('--base is for a new snapshot')
    a.out.mkdir(parents=True, exist_ok=a.resume)
    snap = a.out/'source'
    prior = json.loads((a.out/'manifest.json').read_text()) if a.resume else {}
    hashes = prior.get('sources',{}).copy()
    for name,h in hashes.items():
        if hashlib.sha256((snap/name).read_bytes()).hexdigest()!=h:raise RuntimeError('Snapshot mismatch: '+name)
    if a.resume:
        attempt=len(list(a.out.glob('attempt-*-manifest.json')))
        shutil.copyfile(a.out/'manifest.json',a.out/f'attempt-{attempt}-manifest.json')
        if (a.out/'build.log').exists():shutil.copyfile(a.out/'build.log',a.out/f'attempt-{attempt}-build.log')
    base_hashes=json.loads((a.base/'manifest.json').read_text())['sources'] if a.base else {}
    borrowed=[]
    for name in list(hashes) if not a.own_only else []:
        if not (ROOT/name).is_file():
            (snap/name).unlink(missing_ok=True); del hashes[name]
    for folder in FOLDERS[-2:] if a.own_only else FOLDERS:
        origin=a.base/'source' if a.base and (a.base/'source'/folder).is_dir() else ROOT
        for f in (origin/folder).iterdir():
            if f.is_file() and f.suffix in ('.ads', '.adb', '.py', '.c'):
                name=str(f.relative_to(origin));dest = snap/name; dest.parent.mkdir(parents=True, exist_ok=True)
                data = f.read_bytes(); dest.write_bytes(data)
                hashes[name] = hashlib.sha256(data).hexdigest()
                if origin!=ROOT:
                    if base_hashes.get(name)!=hashes[name]:raise RuntimeError('Base snapshot mismatch: '+name)
                    borrowed.append(name)
    project = snap/'experimental/sdf-step/sdf.gpr'
    shutil.copyfile(HERE/'sdf.gpr', project)
    hashes['experimental/sdf-step/sdf.gpr'] = hashlib.sha256(project.read_bytes()).hexdigest()
    changed = [f for f,h in hashes.items() if not (ROOT/f).is_file()
      or hashlib.sha256((ROOT/f).read_bytes()).hexdigest()!=h]
    if not a.resume and any(name not in borrowed for name in changed):raise RuntimeError('Concurrent source change')
    env = environment(); env['SDF_BUILD_ROOT'] = str(a.out/'build'); env['SDF_MODE'] = a.mode
    cmd = ['gprbuild', '-P', str(project), '-j1']
    manifest=dict(prior,sources=hashes,mode=a.mode,command=cmd,concurrently_changed_sources=changed)
    manifest.pop('exit',None);manifest.pop('binary_sha256',None)
    if a.base:manifest.update(base=str(a.base.resolve()),shared_sources=borrowed,
      base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest())
    (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    with (a.out/'build.log').open('w') as log:
        r = subprocess.run(['python3', str(ROOT/'tools/guarded.py'), '--cap-mb', '3000',
                            '--timeout', '360', '--', *cmd], env=env, stdout=log, stderr=subprocess.STDOUT)
    manifest['exit']=r.returncode
    if not r.returncode:manifest['binary_sha256']={f.name:hashlib.sha256(f.read_bytes()).hexdigest()
      for f in (a.out/'build'/a.mode/'bin').iterdir() if f.is_file()}
    (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(a.out/'build.log'); raise SystemExit(r.returncode)
if __name__ == '__main__': main()
