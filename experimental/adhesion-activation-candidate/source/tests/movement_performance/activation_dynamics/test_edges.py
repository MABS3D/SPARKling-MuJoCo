from pathlib import Path
import sys,subprocess,json
import numpy as np,mujoco
root=Path(__file__).resolve().parent;sys.path.insert(0,str(root.parents[2]/'experimental/smooth/tools'));import compare_numerics as h
probe=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(exist_ok=False);cases=[];summaries=[]
# Scalar tau floor, cancellation regime and saturated exact-filter factor.
body='<body><joint name="j" type="slide"/><inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/></body>'
for tau in [-1,0,1e-20,.00005,.1,1e10]:
 for early in ['false','true']:
  for control,activation in [(0.3,-.2),(1e10,0.)]:
   act=f'<general joint="j" dyntype="filterexact" dynprm="{tau}" actearly="{early}" gainprm="1e-6"/>'
   xml=h.model_xml(body,act,gravity='0 0 0');m=mujoco.MjModel.from_xml_string(xml);a=np.array([activation]);q=np.zeros(1);v=np.zeros(1);u=np.array([control]);f=np.zeros(1)
   cases.append((f'exact-{tau}-{early}-{control}',xml,m,q,v,u,f,a,2))
# 18 multi-DOF models, up to 192 active scalars.
inputs=root/'fixtures'
for name in json.loads((inputs/'cases.json').read_text()):
 xml=(inputs/(name+'.xml')).read_text();m=mujoco.MjModel.from_xml_string(xml);x=np.fromstring((inputs/(name+'.input')).read_text(),sep=' ');n=m.nq;u=m.nu
 cases.append((name,xml,m,x[:n],x[n:2*n],x[2*n:2*n+u],x[2*n+u:3*n+u],x[3*n+u:],100))
# Mixed active/stateless actuators exercise compact actadr with gaps in ctrl.
rng=np.random.default_rng(82641)
for n in [1,6,24]:
 body=''.join(f'<body pos="{i*.1} 0 1"><joint name="j{i}" type="slide" damping=".1"/><inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/></body>' for i in range(n))
 kinds=['none','integrator','filter','filterexact']
 acts=''.join(f'<general joint="j{i%n}" dyntype="{kinds[i%4]}" dynprm=".05" gainprm=".1" actearly="{str(i%2==1).lower()}"/>' for i in range(4*n))
 xml=h.model_xml(body,acts);m=mujoco.MjModel.from_xml_string(xml)
 q=rng.uniform(-.1,.1,m.nq);v=rng.uniform(-.1,.1,m.nv);u=rng.uniform(-.2,.2,m.nu);f=rng.uniform(-.1,.1,m.nv);a=rng.uniform(-.1,.1,m.na)
 cases.append((f'mixed-{n}',xml,m,q,v,u,f,a,100))
# Maximum activation capacity, with all three dynamics types in one model.
body='<body><joint name="j" type="slide"/><inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/></body>'
kinds=['integrator','filter','filterexact']
acts=''.join(f'<general joint="j" dyntype="{kinds[i%3]}" dynprm=".05" gainprm=".1"/>' for i in range(1024))
xml=h.model_xml(body,acts);m=mujoco.MjModel.from_xml_string(xml)
cases.append(('capacity-1024',xml,m,np.zeros(1),np.zeros(1),rng.uniform(-.2,.2,m.nu),np.zeros(1),rng.uniform(-.1,.1,m.na),3))
for name,xml,m,q,v,u,f,a,steps in cases:
 path=out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(out/(name+'.xml')).write_text(xml);external=rng.uniform(-.1,.1,(m.nbody,6)) if name.startswith('mixed-') else None; extra=[] if external is None else list(external.ravel());data='1\n'+' '.join(map(str,[*q,*v,*u,*f,*a,*extra,.125,steps]))+'\n';(out/(name+'.input')).write_text(data)
 d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=u;d.qfrc_applied[:]=f;d.act[:]=a;d.time=.125;
 if external is not None:d.xfrc_applied[:]=external
 mujoco.mj_forward(m,d);want=dict(qacc=d.qacc.copy(),force=d.actuator_force.copy(),act_dot=d.act_dot.copy())
 for _ in range(steps):mujoco.mj_step(m,d)
 want.update(qpos=d.qpos.copy(),qvel=d.qvel.copy(),act=d.act.copy(),time=np.array([d.time]));r=subprocess.run([str(probe),str(path)] + (['Compatible','external'] if external is not None else []),input=data,text=True,capture_output=True,timeout=90);(out/(name+'.output')).write_text(r.stdout+r.stderr);assert r.returncode==0,(name,r.stdout[-300:],r.stderr)
 actual,=h.parse_output(r.stdout);assert actual['forward']==actual['step']=='SUCCESS',(name,actual)
 err={}
 for k,x in want.items():
  delta=abs(x-actual[k]);assert np.all(delta<=2e-10+2e-10*abs(x)),(name,k,x,actual[k]);err[k]=float(delta.max(initial=0))
 summaries.append(dict(name=name,max_error=err));print(name,'PASS',flush=True)
(out/'summary.json').write_text(json.dumps(dict(scenarios=len(cases),probe=str(probe),sha256=h.digest(probe),results=summaries),indent=2))
