"""Official C cancellation fixtures used by the Ada dense/sparse probes."""
import argparse, ctypes, hashlib, json, os
os.environ["OPENBLAS_NUM_THREADS"] = "1"
from pathlib import Path
import mujoco
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
assert mujoco.__version__=='3.14.0'
path=Path(mujoco.__file__).parent/'libmujoco.so.3.14.0';lib=ctypes.CDLL(str(path))
D=ctypes.c_double;I=ctypes.c_int;PD=ctypes.POINTER(D);PI=ctypes.POINTER(I)
lib.mju_dot.argtypes=[PD,PD,I];lib.mju_dot.restype=D
lib.mju_mulMatVecSparse.argtypes=[PD,PD,PD,I,PI,PI,PI,PI];lib.mju_mulMatVecSparse.restype=None
fixtures=[
 ('lanes',[1e8,1,-1e8,1],[1e8,1,1e8,1],2.,2.),
 ('structural_zero',[1e8,0,1,-1e8,1],[1e8,123,1,1e8,1],1.,2.),
 ('tail2',[1e8,1,1,1,-1e8,1],[1e8,1,-1,-1,1e8,1],0.,1.),
 ('tail3',[1e8,1,1,1,-1e8,1,1],[1e8,1,-1,-1,1e8,1,1],0.,2.),
]
records=[]
for name,x,y,dense_expected,sparse_expected in fixtures:
 vx=(D*len(x))(*x);vy=(D*len(y))(*y);indices=[i for i,v in enumerate(x) if v!=0]
 packed=(D*len(indices))(*(x[i] for i in indices));cols=(I*len(indices))(*indices)
 result=(D*1)();nnz=(I*1)(len(indices));adr=(I*1)(0)
 dense=lib.mju_dot(vx,vy,len(x));lib.mju_mulMatVecSparse(result,packed,vy,1,nnz,adr,cols,None)
 records.append(dict(case=name,dense=dense,sparse=result[0],passed=dense==dense_expected and result[0]==sparse_expected))
summary=dict(reference=mujoco.__version__,library_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),records=records)
(a.out/'results.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
raise SystemExit(0 if all(r['passed'] for r in records) else 1)
