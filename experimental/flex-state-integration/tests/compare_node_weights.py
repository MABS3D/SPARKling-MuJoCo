"""Pinned, unchanged private C body; bitwise nodal endpoint comparison."""
import argparse,ctypes,hashlib,json,shlex,subprocess
from pathlib import Path
import mujoco
import numpy as np
PIN='9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'

def function(text,marker):
 start=text.index(marker);brace=text.index('{',start);depth=0
 for i in range(brace,len(text)):
  if text[i]=='{':depth+=1
  elif text[i]=='}':depth-=1
  if depth==0:return text[start:i+1]
 raise ValueError(marker)

def reference(root,out):
 ref=root/'mujoco';path='src/engine/engine_core_constraint.c'
 if mujoco.__version__!='3.14.0':raise RuntimeError('wrong reference')
 if subprocess.check_output(['git','-C',str(ref),'rev-parse','HEAD'],text=True).strip()!=PIN:raise RuntimeError('wrong pin')
 source=(ref/path).read_text();pinned=subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+path]).decode().replace('\r\n','\n')
 if source!=pinned:raise RuntimeError('reference source changed')
 body=function(source,'static int mj_vertBodyWeight(')
 src=out/'reference.c';src.write_text('''// Unchanged extract: Copyright 2021 DeepMind Technologies Limited.
// Apache-2.0: https://www.apache.org/licenses/LICENSE-2.0
#include <mujoco/mujoco.h>
#include "engine/engine_util_blas.h"
#include "engine/engine_util_misc.h"
#include "engine/engine_util_spatial.h"
'''+body+'''
int weights(int degree, const int* cells, const double* vertices, const double* weights,
            int nw, int* nodebodies, int* bodies, double* result, double* coord) {
  mjModel m = {0}; int start=0, v[4]={0,1,2,3};
  m.flex_interp=&degree; m.flex_cellnum=(int*)cells; m.flex_nodeadr=&start;
  m.flex_vert0=(double*)vertices; m.flex_nodebodyid=nodebodies;
  coord[0]=coord[1]=coord[2]=0;
  for(int i=0;i<nw;i++)mju_addToScl3(coord,vertices+3*i,mju_abs(weights[i]));
  return mj_vertBodyWeight(&m,0,0,v,bodies,result,weights,nw);
}
''')
 wheel=Path(mujoco.__file__).parent;library=wheel/'libmujoco.so.3.14.0'
 cmd=['gcc','-std=c11','-O3','-march=native','-ffp-contract=off','-fPIC','-shared','-MMD','-MF',str(out/'reference.d'),'-I'+str(ref/'include'),'-I'+str(ref/'src'),str(src),str(library),'-Wl,-rpath,'+str(wheel),'-o',str(out/'reference.so')]
 r=subprocess.run(cmd,capture_output=True,text=True);(out/'reference-build.log').write_text(r.stdout+r.stderr)
 if r.returncode:raise RuntimeError(r.stderr)
 hashes={path:hashlib.sha256((ref/path).read_bytes()).hexdigest()}
 for dep in shlex.split((out/'reference.d').read_text().replace('\\\n',' ').split(':',1)[1]):
  p=Path(dep)
  if p.is_relative_to(ref):
   rel=str(p.relative_to(ref));original=subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+rel]).decode().replace('\r\n','\n')
   if p.read_text()!=original:raise RuntimeError('changed header '+rel)
   hashes[rel]=hashlib.sha256(p.read_bytes()).hexdigest()
 (out/'reference.json').write_text(json.dumps(dict(commit=PIN,version=mujoco.__version__,sources=hashes,command=cmd,compiler=subprocess.check_output(['gcc','--version'],text=True),body_sha256=hashlib.sha256(body.encode()).hexdigest(),wrapper_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),library_sha256=hashlib.sha256(library.read_bytes()).hexdigest()),indent=2)+'\n')
 lib=ctypes.CDLL(str(out/'reference.so'));fp=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS');ip=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
 lib.weights.argtypes=[ctypes.c_int,ip,fp,fp,ctypes.c_int,ip,ip,fp,fp];lib.weights.restype=ctypes.c_int
 return lib

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 lib=reference(a.root,a.out);rng=np.random.default_rng(202610037);cases=[];lines=[]
 for degree in (1,2):
  for grid in [(1,1,1),(2,3,1),(3,2,4)]:
   cells=np.array(grid,dtype=np.int32);nn=int(np.prod(cells*degree+1))
   fixtures=[('empty',np.zeros((4,3)),np.zeros(4),0),('center',np.full((4,3),.5),np.array([1.,0,0,0]),1),('quarter',np.full((4,3),.25),np.array([1.,0,0,0]),1),('negativezero',np.zeros((4,3)),np.array([-0.,1.,0,0]),2),('outside',np.tile([-.2,1.2,.5],(4,1)),np.array([1.,0,0,0]),1)]
   for x in [np.nextafter(1e-5,0),1e-5,np.nextafter(1e-5,1),1e-6,.1,.5,.9,1.]:
    fixtures.append(('cutoff-'+repr(x),np.tile([x,0,0],(4,1)),np.array([1.,0,0,0]),1))
   for i in range(30):
    count=i%4+1;vw=np.zeros(4);vw[:count]=rng.dirichlet(np.ones(count))
    fixtures.append(('random-'+str(i),rng.uniform(0,1,(4,3)),vw,count))
   for mode in ('distinct','duplicates','all-world'):
    nodebodies=np.arange(nn,dtype=np.int32)+10 if mode=='distinct' else (rng.integers(0,6,nn,dtype=np.int32) if mode=='duplicates' else np.zeros(nn,dtype=np.int32))
    for name,vertices,vw,count in fixtures:
     for sign in (1,-1):
      weights=np.ascontiguousarray(vw*sign);vertices=np.ascontiguousarray(vertices);bodies=np.zeros(27,dtype=np.int32);bw=np.zeros(27);coord=np.zeros(3)
      nb=lib.weights(degree,cells,vertices,weights,count,nodebodies,bodies,bw,coord)
      case=dict(degree=degree,grid=grid,mode=mode,name=name,sign=sign,count=count,expected=dict(coord=coord.tolist(),bodies=bodies[:nb].tolist(),weights=bw[:nb].tolist()))
      cases.append(case);lines.append(' '.join(map(str,[degree,*grid,count,*vertices.ravel(),*weights,*nodebodies])))
 text=str(len(cases))+'\n'+'\n'.join(lines)+'\n';(a.out/'input.txt').write_text(text);(a.out/'expected.json').write_text(json.dumps(cases,indent=2)+'\n')
 r=subprocess.run([str(a.binary)],input=text,text=True,capture_output=True,timeout=120);(a.out/'output.txt').write_text(r.stdout+r.stderr);actual=[]
 for line in r.stdout.splitlines():
  if line=='case':actual.append({})
  elif actual:
   k,_,v=line.partition(' ');actual[-1][k]=np.fromstring(v,sep=' ',dtype=np.int32 if k=='bodies' else np.float64)
 records=[]
 for c,obs in zip(cases,actual):
  checks={}
  for k,v in c['expected'].items():
   x=np.asarray(v,dtype=np.int32 if k=='bodies' else np.float64);y=obs.get(k,np.array([]))
   checks[k]=bool(x.shape==y.shape and np.array_equal(x if k=='bodies' else x.view(np.uint64),y if k=='bodies' else y.view(np.uint64)))
  records.append({k:v for k,v in c.items() if k!='expected'}|dict(checks=checks,passed=all(checks.values())))
 ok=r.returncode==0 and len(records)==len(cases) and all(x['passed'] for x in records)
 result=dict(passed=ok,exit=r.returncode,expected=len(cases),exact=sum(x['passed'] for x in records),records=records,max_output_bodies=max(len(c['expected']['bodies']) for c in cases),max_abs_weight_sum=max(sum(abs(x) for x in c['expected']['weights']) for c in cases),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),input_sha256=hashlib.sha256(text.encode()).hexdigest(),limits='Positive interpolation orders 1/2, finite bitwise corpus; no shell or integrated dynamics claim.')
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['exact'],result['expected'],ok,flush=True);raise SystemExit(not ok)
if __name__=='__main__':main()
