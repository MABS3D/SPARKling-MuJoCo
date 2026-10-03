"""Freeze the flex Model/Data bridge and its dependencies outside the checkout."""
import argparse,hashlib,json,os,pathlib,subprocess,shutil
ROOT=pathlib.Path(__file__).resolve().parents[3]
HERE=ROOT/'experimental/flex-state-integration'
FOLDERS=['src','src/gen','experimental/smooth/src','experimental/spatial-tendon-candidate/src',
 'experimental/muscle-candidate/src','experimental/advanced-collision-candidate/src',
 'experimental/rigid-collision-candidate/src','experimental/constrained-step/src','experimental/sdf-step/src','experimental/flex-state-integration/src',
 'experimental/flex-state-integration/tests']
TC=pathlib.Path('/var/tmp/sparkling-matrix-recovery/toolchains')
def environment():
 e=os.environ.copy();e['PATH']=':'.join(str(p) for n in ['gnat','gprbuild','gnatprove'] for p in (TC/n).glob('*/bin'))+':'+e['PATH'];return e
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=pathlib.Path)
 p.add_argument('--mode',choices=['validation','release'],default='validation');p.add_argument('--resume',action='store_true')
 p.add_argument('--base',type=pathlib.Path,help='Borrow a verified frozen dependency closure')
 p.add_argument('--refresh-owned',action='store_true',help='Refresh only flex-state sources/tests against frozen dependencies')
 a=p.parse_args()
 if a.base and a.resume:p.error('--base and --resume are separate workflows')
 a.out.mkdir(parents=True,exist_ok=a.resume);snap=a.out/'source'
 prior=json.loads((a.out/'manifest.json').read_text()) if a.resume else {};hashes=prior.get('sources',{}).copy()
 for name,h in hashes.items():
  if hashlib.sha256((snap/name).read_bytes()).hexdigest()!=h:raise RuntimeError('Snapshot mismatch: '+name)
 if a.resume:
  attempt=len(list(a.out.glob('attempt-*-manifest.json')))
  shutil.copyfile(a.out/'manifest.json',a.out/f'attempt-{attempt}-manifest.json')
  if (a.out/'build.log').is_file():shutil.copyfile(a.out/'build.log',a.out/f'attempt-{attempt}-build.log')
 base_hashes=json.loads((a.base/'manifest.json').read_text())['sources'] if a.base else {};borrowed=[]
 for folder in (FOLDERS[-2:] if a.resume else FOLDERS):
  refresh=a.refresh_owned and folder in FOLDERS[-2:]
  origin=a.base/'source' if a.base and (a.base/'source'/folder).is_dir() and not refresh else ROOT
  for f in (origin/folder).iterdir():
   if f.is_file() and f.suffix in ['.ads','.adb','.py']:
    data=f.read_bytes();name=str(f.relative_to(origin));dest=snap/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
    hashes[name]=hashlib.sha256(data).hexdigest()
    if origin!=ROOT:
     if base_hashes.get(name)!=hashes[name]:raise RuntimeError('Base snapshot mismatch: '+name)
     borrowed.append(name)
 project_name='experimental/flex-state-integration/flex_state.gpr';project=snap/project_name
 project_origin=a.base/'source'/project_name if a.base and (a.base/'source'/project_name).is_file() else HERE/'flex_state.gpr'
 shutil.copyfile(project_origin,project)
 hashes[str(project.relative_to(snap))]=hashlib.sha256(project.read_bytes()).hexdigest()
 if a.base and project_origin==a.base/'source'/project_name:
  if base_hashes.get(project_name)!=hashes[project_name]:raise RuntimeError('Base project mismatch')
  borrowed.append(project_name)
 changed=[n for n,h in hashes.items() if not (ROOT/n).is_file() or hashlib.sha256((ROOT/n).read_bytes()).hexdigest()!=h]
 if not a.resume and any(n not in borrowed for n in changed):raise RuntimeError('source changed during snapshot: '+repr(changed))
 env=environment();env['FLEX_STATE_BUILD_ROOT']=str(a.out/'build');env['FLEX_STATE_MODE']=a.mode
 cmd=['gprbuild','-P',str(project),'-j1']
 manifest=dict(prior,sources=hashes,mode=a.mode,command=cmd,changed_since_snapshot=changed,refresh_owned=a.refresh_owned)
 manifest.pop('exit',None);manifest.pop('binary_sha256',None)
 if a.base:manifest.update(base=str(a.base.resolve()),shared_sources=borrowed,base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest())
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 with (a.out/'build.log').open('w') as f:
  r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--',*cmd],env=env,stdout=f,stderr=subprocess.STDOUT)
 manifest['exit']=r.returncode
 if not r.returncode:manifest['binary_sha256']=hashlib.sha256((a.out/'build'/a.mode/'bin/flex_state_probe').read_bytes()).hexdigest()
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(a.out/'build.log');raise SystemExit(r.returncode)
if __name__=='__main__':main()
