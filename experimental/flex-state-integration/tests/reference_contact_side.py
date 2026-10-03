"""Stable private element/vertex body-weight bodies for owned contact sides."""
import ctypes
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import mujoco
import numpy as np
from reference_response import function, PIN


def load(out):
    lib = ctypes.CDLL(str(out / 'reference.so'))
    fp = np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')
    ip = np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    lib.side.argtypes = [ctypes.c_void_p,ctypes.c_void_p,*[ctypes.c_int]*5,fp,ip,fp]
    lib.side.restype = ctypes.c_int
    return lib


def build(root,out):
    out.mkdir(parents=True,exist_ok=False)
    ref = root / 'mujoco'; path = 'src/engine/engine_core_constraint.c'
    if mujoco.__version__ != '3.14.0' or subprocess.check_output(
            ['git','-C',str(ref),'rev-parse','HEAD'],text=True).strip() != PIN:
        raise RuntimeError('wrong reference')
    source = (ref / path).read_text()
    original = subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+path]).decode().replace('\r\n','\n')
    if source != original: raise RuntimeError('changed C source')
    bodies = '\n\n'.join(function(source,m) for m in ('static int mj_elemBodyWeight(','static int mj_vertBodyWeight('))
    c = out / 'reference.c'
    c.write_text('''// Unchanged bodies: Copyright 2021 DeepMind Technologies Limited.
// Apache-2.0: https://www.apache.org/licenses/LICENSE-2.0
#include <mujoco/mujoco.h>
#include "engine/engine_util_blas.h"
#include "engine/engine_util_errmem.h"
#include "engine/engine_util_misc.h"
#include "engine/engine_util_spatial.h"
'''+bodies+'''
// Harness dispatch mirrors one side in mj_contactJacobian or mj_diagApprox.
int side(const mjModel* m,const mjData* d,int f,int e,int v,int opp,int negative,
         const double* point,int* body,double* weight) {
  int nw,vid[4]; double vw[4];
  if(v>=0) { nw=1;vid[0]=m->flex_vertadr[f]+v;vw[0]=negative ? -1 : 1; }
  else {
    nw=mj_elemBodyWeight(m,d,f,e,opp,point,vid,vw);
    if(negative)mju_scl(vw,vw,-1,nw);
  }
  if(m->flex_interp[f])return mj_vertBodyWeight(m,d,f,vid,body,weight,vw,nw);
  for(int k=0;k<nw;k++){body[k]=m->flex_vertbodyid[vid[k]];weight[k]=vw[k];}
  return nw;
}
''')
    wheel = Path(mujoco.__file__).parent; library = wheel / 'libmujoco.so.3.14.0'
    cmd = ['gcc','-std=c11','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
        '-MMD','-MF',str(out / 'reference.d'),'-I'+str(ref / 'include'),'-I'+str(ref / 'src'),
        str(c),str(library),'-Wl,-rpath,'+str(wheel),'-o',str(out / 'reference.so')]
    r = subprocess.run(cmd,capture_output=True,text=True);(out / 'build.log').write_text(r.stdout+r.stderr)
    if r.returncode: raise RuntimeError(r.stderr)
    hashes = {path:hashlib.sha256((ref / path).read_bytes()).hexdigest()}
    for dep in shlex.split((out / 'reference.d').read_text().replace('\\\n',' ').split(':',1)[1]):
        p = Path(dep)
        if p.is_relative_to(ref):
            rel = str(p.relative_to(ref)); text = subprocess.check_output(
                ['git','-C',str(ref),'show',PIN+':'+rel]).decode().replace('\r\n','\n')
            if p.read_text() != text: raise RuntimeError('changed header: '+rel)
            hashes[rel] = hashlib.sha256(p.read_bytes()).hexdigest()
    (out / 'manifest.json').write_text(json.dumps(dict(reference=PIN,version=mujoco.__version__,sources=hashes,
        body_sha256=hashlib.sha256(bodies.encode()).hexdigest(),wrapper_sha256=hashlib.sha256(c.read_bytes()).hexdigest(),
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),command=cmd),indent=2)+'\n')
    return load(out)
