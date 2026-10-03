"""Freeze all source inputs and build the opt-in integrated constrained engine."""
import argparse, hashlib, json, os, shutil, subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
FOLDERS=['src','src/gen','experimental/muscle-candidate/src','experimental/smooth/src','experimental/spatial-tendon-candidate/src','experimental/integrators-candidate/src','experimental/integrators-candidate/tests']
def environment():
 env=os.environ.copy(); tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
 env['PATH']=':'.join(str(p) for name in ('gnat','gprbuild','gnatprove') for p in (tc/name).glob('*/bin'))+':'+env['PATH']
 return env
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',default='validation');p.add_argument('--resume',action='store_true');p.add_argument('--working-dependencies',action='store_true',help='refresh all dependencies on resume');a=p.parse_args()
 a.out.mkdir(parents=True,exist_ok=a.resume); snap=a.out/'source'; hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
 for folder in (FOLDERS[-2:] if a.resume and not a.working_dependencies else FOLDERS):
  for f in (ROOT/folder).iterdir():
   if f.is_file() and f.suffix in ('.ads','.adb','.py','.c'):
    dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True)
    data=f.read_bytes()
    if not dest.exists() or dest.read_bytes()!=data:dest.write_bytes(data)
    hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
 project=snap/'experimental/integrators-candidate/integrators.gpr';shutil.copyfile(HERE/'integrators.gpr',project)
 hashes[str((HERE/'integrators.gpr').relative_to(ROOT))]=hashlib.sha256(project.read_bytes()).hexdigest()
 # Fresh snapshots must be internally consistent even during parallel work.
 if not a.resume or a.working_dependencies:
  changed=[name for name,digest in hashes.items() if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=digest]
  if changed:raise RuntimeError('Sources changed while snapshotting: '+repr(changed))
 env=environment();env['INTEGRATORS_BUILD_ROOT']=str(a.out/'build');env['INTEGRATORS_MODE']=a.mode
 cmd=['gprbuild','-P',str(project),'-j1']
 (a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes,command=cmd,mode=a.mode),indent=2)+'\n')
 with (a.out/'build.log').open('w') as log:
  result=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
 print(a.out/'build.log');raise SystemExit(result.returncode)
if __name__=='__main__':main()
