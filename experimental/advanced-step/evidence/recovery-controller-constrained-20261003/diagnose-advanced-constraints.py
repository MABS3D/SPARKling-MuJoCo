from pathlib import Path
import sys,json,subprocess
import numpy as np,mujoco
sys.path.insert(0,'/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/advanced-step/tests');from compare import parse
src=Path('/var/tmp/sparkling-services-advanced-constrained-r13-newton-pyramidal-20261003');out=Path('/var/tmp/sparkling-services-advanced-constrained-r13-isolation-20261003');out.mkdir(exist_ok=True)
binary='/var/tmp/sparkling-services-advanced-constrained-r13-r1-20261003/build/validation/bin/constrained_advanced_probe';records=[]
for name in ['pid_ball_00_0','so3_joint_quat_0','global_disabled']:
 for variant in ['base','no-ball-limit','no-friction','no-contact']:
  m=mujoco.MjModel.from_binary_path(str(src/(name+'.mjb')))
  if variant=='no-ball-limit':m.jnt_limited[m.jnt_type==mujoco.mjtJoint.mjJNT_BALL]=0
  if variant=='no-friction':m.dof_frictionloss[:]=0
  if variant=='no-contact':m.opt.disableflags|=mujoco.mjtDisableBit.mjDSBL_CONTACT
  path=out/(name+'-'+variant+'.mjb');mujoco.mj_saveModel(m,str(path));data=(src/(name+'.input')).read_text()
  r=subprocess.run([binary,str(path),'loads'],input=data,capture_output=True,text=True,timeout=30);got=parse(r.stdout);expect=[]
  for line in data.splitlines()[1:]:
   vals=list(map(float,line.split()));steps=int(vals[0]);d=mujoco.MjData(m);d.time=vals[1];i=2
   for arr in [d.qpos,d.qvel,d.ctrl,d.act,d.qfrc_applied,d.xfrc_applied.ravel()]:arr[:]=vals[i:i+arr.size];i+=arr.size
   mujoco.mj_forward(m,d);ref={'acc':d.qacc.copy()}
   for _ in range(steps):mujoco.mj_step(m,d)
   ref['state']=np.r_[d.qpos,d.qvel,d.time,d.act];expect.append(ref)
  failures=[{'sample':i,**{k:float(np.max(np.abs(a[k]-v)))for k,v in b.items()if not np.allclose(a[k],v,atol=2e-10,rtol=2e-10)}}for i,(a,b)in enumerate(zip(got,expect))];failures=[x for x in failures if len(x)>1]
  record=dict(model=name,variant=variant,failures=failures);records.append(record);print(name,variant,len(failures),flush=True)
(out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
