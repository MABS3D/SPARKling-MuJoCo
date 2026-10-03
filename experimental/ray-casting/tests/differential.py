"""Compare native Ada queries with official MuJoCo, including owned Model/Data poses."""
import argparse, ctypes, hashlib, json, pathlib, subprocess
import mujoco
import numpy as np
HERE=pathlib.Path(__file__).resolve().parents[1]
def digest(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def vec(v):return ' '.join(format(float(x),'.17g') for x in np.asarray(v).ravel())
def run(binary,args,data):
    r=subprocess.run([str(binary),*map(str,args)],input=data,text=True,capture_output=True,timeout=180)
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    rows=[]
    for line in r.stdout.splitlines():
        s=line.split()
        if len(s)!=6:raise RuntimeError(line)
        rows.append((s[0],int(s[1]),float(s[2]),np.array(list(map(float,s[3:])))))
    return rows
def rotation(rng):
    q=rng.normal(size=4);q/=np.linalg.norm(q);r=np.empty(9);mujoco.mju_quat2Mat(r,q);return r.reshape(3,3)
def primitives(binary,rng):
    lib=ctypes.CDLL(str(pathlib.Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'))
    ptr=ctypes.POINTER(ctypes.c_double);lib.mju_rayGeom.argtypes=[ptr,ptr,ptr,ptr,ptr,ctypes.c_int,ptr]
    lib.mju_rayGeom.restype=ctypes.c_double
    inputs=[];expected=[]
    for kind in [0,2,3,4,5,6]:
        for i in range(240):
            pos=rng.uniform(-2,2,3);r=rotation(rng);size=rng.uniform(.01,1.5,3)
            p=pos+r@rng.uniform(-2,2,3);v=r@rng.normal(size=3)*10**rng.uniform(-2,2)
            if i<18:
                p=pos.copy();p[i//6]=pos[i//6]+(i%2*2-1)*.3
                v=r[:,i//6]*(i%2*2-1)
            if kind==0 and i%9==0:size[:2]=0
            n=np.zeros(3)
            arrays=[np.ascontiguousarray(x,dtype=np.float64) for x in [pos,r.ravel(),size,p,v]]
            c=lib.mju_rayGeom(*(a.ctypes.data_as(ptr) for a in arrays),kind,n.ctypes.data_as(ptr))
            inputs.append(str(kind)+' '+vec(pos)+' '+vec(r)+' '+vec(size)+' '+vec(p)+' '+vec(v))
            expected.append((kind,c,n.copy()))
    rows=run(binary,['primitive'],str(len(inputs))+'\n'+'\n'.join(inputs)+'\n')
    assert len(rows)==len(expected);fail=[];worst=0
    for i,(a,c) in enumerate(zip(rows,expected)):
        ok=a[0]=='SUCCESS' and a[1]==c[0] and ((a[2]<0)==(c[1]<0))
        if c[1]>=0:ok=ok and np.isclose(a[2],c[1],atol=3e-11,rtol=3e-11) and np.allclose(a[3],c[2],atol=3e-11,rtol=3e-11)
        if not ok:fail.append(dict(case=i,ada=[a[0],a[1],a[2],a[3].tolist()],c=[c[0],c[1],c[2].tolist()]))
        if c[1]>=0:worst=max(worst,abs(a[2]-c[1]),np.max(abs(a[3]-c[2])))
    return dict(cases=len(expected),passed=len(expected)-len(fail),failures=fail,max_abs=float(worst))
def models():
    option='<option><flag constraint="disable"/></option>'
    primitive=''.join(f'<geom name="g{i}" type="{k}" pos="{i*1.4} 0 .5" size="'+
      ('.25 .4 .3' if k in ['box','ellipsoid'] else '.25 .4' if k in ['capsule','cylinder'] else '.25')+f'" group="{i%6}"/>'
      for i,k in enumerate(['sphere','capsule','ellipsoid','cylinder','box']))
    yield 'filters','<mujoco>'+option+'<asset><material name="hidden" rgba="1 0 0 0"/><material name="visible" rgba="1 0 0 1"/></asset><worldbody>'+primitive+\
      '<geom type="plane" size="10 10 .1"/><geom type="sphere" pos="0 0 2" size=".5" rgba="1 1 1 0"/>'+\
      '<geom type="sphere" pos="1.4 0 2" size=".5" material="hidden"/>'+\
      '<geom type="sphere" pos="2.8 0 2" size=".5" rgba="1 1 1 0" material="visible"/>'+\
      '<body pos="4 1 .4"><joint type="hinge" axis="0 1 0"/><geom type="capsule" size=".3 .6" euler="20 30 40" pos=".3 0 .2" group="2"/></body></worldbody></mujoco>'
    yield 'tie','<mujoco>'+option+'<worldbody><geom type="sphere" size=".4"/><geom type="sphere" size=".4"/></worldbody></mujoco>'
    for joint in ['hinge','slide','ball','free']:
        j='<freejoint/>' if joint=='free' else f'<joint type="{joint}"/>'
        yield joint,'<mujoco>'+option+'<worldbody><geom type="plane" size="0 0 .1"/>'+\
          '<body pos=".2 -.3 .8" euler="20 30 40">'+j+'<geom type="box" size=".3 .2 .4" pos=".1 .3 -.1" euler="50 15 -20"/></body></worldbody></mujoco>'
    vertices='-1 -1 -1  1 -1 -1  1 1 -1  -1 1 -1  -1 -1 1  1 -1 1  1 1 1  -1 1 1'
    faces='0 2 1 0 3 2 4 5 6 4 6 7 0 1 5 0 5 4 1 2 6 1 6 5 2 3 7 2 7 6 3 0 4 3 4 7'
    yield 'mesh','<mujoco>'+option+f'<asset><mesh name="cube" vertex="{vertices}" face="{faces}" scale=".3 .5 .4"/></asset>'+\
      '<worldbody><body pos=".2 .1 .8" euler="23 14 51"><freejoint/><geom type="mesh" mesh="cube" pos=".3 .1 .2" euler="12 34 56"/></body></worldbody></mujoco>'
    for name in ['terrain_flat','terrain_variable']:
        yield name,'<mujoco>'+option+'<asset><hfield name="h" nrow="6" ncol="7" size="2 1.5 1 .3"/></asset>'+\
          '<worldbody><geom type="hfield" hfield="h" pos=".2 .1 .3" euler="12 18 23"/></worldbody></mujoco>'
def scenes(binary,out,rng):
    records=[];failures=[];worst=0
    for name,xml in models():
        m=mujoco.MjModel.from_xml_string(xml)
        if name.startswith('terrain'):m.hfield_data[:]=.4 if name.endswith('flat') else rng.uniform(0,1,len(m.hfield_data))
        path=out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(out/(name+'.xml')).write_text(xml)
        frames=5;nrays=144;parts=[f'{frames} {nrays} 1'];expected=[]
        for f in range(frames):
            q=m.qpos0.copy()
            if f and m.nv:mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.2*f)
            d=mujoco.MjData(m);d.qpos[:]=q;mujoco.mj_forward(m,d);parts.append(vec(q))
            for i in range(nrays):
                g=i%m.ngeom
                p=d.geom_xpos[g]+rng.uniform(-3,3,3);v=rng.normal(size=3)
                if i%2==0:v=d.geom_xpos[g]-p
                if i%13==0:p=d.geom_xpos[g].copy();v=np.eye(3)[i%3].copy()
                static=i%4!=0;exclude=int(m.geom_bodyid[g]) if i%7==0 else -1
                group=np.array([(i+j)%3!=0 for j in range(6)],dtype=np.uint8) if i%3==0 else None
                n=np.zeros(3);gid=np.array([-1],dtype=np.int32)
                distance=mujoco.mj_ray(m,d,p,v,group,static,exclude,gid,n)
                parts.append(vec(p)+' '+vec(v)+f' {int(static)} {exclude} {int(group is not None)} '+\
                             ' '.join(map(str,group if group is not None else np.ones(6,dtype=int))))
                expected.append((int(gid[0]),distance,n.copy()))
        data='\n'.join(parts)+'\n';(out/(name+'.input')).write_text(data)
        rows=run(binary,[path],data);assert len(rows)==len(expected)
        passed=0
        for i,(a,c) in enumerate(zip(rows,expected)):
            ok=a[0]=='SUCCESS' and a[1]==c[0] and np.isclose(a[2],c[1],atol=3e-10,rtol=3e-10) and np.allclose(a[3],c[2],atol=3e-10,rtol=3e-10)
            if ok:passed+=1
            else:failures.append(dict(model=name,case=i,ada=[a[0],a[1],a[2],a[3].tolist()],c=[c[0],c[1],c[2].tolist()]))
            if c[1]>=0:worst=max(worst,abs(a[2]-c[1]),np.max(abs(a[3]-c[2])))
        records.append(dict(model=name,cases=len(rows),passed=passed));print(name,passed,len(rows),flush=True)
    edge=subprocess.run([str(binary.parent/'ray_edges'),str(out/'hinge.mjb')],capture_output=True,text=True)
    if edge.returncode:failures.append(dict(edge_error=edge.stdout+edge.stderr))
    return dict(cases=sum(r['cases'] for r in records),passed=sum(r['passed'] for r in records),records=records,
                failures=failures,max_abs=float(worst),edges=dict(exit=edge.returncode,output=edge.stdout+edge.stderr))
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args()
    assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
    rng=np.random.default_rng(241002)
    result=dict(reference=mujoco.__version__,binary_sha256=digest(a.binary),primitives=primitives(a.binary,rng),scenes=scenes(a.binary,a.out,rng))
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('primitives',result['primitives']['passed'],result['primitives']['cases'])
    print('total failures',len(result['primitives']['failures'])+len(result['scenes']['failures']))
    if result['primitives']['failures'] or result['scenes']['failures']:raise SystemExit(1)
if __name__=='__main__':main()
