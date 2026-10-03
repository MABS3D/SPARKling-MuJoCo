"""Freeze all source inputs and build the opt-in integrated constrained engine."""
import argparse, hashlib, json, os, shutil, subprocess, time
from pathlib import Path
HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
FOLDERS=['src','src/gen','experimental/muscle-candidate/src','experimental/smooth/src','experimental/spatial-tendon-candidate/src',
 'experimental/rigid-collision-candidate/src','experimental/constraint-assembly-candidate/src',
 'experimental/constraint-solvers-candidate/src','experimental/joint-limit-candidate/src',
 'experimental/frictionless-contact-candidate/src','experimental/constrained-step/src',
 'experimental/constrained-step/tests']
def environment():
 env=os.environ.copy(); tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
 env['PATH']=':'.join(str(p) for name in ('gnat','gprbuild','gnatprove') for p in (tc/name).glob('*/bin'))+':'+env['PATH']
 return env
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',choices=['validation','release'],default='validation');p.add_argument('--resume',action='store_true');p.add_argument('--frozen',action='store_true',help='Build another profile from exactly the existing immutable snapshot');a=p.parse_args()
 if a.resume and a.frozen:p.error('--resume and --frozen are mutually exclusive')
 a.out.mkdir(parents=True,exist_ok=a.resume or a.frozen); snap=a.out/'source'; hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume or a.frozen else {}
 for folder in ([] if a.frozen else FOLDERS[-2:] if a.resume else FOLDERS):
  for f in (ROOT/folder).iterdir():
   if f.is_file() and f.suffix in ('.ads','.adb','.py','.c'):
    dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True)
    data=f.read_bytes();dest.write_bytes(data);hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
 project=snap/'experimental/constrained-step/constrained.gpr'
 if not a.frozen:
  shutil.copyfile(HERE/'constrained.gpr',project)
  hashes[str((HERE/'constrained.gpr').relative_to(ROOT))]=hashlib.sha256(project.read_bytes()).hexdigest()
 publication=HERE/'publication.gpr'
 if publication.is_file() and not a.frozen:
  target=snap/publication.relative_to(ROOT);shutil.copyfile(publication,target)
  hashes[str(publication.relative_to(ROOT))]=hashlib.sha256(target.read_bytes()).hexdigest()
 # Fresh snapshots must be internally consistent even during parallel work.
 if not a.resume and not a.frozen:
  changed=[name for name,digest in hashes.items() if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=digest]
  if changed:raise RuntimeError('Sources changed while snapshotting: '+repr(changed))
 env=environment();env['CONSTRAINED_BUILD_ROOT']=str(a.out/'build');env['CONSTRAINED_MODE']=a.mode
 cmd=['gprbuild','-P',str(project),'-j1']
 if not a.frozen:
  (a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes,command=cmd,mode=a.mode),indent=2)+'\n')
 def snapshot_matches():
  return all(hashlib.sha256((snap/name).read_bytes()).hexdigest()==digest for name,digest in hashes.items())
 if not snapshot_matches():raise RuntimeError('Frozen build inputs differ from manifest')
 logpath=a.out/('build-'+a.mode+'.log' if a.frozen else 'build.log')
 start=time.monotonic()
 with logpath.open('w') as log:
  result=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--min-free-mb','12000','--timeout','360','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
 if not snapshot_matches():raise RuntimeError('Frozen build inputs changed during build')
 record=dict(command=cmd,mode=a.mode,exit=result.returncode,seconds=time.monotonic()-start,
  snapshot_hashes_unchanged=True,
  source_manifest_sha256=hashlib.sha256((a.out/'manifest.json').read_bytes()).hexdigest(),
  checkout_matches_snapshot=all((ROOT/name).is_file() and hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest for name,digest in hashes.items()),
  binaries={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in (a.out/'build'/a.mode/'bin').glob('*') if f.is_file()})
 (a.out/('build-'+a.mode+'.json')).write_text(json.dumps(record,indent=2)+'\n')
 print(logpath);raise SystemExit(result.returncode)
if __name__=='__main__':main()
