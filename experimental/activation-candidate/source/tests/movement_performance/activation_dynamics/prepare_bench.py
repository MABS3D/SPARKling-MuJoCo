from pathlib import Path
import sys,json
import numpy as np,mujoco
R=Path(__file__).resolve().parents[3];sys.path.insert(0,str(R/'experimental/smooth/tools'));import compare_numerics as base
out=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parent/'fixtures';out.mkdir(exist_ok=True);rng=np.random.default_rng(51927);cases=[]
for dofs,actuators in [(1,1),(6,6),(24,24),(1,64),(6,192),(24,192)]:
 for kind in ['integrator','filter','filterexact']:
  name=f'{kind}-{dofs}dof-{actuators}act';body=''
  for j in reversed(range(dofs)):
   body=f'<body pos=".12 0 .1"><joint name="j{j}" axis="0 1 0" armature=".08" damping=".2"/><inertial pos=".05 0 0" mass="1" diaginertia=".1 .2 .3"/>{body}</body>'
  acts=''.join(f'<general joint="j{i%dofs}" dyntype="{kind}" dynprm=".02" actearly="true" actlimited="true" actrange="-.8 .8" ctrllimited="true" ctrlrange="-1 1" gainprm="{dofs/actuators}"/>' for i in range(actuators))
  xml=base.model_xml(body,acts);(out/(name+'.xml')).write_text(xml);m=mujoco.MjModel.from_xml_string(xml);mujoco.mj_saveModel(m,str(out/(name+'.mjb')))
  q=rng.uniform(-.1,.1,m.nq);v=rng.uniform(-.1,.1,m.nv);u=rng.uniform(-.8,.8,m.nu);f=rng.uniform(-.1,.1,m.nv);a=rng.uniform(-.2,.2,m.na)
  (out/(name+'.input')).write_text(' '.join(map(str,[*q,*v,*u,*f,*a]))+'\n')
  d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=u;d.qfrc_applied[:]=f;d.act[:]=a;d.time=.125;mujoco.mj_forward(m,d);expected=dict(qacc=d.qacc.tolist(),force=d.actuator_force.tolist(),act_dot=d.act_dot.tolist())
  for _ in range(100):mujoco.mj_step(m,d)
  expected.update(qpos=d.qpos.tolist(),qvel=d.qvel.tolist(),act=d.act.tolist(),time=[d.time]);(out/(name+'.expected.json')).write_text(json.dumps(expected));cases.append(name)
(out/'cases.json').write_text(json.dumps(cases));print(len(cases),'cases')
