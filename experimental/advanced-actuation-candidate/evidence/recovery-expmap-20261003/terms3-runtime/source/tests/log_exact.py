"""Exact component comparison of quaternion Log against the pinned public C API."""
import argparse,hashlib,json,subprocess
from pathlib import Path
import mujoco,numpy as np
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
assert mujoco.__version__=='3.14.0'
rng=np.random.default_rng(3141003)
qs=[[0,0,0,0],[1,0,0,0],[-1,0,0,0],[1,1e-18,2e-18,3e-18],[-1,1e-18,2e-18,3e-18]]
for n in [0.,1e-100,1e-18,np.nextafter(1e-15,0),1e-15,np.nextafter(1e-15,np.inf),1e-14]:
 for w in [-1.,0.,1.]:qs.append([w,n,0,0]);qs.append([w,n,-n,n])
qs.extend(rng.uniform(-1,1,(512,4)).tolist());lines=[];expected=[]
for q in qs:
 vals=[*q,0,0,0,1,0,0,0,0,0,0]+[0]*114
 lines.append('7 '+' '.join(format(float(x),'.17g')for x in vals))
 out=np.zeros(3);mujoco.mju_quat2Vel(out,np.array(q,dtype=float),1.);expected.append(out.tolist())
data='\n'.join(lines)+'\n';(a.out/'input.txt').write_text(data)
r=subprocess.run([str(a.binary)],input=data,text=True,capture_output=True,timeout=30);(a.out/'output.txt').write_text(r.stdout);(a.out/'stderr.txt').write_text(r.stderr);assert r.returncode==0,(r.returncode,r.stderr,r.stdout[-2000:])
rows=r.stdout.splitlines();assert len(rows)==len(qs),(len(rows),len(qs));records=[]
for i,(line,ex)in enumerate(zip(rows,expected)):
 got=np.array(list(map(float,line.split()))[4:7]);want=np.array(ex);records.append(dict(index=i,q=qs[i],actual=got.tolist(),expected=ex,exact=bool(np.array_equal(got,want)),bit_exact=got.tobytes()==want.tobytes(),max_abs=float(np.max(np.abs(got-want)))))
sha=lambda f:hashlib.sha256(Path(f).read_bytes()).hexdigest();lib=next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
report=dict(reference=mujoco.__version__,library_sha256=sha(lib),driver_sha256=sha(__file__),binary_sha256=sha(a.binary),cases=len(records),exact=sum(r['exact']for r in records),bit_exact=sum(r['bit_exact']for r in records),records=records)
(a.out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print('exact',report['exact'],'/',report['cases'],'bit exact',report['bit_exact']);raise SystemExit(report['exact']!=report['cases'])
