"""Build another profile without refreshing or overwriting any frozen sources."""
import argparse,hashlib,json,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment

def main():
 p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',choices=['validation','release'],required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 mfile=a.build/'manifest.json';manifest=json.loads(mfile.read_text());source=a.build/'source'
 for name,h in manifest['sources'].items():
  if hashlib.sha256((source/name).read_bytes()).hexdigest()!=h:raise RuntimeError('source mismatch '+name)
 env=environment();env.update(SDF_MODE=a.mode,SDF_BUILD_ROOT=str(a.out/'build'))
 command=['/var/tmp/sparkling-movement-env/bin/python',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','360','--','gprbuild','-P',str(source/'experimental/sdf-step/sdf.gpr'),'-j1']
 receipt=dict(source_manifest=str(mfile),source_manifest_sha256=hashlib.sha256(mfile.read_bytes()).hexdigest(),sources=manifest['sources'],mode=a.mode,command=command,runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
 shutil.copyfile(Path(__file__),a.out/'build_frozen_profile.py');start=time.monotonic()
 with (a.out/'build.log').open('w') as f:r=subprocess.run(command,env=env,stdout=f,stderr=subprocess.STDOUT)
 receipt.update(exit=r.returncode,seconds=time.monotonic()-start)
 if r.returncode==0:receipt['binaries']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (a.out/'build'/a.mode/'bin').iterdir() if p.is_file()}
 (a.out/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n');print(a.out/'manifest.json',r.returncode,flush=True);raise SystemExit(r.returncode)
if __name__=='__main__':main()
