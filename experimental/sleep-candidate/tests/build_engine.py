#!/usr/bin/env python3
"""Freeze the complete owned smooth sleep-entry source closure."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
from check import environment
HERE=Path(__file__).resolve().parents[1];ROOT=HERE.parents[1]
FOLDERS=['src','src/gen','experimental/smooth/src','experimental/spatial-tendon-candidate/src','experimental/muscle-candidate/src','experimental/sleep-candidate/src','experimental/sleep-candidate/tests']
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',choices=['validation','release'],default='validation');p.add_argument('--resume',action='store_true');p.add_argument('--frozen',action='store_true');a=p.parse_args()
    if a.resume and a.frozen:p.error('--resume and --frozen are exclusive')
    a.out.mkdir(parents=True,exist_ok=a.resume or a.frozen);snap=a.out/'source';hashes=json.loads((a.out/'manifest.json').read_text())['sources'] if a.resume or a.frozen else {}
    for folder in ([] if a.frozen else FOLDERS[-2:] if a.resume else FOLDERS):
        for f in (ROOT/folder).iterdir():
            if f.is_file() and f.suffix in ['.ads','.adb','.py','.c']:
                dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(f,dest)
                hashes[str(f.relative_to(ROOT))]=hashlib.sha256(dest.read_bytes()).hexdigest()
    project=snap/'experimental/sleep-candidate/engine.gpr'
    if not a.frozen:
        shutil.copyfile(HERE/'engine.gpr',project)
        hashes['experimental/sleep-candidate/engine.gpr']=hashlib.sha256(project.read_bytes()).hexdigest()
    assert all(hashlib.sha256((snap/f).read_bytes()).hexdigest()==h for f,h in hashes.items()), 'frozen source changed'
    changed=[f for f,h in hashes.items() if hashlib.sha256((ROOT/f).read_bytes()).hexdigest()!=h]
    if not (a.resume or a.frozen):assert not changed, 'concurrent source edits'
    env=environment();env['SLEEP_BUILD_ROOT']=str(a.out/'build');env['SLEEP_MODE']=a.mode
    cmd=['gprbuild','-P',str(project),'-j1']
    (a.out/'manifest.json').write_text(json.dumps(dict(sources=hashes,mode=a.mode,frozen=a.frozen,command=cmd,concurrently_changed_dependencies=changed),indent=2)+'\n')
    with (a.out/'build.log').open('w') as log:r=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','2600','--timeout','600','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
    print(a.out/'build.log');raise SystemExit(r.returncode)
if __name__=='__main__':main()
