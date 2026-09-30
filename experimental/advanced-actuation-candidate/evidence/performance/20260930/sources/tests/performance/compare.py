"""Compare complete actuation batches with native MuJoCo C; no Python in timed loops.

These are actuation-stage measurements, not whole movement/trajectory results.
Precomputed site/contact Jacobians favor the candidate in those diagnostic cases.
A failed equivalent joint-stage comparison rejects integration; a positive result
alone would still require equivalent preparation, complete proofs and trajectories.
"""
from pathlib import Path
import argparse,ctypes as ct,hashlib,json,os,platform,subprocess,time
import mujoco,numpy as np

here=Path(__file__).resolve().parents[2];repo=here.parents[1]
scratch=Path('/var/tmp/sparkling-actuators-performance-20260930')
toolchain=Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnat/gnat-x86_64-linux-16.1.0-1')
native=Path('/var/tmp/sparkling-movement-c');lib=native/'build/lib/libmujoco.so.3.14.0'
oracle=Path('/var/tmp/sparkling-actuators-20260930/oracle/oracle.c')
assert mujoco.__version__=='3.14.0'
private=ct.CDLL(str(oracle.with_suffix('.so')))
private.mj_nextActivation.restype=ct.c_double
private.mj_nextActivation.argtypes=[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,ct.c_double]

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def write_numbers(path,values):path.write_text(' '.join(format(float(x),'.17g') for x in values)+'\n')
def common(m,first,second):
 a=int(m.body_dofadr[first]+m.body_dofnum[first]-1);b=int(m.body_dofadr[second]+m.body_dofnum[second]-1)
 while a>=0 and b>=0 and a!=b:
  if a<b:b=int(m.dof_parentid[b])
  else:a=int(m.dof_parentid[a])
 r=[0]*m.nv
 if a==b:
  while a>=0:r[a]=1;a=int(m.dof_parentid[a])
 return r

def expected(m,d):
 dot=[];nxt=[];rows=[]
 for a in range(m.nactuator):
  n=int(m.actuator_actnum[a]);adr=int(m.actuator_actadr[a])
  dot.extend(list(d.act_dot[adr:adr+n]) if n else [])
  dot.extend([0.]*(5-n))
  nxt.extend(private.mj_nextActivation(m._address,d._address,a,adr+k,float(d.act_dot[adr+k])) for k in range(n));nxt.extend([0.]*(5-n))
 for o in range(m.nout):
  n=int(d.moment_rownnz[o]);adr=int(d.moment_rowadr[o]);rows.append(n)
  for k in range(n):rows.extend([int(d.moment_colind[adr+k]),float(d.actuator_moment[adr+k])])
 return np.r_[d.actuator_length,d.actuator_velocity,d.actuator_force,dot,nxt,d.qfrc_actuator,rows]

def actor(m,d,a,model):
 raw=int(m.actuator_trntype[a]);ident,reference=map(int,m.actuator_trnid[a])
 trn=(0 if reference<0 else 2) if raw==6 else {0:0,1:0,2:3,3:1,4:2,5:4}[raw]
 out=int(m.actuator_outadr[a]);gear=m.actuator_gear[out]
 kind=3;start=0;position=0.;orientation=np.array([1.,0,0,0]);period=0.
 if trn==0:
  kind=int(m.jnt_type[ident]);start=int(m.jnt_dofadr[ident]);qa=int(m.jnt_qposadr[ident])
  if kind in [2,3]:position=d.qpos[qa]
  else:orientation=d.qpos[qa+3:qa+7] if kind==0 else d.qpos[qa:qa+4]
  if model==2 and kind==1:period=2*np.pi*mujoco.mju_norm3(gear[:3])
 controls=d.ctrl[int(m.actuator_ctrladr[a]):int(m.actuator_ctrladr[a]+m.actuator_ctrlnum[a])]
 u=[0.]*4;flags=int(m.actuator_ctrlspec[a]);idx=0
 if model>=4:u[:len(controls)]=controls
 elif model in [0,1]:u[0]=controls[0];flags=1
 else:
  for k,bit in enumerate([1,2,4,8]):
   if flags&bit:u[k]=controls[idx];idx+=1
 n=int(m.actuator_actnum[a]);adr=int(m.actuator_actadr[a]);states=list(d.act[adr:adr+n]) if n else []
 states.extend([0.]*(5-n))
 base=[trn,model,kind,start,raw==1,position,*orientation,*gear,*m.actuator_gainprm[a],*m.actuator_dynprm[a],*m.actuator_biasprm[a],
       *u,flags,m.opt.timestep,period,m.actuator_actearly[a],m.actuator_forcelimited[a],*m.actuator_forcerange[a],*m.actuator_lengthrange[a],m.actuator_acc0[a],*states]
 if trn==1:
  n=int(m.ten_J_rownnz[ident]);adr=int(m.ten_J_rowadr[ident]);base.extend([d.ten_length[ident],n])
  for k in range(n):base.extend([int(m.ten_J_colind[adr+k]),d.ten_J[adr+k]])
 elif trn==2:
  jp=np.zeros((3,m.nv));jr=jp.copy();rp=jp.copy();rr=jp.copy()
  mujoco.mj_jacSite(m,d,jp,jr,ident)
  sq=np.zeros(4);mujoco.mju_mulQuat(sq,m.site_quat[ident],d.xquat[m.site_bodyid[ident]])
  rq=np.array([1.,0,0,0]);rpos=np.zeros(3);rmat=np.eye(3).ravel();mask=[0]*m.nv
  if reference>=0:
   mujoco.mj_jacSite(m,d,rp,rr,reference);rpos=d.site_xpos[reference];rmat=d.site_xmat[reference]
   mujoco.mju_mulQuat(rq,m.site_quat[reference],d.xquat[m.site_bodyid[reference]])
   mask=common(m,m.site_bodyid[ident],m.site_bodyid[reference])
  base.extend([*d.site_xpos[ident],*rpos,*d.site_xmat[ident],*rmat,*sq,*rq,*jp.ravel(),*jr.ravel(),*rp.ravel(),*rr.ravel(),*mask,reference>=0])
 elif trn==3:
  axis=d.site_xmat[reference].reshape(3,3)[:,2];disp=d.site_xpos[ident]-d.site_xpos[reference]
  jsp=np.zeros((3,m.nv));ja=jsp.copy();jc=jsp.copy()
  mujoco.mj_jacPointAxis(m,d,jsp,ja,d.site_xpos[reference],axis,int(m.site_bodyid[reference]));mujoco.mj_jacSite(m,d,jc,None,ident)
  base.extend([*axis,*disp,m.actuator_cranklength[a],*ja.ravel(),*(jc-jsp).ravel()])
 elif trn==4:
  weights=np.zeros(d.nefc);gap=np.zeros(m.nv);count=0
  for contact in d.contact[:d.ncon]:
   if any(contact.geom<0) or ident not in m.geom_bodyid[np.array(contact.geom)]:continue
   if contact.exclude==0:
    count+=1;adr=contact.efc_address
    if contact.dim==1 or m.opt.cone==mujoco.mjtCone.mjCONE_ELLIPTIC:weights[adr]=1
    else:weights[adr:adr+2*(contact.dim-1)]=.5/(contact.dim-1)
   elif contact.exclude==1:
    count+=1;j1=np.zeros((3,m.nv));j2=j1.copy()
    mujoco.mj_jac(m,d,j1,None,contact.pos,int(m.geom_bodyid[contact.geom[0]]));mujoco.mj_jac(m,d,j2,None,contact.pos,int(m.geom_bodyid[contact.geom[1]]))
    diff=j2-j1;normal=contact.frame[:3]
    gap+=(normal[0]*diff[0]+normal[1]*diff[1])+normal[2]*diff[2]
  active=np.zeros(m.nv)
  if d.nefc:mujoco.mj_mulJacTVec(m,d,active,weights)
  base.extend([*active,*gap,count])
 return base

world='''<body name="base" pos=".1 .2 .3"><joint name="j0" type="slide" axis="1 0 0"/><joint name="j1" type="hinge" axis="0 0 1"/><geom size=".05" mass="1"/>
<body name="tip" pos=".2 .1 .1"><joint name="j2" axis="0 1 0"/><geom size=".05" mass="1"/><site name="s" pos=".2 0 .1" quat=".9 .1 .2 .3"/></body>
<body name="ref" pos="-.1 .2 .3"><joint name="j3" axis="1 0 0"/><geom size=".05" mass="1"/><site name="r" pos="0 .2 0" quat=".8 -.1 .3 .2"/></body></body>'''
dc='motorconst=".2" resistance="2" input="pos vel ff voltage" controller=".5 .8 .2 2 .5 12" cogging=".05 3 .2" inductance="0 .02" thermal="2 10 0 .003 20 20" lugre="30 .1 .2 .3 .1"'
def fixtures():
 out=[]
 for name,kind,act,model in [
  ('hinge_motor','hinge','<motor joint="j"/>',0),('ball_motor','ball','<general joint="j" gear="1.3 -.2 .4"/>',0),
  ('free_parent','free','<general jointinparent="j" gear="1.3 -.2 .4 .3 -.5 .2"/>',0),
  ('muscle','hinge','<muscle joint="j" lengthrange="0 1"/>',1),
  ('pid_integral','hinge','<pid joint="j" kp="3" kv=".4" ki=".7" imax=".5" input="pos vel ff"/>',2),
  ('pid_slew','hinge','<pid joint="j" kp="3" kv=".4" slewmax="2" input="pos vel ff"/>',2),
  ('dc_full','hinge',f'<dcmotor joint="j" {dc}/>',3),
  ('so3_quat','ball','<orientation joint="j" kp="4" kv=".3" input="quat" forcelimited="true" forcerange="0 .8"/>',4),
  ('so3_expmap','ball','<orientation joint="j" kp="4" kv=".3" input="expmap" forcelimited="true" forcerange="0 .8"/>',5)]:
  out.append((name,f'<body><joint name="j" type="{kind}"/><geom size=".1" mass="1" contype="0" conaffinity="0"/></body>',act,'',[model]))
 for n in [8,32,64]:
  w=''.join(f'<body pos="0 0 .2"><joint name="j{i}"/><geom size=".04" mass="1" contype="0" conaffinity="0"/>' for i in range(n))+'</body>'*n
  acts=''.join(f'<dcmotor joint="j{i}" {dc}/>' for i in range(n))
  out.append((f'dc_chain_{n}',w,acts,'',[3]*n))
 out.extend([
  ('site_ref',world,'<general site="s" refsite="r" gear="1.2 -.3 .1 .2 -.4 .7"/>','',[0]),
  ('so3_site',world,'<orientation site="s" refsite="r" kp="4" kv=".3" input="quat" forcelimited="true" forcerange="0 .8"/>','',[4]),
  ('slidercrank',world,'<general cranksite="s" slidersite="r" cranklength="1.1" gear="-2"/>','',[0]),
  ('fixed_tendon',world,'<general tendon="t" gear="-2"/>','<tendon><fixed name="t"><joint joint="j0" coef="1"/><joint joint="j2" coef="-.3"/></fixed></tendon>',[0]),
  ('adhesion','<geom type="plane" size="2 2 .1"/><body name="b" pos="0 0 .09"><joint type="slide" axis="1 0 0"/><joint type="slide" axis="0 1 0"/><joint type="slide" axis="0 0 1"/><joint type="hinge" axis="0 0 1"/><geom type="sphere" size=".1" margin=".02" gap=".005"/></body>','<adhesion body="b" gain="1" ctrlrange="0 1"/>','',[0])])
 return out

def prepare(folder,fixture):
 name,w,acts,tendon,models=fixture
 xml=f'<mujoco><option timestep=".002" gravity="0 0 0" jacobian="dense"/><worldbody>{w}</worldbody>{tendon}<actuator>{acts}</actuator></mujoco>'
 m=mujoco.MjModel.from_xml_string(xml);m.actuator_actearly[:]=1
 (folder/'model.xml').write_text(xml);mujoco.mj_saveModel(m,str(folder/'model.mjb'))
 ada=[m.nv,m.nactuator,8,m.nout];c=[8];frames=[]
 rng=np.random.default_rng(3140930)
 for frame in range(8):
  d=mujoco.MjData(m)
  for j in range(m.njnt):
   qa=int(m.jnt_qposadr[j]);kind=m.jnt_type[j]
   if kind in [2,3]:d.qpos[qa]=.03*np.sin(frame+j)
   else:
    q=np.array([1.,.03*np.sin(frame+j),.02*np.cos(frame-j),.04*np.sin(frame*.5+j)])
    if kind==0:d.qpos[qa+3:qa+7]=q
    else:d.qpos[qa:qa+4]=q
  d.qvel[:]=rng.uniform(-.2,.2,m.nv);d.ctrl[:]=rng.uniform(.1,.5,m.nu);d.act[:]=rng.uniform(-.15,.15,m.na)
  for a,model in enumerate(models):
   if model==1:d.act[int(m.actuator_actadr[a])]=.4
   if model==4:d.ctrl[int(m.actuator_ctrladr[a])]=1.
  mujoco.mj_forward(m,d)
  c.extend([*d.qpos,*d.qvel,*d.ctrl,*d.act]);ada.extend(d.qvel)
  for a,model in enumerate(models):ada.extend(actor(m,d,a,model))
  frames.append(expected(m,d))
 write_numbers(folder/'ada.input',ada);write_numbers(folder/'c.input',c)
 return m,frames

def parse(text):
 frames=[];samples=[];sink=None
 for line in text.splitlines():
  name,*values=line.split()
  if name=='frame':frames.append(np.array(list(map(float,values[1:]))))
  elif name=='sample':samples.append(float(values[0]))
  elif name=='sink':sink=float(values[0])
  else:raise ValueError(line)
 assert sink is not None and np.isfinite(sink)
 return frames,samples,sink

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--blocks',type=int,default=9);ap.add_argument('--samples',type=int,default=3)
 ap.add_argument('--model',action='append',default=[]);ap.add_argument('--cpu',type=int);ap.add_argument('--out',type=Path,required=True)
 a=ap.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 assert a.blocks>=3 and a.samples>=1
 allowed=sorted(os.sched_getaffinity(0));cpu=a.cpu if a.cpu is not None else allowed[-1];os.sched_setaffinity(0,{cpu})
 env=os.environ.copy();env['LD_LIBRARY_PATH']=str(toolchain/'lib64')+':'+str(lib.parent)
 native_sources={}
 for f in (native/'source/src/engine').glob('*.c'):
  assert f.read_text()==(repo/'mujoco/src/engine'/f.name).read_text(),f.name
  native_sources[str(f)]=digest(f)
 gcc=toolchain/'bin/gcc';exe=scratch/'bin/actuation_c';exe.parent.mkdir(parents=True,exist_ok=True)
 cmd=[str(gcc),'-O3','-march=native','-flto','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno',
      '-I'+str(repo/'mujoco/include'),'-I'+str(repo/'mujoco/src'),'-I'+str(repo/'mujoco/src/engine'),str(here/'tests/performance/actuation_c.c'),str(oracle),str(lib),'-lm',
      '-Wl,-rpath,'+str(lib.parent),'-Wl,-rpath,'+str(toolchain/'lib64'),'-o',str(exe)]
 subprocess.run(cmd,env=env,check=True)
 executables={'ada':scratch/'bin/actuation_bench','c':exe}
 rng=np.random.default_rng(3140930);results=[]
 def run(kind,folder,steps,samples,warmups):
  argv=([str(executables[kind]),str(folder/'ada.input')] if kind=='ada' else [str(exe),str(folder/'model.mjb'),str(folder/'c.input')])+list(map(str,[steps,samples,warmups]))
  p=subprocess.run(argv,env=env,text=True,capture_output=True,timeout=120);p.check_returncode()
  fs,ss,sink=parse(p.stdout)
  for i,(actual,target) in enumerate(zip(fs,targets)):
   np.testing.assert_allclose(actual,target,atol=2e-11,rtol=2e-11,err_msg=f'{kind} {name} frame{i}')
  assert len(fs)==len(targets) and len(ss)==samples
  return ss,sink,p.stdout
 for fixture in fixtures():
  name=fixture[0]
  if a.model and name not in a.model:continue
  folder=a.out/name;folder.mkdir();m,targets=prepare(folder,fixture)
  ct,cs,_=run('c',folder,1000,1,1);at,ass,_=run('ada',folder,1000,1,1)
  steps=max(500,min(500000,int(.008/(ct[0]/1000))))
  values={'ada':[],'c':[]};ratios=[];sinks=[]
  for block in range(a.blocks):
   runs={}
   for kind in (['ada','c'] if block%2==0 else ['c','ada']):
    ss,sink,text=run(kind,folder,steps,a.samples,1);values[kind].extend(x/steps for x in ss);runs[kind]=(ss,sink)
    (folder/f'block-{block}-{kind}.output').write_text(text)
   np.testing.assert_allclose(runs['ada'][1],runs['c'][1],rtol=2e-10,atol=2e-10,err_msg=name+' sink')
   ratios.append(float(np.median(runs['ada'][0])/np.median(runs['c'][0])))
   sinks.append([runs['ada'][1],runs['c'][1]])
  bootstrap=np.median(rng.choice(ratios,size=(10000,len(ratios)),replace=True),axis=1)
  ci=list(map(float,np.percentile(bootstrap,[2.5,97.5])))
  result={'name':name,'nv':m.nv,'nactuator':m.nactuator,'nout':m.nout,'na':m.na,'frames':8,'steps':steps,
          'ada_us':float(np.median(values['ada'])*1e6),'c_us':float(np.median(values['c'])*1e6),'ada_over_c':float(np.median(ratios)),
          'ratio_ci95':ci,'block_ratios':ratios,'timings_us':{k:dict(zip(['p10','p50','p90'],map(float,np.percentile(v,[10,50,90])*1e6))) for k,v in values.items()},
          'prepared_geometry_advantage':name in ['site_ref','slidercrank','adhesion'],
          'stage_faster_confirmed':ci[1]<1,'stage_slower_confirmed':ci[0]>1,'numerical_frames_passed':True,'sink_pairs':sinks}
  results.append(result);print(name,'Ada/C',round(result['ada_over_c'],3),'us',round(result['ada_us'],3),round(result['c_us'],3),'CI',ci,flush=True)
  (folder/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 summary={'scope':'transmission + velocity + actuator dynamics/force + next activation + sparse projection; static prepared frames, no whole dynamics or trajectory',
          'aggregate_movement_passed':False,'integration_gate_passed':False,'results':results,'args':{k:str(v) for k,v in vars(a).items()},
          'bootstrap_seed':3140930,'bootstrap_resamples':10000,'cpu':cpu,'affinity':sorted(os.sched_getaffinity(0)),'loadavg':os.getloadavg(),
          'hardware':subprocess.check_output(['lscpu'],text=True),'platform':platform.platform(),'compiler_version':subprocess.check_output([str(gcc),'--version'],text=True),
          'c_compile_command':cmd,'c_engine_compile_commands_sha256':digest(native/'build/compile_commands.json'),
          'reference_version':mujoco.__version__,'reference_commit':'9ecbb9d7b5ee623f54745638d36799ff90e6f7cd','native_library_sha256':digest(lib),
          'native_engine_sources':native_sources,'candidate_sources':{str(p.relative_to(here)):digest(p) for folder in ['src','base','tests/performance'] for p in (here/folder).glob('*') if p.is_file()},
          'binaries':{k:{'path':str(p),'sha256':digest(p)} for k,p in executables.items()},'performance_project_sha256':digest(here/'performance.gpr')}
 (a.out/'results.json').write_text(json.dumps(summary,indent=2)+'\n')

if __name__=='__main__':main()
