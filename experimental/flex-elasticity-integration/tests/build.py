"""Build an immutable source closure; all artifacts stay outside the checkout."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
           'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
           'experimental/constraint-assembly-candidate/src',
           'experimental/flex-elasticity-integration/src', 'experimental/flex-elasticity-integration/tests']
def environment():
    env = os.environ.copy()
    tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(p) for name in ('gnat','gprbuild','gnatprove')
                          for p in (tc/name).glob('*/bin')) + ':' + env['PATH']
    return env
def main():
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation','release'], default='validation')
    p.add_argument('--resume', action='store_true')
    p.add_argument('--base', type=Path, help='Freeze shared dependencies from a verified source closure')
    p.add_argument('--frozen', type=Path, help='Build another profile from the exact same complete closure')
    a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=a.resume)
    if sum(bool(x) for x in (a.resume, a.base, a.frozen)) > 1:
        p.error('--resume, --base and --frozen are separate workflows')
    snap = a.out/'source'
    hashes = json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
    frozen_root = a.frozen or a.base
    prior = json.loads((frozen_root/'manifest.json').read_text())['sources'] if frozen_root else {}
    borrowed = []
    for folder in (FOLDERS[-2:] if a.resume else FOLDERS):
        frozen_folder = frozen_root/'source'/folder if frozen_root else None
        owned = (folder.startswith('experimental/flex-elasticity-integration/')
                 or folder == 'experimental/constraint-assembly-candidate/src')
        origin = frozen_root/'source' if frozen_folder and frozen_folder.is_dir() and (a.frozen or not owned) else ROOT
        for f in (origin/folder).iterdir():
            if f.is_file() and f.suffix in ('.adb','.ads','.py'):
                name = str(f.relative_to(origin))
                dest = snap/name; dest.parent.mkdir(parents=True, exist_ok=True)
                data = f.read_bytes(); dest.write_bytes(data)
                hashes[name] = hashlib.sha256(data).hexdigest()
                if origin != ROOT:
                    if prior.get(name) != hashes[name]: raise RuntimeError('Snapshot hash mismatch: '+name)
                    borrowed.append(name)
    project = snap/'experimental/flex-elasticity-integration/flex.gpr'
    project_source = a.frozen/'source/experimental/flex-elasticity-integration/flex.gpr' if a.frozen else HERE/'flex.gpr'
    shutil.copyfile(project_source, project)
    hashes[str((HERE/'flex.gpr').relative_to(ROOT))] = hashlib.sha256(project.read_bytes()).hexdigest()
    if not a.resume:
        changed = [f for f,h in hashes.items() if f not in borrowed and hashlib.sha256((ROOT/f).read_bytes()).hexdigest()!=h]
        if changed: raise RuntimeError('Concurrent source change: '+repr(changed))
    env = environment(); env['FLEX_BUILD_ROOT'] = str(a.out/'build'); env['FLEX_MODE'] = a.mode
    cmd = ['gprbuild', '-P', str(project), '-j1']
    manifest = dict(sources=hashes, command=cmd, mode=a.mode, borrowed=borrowed)
    if frozen_root: manifest['base_manifest_sha256'] = hashlib.sha256((frozen_root/'manifest.json').read_bytes()).hexdigest()
    (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    with (a.out/('build-'+a.mode+'.log')).open('w') as log:
        r = subprocess.run(['python3', str(ROOT/'tools/guarded.py'), '--cap-mb','2500','--timeout','360','--',*cmd],
                           env=env,stdout=log,stderr=subprocess.STDOUT)
    print(a.out/('build-'+a.mode+'.log')); raise SystemExit(r.returncode)
if __name__ == '__main__': main()
