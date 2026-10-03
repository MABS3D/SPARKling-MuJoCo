import argparse, pathlib, sys, subprocess, json, hashlib
import numpy as np, mujoco
ROOT=pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experimental/smooth/tools'))
from compare_numerics import fixtures, model_xml

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--samples',type=int,default=4);p.add_argument('--steps',type=int,default=100);p.add_argument('--only');p.add_argument('--integrator',choices=['RK4','implicit','implicitfast','discrete']);a=p.parse_args()
 assert mujoco.__version__=='3.14.0'
 a.out.mkdir(parents=True,exist_ok=False);rng=np.random.default_rng(261002);records=[];fail=[]
 cases=fixtures()
 inertia='<inertial pos=".1 -.03 .07" mass="1.3" diaginertia=".12 .18 .21"/>'
 cases['ball']=model_xml('<body><joint name="j" type="ball" damping=".2" stiffness=".3"/>'+inertia+'</body>','<general joint="j" gear=".4 -.2 .7" biastype="affine" biasprm="0 -.8 -.3"/>')
 cases['free']=model_xml('<body><freejoint name="j"/>'+inertia+'</body>','<general joint="j" gear=".4 -.2 .7 .3 -.1 .8" biastype="affine" biasprm="0 0 -.3"/>')
 cases['free_plain']=model_xml('<body><freejoint/>'+inertia+'</body>')
 cases['free_pgs']=cases['free'].replace('<option timestep=', '<option solver="PGS" timestep=')
 cases['free_tolerance_loose']=cases['free'].replace('<option timestep=', '<option tolerance=".001" timestep=')
 cases['free_tolerance_tight']=cases['free'].replace('<option timestep=', '<option tolerance="1e-13" timestep=')
 cases['muscle']=model_xml('<body><joint name="j" type="slide" damping=".1"/>'+inertia+'</body>', '<muscle joint="j" lengthrange="0 1"/>')
 cases['exact_filter']=model_xml('<body><joint name="j" type="slide" damping=".1"/>'+inertia+'</body>', '<general joint="j" dyntype="filterexact" dynprm=".05" biastype="affine" biasprm="0 -2 -.3" actearly="true" actlimited="true" actrange="0 1"/>')
 cases['fluid_box']=model_xml('<body><joint name="j" type="ball"/>'+inertia+'</body>').replace('<option timestep=', '<option density="1.1" viscosity=".003" wind=".1 -.2 .05" timestep=')
 cases['fluid_ellipsoid']=model_xml('<body><freejoint/>'+inertia+'<geom type="ellipsoid" size=".13 .2 .3" fluidshape="ellipsoid" fluidcoef=".5 .2 .4 .7 .3"/></body>').replace('<option timestep=', '<option density="1.1" viscosity=".003" wind=".1 -.2 .05" timestep=')
 cases['fluid_ellipsoid_ball']=cases['fluid_ellipsoid'].replace('<freejoint/>','<joint type="ball"/>')
 cases['fluid_fixed_descendant']=model_xml('<body><freejoint/>'+inertia+'<body pos=".1 .2 .3"><geom type="ellipsoid" size=".13 .2 .3" fluidshape="ellipsoid" fluidcoef=".5 .2 .4 .7 .3"/></body></body>').replace('<option timestep=', '<option density="1.1" viscosity=".003" wind=".1 -.2 .05" timestep=')
 tendon_body='<site name="anchor" pos="1 0 0"/><body><joint name="j" type="slide" axis="1 0 0"/>'+inertia+'<site name="end" pos="0 0 0"/></body>'
 cases['fixed_tendon']=model_xml(tendon_body).replace('</mujoco>','<tendon><fixed stiffness="2" damping=".3" springlength=".2 .4" armature=".05"><joint joint="j" coef=".7"/></fixed></tendon></mujoco>')
 cases['spatial_tendon']=model_xml(tendon_body).replace('</mujoco>','<tendon><spatial stiffness="2" damping=".3" springlength=".2 .4"><site site="anchor"/><site site="end"/></spatial></tendon></mujoco>')
 for name in ['fixed_tendon','spatial_tendon','ball']:
  cases[name+'_pgs']=cases[name].replace('<option timestep=', '<option solver="PGS" timestep=')
 for mode in ([a.integrator] if a.integrator else ['RK4','implicit','implicitfast','discrete']):
  for name,xml in cases.items():
   if a.only and a.only not in name:continue
   model=mujoco.MjModel.from_xml_string(xml.replace('integrator="Euler"','integrator="'+mode+'"'));path=a.out/(mode+'_'+name+'.mjb');mujoco.mj_saveModel(model,str(path))
   for sample in range(a.samples):
    d=mujoco.MjData(model);d.qpos[:]=model.qpos0;mujoco.mj_integratePos(model,d.qpos,rng.uniform(-.3,.3,model.nv),.02)
    d.qvel[:]=rng.uniform(-.3,.3,model.nv);d.ctrl[:]=rng.uniform(-.2,.2,model.nu);d.qfrc_applied[:]=rng.uniform(-.1,.1,model.nv);d.act[:]=rng.uniform(.1,.5,model.na);d.time=.03
    data=' '.join(format(x,'.17g') for x in np.r_[d.time,d.qpos,d.qvel,d.ctrl,d.qfrc_applied,d.act])+'\n'
    for _ in range(a.steps):mujoco.mj_step(model,d)
    run=subprocess.run([str(a.binary),str(path),str(a.steps)],input=data,text=True,capture_output=True,timeout=180)
    lines=run.stdout.splitlines();state=[l for l in lines if l.startswith('state')]
    good=run.returncode==0 and 'create SUCCESS' in run.stdout and 'step ' not in run.stdout and len(state)==1 and 'edges PASS' in run.stdout
    error=None
    if good:
     actual=np.fromstring(state[0][5:],sep=' ');expected=np.r_[d.qpos,d.qvel,d.time,d.act]
     error=float(np.max(np.abs(actual-expected))) if actual.size else 0.0
     good=actual.shape==expected.shape and bool(np.allclose(actual,expected,atol=2e-10,rtol=2e-10))
    r=dict(mode=mode,model=name,sample=sample,passed=good,max_abs=error)
    if not good:r['output']=run.stdout[-1600:];fail.append(r);print('FAIL',mode,name,sample,error,run.stdout[-180:],flush=True)
    records.append(r)
   print(mode,name,'checked',flush=True)
 result=dict(reference=mujoco.__version__,cases=len(records),passed=sum(r['passed'] for r in records),failures=fail,records=records,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),steps=a.steps)
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases']);raise SystemExit(bool(fail))
if __name__=='__main__':main()
