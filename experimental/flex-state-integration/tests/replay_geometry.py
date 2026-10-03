"""Replay saved states against their frozen C vertex/contact oracle."""
import argparse,hashlib,json,resource,subprocess
from pathlib import Path
import numpy as np
import compare

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
 p.add_argument('--fixtures',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--only',default='');a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
 records=[];hashes={}
 for inp in sorted(a.fixtures.glob('*.input')):
  if inp.name.endswith('.pending.input') or a.only not in inp.stem:continue
  name=inp.stem;expected_path=a.fixtures/(name+'.expected.json')
  model=a.fixtures/(name+'.mjb');core=a.fixtures/(name+'-core.mjb')
  expected=json.loads(expected_path.read_text())
  for f in [inp,expected_path,model,core]:hashes[f.name]=hashlib.sha256(f.read_bytes()).hexdigest()
  r=subprocess.run([str(a.binary),str(model),str(core)],input=inp.read_text(),text=True,capture_output=True,timeout=180)
  (a.out/(name+'.output')).write_text(r.stdout+r.stderr)
  actual=compare.parse(r.stdout) if r.returncode==0 else []
  if len(actual)!=len(expected):records.append(dict(model=name,passed=False,error='probe/sample count',exit=r.returncode))
  for i,(x,y) in enumerate(zip(actual,expected)):
   # Saved older oracles contain geometry only. Keep node API checks in the
   # fresh full harness rather than fabricate nodal reference values here.
   b=dict(vertices={(v['flex'],v['vertex']):np.array(v['position']) for v in y['vertices']},
     contacts=[(tuple(c['key']),np.array(c['values'])) for c in y['contacts']])
   errors,ve,ce=compare.compare(x,b,check_nodes=False)
   records.append(dict(model=name,sample=i,passed=not errors,errors=errors,vertex_abs_error=ve,contact_abs_error=ce))
  print(name,all(row['passed'] for row in records if row['model']==name),flush=True)
 result=dict(cases=len(records),passed=sum(r['passed'] for r in records),records=records,
  fixtures=str(a.fixtures),input_sha256=hashes,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
  runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
  scope='Replay exact saved states and C oracle: vertices and contacts only; no claim for newly emitted node metadata.')
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'])
 raise SystemExit(result['passed']!=result['cases'])
if __name__=='__main__':main()
