"""Freeze the integrated flex, collision and solver closure, then build once."""
import argparse,hashlib,json,subprocess,shutil
from pathlib import Path
from build import ROOT,HERE,environment
FOLDERS=['src','src/gen',*[f'experimental/{name}/src' for name in (
 'smooth','spatial-tendon-candidate','muscle-candidate','rigid-collision-candidate',
 'constraint-assembly-candidate','constraint-solvers-candidate','joint-limit-candidate',
 'frictionless-contact-candidate','constrained-step','advanced-collision-candidate',
 'flex-state-integration','flex-elasticity-integration')],
 'experimental/flex-elasticity-integration/tests']
FOLDERS.insert(-2,'experimental/flex-state-integration/tests')
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
 p.add_argument('--mode',choices=['validation','release'],default='validation')
 p.add_argument('--resume',action='store_true',help='Refresh only this owned entry, retaining frozen dependency hashes')
 p.add_argument('--base',type=Path,help='Use a frozen shared dependency closure with a sources manifest')
 p.add_argument('--patch',type=Path,help='Apply a recorded integration patch only inside the new snapshot')
 a=p.parse_args()
 if a.base and a.resume:p.error('--base and --resume are separate workflows')
 a.out.mkdir(parents=True,exist_ok=a.resume);snap=a.out/'source'
 prior=json.loads((a.out/'manifest.json').read_text()) if a.resume else {}
 if a.resume:
  attempt=len(list(a.out.glob('attempt-*-manifest.json')))
  shutil.copyfile(a.out/'manifest.json',a.out/f'attempt-{attempt}-manifest.json')
  if (a.out/'build.log').exists():shutil.copyfile(a.out/'build.log',a.out/f'attempt-{attempt}-build.log')
 hashes=prior.get('sources',{}).copy()
 for name,h in hashes.items():
  if hashlib.sha256((snap/name).read_bytes()).hexdigest()!=h:raise RuntimeError('Snapshot mismatch: '+name)
 base_hashes=json.loads((a.base/'manifest.json').read_text())['sources'] if a.base else {}
 borrowed=[]
 for folder in (FOLDERS[-2:] if a.resume else FOLDERS):
  origin=a.base/'source' if a.base and (a.base/'source'/folder).is_dir() else ROOT
  for source in (origin/folder).iterdir():
   if source.is_file() and source.suffix in ('.ads','.adb','.py'):
    name=source.relative_to(origin);target=snap/name;target.parent.mkdir(parents=True,exist_ok=True)
    data=source.read_bytes();target.write_bytes(data);hashes[str(name)]=hashlib.sha256(data).hexdigest()
    if origin!=ROOT:
     if base_hashes.get(str(name))!=hashes[str(name)]:raise RuntimeError('Base snapshot mismatch: '+str(name))
     borrowed.append(str(name))
 project=snap/'experimental/flex-elasticity-integration/flex_constrained.gpr'
 shutil.copyfile(HERE/'flex_constrained.gpr',project)
 hashes[str(project.relative_to(snap))]=hashlib.sha256(project.read_bytes()).hexdigest()
 changed=[name for name,h in hashes.items() if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=h]
 current_changed=[name for name in changed if name not in borrowed]
 if current_changed and not a.resume:raise RuntimeError('Concurrent source change: '+repr(current_changed))
 patched=[]
 if a.patch:
  patch_data=a.patch.resolve().read_bytes()
  patch_run=subprocess.run(['patch','--batch','--forward','-p1','-i',str(a.patch.resolve())],cwd=snap,capture_output=True,text=True)
  (a.out/'integration.patch').write_bytes(patch_data)
  (a.out/'patch.log').write_text(patch_run.stdout+patch_run.stderr)
  if patch_run.returncode:raise RuntimeError('Integration patch failed; see patch.log')
  for name,h in list(hashes.items()):
   after=hashlib.sha256((snap/name).read_bytes()).hexdigest()
   if after!=h:patched.append(name);hashes[name]=after
  borrowed=[name for name in borrowed if name not in patched]
 env=environment();env.update(FLEX_BUILD_ROOT=str(a.out.resolve()/'build'),FLEX_MODE=a.mode)
 cmd=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--','gprbuild','-P',str(project.resolve()),'-j1']
 manifest=dict(prior,sources=hashes,mode=a.mode,command=cmd,changed_since_snapshot=changed)
 manifest.pop('exit',None);manifest.pop('binary_sha256',None)
 if a.patch:manifest.update(integration_patch_sha256=hashlib.sha256(patch_data).hexdigest(),patched_sources=patched)
 if a.base:manifest.update(base=str(a.base.resolve()),shared_sources=borrowed,
   base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest())
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 with (a.out/'build.log').open('w') as log:run=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
 manifest['exit']=run.returncode
 binary=a.out/'build'/a.mode/'bin/flex_constrained_probe'
 if run.returncode==0:manifest['binary_sha256']=hashlib.sha256(binary.read_bytes()).hexdigest()
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 raise SystemExit(run.returncode)
if __name__=='__main__':main()
