from pathlib import Path
import sys,subprocess,json,hashlib
import numpy as np, mujoco
R=Path(__file__).resolve().parents[3];sys.path.insert(0,str(R/'experimental/smooth/tools'))
import compare_numerics as base
out=Path(sys.argv[1]);out.mkdir(exist_ok=False);probe=Path(sys.argv[2]);policy=sys.argv[3] if len(sys.argv)>3 else 'Compatible';rng=np.random.default_rng(20260927)
summary={'oracle':mujoco.__version__,'policy':policy,'probe':str(probe),'sha256':base.digest(probe),'scenarios':0,'comparisons':0,'max_error':{},'models':[]}
body='<body><joint name="j" axis="0 1 0" armature=".1" damping=".2"/><inertial pos=".2 0 0" mass="1" diaginertia=".1 .2 .3"/></body>'
for kind in ['integrator','filter','filterexact']:
 for early in [False,True]:
  for limited in [False,True]:
   for flag in ['', 'actuation="disable"', 'clampctrl="disable"']:
    name=f'{kind}-{early}-{limited}-{flag[:5] or "normal"}'
    act=f'<general joint="j" dyntype="{kind}" dynprm=".02" actearly="{str(early).lower()}" gainprm="1.7" biastype="affine" biasprm=".1 -.3 -.2" gear="-.7" ctrllimited="true" ctrlrange="-.5 .8" forcelimited="true" forcerange="-1 1.2"'
    if limited:act+=' actlimited="true" actrange="-.3 .4"'
    act+='/><motor joint="j" gear=".2"/>'
    xml=base.model_xml(body,act,flag);m=mujoco.MjModel.from_xml_string(xml);path=out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(out/(name+'.xml')).write_text(xml)
    scenarios=[];lines=['12']
    for i in range(12):
     q=rng.uniform(-.5,.5,m.nq);v=rng.uniform(-.5,.5,m.nv);u=rng.uniform(-2,2,m.nu);f=rng.uniform(-.1,.1,m.nv);a=rng.uniform(-.7,.7,m.na);steps=100 if i%3==0 else 1
     values=[*q,*v,*u,*f,*a,.125,steps];lines.append(' '.join(map(str,values)))
     d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=u;d.qfrc_applied[:]=f;d.act[:]=a;d.time=.125;mujoco.mj_forward(m,d)
     expected={'qacc':d.qacc.copy(),'force':d.actuator_force.copy(),'act_dot':d.act_dot.copy()}
     for _ in range(steps):mujoco.mj_step(m,d)
     expected.update(qpos=d.qpos.copy(),qvel=d.qvel.copy(),act=d.act.copy(),time=np.array([d.time]));scenarios.append(expected)
    data='\n'.join(lines)+'\n';(out/(name+'.input')).write_text(data)
    r=subprocess.run([str(probe),str(path),policy],input=data,text=True,capture_output=True);(out/(name+'.output')).write_text(r.stdout+r.stderr)
    if r.returncode:raise RuntimeError((name,r.stdout[-500:],r.stderr))
    rows=base.parse_output(r.stdout)
    for actual,expected in zip(rows,scenarios,strict=True):
     assert actual['forward']=='SUCCESS' and actual['step']=='SUCCESS',(name,actual)
     for k,x in expected.items():
      y=actual[k];err=np.abs(x-y);assert x.shape==y.shape and np.all(err<=2e-10+2e-10*abs(x)),(name,k,x,y)
      summary['max_error'][k]=max(summary['max_error'].get(k,0),float(np.max(err,initial=0)));summary['comparisons']+=x.size
     summary['scenarios']+=1
    summary['models'].append(name);print(name,'PASS',flush=True)
(out/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
