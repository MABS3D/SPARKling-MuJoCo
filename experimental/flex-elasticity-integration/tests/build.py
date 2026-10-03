"""Build an immutable source closure; all artifacts stay outside the checkout."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
           'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
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
    a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=a.resume)
    snap = a.out/'source'
    hashes = json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
    for folder in (FOLDERS[-2:] if a.resume else FOLDERS):
        for f in (ROOT/folder).iterdir():
            if f.is_file() and f.suffix in ('.adb','.ads','.py'):
                dest = snap/f.relative_to(ROOT); dest.parent.mkdir(parents=True, exist_ok=True)
                data = f.read_bytes(); dest.write_bytes(data)
                hashes[str(f.relative_to(ROOT))] = hashlib.sha256(data).hexdigest()
    project = snap/'experimental/flex-elasticity-integration/flex.gpr'
    shutil.copyfile(HERE/'flex.gpr', project)
    hashes[str((HERE/'flex.gpr').relative_to(ROOT))] = hashlib.sha256(project.read_bytes()).hexdigest()
    if not a.resume:
        changed = [f for f,h in hashes.items() if hashlib.sha256((ROOT/f).read_bytes()).hexdigest()!=h]
        if changed: raise RuntimeError('Concurrent source change: '+repr(changed))
    env = environment(); env['FLEX_BUILD_ROOT'] = str(a.out/'build'); env['FLEX_MODE'] = a.mode
    cmd = ['gprbuild', '-P', str(project), '-j1']
    (a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes, command=cmd, mode=a.mode),indent=2)+'\n')
    with (a.out/('build-'+a.mode+'.log')).open('w') as log:
        r = subprocess.run(['python3', str(ROOT/'tools/guarded.py'), '--cap-mb','2500','--timeout','360','--',*cmd],
                           env=env,stdout=log,stderr=subprocess.STDOUT)
    print(a.out/('build-'+a.mode+'.log')); raise SystemExit(r.returncode)
if __name__ == '__main__': main()
