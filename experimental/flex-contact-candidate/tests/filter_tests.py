#!/usr/bin/env python3
"""Exact order against the unedited 3.14.0 C filter body, including its quirks.

Only stack allocation and arena bookkeeping are stubbed. Independent full
engine differential trajectories are covered by compare.py, not this harness.
"""
from pathlib import Path
import argparse, ctypes, hashlib, json, os, re, subprocess
import numpy as np
from check import ROOT, environment, digest
from compare import numbers

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--exe',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    a.exe=a.exe.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=True);os.chdir(out)
    source=ROOT/'mujoco/src/engine/engine_collision_driver.c'
    model_header=ROOT/'mujoco/include/mujoco/mjmodel.h'
    type_header=ROOT/'mujoco/include/mujoco/mjtype.h'
    assert re.search(r'#define\s+mjMAXCONPAIR\s+50\b',model_header.read_text())
    assert re.search(r'#define\s+mjMAXVAL\s+1E\+10\s',type_header.read_text())
    reference=source.read_text();start=reference.index('static void filterFlexContacts(')
    end=reference.index('\n}\n',start)+2;body=reference[start:end]
    # Retain the upstream copyright and license notice on the extracted body.
    c=reference.split('#include',1)[0]+'''#include <stdlib.h>
#include <string.h>
typedef double mjtNum;
typedef unsigned char mjtByte;
typedef struct { double dist, pos[3]; int id; } mjContact;
typedef struct { int ncon; mjContact* contact; } mjData;
#define mjMAXCONPAIR 50
#define mjMAXVAL 1e10
#define mjSTACKALLOC(d,n,T) ((T*)__builtin_alloca((n)*sizeof(T)))
#define mj_markStack(d) ((void)0)
#define mj_freeStack(d) ((void)0)
#define resetArena(d) ((void)0)
'''+body+'''
int reference_filter(int n, const double* dist, const double* pos, int* ids) {
  mjContact* contacts = calloc(n+3, sizeof(mjContact));
  if (!contacts) return -1;
  for (int i=0; i<3; ++i) contacts[i].id = -100-i;
  for (int i=0; i<n; ++i) {
    contacts[i+3].id=i+1; contacts[i+3].dist=dist[i];
    memcpy(contacts[i+3].pos, pos+3*i, 3*sizeof(double));
  }
  mjData data = {n+3, contacts};
  filterFlexContacts(&data, 3);
  int count=data.ncon-3;
  for (int i=0; i<count; ++i) ids[i]=contacts[i+3].id;
  for (int i=0; i<3; ++i) if(contacts[i].id != -100-i) count=-2;
  free(contacts); return count;
}
'''
    (out/'reference.c').write_text(c);lib=out/'reference.so'
    cmd=['gcc','-shared','-fPIC','-O3','-march=native','-ffp-contract=off',str(out/'reference.c'),'-o',str(lib)]
    subprocess.run(cmd,env=environment(),check=True,capture_output=True)
    fn=ctypes.CDLL(str(lib)).reference_filter
    arr=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')
    ints=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    fn.argtypes=[ctypes.c_int,arr,arr,ints];fn.restype=ctypes.c_int
    rng=np.random.default_rng(93050);records=[]
    for n in [0,1,2,49,50,51,64,128,4096]:
        for mode in ['random','ties','coincident','saturated','deepest_last','signed_zero']:
            dist=rng.uniform(-.1,.1,n);pos=rng.uniform(-10.,10.,(n,3))
            if mode=='ties':dist[:]=0.;pos=np.column_stack((np.arange(n)%17,np.arange(n)//17,np.zeros(n))).astype(float)
            if mode=='coincident':pos[:]=.5;dist[:]=0.
            if mode=='saturated':pos*=1e10
            if mode=='deepest_last' and n:dist[:]=0.;dist[-1]=-1.
            if mode=='signed_zero':pos[:]=0.;pos[::2]=-0.;dist[:]=0.;dist[::2]=-0.
            expected=np.zeros(max(n,1),dtype=np.int32)
            count=fn(n,dist,pos,expected);assert 0<=count<=50
            text=str(n)+'\n'+'\n'.join(numbers([dist[i],*pos[i]]) for i in range(n))+'\n'
            p=subprocess.run([str(a.exe),'filter'],input=text,text=True,capture_output=True,check=True)
            got=list(map(int,p.stdout.split()[1:]));assert got==expected[:count].tolist(),(n,mode,got,expected[:count])
            assert len(got)==min(n,50) and len(set(got))==len(got)
            name=f'{mode}-{n}';(out/(name+'.input')).write_text(text);(out/(name+'.output')).write_text(p.stdout)
            records.append(dict(n=n,mode=mode,ids=got))
    (out/'results.json').write_text(json.dumps(dict(cases=records,passed=True,
        source=str(source.relative_to(ROOT)),source_sha256=digest(source),
        header_sha256={str(p.relative_to(ROOT)):digest(p) for p in [model_header,type_header]},
        filter_body_sha256=hashlib.sha256(body.encode()).hexdigest(),
        command=cmd,library_sha256=digest(lib),ada_sha256=digest(a.exe)),indent=2))
    print(f'{len(records)} exact C filter-order cases passed')
if __name__=='__main__':main()
