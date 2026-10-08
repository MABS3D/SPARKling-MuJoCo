"""Stable CSR slots and primal JT*force against native MuJoCo 3.14.0."""
import argparse,ctypes,hashlib,json,subprocess
from pathlib import Path
import mujoco
import numpy as np


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--out',type=Path,required=True)
    a=ap.parse_args(); assert mujoco.__version__=='3.14.0'
    library=next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'));lib=ctypes.CDLL(str(library))
    dp=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS');ip=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    lib.mju_transposeSparse.argtypes=[dp,dp,ctypes.c_int,ctypes.c_int,ip,ip,ip,ctypes.c_void_p,ip,ip,ip]
    lib.mju_mulMatVecSparse.argtypes=[dp,dp,dp,ctypes.c_int,ip,ip,ip,ctypes.c_void_p]
    rng=np.random.default_rng(314100314);cases=[];lines=[]
    for count in [*range(17),31,32,33,63,127,128,129,257,1025]:
        for mode in ['random','zeros','duplicate','signed-zero']:
            for scale in [1.,1e-120,1e116]:
                n,k=7,3; widths=np.array([count,count//2,count%5],dtype=np.int32)
                offsets=np.array([2,3+count,5+count+count//2],dtype=np.int32)
                stored=int(offsets[-1]+widths[-1]);used=int(sum(widths))
                cols=rng.integers(0,n,stored,dtype=np.int32);vals=rng.uniform(-1,1,stored)*scale
                force=rng.uniform(-1,1,k)*scale
                if mode=='zeros': vals[::2]=0.
                elif mode=='duplicate': cols[:]=np.resize([6,0,6,0,1],stored)
                elif mode=='signed-zero': vals[:]=np.resize([-0.,0.,-0.,0.,0.],stored)
                tw=np.zeros(n,dtype=np.int32);to=np.zeros(n,dtype=np.int32)
                tc=np.zeros(used,dtype=np.int32);tv=np.zeros(used)
                # Native transpose receives mat/colind at rowadr[0], then
                # subtracts that base address internally. CSR gaps remain.
                first=int(offsets[0]);lib.mju_transposeSparse(tv,vals[first:],k,n,tw,to,tc,None,widths,offsets,cols[first:])
                result=np.zeros(n);lib.mju_mulMatVecSparse(result,tv,force,n,tw,to,tc,None)
                fields=[n,k,stored,*np.column_stack([offsets,widths]).ravel(),*(cols+1),*vals,*force]
                lines.append(' '.join(format(float(x),'.17g') for x in fields)+'\n')
                cases.append(dict(count=count,mode=mode,scale=scale,used=used,
                    metadata=np.r_[np.column_stack([to,tw]).ravel(),tc+1],values=np.r_[tv,result]))
    a.out.mkdir(parents=True,exist_ok=False);payload=''.join(lines);(a.out/'input.txt').write_text(payload)
    run=subprocess.run([str(a.binary)],input=payload,text=True,capture_output=True,timeout=90)
    (a.out/'output.txt').write_text(run.stdout+run.stderr);assert run.returncode==0,run.stderr
    output=run.stdout.splitlines();assert len(output)==len(cases)
    records=[]
    for line,c in zip(output,cases):
        got=np.fromstring(line,sep=' ');meta=c.pop('metadata');values=c.pop('values');m=len(meta)
        ok=bool(np.array_equal(got[:m],meta) and np.array_equal(got[m:].view(np.uint64),values.view(np.uint64)))
        records.append(dict(**c,passed=ok,metadata=meta.tolist(),native=values.tolist(),ada=got[m:].tolist()))
    failures=[r for r in records if not r['passed']]
    report=dict(reference=mujoco.__version__,cases=len(cases),passed=len(cases)-len(failures),records=records,failures=failures,
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (a.out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(report['passed'],'/',report['cases'],'bitwise native transpose + primal force')
    raise SystemExit(bool(failures))
if __name__=='__main__':main()
