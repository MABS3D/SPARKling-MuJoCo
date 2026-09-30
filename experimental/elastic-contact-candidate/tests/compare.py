#!/usr/bin/env python3
"""Differential tests against MuJoCo 3.14.0 itself, including complete Euler steps."""
import argparse
import copy
import json
import os
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
import numpy as np
import mujoco
from build import build, sources

def numbers(x):
    return ' '.join(format(float(v), '.17g') for v in np.asarray(x).ravel())

def case(pos, edges, **kw):
    n = len(pos)
    result = dict(pos=np.array(pos, float), vel=np.zeros((n,3)), mass=np.ones(n),
        pin=np.zeros(n, int), applied=np.zeros((n,3)), links=np.zeros(n, int),
        local=np.zeros((n,3)), edges=edges, bodies=[], shapes=[], steps=1,
        gravity=np.zeros(3), dt=.0005, radius=.02, self=1, iterations=2000,
        tolerance=1e-11, contact=[.02,1,.9,.95,.001,.5], stiffness=0., damping=0.)
    result.update(kw)
    result['rest'] = np.array([np.linalg.norm(result['pos'][a]-result['pos'][b]) for a,b in edges])
    return result

def body(**kw):
    b = dict(mass=2., fixed=0, inertia=np.array([.03,.04,.05]), pos=np.array([0,0,-.035]),
             vel=np.zeros(3), omega=np.zeros(3), quat=np.array([1.,0,0,0]),
             force=np.zeros(3), torque=np.zeros(3))
    b.update(kw); return b

def shape(kind=0, owner=0, **kw):
    s = dict(kind=kind, owner=owner, center=np.zeros(3), direction=np.array([0.,0,1]), radius=.06, half=.2)
    s.update(kw); return s

def xml(c):
    root = ET.Element('mujoco')
    ET.SubElement(root,'compiler',angle='radian')
    opt = ET.SubElement(root,'option',integrator='Euler', solver='PGS', jacobian='auto',
                        timestep=str(c['dt']), gravity=numbers(c['gravity']), iterations='10000', tolerance='1e-14')
    ET.SubElement(opt,'flag',warmstart='disable')
    default = ET.SubElement(root,'default')
    tc,dr,d0,dw,width,mid=c['contact']
    ET.SubElement(default,'geom',condim='1',contype='2',conaffinity='1',
                  solref=numbers([tc,dr]), solimp=numbers([d0,dw,width,mid,2]))
    world = ET.SubElement(root,'worldbody'); rb=[]
    for i,b in enumerate(c['bodies']):
        r=ET.SubElement(world,'body',name=f'r{i}',pos=numbers(b['pos']),quat=numbers(b['quat']))
        if not b['fixed']: ET.SubElement(r,'freejoint',name=f'rj{i}')
        ET.SubElement(r,'inertial',pos='0 0 0',mass=str(b['mass']),diaginertia=numbers(b['inertia']))
        rb.append(r)
    names=[]; points=[]
    for i,pos in enumerate(c['pos']):
        link=c['links'][i]
        if link:
            names.append(f'r{link-1}'); points.extend(c['local'][i]); continue
        names.append(f'v{i}'); points.extend([0,0,0])
        r=ET.SubElement(world,'body',name=f'v{i}',pos=numbers(pos))
        if not c['pin'][i]:
            for axis in np.eye(3): ET.SubElement(r,'joint',type='slide',axis=numbers(axis))
        ET.SubElement(r,'inertial',pos='0 0 0',mass=str(c['mass'][i]),diaginertia='.01 .01 .01')
    for i,s in enumerate(c['shapes']):
        parent=world if s['owner']==0 else rb[s['owner']-1]
        typ=['sphere','capsule','plane'][s['kind']]
        size=([s['radius']] if typ=='sphere' else [s['radius'],s['half']] if typ=='capsule' else [2,2,.1])
        ET.SubElement(parent,'geom',name=f'g{i}',type=typ,pos=numbers(s['center']),
                      zaxis=numbers(s['direction']),size=numbers(size),mass='0')
    deform=ET.SubElement(root,'deformable')
    flex=ET.SubElement(deform,'flex',name='network',dim='1',body=' '.join(names),
                       vertex=numbers(points),element=' '.join(str(x) for e in c['edges'] for x in e),radius=str(c['radius']))
    ET.SubElement(flex,'edge',stiffness=str(c['stiffness']),damping=str(c['damping']))
    ET.SubElement(flex,'contact',condim='1',contype='1',conaffinity='3',
                  selfcollide='narrow' if c['self'] else 'none', internal='false',
                  solref=numbers([tc,dr]),solimp=numbers([d0,dw,width,mid,2]))
    return ET.tostring(root, encoding='unicode')

def payload(c):
    rows=[[len(c['pos']),len(c['edges']),len(c['bodies']),len(c['shapes']),c['steps'],c['dt'],*c['gravity']],
          [c['radius'],c['self'],c['iterations'],c['tolerance'],*c['contact']]]
    for i in range(len(c['pos'])):
        rows.append([c['mass'][i],c['pin'][i],*c['pos'][i],*c['vel'][i],*c['applied'][i],c['links'][i],*c['local'][i]])
    rows += [[a+1,b+1,c['rest'][e],c['stiffness'],c['damping']] for e,(a,b) in enumerate(c['edges'])]
    for b in c['bodies']:
        rows.append([b['mass'],b['fixed'],*b['inertia'],*b['pos'],*b['vel'],*b['omega'],*b['quat'],*b['force'],*b['torque']])
    for s in c['shapes']:
        rows.append([s['kind'],s['owner'],*s['center'],*s['direction'],s['radius'],s['half']])
    # Integer fields must use integer tokens for Ada Integer_Text_IO.
    def fmt(x): return str(int(x)) if float(x).is_integer() else format(float(x),'.17g')
    return '\n'.join(' '.join(fmt(x) for x in row) for row in rows)+'\n'

def parse(text):
    result={}
    for line in text.splitlines():
        key,*fields=line.split()
        if key=='status': result[key]=fields[0]
        else: result.setdefault(key,[]).append(list(map(float,fields)))
    return result

def reference(c, text):
    m=mujoco.MjModel.from_xml_string(text); d=mujoco.MjData(m)
    m.flexedge_length0[:]=c['rest']
    for i in range(len(c['pos'])):
        if c['links'][i] or c['pin'][i]: continue
        bid=m.body(f'v{i}').id; adr=m.body_dofadr[bid]
        d.qvel[adr:adr+3]=c['vel'][i]; d.qfrc_applied[adr:adr+3]=c['applied'][i]
    for i,b in enumerate(c['bodies']):
        bid=m.body(f'r{i}').id
        if not b['fixed']:
            adr=m.body_dofadr[bid]; d.qvel[adr:adr+6]=np.r_[b['vel'],b['omega']]
        d.xfrc_applied[bid]=np.r_[b['force'],b['torque']]
    mujoco.mj_forward(m,d)
    def attached_loads():
        # A world-space force at a rotating body-local vertex has a changing
        # generalized moment. Do not freeze its first-step projection.
        if not np.any(c['links']): return
        d.qfrc_applied[:]=0
        mujoco.mj_forward(m,d)
        for i in range(len(c['pos'])):
            if c['links'][i]:
                bid=m.body(f'r{c["links"][i]-1}').id
                mujoco.mj_applyFT(m,d,np.array(c['applied'][i],float),np.zeros(3),d.flexvert_xpos[i],bid,d.qfrc_applied)
            elif not c['pin'][i]:
                adr=m.body_dofadr[m.body(f'v{i}').id]
                d.qfrc_applied[adr:adr+3]=c['applied'][i]
    attached_loads()
    for _ in range(c['steps']):
        attached_loads()
        mujoco.mj_step(m,d)
    # qfrc_constraint and contacts still describe the pre-integration state.
    out=dict(particle_contact=np.zeros_like(c['pos']), body_force=[], body_torque=[])
    for i in range(len(c['pos'])):
        if c['links'][i] or c['pin'][i]: continue
        bid=m.body(f'v{i}').id; adr=m.body_dofadr[bid]
        out['particle_contact'][i]=d.qfrc_constraint[adr:adr+3]
    for i,b in enumerate(c['bodies']):
        bid=m.body(f'r{i}').id; adr=m.body_dofadr[bid]
        if b['fixed']:
            # qfrc has no columns for fixed bodies: checked separately by reaction balance.
            out['body_force'].append(np.zeros(3)); out['body_torque'].append(np.zeros(3))
        else:
            out['body_force'].append(d.qfrc_constraint[adr:adr+3].copy())
            out['body_torque'].append(d.xmat[bid].reshape(3,3)@d.qfrc_constraint[adr+3:adr+6])
    contacts=[]
    for con in d.contact:
        if con.efc_address < 0: continue
        contacts.append([con.dist,d.efc_force[con.efc_address],*con.pos,*con.frame[:3]])
    out['contact']=contacts; out['count']=[[len(contacts)]]
    mujoco.mj_kinematics(m,d); mujoco.mj_comPos(m,d); mujoco.mj_comVel(m,d); mujoco.mj_flex(m,d)
    out['position']=d.flexvert_xpos.copy(); out['velocity']=np.zeros_like(c['pos'])
    out['coordinate']=np.zeros_like(c['pos'])
    for i in range(len(c['pos'])):
        if c['links'][i]:
            bid=m.body(f'r{c["links"][i]-1}').id
            if c['bodies'][c['links'][i]-1]['fixed']: continue
            j=np.zeros((3,m.nv)); jr=np.zeros_like(j)
            mujoco.mj_jac(m,d,j,jr,d.flexvert_xpos[i],bid); out['velocity'][i]=j@d.qvel
        elif not c['pin'][i]:
            adr=m.body_dofadr[m.body(f'v{i}').id]; out['velocity'][i]=d.qvel[adr:adr+3]
            qadr=m.jnt_qposadr[m.body_jntadr[m.body(f'v{i}').id]]
            out['coordinate'][i]=d.qpos[qadr:qadr+3]
        else: out['velocity'][i]=c['vel'][i]
    for key in ('body_position','body_velocity','body_omega','body_quaternion'): out[key]=[]
    for i,b in enumerate(c['bodies']):
        bid=m.body(f'r{i}').id; adr=m.body_dofadr[bid]
        out['body_position'].append(d.xpos[bid].copy()); out['body_quaternion'].append(d.xquat[bid].copy())
        out['body_velocity'].append(b['vel'] if b['fixed'] else d.qvel[adr:adr+3].copy())
        out['body_omega'].append(b['omega'] if b['fixed'] else d.qvel[adr+3:adr+6].copy())
    assert not np.any(d.warning.number), str(d.warning)
    return out,m,d

def cases():
    p=[[-.3,0,0],[.3,0,0],[0,-.3,.025],[0,.3,.025]]
    yield 'crossing',case(p,[(0,1),(2,3)])
    yield 'two_light_sides',case(p,[(0,1),(2,3)],mass=np.full(4,1e-15))
    yield 'parallel',case([[-.3,0,0],[.3,0,0],[-.25,.03,0],[.25,.03,0]],[(0,1),(2,3)])
    yield 'coincident',case([[-.3,0,0],[.3,0,0],[0,-.3,0],[0,.3,0]],[(0,1),(2,3)])
    yield 'shared_vertex',case([[-.01,0,0],[0,0,0],[.01,.001,0]],[(0,1),(1,2)])
    yield 'disabled_self',case(p,[(0,1),(2,3)],self=0)
    yield 'separating',case(p,[(0,1),(2,3)],vel=np.array([[0,0,-2]]*2+[[0,0,2]]*2))
    yield 'plane',case([[-.3,0,.015],[0,0,.012],[.3,0,.019]],[(0,1),(1,2)],shapes=[shape(2)],gravity=np.array([0,0,-9.81]))
    yield 'sphere',case([[-.3,0,0],[.3,0,0]],[(0,1)],bodies=[body()],shapes=[shape(owner=1,center=np.array([.09,0,0]))])
    yield 'capsule',case([[-.3,0,0],[.3,0,0]],[(0,1)],bodies=[body()],shapes=[shape(1,1,direction=np.array([0,1.,0]))])
    yield 'parallel_rigid_capsule',case([[-.3,0,0],[.3,0,0]],[(0,1)],bodies=[body()],
             shapes=[shape(1,1,direction=np.array([1.,0,0]))])
    multi=case([[-.3,-.03,0],[.3,-.03,0],[-.3,.03,.005],[.3,.03,.005]],[(0,1),(2,3)],bodies=[body()],shapes=[shape(owner=1,center=np.array([.09,0,0]))])
    yield 'shared_body',multi
    soft=copy.deepcopy(multi); soft['contact']=[.04,1.3,.6,.93,.2,.3]; soft['dt']=.005
    yield 'variable_impedance',soft
    b=body(omega=np.array([.3,-.2,.4]),vel=np.array([.01,.02,-.03]),quat=np.array([np.cos(.2),0,np.sin(.2),0]),
           force=np.array([.1,-.2,.3]),torque=np.array([.02,.03,-.01]))
    yield 'rotating_body',case([[-.3,0,0],[.3,0,0]],[(0,1)],bodies=[b],shapes=[shape(owner=1,center=np.array([.09,0,0]))])
    attached=case([[.1,0,.035],[.4,0,.035]],[(0,1)],bodies=[body(pos=np.array([0,0,.035]))],
                  links=np.array([1,0]),local=np.array([[.1,0,0],[0,0,0]]),stiffness=20.,damping=.1,
                  shapes=[shape(2)],gravity=np.array([0,0,-9.81]))
    attached['rest']*=.8
    yield 'attachment_spring',attached
    touching=copy.deepcopy(attached)
    touching['pos'][:,2]=.015; touching['bodies'][0]['pos'][2]=.015
    touching['bodies'][0]['omega']=np.array([.1,-.2,.3])
    yield 'attached_vertex_contact',touching
    touching=copy.deepcopy(touching); touching['steps']=50
    yield 'attached_vertex_contact_trajectory',touching
    loaded=copy.deepcopy(attached);loaded['applied'][0]=[.7,-.4,.3]
    loaded['bodies'][0]['omega']=[.4,-.3,.2];loaded['steps']=200
    yield 'attached_world_force_trajectory',loaded
    shared=case(p,[(0,1),(2,3)],bodies=[body(pos=np.array([0,0,0]))],
                links=np.array([1,0,1,0]),local=np.array([p[0],[0,0,0],p[2],[0,0,0]]))
    yield 'shared_attachment_filtered',shared
    merged=case(p,[(0,1),(2,3)],bodies=[body(pos=np.zeros(3))],links=np.array([1,1,0,0]),
                local=np.array([p[0],p[1],[0,0,0],[0,0,0]]))
    yield 'merged_body_jacobian',merged
    pinned=case(p,[(0,1),(2,3)],pin=np.array([1,1,0,0]))
    yield 'pinned_side',pinned
    fixed=case([[-.3,0,0],[.3,0,0]],[(0,1)],bodies=[body(fixed=1)],shapes=[shape(owner=1)])
    yield 'fixed_body',fixed
    for n in (51,128):
        yield f'plane_filter_{n}',case([[i*.1,0,.019] for i in range(n)],
             [(i,i+1) for i in range(n-1)],shapes=[shape(2)],gravity=np.array([0,0,-9.81]),stiffness=10.)
    yield 'plane_filter_symmetric_trajectory',case([[i*.1,0,.019] for i in range(128)],
          [(i,i+1) for i in range(127)],shapes=[shape(2)],gravity=np.array([0,0,-9.81]),stiffness=10.,steps=1000)
    # Unequal depths and distances exercise selection without geometric ties.
    rng_plane=np.random.default_rng(31337)
    xyz=np.array([[i*.1,0,.019] for i in range(80)])
    xyz+=rng_plane.uniform(-1,1,xyz.shape)*np.array([.003,.002,.0002])
    yield 'plane_filter_trajectory',case(xyz,[(i,i+1) for i in range(79)],shapes=[shape(2)],
          gravity=np.array([0,0,-9.81]),stiffness=10.,steps=100)
    for name,c in [('crossing',case(p,[(0,1),(2,3)])),('coupled',multi),('attached',attached)]:
        c=copy.deepcopy(c); c['steps']=100
        yield name+'_trajectory',c
    rng=np.random.default_rng(30092026)
    for i in range(24):
        c=copy.deepcopy(multi)
        c['pos']+=rng.normal(0,.002,c['pos'].shape); c['vel']=rng.normal(0,.015,c['vel'].shape)
        c['mass']=rng.uniform(.4,2,len(c['pos'])); c['bodies'][0]['mass']=float(rng.uniform(.5,3))
        c['bodies'][0]['omega']=rng.normal(0,.1,3)
        c['steps']=1 if i%3 else 25
        yield f'random_{i}',c

def run(exe,out,name,c,coordinates=True):
    text=xml(c); inp=payload(c)
    (out/(name+'.xml')).write_text(text); (out/(name+'.input')).write_text(inp)
    proc=subprocess.run([str(exe)],input=inp,text=True,capture_output=True)
    (out/(name+'.output')).write_text(proc.stdout+proc.stderr)
    proc.check_returncode(); actual=parse(proc.stdout); assert actual['status']=='SUCCESS',actual['status']
    expected,m,d=reference(c,text)
    (out/(name+'.expected.json')).write_text(json.dumps({k:np.asarray(v).tolist() for k,v in expected.items()},indent=2))
    errors={}
    for key,value in expected.items():
        if key=='coordinate' and not coordinates: continue  # old baseline API has no offset output
        if key=='contact':
            # C broadphase order differs. Match geometry; then compare corresponding force.
            remaining=list(actual.get('contact',[]))
            for row in value:
                index=min(range(len(remaining)),key=lambda j:np.linalg.norm(np.array(remaining[j][2:5])-row[2:5]))
                got=np.array(remaining.pop(index)); row=np.array(row)
                # Opposite side ordering flips normal, but not distance/force/point.
                if np.dot(got[5:],row[5:])<0: got[5:]*=-1
                np.testing.assert_allclose(got,row,atol=2e-8,rtol=2e-8,err_msg=name+' '+key)
            assert not remaining
            continue
        if len(value)==0: continue
        got=np.array(actual[key]); want=np.array(value)
        mask=np.ones(len(want),bool)
        if key in ('body_force','body_torque'): mask=np.array([not b['fixed'] for b in c['bodies']])
        if key=='particle_contact': mask=(c['pin']==0)&(c['links']==0)
        np.testing.assert_allclose(got[mask],want[mask],atol=2e-8,rtol=2e-8,err_msg=name+' '+key)
        errors[key]=float(np.max(np.abs(got[mask]-want[mask]),initial=0))
    # All dynamic and fixed participants appear in our reaction accounting.
    if not any(s['owner']==0 for s in c['shapes']):
        balance=np.sum(actual['particle_contact'],axis=0)
        if c['bodies']: balance+=np.sum(actual['body_force'],axis=0)
        np.testing.assert_allclose(balance,0,atol=2e-9,err_msg=name+' reaction balance')
    return dict(name=name,steps=c['steps'],contacts=actual['count'][0][0],max_abs_error=errors,
                iterations=actual['solver'][0][0],residual=actual['solver'][0][1])

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--probe',type=Path); ap.add_argument('--case')
    a=ap.parse_args(); a.out=a.out.resolve(); a.out.mkdir(parents=True,exist_ok=True)
    os.chdir(a.out)  # keep MuJoCo's compiler warning log with the test evidence
    assert mujoco.__version__=='3.14.0',mujoco.__version__
    before=sources(); exe=a.probe or build(a.out/'build'); results=[]
    for name,c in cases():
        if a.case and name!=a.case: continue
        results.append(run(exe,a.out,name,c)); print(name,'PASS',flush=True)
    assert before==sources(),'source changed during comparison'
    (a.out/'comparison.json').write_text(json.dumps(dict(reference=mujoco.__version__,sources=before,results=results),indent=2)+'\n')

if __name__=='__main__': main()
