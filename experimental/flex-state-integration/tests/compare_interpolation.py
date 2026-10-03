"""Exact binary64 comparison of cell lookup, array basis and nodal interpolation."""
import argparse,ctypes,hashlib,json,subprocess
from pathlib import Path
import mujoco
import numpy as np

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
 p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 if mujoco.__version__!='3.14.0':raise RuntimeError('wrong reference')
 library=Path(mujoco.__file__).parent/'libmujoco.so.3.14.0';lib=ctypes.CDLL(str(library))
 fp=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')
 ip=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
 lib.mju_cellLookup.argtypes=[fp,ip,ctypes.c_int,fp,ip];lib.mju_cellLookup.restype=ctypes.c_int
 lib.mju_evalBasisArray.argtypes=[fp,fp,ctypes.c_int];lib.mju_evalBasisArray.restype=None
 lib.mju_interpolate3D.argtypes=[fp,fp,fp,ctypes.c_int,ip];lib.mju_interpolate3D.restype=None
 rng=np.random.default_rng(2026100317);cases=[];lines=[]
 for degree in (1,2):
  for grid in [(1,1,1),(2,3,4),(4,1,2),(1,7,1),(8,8,8),(4096,1,1)]:
   cells=np.array(grid,dtype=np.int32);n=int(np.prod(cells*degree+1))
   coords=[np.zeros(3),np.ones(3),np.array([-.1,1.1,.5]),np.array([-0.,0.,1.]),
     np.array([.25,.5,.75]),np.nextafter(1/cells,0),np.nextafter(1/cells,1),
     *rng.uniform(0,1,(12,3))]
   for sample,coord in enumerate(coords):
    scale=1.e10 if sample%5==0 else 1.
    nodes=np.ascontiguousarray(rng.uniform(-scale,scale,(n,3)))
    local=np.zeros(3);indices=np.zeros(27,dtype=np.int32)
    count=lib.mju_cellLookup(coord,cells,degree,local,indices)
    basis=np.zeros(27);lib.mju_evalBasisArray(basis,local,degree)
    result=np.zeros(3);lib.mju_interpolate3D(result,local,nodes,degree,indices)
    cases.append(dict(degree=degree,grid=grid,sample=sample,
      expected=dict(indices=indices[:count].tolist(),local=local.tolist(),basis=basis[:count].tolist(),result=result.tolist())))
    lines.extend([' '.join(map(str,[degree,*grid,*coord])), ' '.join(format(float(x),'.17g') for x in nodes.ravel())])
 text=str(len(cases))+'\n'+'\n'.join(lines)+'\n';(a.out/'input.txt').write_text(text)
 (a.out/'expected.json').write_text(json.dumps(cases,indent=2)+'\n')
 run=subprocess.run([str(a.binary)],input=text,text=True,capture_output=True,timeout=120)
 (a.out/'output.txt').write_text(run.stdout+run.stderr);actual=[]
 for line in run.stdout.splitlines():
  if line=='case':actual.append({})
  elif actual:
   k,_,v=line.partition(' ');actual[-1][k]=np.fromstring(v,sep=' ',dtype=np.int32 if k=='indices' else np.float64)
 records=[]
 for expected,observed in zip(cases,actual):
  checks={}
  for key,values in expected['expected'].items():
   x=np.asarray(values,dtype=np.int32 if key=='indices' else np.float64);y=observed.get(key,np.array([]))
   checks[key]=bool(x.shape==y.shape and np.array_equal(x if key=='indices' else x.view(np.uint64),y if key=='indices' else y.view(np.uint64)))
  records.append({k:expected[k] for k in ('degree','grid','sample')}|dict(checks=checks,passed=all(checks.values())))
 ok=run.returncode==0 and len(records)==len(cases) and all(r['passed'] for r in records)
 result=dict(passed=ok,exit=run.returncode,expected=len(cases),cases=len(records),exact=sum(r['passed'] for r in records),records=records,
  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
  runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),reference=mujoco.__version__,
  inputs_sha256=hashlib.sha256(text.encode()).hexdigest(),limits='Finite bitwise comparisons, not universal equivalence or integrated movement.')
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['exact'],result['expected'],ok)
 raise SystemExit(not ok)
if __name__=='__main__':main()
