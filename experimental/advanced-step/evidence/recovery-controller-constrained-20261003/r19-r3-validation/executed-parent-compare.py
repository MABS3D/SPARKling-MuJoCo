"""Compare a complete constrained Ada path with the official C engine.

No C-supplied contacts, rows, response coefficients or solved forces enter Ada.
The sole common input is an MJB model, state, controls and applied forces.
"""
import argparse, hashlib, json, subprocess
from pathlib import Path
import mujoco
import numpy as np

def model_xml(body, *, dim=3, solver='Newton', damp=.2, plane=True):
 return f'''<mujoco><compiler angle="radian"/>
 <option timestep="0.001" solver="{solver}" iterations="200" tolerance="1e-12" cone="pyramidal" jacobian="sparse">
 <flag warmstart="disable" island="disable"/></option>
 <default><joint damping="{damp}"/><geom condim="{dim}" friction="0.6 0.015 0.004" solref="0.025 1.1"/></default>
 <worldbody>{'<geom type="plane" size="2 2 .1"/>' if plane else ''}{body}</worldbody></mujoco>'''

def fixtures():
 for solver in ['PGS','CG','Newton']:
  for dim in [1,3,4,6]:
   for damp in [0,.2]:
    yield f'sphere_{solver}_{dim}_{damp}',model_xml('<body pos="0 0 .095"><joint type="free"/><geom type="sphere" size=".1" mass="1"/></body>',dim=dim,solver=solver,damp=damp)
 yield 'coupled_limits_friction',model_xml('''<body pos="0 0 .09">
 <joint type="slide" axis="1 0 0" frictionloss=".1"/>
 <joint type="slide" axis="0 1 0" frictionloss=".2"/>
 <joint type="slide" axis="0 0 1" range="0 .2" margin=".015"/>
 <geom type="sphere" size=".1" mass="1"/></body>''')
 yield 'hinge_contact',model_xml('''<body pos="0 0 .15"><joint type="hinge" axis="0 1 0" range="-.1 .1" margin=".02"/>
 <geom type="sphere" pos=".2 0 -.055" size=".1" mass="1"/></body>''')
 yield 'ball_limit',model_xml('''<body pos="0 0 .095"><joint type="ball" range="0 .15" margin=".02"/>
 <geom type="sphere" pos=".04 0 0" size=".1" mass="1"/></body>''')
 yield 'box_multiple',model_xml('<body pos="0 0 .095"><joint type="free"/><geom type="box" size=".1 .1 .1" mass="1"/></body>')
 yield 'shared_ancestors',model_xml('''<body pos="0 0 .5"><joint type="free"/><geom type="sphere" size=".03" mass="1" contype="0" conaffinity="0"/>
 <body pos="-.08 0 0"><joint type="slide" axis="1 0 0"/><geom type="sphere" size=".1" mass="1"/></body>
 <body pos=".08 0 0"><joint type="slide" axis="1 0 0"/><geom type="sphere" size=".1" mass="1"/></body></body>''',plane=False)
 for kind,size in [('capsule','.07 .08'),('ellipsoid','.11 .08 .09'),('cylinder','.09 .08')]:
  yield kind,model_xml(f'<body pos="0 0 .08"><joint type="free"/><geom type="{kind}" size="{size}" mass="1"/></body>')
 motor=model_xml('<body pos="0 0 .09"><joint name="z" type="slide" axis="0 0 1" range="0 .2" margin=".015"/><geom type="sphere" size=".1" mass="1"/></body>')
 yield 'motor_limit_contact',motor.replace('</mujoco>','<actuator><motor joint="z" gear="2"/></actuator></mujoco>')
 yield 'no_contacts',model_xml('<body pos="0 0 1"><joint type="free"/><geom type="sphere" size=".1" mass="1"/></body>')
 yield 'margin_gap',model_xml('<body pos="0 0 .109"><joint type="free"/><geom type="sphere" size=".1" mass="1" margin=".004" gap=".015"/></body>')
 for solver in ['PGS','CG','Newton']:
  for power in [0.,1.25,1.5,2.5,3.,8.]:
   impedance=f'.9 .95 .005 .3 {power}'
   body=f'''<body pos="0 0 .0995"><joint type="slide" axis="0 0 1"
    range="0 .2" margin=".001" frictionloss=".05"
    solimplimit="{impedance}" solimpfriction="{impedance}"/>
    <geom type="sphere" size=".1" mass="1" solimp="{impedance}"/></body>'''
   yield f'solimp_{solver}_{power}',model_xml(body,solver=solver)

def parse(text,nv,na=0):
 lines=iter(text.splitlines());results=[]
 for line in lines:
  if not line:continue
  if not line.startswith('counts '):raise ValueError(text)
  v=np.fromstring(line[7:],sep=' ');r={'counts':v}
  for key in ['free','acc','qfrc','aref','reg','force']:
   line=next(lines); assert line.split()[0]==key,line
   r[key]=np.fromstring(line[len(key):],sep=' ')
  nr=int(v[1]);rows=[]
  for _ in range(nr):
   line=next(lines);assert line.startswith('jac '),line;rows.append(np.fromstring(line[4:],sep=' '))
  r['jac']=np.array(rows).reshape(nr,nv)
  if na:
   line=next(lines);assert line.startswith('act_dot '),line;r['act_dot']=np.fromstring(line[8:],sep=' ')
  line=next(lines);assert line.startswith('state '),line;r['state']=np.fromstring(line[6:],sep=' ')
  if na:
   line=next(lines);assert line.startswith('activation '),line;r['activation']=np.fromstring(line[11:],sep=' ')
  results.append(r)
 return results

def oracle(m,q,v,applied,steps,ctrl=None,loads=None,act=None):
 d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.qfrc_applied[:]=applied
 if ctrl is not None:d.ctrl[:]=ctrl
 if loads is not None:d.xfrc_applied[:]=loads
 if act is not None:d.act[:]=act
 mujoco.mj_forward(m,d);nr=d.nefc
 J=np.zeros((nr,m.nv))
 if mujoco.mj_isSparse(m):
  for i in range(nr):
   adr=d.efc_J_rowadr[i];n=d.efc_J_rownnz[i]
   J[i,d.efc_J_colind[adr:adr+n]]=d.efc_J[adr:adr+n]
 else:
  J[:]=d.efc_J.reshape(nr,m.nv)
 r={k:np.array(val).copy() for k,val in dict(counts=[d.ncon,nr],free=d.qacc_smooth,acc=d.qacc,
  qfrc=d.qfrc_constraint,aref=d.efc_aref,reg=d.efc_R,force=d.efc_force,jac=J).items()}
 if m.na:r['act_dot']=d.act_dot.copy()
 for _ in range(steps):mujoco.mj_step(m,d)
 r['state']=np.r_[d.qpos,d.qvel,d.time]
 if m.na:r['activation']=d.act.copy()
 return r

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--loads',action='store_true');p.add_argument('--samples',type=int,default=5);p.add_argument('--steps',type=int,default=30);p.add_argument('--only');a=p.parse_args()
 assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
 rng=np.random.default_rng(241002);records=[];failures=[]
 for name,xml in fixtures():
  if a.only and a.only not in name:continue
  m=mujoco.MjModel.from_xml_string(xml);file=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(file))
  samples=[];refs=[]
  for i in range(a.samples):
   q=m.qpos0.copy()
   if i:
    mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.008)
   if name=='ball_limit':q[:]=[np.cos(.11),0,np.sin(.11),0]
   if name=='hinge_contact':q[:]=.11
   v=rng.uniform(-.1,.1,m.nv);applied=rng.uniform(-.1,.1,m.nv)
   ctrl=rng.uniform(-.2,.2,m.nu);loads=rng.uniform(-.1,.1,(m.nbody,6)) if a.loads else None
   act=rng.uniform(-.2,.8,m.na)
   samples.extend([0.,*q,*v,*applied,*ctrl,*act])
   if a.loads:samples.extend(loads.ravel())
   refs.append(oracle(m,q,v,applied,a.steps,ctrl,loads,act))
  data=f'{a.samples} {a.steps}\n'+' '.join(format(x,'.17g') for x in samples)+'\n'
  run=subprocess.run([str(a.binary),str(file)]+(["loads"] if a.loads else []),input=data,text=True,capture_output=True,timeout=180)
  (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
  if run.returncode or run.stdout.startswith('create'):
   failures.append(dict(model=name,error=run.stdout[-1800:]));print('FAIL',name,run.stdout[-800:],flush=True);continue
  try: actual=parse(run.stdout,m.nv,m.na)
  except Exception as e:failures.append(dict(model=name,error=str(e)));continue
  assert len(actual)==len(refs)
  for i,(x,y) in enumerate(zip(actual,refs)):
   error={}
   for key in y:
    if x[key].shape!=y[key].shape:error[key]=dict(shape_ada=x[key].shape,shape_c=y[key].shape);continue
    delta=float(np.max(np.abs(x[key]-y[key]))) if y[key].size else 0.
    tol=2e-10 if key in ['counts','free','jac','aref','reg'] else 3e-6
    passed=bool(np.allclose(x[key],y[key],atol=tol,rtol=1e-8 if tol>1e-8 else 2e-12))
    error[key]=dict(max_abs=delta,passed=passed)
   ok=all(v.get('passed',False) for v in error.values())
   record=dict(model=name,sample=i,passed=ok,errors=error);records.append(record)
   if not ok:failures.append(record);print('FAIL',name,i,{k:v for k,v in error.items() if not v.get('passed',False)},flush=True)
  print(name,'checked',flush=True)
 result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
  steps=a.steps,cases=len(records),passed=sum(r['passed'] for r in records),failures=failures,records=records)
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'failures',len(failures))
 if failures:raise SystemExit(1)
if __name__=='__main__':main()
