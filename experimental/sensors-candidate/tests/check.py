"""Compare actual Ada-owned sensor stages and trajectories to official MuJoCo."""
import argparse,hashlib,json,subprocess
from pathlib import Path
import mujoco,numpy as np

def fixtures():
 common='''<site name="ref" pos=".2 -.3 .1" quat=".9238795325 0 0 .3826834324" size=".4"/>
 <body name="b" pos=".3 .1 .8"><joint name="j" type="hinge" axis="0 1 0" stiffness="2" damping=".2"/>
 <geom name="g" type="box" size=".12 .08 .1" mass="2" pos=".07 0 .03"/>
 <site name="s" pos=".05 .08 .02" quat=".9238795325 .3826834324 0 0" size=".2"/>
 <body name="child" pos=".1 .2 .3"><joint name="k" type="slide" axis="1 0 0" stiffness="1" damping=".1"/>
 <geom type="sphere" size=".07" mass="1"/><site name="tip" pos=".04 .03 .01"/></body></body>'''
 sensors='<jointpos joint="j"/><jointvel joint="j"/><jointactuatorfrc joint="j"/>'
 sensors+=''.join(f'<{s} site="s"/>' for s in ['accelerometer','velocimeter','gyro','force','torque','magnetometer'])
 sensors+=''.join(f'<{s} objtype="{t}" objname="{n}"/>' for s in ['framepos','framequat','framexaxis','frameyaxis','framezaxis','framelinvel','frameangvel','framelinacc','frameangacc'] for t,n in [('body','b'),('xbody','b'),('geom','g'),('site','s')])
 sensors+=''.join(f'<{s} objtype="site" objname="s" reftype="site" refname="ref"/>' for s in ['framepos','framequat','framexaxis','frameyaxis','framezaxis','framelinvel','frameangvel'])
 sensors+=''.join(f'<{s} body="{b}"/>' for s in ['subtreecom','subtreelinvel','subtreeangmom'] for b in ['world','b','child'])
 sensors+='<clock/><e_potential/><e_kinetic/>'
 yield 'scalar_frames',False,f'<mujoco><option timestep=".001" magnetic=".1 .3 -.2"><flag constraint="disable"/></option><worldbody>{common}</worldbody><sensor>{sensors}</sensor></mujoco>'
 for kind in ['ball','free']:
  j=f'<joint name="j" type="{kind}" stiffness="2" damping=".1"/>'
  ss=''.join(f'<{s} site="s"/>' for s in ['accelerometer','velocimeter','gyro','force','torque','magnetometer'])
  ss+=''.join(f'<{s} objtype="site" objname="s"/>' for s in ['framepos','framequat','framelinvel','frameangvel','framelinacc','frameangacc'])
  if kind=='ball':ss+='<ballquat joint="j"/><ballangvel joint="j"/>'
  ss+='<subtreecom body="b"/><subtreelinvel body="b"/><subtreeangmom body="b"/><e_potential/><e_kinetic/><clock/>'
  yield kind,False,f'<mujoco><option timestep=".001"><flag constraint="disable"/></option><worldbody><body name="b" pos=".1 -.1 .6">{j}<geom type="box" size=".1 .2 .15" mass="2"/><site name="s" pos=".12 .03 .04"/></body></worldbody><sensor>{ss}</sensor></mujoco>'
 # Several constrained algorithms/cones, nonzero contact reaction and limits.
 for solver in ['PGS','CG','Newton']:
  for cone in ['pyramidal']:
   ss=''.join(f'<{s} site="s"/>' for s in ['accelerometer','velocimeter','gyro','force','torque','touch'])
   ss+='<framelinacc objtype="site" objname="s"/><e_kinetic/><clock/>'
   yield 'contact_'+solver+'_'+cone,True,f'<mujoco><option timestep=".001" solver="{solver}" cone="{cone}" iterations="100"><flag warmstart="disable" island="disable"/></option><worldbody><geom type="plane" size="5 5 .1"/><body name="b" pos="0 0 .099"><freejoint/><geom type="sphere" size=".1" mass="1" condim="6" friction=".7 .01 .001"/><site name="s" pos="0 0 -.08" size=".15"/></body></worldbody><sensor>{ss}</sensor></mujoco>'
 for kind in ['hinge','slide','ball']:
  ss='<jointlimitpos joint="j"/><jointlimitvel joint="j"/><jointlimitfrc joint="j"/>'
  ss+=''.join(f'<{s} site="s"/>' for s in ['force','torque','accelerometer'])
  joint_range='0 .1' if kind=='ball' else '-.1 .1'
  yield 'limit_'+kind,True,f'<mujoco><compiler angle="radian"/><option timestep=".001"><flag warmstart="disable" island="disable" contact="disable"/></option><worldbody><body pos="0 0 .5"><joint name="j" type="{kind}" limited="true" range="{joint_range}" damping=".1"/><geom type="sphere" size=".1" mass="1"/><site name="s" pos=".04 0 .05"/></body></worldbody><sensor>{ss}</sensor></mujoco>'
 for sitekind,size in [('sphere','.3'),('box','.3 .3 .3'),('ellipsoid','.3 .4 .5'),('cylinder','.3 .5'),('capsule','.3 .5')]:
  yield 'inside_'+sitekind,False,f'<mujoco><option><flag constraint="disable"/></option><worldbody>{common}<site name="zone" type="{sitekind}" size="{size}" pos=".3 .1 .8"/></worldbody><sensor><insidesite objtype="site" objname="s" site="zone"/></sensor></mujoco>'


 # Rangefinder visibility follows material alpha when a material is assigned.
 for label,mat_alpha,geom_alpha in [('material_visible',1,0),('material_hidden',0,1)]:
  xml=f'<mujoco><option><flag constraint="disable"/></option><asset><material name="mat" rgba="1 1 1 {mat_alpha}"/></asset><worldbody><geom name="floor" type="plane" size="5 5 .1" material="mat" rgba="1 1 1 {geom_alpha}"/><body pos="0 0 .8"><joint type="slide" axis="0 0 1" damping=".1"/><geom type="sphere" size=".1" mass="1"/><site name="s" quat="0 1 0 0" size=".01"/></body></worldbody><sensor><rangefinder site="s"/><rangefinder site="s" data="dist dir origin point normal depth"/></sensor></mujoco>'
  yield 'range_'+label,False,xml.replace('<rangefinder site="s" data="dist dir origin point normal depth"/>','')
  yield 'range_'+label+'_fields',False,xml
 for target in ['mesh','hfield']:
  vertices='-1 -1 -1 1 -1 -1 1 1 -1 -1 1 -1 -1 -1 1 1 -1 1 1 1 1 -1 1 1'
  faces='0 2 1 0 3 2 4 5 6 4 6 7 0 1 5 0 5 4 1 2 6 1 6 5 2 3 7 2 7 6 3 0 4 3 4 7'
  asset=f'<mesh name="target" vertex="{vertices}" face="{faces}" scale=".4 .5 .1"/>' if target=='mesh' else '<hfield name="target" nrow="3" ncol="3" size="1 1 .3 .1"/>'
  xml=f'<mujoco><option><flag constraint="disable"/></option><asset>{asset}</asset><worldbody><geom type="{target}" {target}="target"/><body pos="0 0 .8"><joint type="slide" axis="0 0 1" damping=".1"/><geom type="sphere" size=".1" mass="1"/><site name="s" quat="0 1 0 0" size=".01"/></body></worldbody><sensor><rangefinder site="s"/><rangefinder site="s" data="dist dir origin point normal depth"/></sensor></mujoco>'
  yield 'range_'+target,False,xml.replace('<rangefinder site="s" data="dist dir origin point normal depth"/>','')
  yield 'range_'+target+'_fields',False,xml
 yield 'actuator_tendon',False,'<mujoco><option><flag constraint="disable"/></option><worldbody><body pos="0 0 .8"><joint name="j" type="slide" axis="1 0 0" damping=".1"/><geom type="sphere" size=".1" mass="1"/></body></worldbody><tendon><fixed name="t"><joint joint="j" coef="1.7"/></fixed></tendon><actuator><position name="a" joint="j" kp="2" gear="1.5"/></actuator><sensor><tendonpos tendon="t"/><tendonvel tendon="t"/><tendonactuatorfrc tendon="t"/><actuatorpos actuator="a"/><actuatorvel actuator="a"/><actuatorfrc actuator="a"/></sensor></mujoco>'
 yield 'camera',False,'<mujoco><option><flag constraint="disable"/></option><worldbody><camera name="cam" pos="0 0 3" resolution="640 480" fovy="45"/><body pos=".2 .1 .8"><joint type="slide" axis="1 0 0" damping=".1"/><geom type="sphere" size=".1" mass="1"/><site name="s" pos=".03 .04 .1" size=".01"/></body></worldbody><sensor><camprojection site="s" camera="cam"/></sensor></mujoco>'
 for offset in ['.25','.15']:
  yield 'distance_'+offset,False,f'<mujoco><option><flag constraint="disable"/></option><worldbody><geom name="g1" type="sphere" size=".1"/><body pos="{offset} 0 0"><joint type="slide" axis="1 0 0" damping=".1"/><geom name="g2" type="sphere" size=".1" mass="1"/></body></worldbody><sensor><distance geom1="g1" geom2="g2" cutoff="1"/><normal geom1="g1" geom2="g2" cutoff="1"/><fromto geom1="g1" geom2="g2" cutoff="1"/></sensor></mujoco>'

 # Constraint-backed sensors: every contact reduction, tendon limits and tactile channels.
 for reduction in ['none','mindist','maxforce','netforce']:
  sensors=''.join(f'<contact geom1="{a}" geom2="{b}" data="found force torque dist pos normal tangent" reduce="{reduction}" num="2"/>' for a,b in [('floor','g'),('g','floor')])
  yield 'contact_fields_'+reduction,True,f'<mujoco><option timestep=".001" iterations="100"><flag warmstart="disable" island="disable"/></option><worldbody><geom name="floor" type="plane" size="5 5 .1"/><body pos="0 0 .095"><freejoint/><geom name="g" type="sphere" size=".1" mass="1" condim="6" friction=".7 .01 .001"/></body></worldbody><sensor>{sensors}</sensor></mujoco>'
 yield 'tendon_limit',True,'<mujoco><option timestep=".001" gravity="0 0 0"><flag warmstart="disable" island="disable" contact="disable"/></option><worldbody><body><joint name="j" type="slide" axis="1 0 0" damping=".1"/><geom type="sphere" size=".1" mass="1"/></body></worldbody><tendon><fixed name="t" limited="true" range="-.1 .1"><joint joint="j" coef="1.7"/></fixed></tendon><sensor><tendonlimitpos tendon="t"/><tendonlimitvel tendon="t"/><tendonlimitfrc tendon="t"/></sensor></mujoco>'
 for builtin,params in [('sphere','0'),('wedge','3 3 45 45 0')]:
  yield 'tactile_'+builtin,True,f'<mujoco><option timestep=".001" iterations="100"><flag warmstart="disable" island="disable"/></option><asset><mesh name="taxels" builtin="{builtin}" params="{params}" scale=".1 .1 .1"/></asset><worldbody><geom type="plane" size="5 5 .1"/><body pos="0 0 .07"><freejoint/><geom name="g" type="sphere" size=".1" mass="1" condim="3"/></body></worldbody><sensor><tactile geom="g" mesh="taxels"/></sensor></mujoco>'

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=8);p.add_argument('--steps',type=int,default=30);p.add_argument('--only');a=p.parse_args()
 a.out.mkdir(parents=True,exist_ok=False);rng=np.random.default_rng(20261002);records=[];failures=[];types=set()
 for name,constrained,xml in fixtures():
  if a.only and a.only not in name:continue
  try:m=mujoco.MjModel.from_xml_string(xml)
  except Exception as e:failures.append(dict(model=name,error=str(e)));print('MODEL',name,e,flush=True);continue
  if name.startswith('range_hfield'):m.hfield_data[:]=[0,.2,.4,.1,.6,.8,.2,.4,1]
  types.update(map(int,m.sensor_type));f=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(f));(a.out/(name+'.xml')).write_text(xml)
  for sample in range(a.samples):
   q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-.4,.4,m.nv),.05)
   if name.startswith('tendon_limit'):q[0]=.15
   if name.startswith('contact_fields_'):q[2]=.095
   if name.startswith('tactile_'):q[2]=.07
   if name.startswith('limit_'):
    if name.endswith('ball'):q[:]=[np.cos(.07),np.sin(.07),0,0]
    else:q[0]=.15
   v=rng.uniform(-.3,.3,m.nv);d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v
   expected=[]
   for t in range(a.steps+1):
    mujoco.mj_forward(m,d);expected.append(d.sensordata.copy())
    if t<a.steps:mujoco.mj_step(m,d)
   command=[str(a.binary),str(f)]+(['constrained'] if constrained else [])
   inputs=[a.steps,*q,*v]
   run=subprocess.run(command,input=' '.join(format(float(x),'.17g') for x in inputs)+'\n',text=True,capture_output=True,timeout=120)
   lines=[l[2:] for l in run.stdout.splitlines() if l.startswith('S ')]
   actual=np.empty((0,));ref=np.array(expected)
   try:actual=np.array([[float(x) for x in l.split()] for l in lines]);ref=np.array(expected);delta=np.abs(actual-ref);ok=run.returncode==0 and actual.shape==ref.shape and np.allclose(actual,ref,atol=3e-7 if constrained else 2e-10,rtol=2e-8 if constrained else 2e-10)
   except Exception:ok=False;delta=np.array([np.inf])
   record=dict(model=name,sample=sample,passed=bool(ok),max_abs=float(np.max(delta)) if delta.size else 0.,comparisons=int(delta.size))
   if not ok:
    record['output']=run.stdout[-1400:]+run.stderr[-400:]
    if actual.shape==ref.shape and ref.size:
     indices=np.argwhere(~np.isclose(actual,ref,atol=3e-7 if constrained else 2e-10,rtol=2e-8 if constrained else 2e-10))
     record['mismatches']=[dict(step=int(t),index=int(i),ada=float(actual[t,i]),c=float(ref[t,i])) for t,i in indices[:12]]
    failures.append(record);print('FAIL',json.dumps(record),flush=True)
   records.append(record)
  print(name,'checked',flush=True)
 result=dict(reference=mujoco.__version__,test_source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),cases=len(records),passed=sum(r['passed'] for r in records),sensor_types=sorted(types),comparisons=sum(r['comparisons'] for r in records),steps=a.steps,failures=failures,records=records)
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
