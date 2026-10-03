"""Freeze the flex Model/Data bridge and its dependencies outside the checkout."""
import argparse,hashlib,json,os,pathlib,subprocess,shutil
ROOT=pathlib.Path(__file__).resolve().parents[3]
HERE=ROOT/'experimental/flex-state-integration'
FOLDERS=['src','src/gen','experimental/smooth/src','experimental/spatial-tendon-candidate/src',
 'experimental/muscle-candidate/src','experimental/advanced-collision-candidate/src',
 'experimental/advanced-collision-candidate/vendor/src','experimental/flex-state-integration/src',
 'experimental/flex-state-integration/tests']
TC=pathlib.Path('/var/tmp/sparkling-matrix-recovery/toolchains')
def environment():
 e=os.environ.copy();e['PATH']=':'.join(str(p) for n in ['gnat','gprbuild','gnatprove'] for p in (TC/n).glob('*/bin'))+':'+e['PATH'];return e
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=pathlib.Path);p.add_argument('--mode',default='validation');p.add_argument('--resume',action='store_true');a=p.parse_args()
 a.out.mkdir(parents=True,exist_ok=a.resume);snap=a.out/'source';hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume else {}
 for folder in (FOLDERS[-2:] if a.resume else FOLDERS):
  for f in (ROOT/folder).iterdir():
   if f.is_file() and f.suffix in ['.ads','.adb','.py']:
    data=f.read_bytes();dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
    hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
 project=snap/'experimental/flex-state-integration/flex_state.gpr';shutil.copyfile(HERE/'flex_state.gpr',project)
 hashes[str(project.relative_to(snap))]=hashlib.sha256(project.read_bytes()).hexdigest()
 changed=[n for n,h in hashes.items() if hashlib.sha256((ROOT/n).read_bytes()).hexdigest()!=h] if not a.resume else []
 if changed:raise RuntimeError('source changed during snapshot: '+repr(changed))
 env=environment();env['FLEX_STATE_BUILD_ROOT']=str(a.out/'build');env['FLEX_STATE_MODE']=a.mode
 cmd=['gprbuild','-P',str(project),'-j1']
 (a.out/'manifest.json').write_text(json.dumps({'sources':hashes,'mode':a.mode,'command':cmd},indent=2)+'\n')
 with (a.out/'build.log').open('w') as f:
  r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--',*cmd],env=env,stdout=f,stderr=subprocess.STDOUT)
 print(a.out/'build.log');raise SystemExit(r.returncode)
if __name__=='__main__':main()
