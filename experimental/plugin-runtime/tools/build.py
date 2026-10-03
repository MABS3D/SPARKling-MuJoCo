"""Snapshot dependencies before building; shared files are never patched."""
import argparse, hashlib, json, os, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parents[1]
def environment():
    env=os.environ.copy(); tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=':'.join(str(p) for name in ('gnat','gprbuild','gnatprove') for p in (tc/name).glob('*/bin'))+':'+env['PATH']
    return env
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',default='validation');p.add_argument('--resume',action='store_true');a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=a.resume);snap=a.out/'source';hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
    folders=['src','src/gen','experimental/smooth/src','experimental/spatial-tendon-candidate/src','experimental/muscle-candidate/src','experimental/plugin-runtime/src','experimental/plugin-runtime/tests']
    for folder in (folders[-2:] if a.resume else folders):
        for f in (ROOT/folder).iterdir():
            if f.is_file() and f.suffix in ('.ads','.adb','.py','.c'):
                data=f.read_bytes();dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
                hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
    proj=HERE/'plugin.gpr';dest=snap/proj.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(proj.read_bytes());hashes[str(proj.relative_to(ROOT))]=hashlib.sha256(proj.read_bytes()).hexdigest()
    changed=[f for f,h in hashes.items() if (not a.resume or f.startswith('experimental/plugin-runtime/')) and hashlib.sha256((ROOT/f).read_bytes()).hexdigest()!=h]
    if changed:raise RuntimeError('Snapshot changed: '+repr(changed))
    env=environment();env['PLUGIN_BUILD_ROOT']=str(a.out/'build');env['PLUGIN_MODE']=a.mode
    command=['gprbuild','-P',str(dest),'-j1'];(a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes,command=command,mode=a.mode),indent=2)+'\n')
    with (a.out/'build.log').open('w') as log:
        r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--',*command],env=env,stdout=log,stderr=subprocess.STDOUT)
    print(a.out/'build.log');raise SystemExit(r.returncode)
if __name__=='__main__':main()
