"""Snapshot sources and build without touching shared objects or engine files."""
import argparse,hashlib,json,os,subprocess,tarfile,io
from pathlib import Path
HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
FOLDERS=['src','src/gen','experimental/smooth/src','experimental/muscle-candidate/src',
 'experimental/spatial-tendon-candidate/src','experimental/constrained-step/src',
 'experimental/rigid-collision-candidate/src','experimental/constraint-assembly-candidate/src',
 'experimental/constraint-solvers-candidate/src','experimental/joint-limit-candidate/src',
 'experimental/frictionless-contact-candidate/src',
 'experimental/mocap/tests']
OWNED_FOLDERS=['experimental/mocap/tests']
DEPENDENCY_FOLDERS=[f for f in FOLDERS if f not in OWNED_FOLDERS]
def env(out,mode):
 e=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
 e['PATH']=':'.join(str(p) for name in ('gnat','gprbuild','gnatprove') for p in (tc/name).glob('*/bin'))+':'+e['PATH']
 e['MOCAP_BUILD_ROOT']=str(out/'build');e['MOCAP_MODE']=mode
 return e
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',default='validation');p.add_argument('--resume',action='store_true');p.add_argument('--working-dependencies',action='store_true',help='snapshot or refresh the full working dependency closure');a=p.parse_args()
 a.out.mkdir(parents=True,exist_ok=a.resume);snap=a.out/'source'
 hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
 baseline=None
 if not a.resume and not a.working_dependencies:
  baseline=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
  archive=subprocess.check_output(['git','archive',baseline,'--',*DEPENDENCY_FOLDERS],cwd=ROOT)
  with tarfile.open(fileobj=io.BytesIO(archive)) as t:
   for member in t:
    if member.isfile() and Path(member.name).suffix in ('.ads','.adb'):
     data=t.extractfile(member).read();q=snap/member.name;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(data)
     hashes[member.name]=hashlib.sha256(data).hexdigest()
 for folder in (FOLDERS if a.working_dependencies else OWNED_FOLDERS):
  for f in (ROOT/folder).iterdir():
   if f.is_file() and f.suffix in ('.ads','.adb','.py'):
    name=str(f.relative_to(ROOT));q=snap/name;q.parent.mkdir(parents=True,exist_ok=True)
    data=f.read_bytes()
    if not q.exists() or q.read_bytes()!=data:q.write_bytes(data)
    hashes[name]=hashlib.sha256(data).hexdigest()
 project=snap/'experimental/mocap/mocap.gpr';data=(HERE/'mocap.gpr').read_bytes()
 if not project.exists() or project.read_bytes()!=data:project.write_bytes(data)
 hashes['experimental/mocap/mocap.gpr']=hashlib.sha256(data).hexdigest()
 if a.working_dependencies:
  for attempt in range(5):
   changed=[n for n,h in hashes.items() if hashlib.sha256((ROOT/n).read_bytes()).hexdigest()!=h]
   if not changed:break
   for n in changed:
    data=(ROOT/n).read_bytes();(snap/n).write_bytes(data);hashes[n]=hashlib.sha256(data).hexdigest()
  else:raise RuntimeError('Shared sources changed during snapshot: '+repr(changed))
 previous=json.loads((a.out/'manifest.json').read_text()) if a.resume else {}
 (a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes,mode=a.mode,baseline=None if a.working_dependencies else baseline or previous.get('baseline')),indent=2)+'\n')
 with (a.out/('build-'+a.mode+'.log')).open('w') as log:
  r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--','gprbuild','-P',str(project),'-j1'],env=env(a.out,a.mode),stdout=log,stderr=subprocess.STDOUT)
 print(a.out/('build-'+a.mode+'.log'));raise SystemExit(r.returncode)
if __name__=='__main__':main()
