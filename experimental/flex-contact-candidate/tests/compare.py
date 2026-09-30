#!/usr/bin/env python3
"""Differential full-flex tests against MuJoCo 3.14.0 (no vertex-sphere proxy)."""
from pathlib import Path
import argparse, json, os, subprocess
import numpy as np
import mujoco

def numbers(x): return ' '.join(format(float(v),'.17g') for v in np.asarray(x).ravel())
def xml_model(base,mass,pin,edges,normal,origin,radius,margin,gap,k,damp,gravity,h,solver):
    sr=numbers(solver[:2]); si=numbers([*solver[2:],2])
    text=['<mujoco><option integrator="Euler" solver="PGS" iterations="100" tolerance="1e-12" '
          f'timestep="{h}" gravity="{numbers(gravity)}"><flag warmstart="disable" island="disable"/></option><worldbody>',
          f'<geom type="plane" size="1 1 .1" pos="{numbers(origin)}" zaxis="{numbers(normal)}" '
          f'condim="1" solref="{sr}" solimp="{si}"/>']
    for v,x in enumerate(base):
        text += [f'<body name="v{v}" pos="{numbers(x)}">']
        if not pin[v]:text += [f'<joint type="slide" axis="{a}"/>' for a in ['1 0 0','0 1 0','0 0 1']]
        text += [f'<inertial mass="{mass[v]}" pos="0 0 0" diaginertia=".01 .01 .01"/></body>']
    text+=['</worldbody><deformable>',
           f'<flex name="net" dim="1" radius="{radius}" body="'+ ' '.join('world' if pin[v] else f'v{v}' for v in range(len(base)))+'" vertex="'+ numbers([base[v] if pin[v] else np.zeros(3) for v in range(len(base))])+'" element="'+ ' '.join(str(i) for e in edges for i in e)+'">',
           f'<edge stiffness="{k}" damping="{damp}"/>',
           f'<contact condim="1" selfcollide="none" internal="false" margin="{margin}" gap="{gap}" solref="{sr}" solimp="{si}"/>',
           '</flex></deformable></mujoco>']
    return ''.join(text)

def payload(pos,vel,mass,pin,edges,rest,k,damp,applied,gravity,h,steps,normal,origin,radius,margin,gap,solver):
    rows=[[len(pos),len(edges),steps,h,*gravity],[*origin,*normal,radius,margin,gap,*solver]]
    rows += [[mass[v],int(pin[v]),*pos[v],*vel[v],*applied[v]] for v in range(len(pos))]
    rows += [[a+1,b+1,rest[e],k,damp] for e,(a,b) in enumerate(edges)]
    return '\n'.join(numbers(r) for r in rows)+'\n'

def parse(text):
    result={}
    for line in text.splitlines():
        key,*v=line.split()
        if key in ['evaluate','step']: result[key]=v[0]
        else:result.setdefault(key,[]).append(list(map(float,v)))
    return result

def fixture(n,mode,seed):
    rng=np.random.default_rng(seed)
    normal=np.array([0.,0.,1.]) if mode not in ['tilt','tilt_impact'] else np.array([.3,-.4,np.sqrt(.75)])
    tangent=np.cross(normal,[0.,1.,0.]);tangent/=np.linalg.norm(tangent)
    origin=np.array([.07,-.03,.02]);radius=.015;h=.0005
    base=origin+np.outer(np.arange(n)*.04,tangent)+np.outer(np.ones(n)*(radius-.0003),normal)
    if mode in ['impact','tilt_impact']:base+=normal*.02
    if mode=='separated':base+=normal
    if mode=='gap':base+=normal*.002
    pin=np.zeros(n,dtype=bool)
    if mode=='pinned':pin[::3]=True
    if mode=='all_pinned':pin[:]=True
    edges=[(v,v+1) for v in range(n-1)]
    if mode=='star':edges=[(0,v) for v in range(1,n)]
    mass=rng.uniform(.3,2,n);k=20.;damp=.15
    if mode=='spring':damp=0.
    if mode=='damper':k=0.
    gravity=np.array([.2,-.1,-9.81]);applied=rng.uniform(-.1,.1,(n,3))
    vel=rng.uniform(-.05,.05,(n,3));vel[pin]=0
    pos=base+rng.uniform(-.0001,.0001,(n,3));pos[pin]=base[pin]
    if mode=='gap':pos=base.copy();vel[:]=0
    if mode=='separating':vel[:]=normal*2;applied[:]=normal*30
    margin=.001 if mode=='gap' else 0.;gap=.002 if mode=='gap' else 0.
    solver=[.02,1.,.9,.95,.001,.5]
    if mode=='constant':solver[2]=solver[3]=.9
    if mode=='reversed_impedance':solver[2:4]=[.95,.9]
    if mode=='refsafe':solver[0]=.00001
    xml=xml_model(base,mass,pin,edges,normal,origin,radius,margin,gap,k,damp,gravity,h,solver)
    m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
    for v in range(n):
        if pin[v]:continue
        a=m.body_dofadr[v+1]
        d.qpos[a:a+3]=pos[v]-base[v];d.qvel[a:a+3]=vel[v];d.qfrc_applied[a:a+3]=applied[v]
    mujoco.mj_forward(m,d)
    # Realized compiled plane and vertex coordinates; one flex, so each vertex
    # generates at most one contact, irrespective of incident edge count.
    normal=d.geom_xmat[0].reshape(3,3)[:,2].copy();pos=d.xpos[1:].copy()
    edges=m.flex_edge.copy().tolist()
    return locals()

def run_case(exe,out,n,mode,seed,steps):
    f=fixture(n,mode,seed);m=f['m'];d=f['d'];pin=f['pin']
    expected={'acceleration':np.zeros((n,3)),'contact':np.zeros((n,4)), 'rank':np.zeros((n,1))}
    for v in range(n):
        height=np.dot(f['pos'][v]-f['origin'],f['normal'])
        expected['contact'][v]=[height<=f['margin']+f['gap']+f['radius'],
                              False,height-f['radius'],0]
        if not pin[v]:a=m.body_dofadr[v+1];expected['acceleration'][v]=d.qacc[a:a+3]
    seen=set()
    for rank,c in enumerate(d.contact,1):
        assert c.flex[1]==0 and c.vert[1]>=0 and c.dim==1
        v=c.vert[1];assert v not in seen;seen.add(v)
        expected['rank'][v,0]=rank
        expected['contact'][v,1]=c.dist<f['margin'] and not pin[v]
        if c.efc_address>=0 and not pin[v]:expected['contact'][v,3]=d.efc_force[c.efc_address]
        if not pin[v]:assert bool(expected['contact'][v,1])==(c.efc_address>=0)
    for v in range(n):
        if v in seen:assert bool(expected['contact'][v,0])
    assert len(seen)<=50
    inp=payload(f['pos'],f['vel'],f['mass'],pin,f['edges'],m.flexedge_length0,f['k'],f['damp'],f['applied'],f['gravity'],f['h'],steps,f['normal'],f['origin'],f['radius'],f['margin'],f['gap'],f['solver'])
    name=f'{mode}-{n}-{seed}-{steps}'
    (out/(name+'.xml')).write_text(f['xml']);(out/(name+'.input')).write_text(inp)
    p=subprocess.run([str(exe)],input=inp,text=True,capture_output=True)
    (out/(name+'.output')).write_text(p.stdout+p.stderr);p.check_returncode();got=parse(p.stdout)
    assert got['evaluate']=='SUCCESS' and got['step']=='SUCCESS',got
    for _ in range(steps):mujoco.mj_step(m,d)
    mujoco.mj_kinematics(m,d)
    expected['position']=d.xpos[1:].copy();expected['velocity']=np.zeros((n,3))
    for v in range(n):
        if not pin[v]:a=m.body_dofadr[v+1];expected['velocity'][v]=d.qvel[a:a+3]
    assert not np.any(d.warning.number)
    errors={}
    for key,value in expected.items():
        actual=np.array(got[key])
        if key=='rank':
            # The default C midphase sorts the retained prefix by vertex ID.
            # Retained_Rank intentionally exposes the preceding filter order.
            actual=np.where(actual>0,np.cumsum(actual>0).reshape(n,1),0)
        np.testing.assert_allclose(actual,value,rtol=2e-9,atol=2e-9,err_msg=f'{name} {key}')
        errors[key]=float(np.max(np.abs(actual-value)))
    (out/(name+'.expected.json')).write_text(json.dumps({k:v.tolist() for k,v in expected.items()},indent=2))
    return dict(name=name,n=n,steps=steps,max_abs_error=errors)

def boundaries(exe,out):
    records=[]
    # Exact binary thresholds: at margin no force; at margin+gap still detected.
    solver=[.02,1,.9,.95,.001,.5];z=[.5,.625,np.nextafter(.625,np.inf)]
    inp=payload(np.array([[0,0,x] for x in z]),np.zeros((3,3)),np.ones(3),[False]*3,[],[],0,0,np.zeros((3,3)),[0,0,-9.81],0,0,[0,0,1],[0,0,0],.25,.25,.125,solver)
    got=parse(subprocess.check_output([str(exe)],input=inp,text=True));assert [x[:2] for x in got['contact']]==[[1,0],[1,0],[0,0]]
    records.append('margin and gap exact boundary')
    # Second particle fails after first was integrated: atomic whole-network rollback.
    for label,pos,vel,applied,mass in [
        ('position rollback',[[0,0,1],[1e10,0,1]],[[1,0,0],[1,0,0]],np.zeros((2,3)),[1,1]),
        ('velocity rollback',[[0,0,1],[0,0,1]],[[1,0,0],[0,0,0]],[[0,0,0],[1e10,0,0]],[1,1e-15]),
    ]:
        inp=payload(pos,vel,mass,[False]*2,[],[],0,0,applied,[0,0,0],1,1,[0,0,1],[0,0,0],.1,0,0,solver)
        p=subprocess.run([str(exe)],input=inp,capture_output=True,text=True,check=True);got=parse(p.stdout)
        assert got['step']=='NUMERIC_LIMIT';assert got['position']==pos and got['velocity']==vel
        (out/(label.replace(' ','-')+'.output')).write_text(p.stdout);records.append(label)
    # Full particle capacity, both below and above the C filter threshold.
    n=4096;pos=np.zeros((n,3));pos[50:,2]=1
    inp=payload(pos,np.zeros((n,3)),np.ones(n),[False]*n,[],[],0,0,np.zeros((n,3)),[0,0,-9.81],0,1,[0,0,1],[0,0,0],.01,0,0,solver)
    got=parse(subprocess.check_output([str(exe)],input=inp,text=True));assert got['step']=='SUCCESS'
    assert len(got['contact'])==n and sum(x[1] for x in got['contact'])==50
    records.append('4096 particles, 50 simultaneous vertex contacts')
    pos[50,2]=0
    inp=payload(pos,np.zeros((n,3)),np.ones(n),[False]*n,[],[],0,0,np.zeros((n,3)),[0,0,-9.81],.001,1,[0,0,1],[0,0,0],.01,0,0,solver)
    got=parse(subprocess.check_output([str(exe)],input=inp,text=True))
    assert got['step']=='SUCCESS'
    assert sum(x[0]>0 for x in got['rank'])==50
    assert sum(x[0] for x in got['contact'])==51
    records.append('4096 particles, 51 detected contacts filtered to 50')
    return records

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--exe',type=Path,required=True);ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    a.exe=a.exe.resolve();a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=True)
    os.chdir(a.out)  # Keep any C diagnostic logs out of the shared checkout.
    assert mujoco.__version__=='3.14.0';results=[]
    modes=['rest','tilt'] if a.quick else ['rest','tilt','pinned','all_pinned','impact','tilt_impact','separated','separating','gap','star','spring','damper','constant','reversed_impedance','refsafe']
    for mode in modes:
        for n in ([4] if a.quick else [2,8,32]):
            for steps in ([1] if a.quick else [1,200]):
                r=run_case(a.exe.resolve(),a.out,n,mode,930+n,steps);results.append(r);print(r['name'],'PASS',flush=True)
    if not a.quick:
        for mode in ['rest','tilt','pinned','all_pinned','impact','tilt_impact','gap','star','refsafe']:
            for n in [51,64,128]:
                for steps in [1,200]:
                    r=run_case(a.exe,a.out,n,mode,930+n,steps);results.append(r);print(r['name'],'PASS',flush=True)
    b=[] if a.quick else boundaries(a.exe.resolve(),a.out)
    (a.out/'results.json').write_text(json.dumps(dict(reference=mujoco.__version__,rtol=2e-9,atol=2e-9,cases=results,boundaries=b),indent=2))
if __name__=='__main__':main()
