"""Admission checks for the node/cell layout of interpolated flexes."""
import argparse,hashlib,json,subprocess,resource
from pathlib import Path

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
 p.add_argument('--fixtures',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--model-name',default='interp1_1x1x1_plane_plain')
 a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
 name=a.model_name;model=a.fixtures/(name+'.mjb');core=a.fixtures/(name+'-core.mjb');rows=[]
 for mode in ['nodecount','nodeadr','nodebody','nodebodynegative','nodeoffset','cellzero','parametric','interpbody','bvhadr','bvhcycle','bvhleaf','bvhduplicate','shell','interp']:
  expected='UNSUPPORTED_FEATURE' if mode in ['shell','interp'] else 'INVALID_MODEL'
  command=[str(a.binary),str(model),str(core),'4096',mode]
  r=subprocess.run(command,text=True,capture_output=True,timeout=30)
  rows.append(dict(mode=mode,passed=r.returncode==0 and r.stdout.strip()=='create '+expected,
    expected=expected,exit=r.returncode,output=r.stdout+r.stderr))
 result=dict(cases=len(rows),passed=sum(r['passed'] for r in rows),records=rows,
  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),model_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),
  runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
 raise SystemExit(result['passed']!=result['cases'])
if __name__=='__main__':main()
