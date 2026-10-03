import argparse,hashlib,json,subprocess
from pathlib import Path
import numpy as np, mujoco
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(exist_ok=False)
rng=np.random.default_rng(314000);cases=[]
for n in [0,1,2,3,4,5,7,16,31,64,128,256]:
 for k in range(16):
  v=rng.uniform(-1,1,(4,n))*10.**rng.uniform(-40,59,(4,n))
  if k%4==0 and n: v[1]=v[0]
  if k%4==1 and n: v[2]=-v[0];v[3]=v[1]
  cases.append(v)
for p0,b0,a0,u0 in [(0.,0.,0.,0.),(-0.,0.,-0.,-0.),(1e60,-1e60,0,0),(1e60,1e60,-1e60,1e60),(1.,2.**-53,-1.,2.**-53),(1e60,0.,1e60,-1e60)]:
 cases.append(np.array([[p0],[b0],[a0],[u0]]))
encoded=''.join(str(v.shape[1])+' '+' '.join(format(x,'.17g') for x in v.flat)+'\n' for v in cases)
(a.out/'input.txt').write_text(encoded)
r=subprocess.run([str(a.binary)],input=encoded,text=True,capture_output=True);(a.out/'output.txt').write_text(r.stdout);(a.out/'stderr.txt').write_text(r.stderr)
records=[]
for v,line in zip(cases,r.stdout.splitlines()):
 n=v.shape[1];ref=np.empty(n)
 if n:
  mujoco.mju_sub(ref,v[0],v[1]);mujoco.mju_addTo(ref,v[2]);mujoco.mju_addTo(ref,v[3])
 expected=bool(np.all(np.abs(ref)<=1e60));parts=line.split();ok=parts[0]=='TRUE';out=np.array(list(map(float,parts[1:])))
 exact=bool(not expected or(out.shape==ref.shape and np.array_equal(out.view('uint64'),ref.view('uint64'))))
 records.append(dict(n=n,accepted=ok,expected_accepted=expected,bitwise_equal=exact,passed=(ok==expected and exact)))
meta=dict(reference_version=mujoco.__version__,reference_calls=['mju_sub','mju_addTo applied','mju_addTo actuator'],binary=str(a.binary),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),input_sha256=hashlib.sha256(encoded.encode()).hexdigest(),code=r.returncode,count=len(cases),records=len(records),passed=sum(x['passed'] for x in records),cases=records)
(a.out/'results.json').write_text(json.dumps(meta,indent=2)+'\n');print({k:v for k,v in meta.items() if k!='cases'});raise SystemExit(0 if r.returncode==0 and len(records)==len(cases) and all(x['passed'] for x in records) else 1)
