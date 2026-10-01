"""Compare distances, positions, normals and tangents with native C contacts."""
import argparse
import ctypes
import itertools
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np
from common import build, KINDS
from check import pair_model, rotation

def serialize_objects(kinds,sizes,positions,mats,vertices=None,skins=None,margin=0,mode=0,repeats=1,facets=None,heightfield=None,graphs=None,seeds=None,shared_mesh=False):
    if shared_mesh and kinds != ['mesh','mesh']:raise ValueError('Shared asset requires two mesh instances')
    vertices=vertices or [[],[]];skins=skins or [0,0];facets=facets or [[],[]];graphs=graphs or [[],[]];seeds=seeds or [[],[]]
    if shared_mesh:
        equal_vertices=np.array_equal(np.asarray(vertices[0]),np.asarray(vertices[1]))
        if not equal_vertices or facets[0]!=facets[1] or graphs[0]!=graphs[1] or seeds[0]!=seeds[1]:
            raise ValueError('Shared mesh must reference identical compiled vertices, facets and graph')
    values=[mode,repeats,margin]
    for i,kind in enumerate(kinds):
        reused=shared_mesh and i==1
        vertex=vertices[i] if not reused else []
        facet=facets[i] if not reused else []
        graph=graphs[i] if not reused else []
        values += [8 if reused else KINDS[kind] if kind in KINDS else 7 if kind=='hfield' else 6,*sizes[i],*positions[i],*mats[i],skins[i],len(vertex)]
        if kind=='hfield':values += heightfield
        else:values += np.asarray(vertex).reshape(-1).tolist()
        values += [len(facet)]
        for normal,indices in facet:values += [*normal,len(indices),*indices]
        values += [len(graph)]
        if len(graph):values += [*seeds[i],*graph]
    return ' '.join(format(float(v),'.17g') if isinstance(v,(float,np.floating)) else str(v) for v in values)+'\n'

def library(out):
    lib=ctypes.CDLL(str(out/'reference.so'))
    for name in ['rigid_contacts','rigid_convex_contacts','rigid_indexed_terrain_contacts']:
        f=getattr(lib,name);f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_double,np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')];f.restype=ctypes.c_int
    return lib

def match(actual,want,tolerance=3e-7):
    if len(actual)!=len(want):return dict(reason='count',ada=len(actual),c=len(want))
    left=list(range(len(want)));errors=[]
    for a in actual:
        if not np.isfinite(a).all():return dict(reason='nonfinite')
        best=min(left,key=lambda j:np.max(np.abs(a-want[j])))
        e=np.abs(a-want[best]);scale=1+np.maximum(np.abs(a),np.abs(want[best]))
        if np.any(e>tolerance*scale):errors.append(dict(c=want[best].tolist(),ada=a.tolist(),error=e.tolist()))
        left.remove(best)
    return dict(reason='values',differences=errors) if errors else None

def run(out,samples,convex):
    lib=library(out);rng=np.random.default_rng(3141001);texts=[];expected=[];desc=[]
    kinds=list(KINDS)[1:] if convex else list(KINDS)
    for a,b in itertools.combinations_with_replacement(kinds,2):
        m,d=pair_model(a,b)
        for i in range(samples):
            sizes=np.exp(rng.uniform(-1.7,.8,(2,3)));positions=rng.uniform(-1.4,1.4,(2,3));mats=np.stack([rotation(rng),rotation(rng)])
            if i%9==0:positions[:]=0;positions[1,0]=.03
            if i%9==1:mats[:]=np.eye(3).reshape(9)
            margin=float(rng.choice([0,0,.005,.1]))
            m.geom_size[:]=sizes;d.geom_xpos[:]=positions;d.geom_xmat[:]=mats
            for k,kind in enumerate([a,b]):
                m.geom_rbound[k]=(sizes[k,0]+sizes[k,1] if kind=='capsule' else np.hypot(*sizes[k,:2]) if kind=='cylinder' else np.linalg.norm(sizes[k]) if kind=='box' else max(sizes[k]) if kind=='ellipsoid' else sizes[k,0])
            result=np.zeros(500);n=getattr(lib,'rigid_convex_contacts' if convex else 'rigid_contacts')(m._address,d._address,0,1,margin,result)
            expected.append(result[:10*n].reshape(-1,10));texts.append(serialize_objects([a,b],sizes,positions,mats,margin=margin,mode=2 if convex else 0));desc.append(dict(pair=[a,b],sample=i))
    reports={}
    for profile in ['validation','release']:
        r=subprocess.run([str(out/'build'/profile/'bin/contact_probe')],input=''.join(texts),text=True,capture_output=True,timeout=240)
        lines=r.stdout.splitlines();failures=[];native_normal_fallbacks=[];native_capsule_misses=[]
        for i,want in enumerate(expected):
            fields=lines[i].split() if i<len(lines) else ['MISSING']
            if fields[0]!='SUCCESS':error=dict(reason='status',output=fields)
            else:
                a=np.asarray(list(map(float,fields[2:]))).reshape(-1,10);error=match(a,want)
                if len(a)!=int(fields[1]):error=dict(reason='protocol')
            if error:
                # Native edge-face clipping with no polygon swaps the original
                # EPA witnesses anyway.  Verify that precise diagnosis against
                # raw native CCD, rather than exempting arbitrary normal errors.
                diagnosed=False
                if not convex and error['reason']=='values' and len(a)==len(want)==1:
                    v=texts[i].split();j=3;sizes=[];positions=[];mats=[]
                    for g in range(2):
                        sizes.append(np.array(v[j+1:j+4],float));positions.append(np.array(v[j+4:j+7],float));mats.append(np.array(v[j+7:j+16],float));j+=20
                    mm,dd=pair_model(*desc[i]['pair']);mm.geom_size[:]=sizes;dd.geom_xpos[:]=positions;dd.geom_xmat[:]=mats;raw=np.zeros(500)
                    nn=lib.rigid_convex_contacts(mm._address,dd._address,0,1,float(v[2]),raw)
                    diagnosed=(nn==1 and match(a,raw[:10].reshape(1,10),1e-10) is None
                               and np.max(np.abs(want[0,:4]-raw[:4]))<1e-10
                               and np.max(np.abs(want[0,4:7]+raw[4:7]))<1e-10)
                capsule_missed=False;gap=None
                if not convex and error['reason']=='count' and desc[i]['pair']==['capsule','box'] and len(a)>0 and len(want)==0:
                    from check import independent_capsule_box
                    from common import row,serialize
                    v=texts[i].split();j=3;rows=[]
                    for g,kind in enumerate(desc[i]['pair']):
                        rows.append(row((kind,np.array(v[j+1:j+4],float)),np.array(v[j+4:j+7],float),np.array(v[j+7:j+16],float),g+1,g+1,0,True));j+=20
                    gap=independent_capsule_box(serialize(rows,mode=2,margin=float(v[2])))
                    capsule_missed=gap<0
                record=dict(index=i,**desc[i],**error,input=texts[i])
                if capsule_missed:record['independent_decimal_gap']=gap;native_capsule_misses.append(record);continue
                (native_normal_fallbacks if diagnosed else failures).append(record)
        reports[profile]=dict(cases=len(expected),returncode=r.returncode,failures=failures,native_empty_clip_normal_flip=native_normal_fallbacks,native_capsule_box_false_negatives=native_capsule_misses)
        print(profile,'contacts',len(expected),'unexpected',len(failures),'native normal flips',len(native_normal_fallbacks),flush=True)
    name='convex-witness' if convex else 'primitive-contact'
    (out/(name+'-numerics.json')).write_text(json.dumps(reports,indent=2)+'\n')
    (out/(name+'-input.txt')).write_text(''.join(texts))
    return not any(x['returncode'] or x['failures'] for x in reports.values())

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=100);p.add_argument('--convex',action='store_true');p.add_argument('--reuse',action='store_true');a=p.parse_args();out=a.out.resolve()
    if not a.reuse:build(out)
    raise SystemExit(0 if run(out,a.samples,a.convex) else 1)
