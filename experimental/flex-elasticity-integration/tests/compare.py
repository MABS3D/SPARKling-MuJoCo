"""End-to-end comparison: Ada receives only MJB, state, controls and applied forces."""
import argparse, hashlib, json, subprocess
from pathlib import Path
import mujoco
import numpy as np
import xml.etree.ElementTree as ET

def numbers(a): return ' '.join(format(float(x), '.17g') for x in np.asarray(a).ravel())
def fixture(dim=2, mode='both', pinned=False, rotated=False, shared=False,
            curved=False, free=False, flags='', count=1, edge=False, muscle=False):
    points = [(0.,0.,0.),(1.,0.,.12 if curved else 0.),(0.,1.,.21 if curved else 0.),
              (1.,1.,-.05 if curved else 0.)] if dim==2 else [(0.,0.,0.),(1.,0.,0.),(0.,1.,0.),(0.,0.,1.)]
    if dim==1: points=[(0.,0.,0.),(.6,.1,0.),(1.,.4,0.)]
    elements = '0 1 2 1 3 2' if dim==2 else ('0 1 2 3' if dim==3 else '0 1 1 2')
    bodies=[]; flexes=[]; actuator=''
    for f in range(count):
        names=[]
        for i,p in enumerate(points):
            name=f'v{f}_{i}'; names.append(name)
            joints = '' if pinned and i==0 else ('<freejoint/>' if free else
                ''.join(f'<joint name="j{f}_{i}_{k}" type="slide" axis="{a}" damping=".013"/>'
                        for k,a in enumerate(['1 0 0','0 1 0','0 0 1'])))
            bodies.append(f'<body name="{name}" pos="{numbers(np.array(p)+[2*f,0,0])}">{joints}'
                          '<inertial mass="1" pos=".03 -.02 .01" diaginertia=".1 .11 .12"/></body>')
        elasticity = f'<elasticity young="120" poisson=".23" thickness=".045" damping=".012" elastic2d="{mode}"/>' if dim>1 else ''
        springs = '<edge stiffness="13" damping=".07"/>' if edge else ''
        flexes.append(f'<flex name="f{f}" dim="{dim}" body="'+ ' '.join(names)+'" vertex="'+
                      ' '.join('0 0 0' for _ in points)+'" element="'+elements+'">'+
                      '<contact contype="0" conaffinity="0" selfcollide="none"/>'+elasticity+springs+'</flex>')
    root=''.join(bodies)
    if rotated or shared:
        quat = '0.9238795325112867 0 0 0.3826834323650898' if rotated else '1 0 0 0'
        parent_joint = '<joint name="parent" type="hinge" axis="0 1 0" damping=".023"/>' if shared else ''
        root=f'<body name="root" quat="{quat}" pos=".2 -.1 .3">{parent_joint}<inertial mass="3" pos="0 0 0" diaginertia="1 1 1"/>{root}</body>'
    if muscle:
        # The scope includes coexistence with owned muscle activation in smooth.
        actuator='<actuator><muscle joint="j0_1_0" lengthrange="-.5 .5" force=".3"/></actuator>'
    return '<mujoco><option timestep=".0002" gravity="0 0 -.3"><flag constraint="disable" '+flags+'/></option>'\
        '<worldbody>'+root+'</worldbody><deformable>'+''.join(flexes)+'</deformable>'+actuator+'</mujoco>'

def fixtures():
    for mode in ['stretch','bend','both']:
        for variant,kw in [('flat',{}),('curved',dict(curved=True)),('pinned',dict(pinned=True)),
                           ('rotated',dict(rotated=True)),('shared',dict(shared=True,pinned=True))]:
            yield f'membrane_{mode}_{variant}',fixture(mode=mode,**kw)
    yield 'tetra_slides',fixture(dim=3,mode='none')
    yield 'tetra_free',fixture(dim=3,mode='none',free=True)
    yield 'membrane_free',fixture(mode='stretch',free=True)
    yield 'multiple',fixture(count=2,curved=True,pinned=True,rotated=True)
    membrane=ET.fromstring(fixture(curved=True))
    wire=ET.fromstring(fixture(dim=1,edge=True).replace('v0_', 'w0_').replace('j0_', 'wj0_').replace('name="f0"','name="wire"'))
    membrane.find('worldbody').extend(list(wire.find('worldbody')))
    membrane.find('deformable').extend(list(wire.find('deformable')))
    yield 'continuum_and_edges',ET.tostring(membrane,encoding='unicode')
    yield 'edge_chain',fixture(dim=1,edge=True,pinned=True,shared=True)
    yield 'spring_disabled',fixture(flags='spring="disable"',curved=True)
    yield 'damper_disabled',fixture(flags='damper="disable"',curved=True)
    yield 'both_disabled',fixture(flags='spring="disable" damper="disable"')
    yield 'muscle',fixture(mode='both',muscle=True)

def full_state(m,d): return np.r_[d.qpos,d.qvel,d.time,d.act]
def oracle(m,q,v,applied,ctrl,act,steps):
    d=mujoco.MjData(m); d.qpos[:]=q; d.qvel[:]=v; d.qfrc_applied[:]=applied; d.ctrl[:]=ctrl; d.act[:]=act
    mujoco.mj_forward(m,d)
    answer=dict(pos=d.flexvert_xpos.ravel().copy(),length=d.flexedge_length.copy(),velocity=d.flexedge_velocity.copy(),
                spring=d.qfrc_spring.copy(),damper=d.qfrc_damper.copy(),passive=d.qfrc_passive.copy(),acc=d.qacc.copy())
    original = [m.flex_stiffness.copy(),m.flex_bending.copy(),m.flex_edgestiffness.copy(),m.flex_edgedamping.copy()]
    for a in [m.flex_stiffness,m.flex_bending,m.flex_edgestiffness,m.flex_edgedamping]:a[:]=0
    mujoco.mj_forward(m,d)
    answer['spring']-=d.qfrc_spring; answer['damper']-=d.qfrc_damper
    for a,b in zip([m.flex_stiffness,m.flex_bending,m.flex_edgestiffness,m.flex_edgedamping],original):a[:]=b
    mujoco.mj_forward(m,d)
    for _ in range(steps):mujoco.mj_step(m,d)
    answer['state']=full_state(m,d)
    return answer
def parse(text):
    records=[]
    for line in text.splitlines():
        if line.startswith('case'):records.append({})
        elif records:
            key,_,data=line.partition(' ')
            if key in ['pos','length','velocity','spring','damper','passive','acc','state']:
                records[-1][key]=np.fromstring(data,sep=' ')
    return records
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--samples',type=int,default=8);p.add_argument('--steps',type=int,default=100);p.add_argument('--only')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0'
    rng=np.random.default_rng(2026100215);records=[];failures=[]
    for name,xml in fixtures():
        if a.only and a.only not in name:continue
        m=mujoco.MjModel.from_xml_string(xml); file=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(file));(a.out/(name+'.xml')).write_text(xml)
        inputs=[];expected=[]
        for i in range(a.samples):
            q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-.07,.07,m.nv),.4 if i else 0.)
            v=rng.uniform(-.04,.04,m.nv) if i else np.zeros(m.nv)
            applied=rng.uniform(-.02,.02,m.nv);ctrl=rng.uniform(.05,.15,m.nu);act=rng.uniform(.05,.15,m.na)
            inputs.extend([0.,*q,*v,*applied,*ctrl,*act]);expected.append(oracle(m,q,v,applied,ctrl,act,a.steps))
        data=f'{a.samples} {a.steps}\n'+numbers(inputs)+'\n'
        (a.out/(name+'.input')).write_text(data)
        run=subprocess.run([str(a.binary),str(file)],input=data,text=True,capture_output=True,timeout=180)
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        actual=parse(run.stdout)
        if run.returncode or len(actual)!=len(expected):
            failures.append(dict(model=name,error=(run.stdout+run.stderr)[-1800:]));print('FAIL',name,failures[-1]['error'],flush=True);continue
        for i,(x,y) in enumerate(zip(actual,expected)):
            errors={}
            for key in y:
                ok=x.get(key,np.array([])).shape==y[key].shape
                delta=float(np.max(np.abs(x[key]-y[key]))) if ok and y[key].size else 0.
                ok=ok and np.allclose(x[key],y[key],atol=2e-10,rtol=2e-10)
                errors[key]=dict(max_abs=delta,passed=bool(ok))
            row=dict(model=name,sample=i,errors=errors,passed=all(e['passed'] for e in errors.values()));records.append(row)
            if not row['passed']:failures.append(row);print('FAIL',name,i,{k:v for k,v in errors.items() if not v['passed']},flush=True)
        print(name,'checked',flush=True)
    result=dict(reference=mujoco.__version__,steps=a.steps,cases=len(records),passed=sum(r['passed'] for r in records),failures=failures,
                binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
