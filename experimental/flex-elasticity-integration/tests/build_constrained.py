"""Freeze the integrated flex, collision and solver closure, then build once."""
import argparse,hashlib,json,subprocess,shutil
from pathlib import Path
from build import ROOT,HERE,environment
FOLDERS=['src','src/gen',*[f'experimental/{name}/src' for name in (
 'smooth','spatial-tendon-candidate','muscle-candidate','rigid-collision-candidate',
 'constraint-assembly-candidate','constraint-solvers-candidate','joint-limit-candidate',
 'frictionless-contact-candidate','constrained-step','advanced-collision-candidate',
 'sdf-step','flex-state-integration','flex-elasticity-integration')],
 'experimental/flex-elasticity-integration/tests']
FOLDERS.insert(-2,'experimental/flex-state-integration/tests')
OWNED = {f'experimental/{name}/{part}' for name in (
 'advanced-collision-candidate','sdf-step','flex-state-integration','flex-elasticity-integration')
 for part in ('src','tests')}

def overlay_sources(snap, hashes, folder, build):
 """Replace one folder only from a manifest-verified frozen closure."""
 if folder not in FOLDERS:raise ValueError('Unsupported overlay folder: '+folder)
 build=Path(build).resolve();manifest=build/'manifest.json'
 overlay_hashes=json.loads(manifest.read_text())['sources']
 names={name for name in overlay_hashes if str(Path(name).parent)==folder
   and Path(name).suffix in ('.ads','.adb','.py')}
 if not names:raise RuntimeError('Overlay has no manifested sources: '+folder)
 data={}
 for name in sorted(names):
  if Path(name).is_absolute() or '..' in Path(name).parts:raise RuntimeError('Unsafe source path: '+name)
  data[name]=(build/'source'/name).read_bytes()
  if hashlib.sha256(data[name]).hexdigest()!=overlay_hashes[name]:
   raise RuntimeError('Overlay snapshot mismatch: '+name)
 removed=[]
 for name in list(hashes):
  if str(Path(name).parent)==folder and Path(name).suffix in ('.ads','.adb','.py') and name not in names:
   (snap/name).unlink();del hashes[name];removed.append(name)
 for name,body in data.items():
  target=snap/name;target.parent.mkdir(parents=True,exist_ok=True)
  target.write_bytes(body);hashes[name]=overlay_hashes[name]
 return dict(folder=folder,build=str(build),
   manifest_sha256=hashlib.sha256(manifest.read_bytes()).hexdigest(),
   sources=sorted(names),removed_sources=sorted(removed))

def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
 p.add_argument('--mode',choices=['validation','release'],default='validation')
 p.add_argument('--freeze-only',action='store_true',help='Prepare a verified source snapshot for minimal proofs without a runtime build')
 p.add_argument('--resume',action='store_true',help='Refresh only this owned entry, retaining frozen dependency hashes')
 p.add_argument('--base',type=Path,help='Use a frozen shared dependency closure with a sources manifest')
 p.add_argument('--refresh-owned',action='store_true',help='Combine frozen common sources with current collision-owned sources')
 p.add_argument('--refresh-tests',action='store_true',help='Refresh test sources only, keeping every implementation source frozen')
 p.add_argument('--refresh-folder',action='append',default=[],choices=FOLDERS,
   help='Refresh only this named source folder, retaining other frozen dependencies')
 p.add_argument('--patch',type=Path,help='Apply a recorded integration patch only inside the new snapshot')
 p.add_argument('--overlay',nargs=2,action='append',default=[],metavar=('FOLDER','BUILD'),
   help='Replace one source folder from an independently verified frozen BUILD; repeat for other folders')
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
  refresh=(a.refresh_owned and folder in OWNED) or (a.refresh_tests and folder.endswith('/tests')) or folder in a.refresh_folder
  origin=a.base/'source' if a.base and (a.base/'source'/folder).is_dir() and not refresh else ROOT
  for source in (origin/folder).iterdir():
   if source.is_file() and source.suffix in ('.ads','.adb','.py'):
    name=source.relative_to(origin);target=snap/name;target.parent.mkdir(parents=True,exist_ok=True)
    data=source.read_bytes();target.write_bytes(data);hashes[str(name)]=hashlib.sha256(data).hexdigest()
    if origin!=ROOT:
     if base_hashes.get(str(name))!=hashes[str(name)]:raise RuntimeError('Base snapshot mismatch: '+str(name))
     borrowed.append(str(name))
 project=snap/'experimental/flex-elasticity-integration/flex_constrained.gpr'
 project_name=str(project.relative_to(snap))
 project_origin=a.base/'source'/project_name if a.base and not a.refresh_owned and (a.base/'source'/project_name).is_file() else HERE/'flex_constrained.gpr'
 shutil.copyfile(project_origin,project)
 hashes[str(project.relative_to(snap))]=hashlib.sha256(project.read_bytes()).hexdigest()
 if a.base and project_origin==a.base/'source'/project_name:
  if base_hashes.get(project_name)!=hashes[project_name]:raise RuntimeError('Base project mismatch')
  borrowed.append(project_name)
 changed=[name for name,h in hashes.items() if not (ROOT/name).is_file()
   or hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=h]
 current_changed=[name for name in changed if name not in borrowed]
 if current_changed and not a.resume:raise RuntimeError('Concurrent source change: '+repr(current_changed))
 overlays=[];overlay_folders=set()
 for folder,build in a.overlay:
  if folder in overlay_folders:raise RuntimeError('Repeated overlay folder: '+folder)
  overlays.append(overlay_sources(snap,hashes,folder,build));overlay_folders.add(folder)
 borrowed=[name for name in borrowed if str(Path(name).parent) not in overlay_folders]
 patched=[]
 if a.patch:
  patch_data=a.patch.resolve().read_bytes()
  patch_run=subprocess.run(['patch','--batch','--forward','-p1','-i',str(a.patch.resolve())],cwd=snap,capture_output=True,text=True)
  (a.out/'integration.patch').write_bytes(patch_data)
  (a.out/'patch.log').write_text(patch_run.stdout+patch_run.stderr)
  if patch_run.returncode:raise RuntimeError('Integration patch failed; see patch.log')
  after_hashes={}
  for folder in FOLDERS:
   for source in (snap/folder).iterdir():
    if source.is_file() and source.suffix in ('.ads','.adb','.py'):
     after_hashes[str(source.relative_to(snap))]=hashlib.sha256(source.read_bytes()).hexdigest()
  after_hashes[project_name]=hashlib.sha256(project.read_bytes()).hexdigest()
  patched=sorted(name for name in hashes.keys()|after_hashes.keys() if hashes.get(name)!=after_hashes.get(name))
  hashes=after_hashes
  borrowed=[name for name in borrowed if name not in patched]
 env=environment();env.update(FLEX_BUILD_ROOT=str(a.out.resolve()/'build'),FLEX_MODE=a.mode)
 cmd=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--','gprbuild','-P',str(project.resolve()),'-j1']
 manifest=dict(prior,sources=hashes,mode=a.mode,command=cmd,changed_since_snapshot=changed,refresh_owned=a.refresh_owned,refresh_tests=a.refresh_tests,refresh_folders=a.refresh_folder)
 manifest['builder_sha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
 manifest['checkout_differences']=[name for name,h in hashes.items()
   if not (ROOT/name).is_file() or hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=h]
 if overlays:manifest['overlays']=overlays
 manifest.pop('exit',None);manifest.pop('binary_sha256',None)
 if a.patch:manifest.update(integration_patch_sha256=hashlib.sha256(patch_data).hexdigest(),patched_sources=patched)
 if a.base:manifest.update(base=str(a.base.resolve()),shared_sources=borrowed,
   base_manifest_sha256=hashlib.sha256((a.base/'manifest.json').read_bytes()).hexdigest())
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 if a.freeze_only:
  manifest.update(phase='snapshot-only',runtime_build_executed=False)
  (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
  print(a.out/'manifest.json');return
 with (a.out/'build.log').open('w') as log:run=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
 manifest['exit']=run.returncode
 binary=a.out/'build'/a.mode/'bin/flex_constrained_probe'
 if run.returncode==0:manifest['binary_sha256']=hashlib.sha256(binary.read_bytes()).hexdigest()
 (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 raise SystemExit(run.returncode)
if __name__=='__main__':main()
