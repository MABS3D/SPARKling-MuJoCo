"""Build unchanged stable C Jacobian bodies against the official shared library."""
import ctypes
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import mujoco
import numpy as np

PIN = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'


def function(text,marker):
    start = text.index(marker); brace = text.index('{',start); depth = 0
    for i in range(brace,len(text)):
        if text[i] == '{': depth += 1
        elif text[i] == '}': depth -= 1
        if depth == 0: return text[start:i+1]
    raise ValueError(marker)


def load(out):
    lib = ctypes.CDLL(str(out / 'reference.so'))
    fp = np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')
    ip = np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    lib.response.argtypes = [ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ip,fp,fp,fp,ip,fp,ip]
    lib.response.restype = ctypes.c_int
    lib.project.argtypes = [fp,fp,fp,ctypes.c_int]
    return lib


def build(root,out):
    out.mkdir(parents=True,exist_ok=False)
    ref = root / 'mujoco'
    if mujoco.__version__ != '3.14.0' or subprocess.check_output(
            ['git','-C',str(ref),'rev-parse','HEAD'],text=True).strip() != PIN:
        raise RuntimeError('reference pin mismatch')
    hashes = {}; bodies = []
    for path, markers in [('src/engine/engine_core_util.c', ['int mj_bodyChain(',
            'void mj_jacSparse(', 'void mj_jacSparseSimple(', 'int mj_jacSum(']),
            ('src/engine/engine_util_sparse.c', ['int mju_addToSparseMat('])]:
        source = (ref / path).read_text()
        pinned = subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+path]).decode().replace('\r\n','\n')
        if source != pinned: raise RuntimeError('reference changed: '+path)
        hashes[path] = hashlib.sha256((ref / path).read_bytes()).hexdigest()
        bodies += [function(source,m) for m in markers]
    source = out / 'reference.c'
    source.write_text('''// Unchanged function bodies: Copyright 2021 DeepMind Technologies Limited.
// Apache-2.0: https://www.apache.org/licenses/LICENSE-2.0
#include <stdlib.h>
#include <mujoco/mujoco.h>
#include "engine/engine_core_util.h"
#include "engine/engine_inline.h"
#include "engine/engine_memory.h"
#include "engine/engine_util_blas.h"
#include "engine/engine_util_errmem.h"
#include "engine/engine_util_misc.h"
#include "engine/engine_util_sparse.h"
#include "engine/engine_util_spatial.h"
'''+'\n\n'.join(bodies)+'''
// Harness wrapper exposes the operands consumed by the unchanged mj_jacSum.
int response(const mjModel* m, mjData* d, int n, const int* body, const double* weight,
             const double* point, double* parts, int* present, double* sum, int* chain) {
  int nv=m->nv, sparse=mj_isSparse(m);
  double* tmp=calloc(6*nv,sizeof(double));
  int* bc=calloc(nv,sizeof(int));
  if (!tmp || !bc) abort();
  for(int i=0;i<n;i++) {
    if(sparse) {
      int bn=mj_bodyChain(m,body[i],bc);
      if(!bn) continue;
      if(m->body_simple[body[i]])
        mj_jacSparseSimple(m,d,tmp,tmp+3*bn,point,body[i],1,bn,0);
      else mj_jacSparse(m,d,tmp,tmp+3*bn,point,body[i],bn,bc,0);
      for(int c=0;c<bn;c++) {
        present[i*nv+bc[c]]=1;
        for(int r=0;r<6;r++) parts[(i*6+r)*nv+bc[c]]=tmp[r*bn+c];
      }
    } else {
      mj_jac(m,d,parts+i*6*nv,parts+i*6*nv+3*nv,point,body[i]);
      for(int c=0;c<nv;c++) present[i*nv+c]=1;
    }
  }
  int nn=mj_jacSum(m,d,chain,n,body,weight,point,sum,sum+3*nv,1);
  if(!sparse) for(int c=0;c<nv;c++) chain[c]=c;
  free(tmp);free(bc);return nn;
}
void project(double* out,const double* frame,const double* source,int n) {
  mju_mulMatMat(out,frame,source,3,3,n);
}
''')
    wheel = Path(mujoco.__file__).parent; library = wheel / 'libmujoco.so.3.14.0'
    command = ['gcc','-std=c11','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
        '-MMD','-MF',str(out / 'reference.d'),'-I'+str(ref / 'include'),'-I'+str(ref / 'src'),
        str(source),str(library),'-Wl,-rpath,'+str(wheel),'-o',str(out / 'reference.so')]
    r = subprocess.run(command,capture_output=True,text=True)
    (out / 'build.log').write_text(r.stdout+r.stderr)
    if r.returncode: raise RuntimeError(r.stderr)
    for dep in shlex.split((out / 'reference.d').read_text().replace('\\\n',' ').split(':',1)[1]):
        p = Path(dep)
        if p.is_relative_to(ref):
            rel = str(p.relative_to(ref)); original = subprocess.check_output(
                ['git','-C',str(ref),'show',PIN+':'+rel]).decode().replace('\r\n','\n')
            if p.read_text() != original: raise RuntimeError('changed header: '+rel)
            hashes[rel] = hashlib.sha256(p.read_bytes()).hexdigest()
    (out / 'manifest.json').write_text(json.dumps(dict(reference=PIN,version=mujoco.__version__,
        command=command,sources=hashes,body_sha256=hashlib.sha256('\n\n'.join(bodies).encode()).hexdigest(),
        wrapper_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        compiler=subprocess.check_output(['gcc','--version'],text=True)),indent=2)+'\n')
    return load(out)
