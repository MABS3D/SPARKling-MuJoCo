from pathlib import Path
import argparse,hashlib,json,os,subprocess,datetime,sys
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--mode',choices=['validation','release'],required=True);a=p.parse_args();r=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');m=json.loads((a.build/'manifest.json').read_text())
def check():
 for n,h in m['sources'].items():assert hashlib.sha256((a.build/'source'/n).read_bytes()).hexdigest()==h,n
check();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy();env['PATH']=':'.join(str(next((tc/n).glob('*/bin'))) for n in ['gnat','gprbuild','gnatprove'])+':'+env['PATH'];env['DERIVATIVES_BUILD_ROOT']=str(a.build/'build');env['DERIVATIVES_MODE']=a.mode
cmd=[sys.executable,str(r/'tools/guarded.py'),'--cap-mb','3000','--timeout','360','--','gprbuild','-P',str(a.build/'source/experimental/dynamics-derivatives-candidate/derivatives.gpr'),'-j1']
log=a.build/('build-'+a.mode+'.log')
with log.open('w') as f:run=subprocess.run(cmd,env=env,stdout=f,stderr=subprocess.STDOUT)
check();(a.build/('build-'+a.mode+'-result.json')).write_text(json.dumps({'command':cmd,'exit':run.returncode,'sources_before_after_identical':True,'driver_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'time_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()},indent=2)+'\n');print(log,run.returncode)
if run.returncode:print(log.read_text()[-4000:])
sys.exit(run.returncode)
