#!/usr/bin/env python3
"""MuJoCo 3.14.0 differential tests: body transmission and coupled Euler."""
from pathlib import Path
import argparse,hashlib,itertools,json,math,random,subprocess,sys
import mujoco
import numpy as np
ap=argparse.ArgumentParser();ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--kernel',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
a.out.mkdir(parents=True,exist_ok=False);assert mujoco.__version__=='3.14.0'
BASE=[2.,.1,0.,-9.81,.002,0.,0.,.02,1.,.9,.95,.001,.5,0,.02,1.,1,1,0,1,0.,1.,0,0.,1.,0,-100.,100.,.099,0.,0.,0.,.5,0.,0]
def xml(c):
 flags=''
 if not c[16]:flags+=' actuation="disable"'
 if not c[17]:flags+=' clampctrl="disable"'
 kind=['none','integrator','filter','filterexact'][int(c[13])]
 actuator=f'<general body="b" dyntype="{kind}" dynprm="{c[14]:.17g}" gainprm="{c[15]:.17g}" actearly="{str(bool(c[18])).lower()}" ctrllimited="{str(bool(c[19])).lower()}" ctrlrange="{c[20]:.17g} {c[21]:.17g}" forcelimited="{str(bool(c[25])).lower()}" forcerange="{c[26]:.17g} {c[27]:.17g}"'
 if c[13]:actuator+=f' actlimited="{str(bool(c[22])).lower()}" actrange="{c[23]:.17g} {c[24]:.17g}"'
 return f'''<mujoco><option timestep="{c[4]:.17g}" gravity="0 0 {c[3]:.17g}" integrator="Euler" solver="PGS" jacobian="dense" iterations="100" tolerance="1e-12"><flag warmstart="disable"{flags}/></option><worldbody><geom name="floor" type="plane" pos="0 0 {c[2]:.17g}" size="1 1 .1"/><body name="b"><joint type="slide" axis="0 0 1" damping="0" armature="0"/><geom name="ball" type="sphere" size="{c[1]:.17g}" mass="{c[0]:.17g}"/></body></worldbody><contact><pair geom1="floor" geom2="ball" condim="1" margin="{c[5]:.17g}" gap="{c[6]:.17g}" solref="{c[7]:.17g} {c[8]:.17g}" solimp="{c[9]:.17g} {c[10]:.17g} {c[11]:.17g} {c[12]:.17g} 2"/></contact><actuator>{actuator}/></actuator></mujoco>'''
def oracle(c):
 m=mujoco.MjModel.from_xml_string(xml(c));d=mujoco.MjData(m)
 d.qpos[0]=c[28];d.qvel[0]=c[29];d.time=c[30];d.ctrl[0]=c[32];d.qfrc_applied[0]=c[33]
 if m.na:d.act[0]=c[31]
 for _ in range(int(c[34])):mujoco.mj_step(m,d)
 if not c[34]:mujoco.mj_forward(m,d)
 assert not np.any(d.warning.number),d.warning.number
 moment=0. if not d.moment_rownnz[0] else d.actuator_moment[d.moment_rowadr[0]]
 return [0,int(bool(d.ncon)),int(bool(d.nefc)),d.qpos[0],d.qvel[0],d.time,d.act[0] if m.na else c[31],d.act_dot[0] if m.na else 0.,d.actuator_force[0],moment,d.qfrc_actuator[0],c[33]+d.qfrc_actuator[0],d.qacc[0],d.efc_force[0] if d.nefc else 0.]
rows=[];labels=[]
def add(label,**kw):
 c=BASE.copy()
 ix=dict(mass=0,gravity=3,h=4,margin=5,gap=6,kind=13,tau=14,gain=15,enabled=16,clamp=17,early=18,climited=19,clower=20,cupper=21,alimit=22,alower=23,aupper=24,flimit=25,flower=26,fupper=27,z=28,v=29,time=30,act=31,u=32,applied=33,steps=34)
 for k,v in kw.items():c[ix[k]]=v
 rows.append(c);labels.append(label)
for kind,early,alimit,steps,z in itertools.product(range(4),[0,1],[0,1],[0,1,100],[.099,.105,.13]):
 if not kind and alimit:continue
 add('combination',kind=kind,early=early,alimit=alimit,act=.3,u=1.2,z=z,margin=.01,gap=.02,steps=steps,gain=4)
for kind in range(4):
 for flag in ['disabled','unclamped','force-limit']:
  add(flag,kind=kind,act=.6,u=1.4,early=1,steps=100,enabled=flag!='disabled',clamp=flag!='unclamped',flimit=flag=='force-limit',flower=.1,fupper=.25)
for tau in [-1.,0.,1e-15,1e-6,.02,1e10]:
 for kind in [2,3]:add('tau-edge',kind=kind,tau=tau,act=.1,u=.8,alimit=1,steps=1,early=1)
for margin,gap in [(0.,0.),(.01,0.),(.01,.005),(.01,.02)]:
 for offset in [0.,margin,margin+gap]:
  z=.1+offset
  for pos in [math.nextafter(z,-math.inf),z,math.nextafter(z,math.inf)]:add('contact-edge',z=pos,margin=margin,gap=gap,kind=3,act=.2,u=.7)
rng=random.Random(20260930)
for _ in range(180):
 add('random',kind=rng.randrange(4),z=rng.uniform(.095,.14),v=rng.uniform(-1,1),act=rng.uniform(0,.8),u=rng.uniform(-.2,1.2),gain=rng.uniform(0,20),mass=rng.uniform(.5,5),tau=rng.uniform(.01,.2),early=rng.randrange(2),alimit=1,margin=.01,gap=.02,applied=rng.uniform(-5,5),steps=rng.choice([0,1,10,100]))
data=''.join(' '.join(format(x,'.17g') for x in c)+'\n' for c in rows)
p=subprocess.run([str(a.binary)],input=data,text=True,capture_output=True)
(a.out/'inputs.txt').write_text(data);(a.out/'outputs.txt').write_text(p.stdout);(a.out/'stderr.txt').write_text(p.stderr)
assert p.returncode==0,p.stderr
actual=[list(map(float,s.split())) for s in p.stdout.splitlines()];assert len(actual)==len(rows)
errors=[0.]*14;references=[]
for idx,(c,x) in enumerate(zip(rows,actual)):
 y=oracle(c);references.append(y);assert x[:3]==y[:3],(idx,labels[idx],x,y)
 for col,(v,w) in enumerate(zip(x[3:],y[3:]),3):
  errors[col]=max(errors[col],abs(v-w));assert math.isfinite(v) and math.isclose(v,w,rel_tol=2e-10,abs_tol=2e-10),(idx,labels[idx],col,v,w,c)
(a.out/'reference.json').write_text(json.dumps(references))
# General body transmission: get contact descriptions and rows from C, feed
# only the port; compare its moment with C's full mj_transmission calculation.
kinputs=[];kexpected=[];models=[]
for cone,dim,ndof,z,gap,bodyid in itertools.product(['pyramidal','elliptic'],[1,3,4,6],[1,3],[.095,.105,.13],[0.,.02],[1,2]):
 joints=''.join(f'<joint type="slide" axis="{axis}" name="j{k}"/>' for k,axis in enumerate(['0 0 1','1 0 0','0 1 0'][:ndof]))
 x=f'<mujoco><option cone="{cone}" jacobian="dense"/><worldbody><geom type="plane" size="1 1 .1"/><body name="b">{joints}<geom type="sphere" size=".1" pos=".1 0 0"/><geom type="sphere" size=".1" pos="-.1 0 0"/></body><body name="other" pos="0 1 1"><geom type="sphere" size=".1"/></body></worldbody><default><geom condim="{dim}" margin=".01" gap="{gap}"/></default><actuator><adhesion body="{['','b','other'][bodyid]}" ctrlrange="0 1"/></actuator></mujoco>'
 m=mujoco.MjModel.from_xml_string(x);d=mujoco.MjData(m);d.qpos[0]=z;mujoco.mj_forward(m,d)
 cs=[];G=np.zeros((d.ncon,m.nv));J=d.efc_J.reshape((d.nefc,m.nv));moment=np.zeros(m.nv)
 adr=d.moment_rowadr[0];nnz=d.moment_rownnz[0];moment[d.moment_colind[adr:adr+nnz]]=d.actuator_moment[adr:adr+nnz]
 for i,c in enumerate(d.contact):
  rigid=all(g>=0 for g in c.geom);b1,b2=[int(m.geom_bodyid[g]) if g>=0 else 0 for g in c.geom]
  cs.extend([int(rigid),b1,b2,int(c.exclude),int(c.dim),max(0,int(c.efc_address))])
  if c.exclude==1 and rigid:
   j1=np.zeros((3,m.nv));j2=np.zeros_like(j1);mujoco.mj_jac(m,d,j1,None,c.pos,b1);mujoco.mj_jac(m,d,j2,None,c.pos,b2);G[i]=c.frame[:3]@(j2-j1)
 values=[d.ncon,d.nefc,m.nv,bodyid,int(cone=='elliptic'),*cs,*J.flat,*G.flat]
 kinputs.append(' '.join(format(v,'.17g') for v in values));kexpected.append(moment.tolist());models.append(x)
# Empty contact/row sets, flex placeholders and excluded 2/3 must be neutral.
kinputs += ['0 0 3 1 0','3 0 1 1 0 0 0 1 0 3 0 1 0 1 2 1 0 1 0 1 3 1 0 99 88 77']
kexpected += [[0.,0.,0.],[0.]]
kdata='\n'.join(kinputs)+'\n';r=subprocess.run([str(a.kernel)],input=kdata,text=True,capture_output=True)
(a.out/'kernel-inputs.txt').write_text(kdata);(a.out/'kernel-outputs.txt').write_text(r.stdout);(a.out/'kernel-stderr.txt').write_text(r.stderr)
assert r.returncode==0,r.stderr
kactual=[list(map(float,s.split())) for s in r.stdout.splitlines()];assert len(kactual)==len(kexpected)
kerror=0.
for i,(x,y) in enumerate(zip(kactual,kexpected)):
 assert np.allclose(x,y,atol=2e-12,rtol=2e-12),(i,x,y);kerror=max(kerror,float(np.max(np.abs(np.array(x)-y),initial=0)))
(a.out/'kernel-reference.json').write_text(json.dumps(kexpected));(a.out/'kernel-models.json').write_text(json.dumps(models))
# Both physical-state and activation-update failures must roll back all state.
fails=[]
for params in [dict(kind=1,act=1e10,u=1e10,climited=0,h=1.,steps=1),dict(kind=3,time=1e10,act=.2,u=.8,steps=1),dict(kind=0,gain=1e10,u=1e10,climited=0,steps=1),dict(kind=0,gain=1e10,u=1,applied=-1e10,steps=1)]:
 c=BASE.copy();ix=dict(kind=13,act=31,u=32,climited=19,h=4,steps=34,time=30,gain=15,applied=33)
 for k,v in params.items():c[ix[k]]=v
 r=subprocess.run([str(a.binary)],input=' '.join(format(x,'.17g') for x in c)+'\n',text=True,capture_output=True)
 assert r.returncode==0,r.stderr
 x=list(map(float,r.stdout.split()));assert x[0]==1 and x[3:7]==[c[28],c[29],c[30],c[31]],x;fails.append(x)
(a.out/'failures.json').write_text(json.dumps(fails))
summary=dict(reference=mujoco.__version__,coupled_cases=len(rows),coupled_scalar_comparisons=len(rows)*11,max_abs_error=errors,kernel_cases=len(kexpected),kernel_max_abs_error=kerror,atomic_failure_cases=len(fails),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),kernel_sha256=hashlib.sha256(a.kernel.read_bytes()).hexdigest())
(a.out/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
