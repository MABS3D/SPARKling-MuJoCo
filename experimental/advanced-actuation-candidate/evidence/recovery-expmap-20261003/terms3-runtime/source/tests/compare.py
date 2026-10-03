#!/usr/bin/env python3
"""Differential tests against actual MuJoCo 3.14 C and verbatim private helpers."""
from pathlib import Path
import ctypes as ct,hashlib,json,math,os,random,subprocess,itertools
import mujoco,numpy as np
here=Path(__file__).resolve().parents[1]
assert mujoco.__version__=='3.14.0'
lib=next(Path(mujoco.__file__).parent.glob('libmujoco.so*'));c=ct.CDLL(str(lib));b=ct.CDLL('/var/tmp/sparkling-actuators-20260930/oracle/oracle.so')
oracle=json.loads((here/'evidence/oracle.json').read_text())
assert oracle['version']==mujoco.__version__ and oracle['library_sha256']==hashlib.sha256(lib.read_bytes()).hexdigest()
assert oracle['oracle_sha256']==hashlib.sha256(Path('/var/tmp/sparkling-actuators-20260930/oracle/oracle.so').read_bytes()).hexdigest()
for source in oracle['excerpts']:
 assert source['source_sha256_raw']==hashlib.sha256((here.parents[1]/source['file']).read_bytes()).hexdigest()
for name,digest in oracle['headers'].items():assert digest==hashlib.sha256((here.parents[1]/name).read_bytes()).hexdigest()
D=ct.c_double;DP=ct.POINTER(D)
I=ct.c_int;IP=ct.POINTER(I)
c.mju_mulMatVecSparse.argtypes=[DP,DP,DP,I,IP,IP,IP,IP]
c.mju_mulMatTVecSparse.argtypes=[DP,DP,DP,I,I,IP,IP,IP]
def vec(v):return (D*len(v))(*v)
def sparse_expected(dense,gear,velocity,force,old):
 indices=[j for j,x in enumerate(dense) if x!=0.0]
 values=[dense[j]*gear for j in indices]
 speed=vec([0.]);c.mju_mulMatVecSparse(speed,vec(values),vec(velocity),1,(I*1)(len(values)),(I*1)(0),(I*len(indices))(*indices),None)
 # Identity rows contribute the old generalized force; last row is this actuator.
 nv=len(dense);all_values=[1.]*nv+values;all_indices=list(range(nv))+indices
 out=vec([0.]*nv)
 c.mju_mulMatTVecSparse(out,vec(all_values),vec(list(old)+[force]),nv+1,nv,
   (I*(nv+1))(*([1]*nv+[len(values)])),(I*(nv+1))(*list(range(nv+1))),
   (I*len(all_indices))(*all_indices))
 row=[len(indices)]
 for j,x in zip(indices,values):row.extend([j,x])
 return [*row,float(speed[0]),*out]
def scalar(name,args,typ):
 f=getattr(c,name);f.restype=D;f.argtypes=typ;return float(f(*args))
b.mj_nextActivation.restype=D;b.mj_nextActivation.argtypes=[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,D]
rng=random.Random(3140930);cases=[];labels={}
def add(label,code,a,expected,atol=2e-12,rtol=2e-12):
 a=list(map(float,a));assert len(a)<=128 and all(math.isfinite(x) and abs(x)<=1e100 for x in a)
 a+= [0.]*(128-len(a));expected=list(map(float,expected));assert all(math.isfinite(x) for x in expected)
 cases.append((label,code,a,expected,atol,rtol));labels[label]=labels.get(label,0)+1
def pp(length=0.,velocity=0.,lo=0.,hi=1.,acc=1.,p=None):return [length,velocity,lo,hi,acc]+list(p or [0.75,1.05,100.,200.,0.5,1.6,1.5,1.3,1.2,0.])
for i in range(1000):
 p=[rng.uniform(.1,1),rng.uniform(1.01,2),rng.choice([-1.,rng.uniform(.1,1000)]),rng.uniform(1,300),rng.uniform(.1,.8),rng.uniform(1.1,2.5),rng.uniform(.2,4),rng.uniform(.1,3),rng.uniform(1.01,2),0.]
 a=pp(rng.uniform(-1,4),rng.uniform(-5,5),-.1,2,rng.uniform(.01,10),p)
 gain=scalar('mju_muscleGain',[a[0],a[1],vec(a[2:4]),a[4],vec(p[:9])],[D,D,DP,D,DP])
 bias=scalar('mju_muscleBias',[a[0],vec(a[2:4]),a[4],vec(p[:9])],[D,DP,D,DP])
 add('muscle-gain',0,a,[gain]);add('muscle-bias',1,a,[bias])
 control=rng.uniform(-1,2);act=rng.uniform(-.5,1.5);dyn=[.01,.04,rng.choice([0.,.5,1e-15])]+[0.]*7
 dot=scalar('mju_muscleDynamics',[control,act,vec(dyn[:3])],[D,D,DP]);add('muscle-dynamics',2,[control,act,0,0,0]+dyn,[dot])
for lo,hi in [(.5,1.6),(1,1),(2,-2),(-1e10,1e10)]:
 for x in [-1e10,lo,math.nextafter(lo,-math.inf),(lo+1)/2,1,(1+hi)/2,hi,math.nextafter(hi,math.inf),1e10]:
  if abs(x)>1e10:continue
  add('muscle-length-boundaries',3,[x,lo,hi],[scalar('mju_muscleGainLength',[x,lo,hi],[D,D,D])])
for x in [-1e10,-1e-15,0,.1,.5,.9,1,1.01,1e10]:add('sigmoid',4,[x],[scalar('mju_sigmoid',[x],[D])])
for lo,hi in [(0,0),(1,0),(0,1e-15),(0,1)]:
 for force,acc in [(-1,0),(-1,1e-15),(-1,-1),(1e10,1)]:
  a=pp(1,-1,lo,hi,acc,[.75,1.05,force,200,.5,1.6,1.5,1.3,1.2,0])
  add('muscle-degenerate-gain',0,a,[scalar('mju_muscleGain',[a[0],a[1],vec(a[2:4]),a[4],vec(a[5:14])],[D,D,DP,D,DP])])
# Quaternion operations call the real C API, including tiny and antipodal cases.
for i in range(150):
 q=np.array([rng.uniform(-1,1) for _ in range(4)]);other=np.array([rng.uniform(-1,1) for _ in range(4)])
 if i<4:q=np.array([[0,0,0,0],[1,0,0,0],[-1,0,0,0],[0,1,0,0]][i],dtype=float)
 v=np.array([rng.uniform(-2,2) for _ in range(3)]);emap=np.array([rng.uniform(-4,4) for _ in range(3)])
 norm=q.copy();mujoco.mju_normalize4(norm);log=np.zeros(3);mujoco.mju_quat2Vel(log,q,1.)
 rot=np.zeros(3);mujoco.mju_rotVecQuat(rot,v,q);diff=np.zeros(3);mujoco.mju_subQuat(diff,q,other)
 eq=np.zeros(4);angle=np.linalg.norm(emap)
 if angle<1e-15:eq[0]=1
 else:mujoco.mju_axisAngle2Quat(eq,emap/angle,angle)
 add('quaternion-geometry',7,[*q,*v,*other,*emap],[*norm,*log,*rot,*diff,*eq])
# Slider derivatives and CSR projection are also tested through full C fixtures below.
for i in range(200):
 axis=np.array([rng.uniform(-1,1) for _ in range(3)]);v=np.array([rng.uniform(-2,2) for _ in range(3)]);rod=rng.choice([.1,1.,4.]);gear=rng.choice([0.,-2.,1.])
 ja=np.array([rng.uniform(-1,1) for _ in range(12)]).reshape(3,4);jv=np.array([rng.uniform(-1,1) for _ in range(12)]).reshape(3,4)
 av=sum(axis[k]*v[k] for k in range(3));det=(av*av+rod*rod)-sum(v[k]*v[k] for k in range(3));good=det>0
 if good:
  sd=math.sqrt(det);coeff=1-av/sd;da=v*coeff;dv=axis*coeff+v*(1/sd);length=av-sd
 else:da=v;dv=axis;length=av
 moments=[]
 for j in range(4):
  s=0.
  for k in range(3):s+=da[k]*ja[k,j]+dv[k]*jv[k,j]
  moments.append(s)
 row=[sum(x!=0 for x in moments)]
 for j,x in enumerate(moments):
  if x!=0:row.extend([j,x*gear])
 add('slider-branches',8,[*axis,*v,rod,gear,*ja.ravel(),*jv.ravel()],[length,*da,*dv,float(good),1,1,length*gear,0,0,*row])
for i in range(150):
 a=[rng.choice([0.,rng.uniform(-2,2)]) for _ in range(4)];gear=rng.choice([0.,-3.,2.]);vel=[rng.uniform(-2,2) for _ in range(4)];force=rng.uniform(-2,2);g=[rng.uniform(-2,2) for _ in range(4)]
 add('C-csr-projection',13,[*a,gear,*vel,force,*g],sparse_expected(a,gear,vel,force,g))
for nv in range(41):
 for trial in range(5):
  dense=[rng.choice([0.,rng.uniform(-2,2)]) for _ in range(nv)]
  velocity=[rng.uniform(-2,2) for _ in range(nv)];old=[rng.uniform(-2,2) for _ in range(nv)]
  gear=rng.choice([0.,-3.,2.]);force=0.0 if trial==0 else rng.uniform(-2,2)
  add('C-csr-groups-tails',19,[nv,gear,*dense,*velocity,force,*old],sparse_expected(dense,gear,velocity,force,old))
dense=[1e10,1e-10,-1e10,1e-10];velocity=[1.]*4;old=[0.]*4
add('C-csr-cancellation',19,[4,1,*dense,*velocity,0,*old],sparse_expected(dense,1,velocity,0,old),atol=0,rtol=0)
# Full C state preparation and actuation; XML compilers and layouts are the matching stable version.
def model(act,world=None,tendon=''):
 if world is None:world='<body name="b"><joint name="j" type="hinge"/><geom size=".1" mass="1"/></body>'
 return mujoco.MjModel.from_xml_string(f'<mujoco><option timestep=".002" jacobian="dense"/>{"<worldbody>"+world+"</worldbody>"}{tendon}<actuator>{act}</actuator></mujoco>')
def rowdata(m,d):
 out=[]
 for row in range(m.nout):
  n=int(d.moment_rownnz[row]);adr=int(d.moment_rowadr[row]);out.append(n)
  for k in range(n):out.extend([int(d.moment_colind[adr+k]),float(d.actuator_moment[adr+k])])
 return [1,m.nout,*list(d.actuator_length)+[0.]*(3-m.nout),*out]
def common(m,a,b):
 x=int(m.body_dofadr[a]+m.body_dofnum[a]-1);y=int(m.body_dofadr[b]+m.body_dofnum[b]-1)
 while x>=0 and y>=0 and x!=y:
  if x<y:y=int(m.dof_parentid[y])
  else:x=int(m.dof_parentid[x])
 r=[0]*m.nv
 if x==y:
  while x>=0:r[x]=1;x=int(m.dof_parentid[x])
 return r
def pid_fields(m,d,u,integral,slew):
 sd=float(d.act_dot[0]) if slew else 0.0
 position=float(d.act[0]+sd*m.opt.timestep) if slew else u[0]
 slot=int(slew)
 idot=float(d.act_dot[slot]) if integral else 0.0
 advanced=b.mj_nextActivation(m._address,d._address,0,slot,idot) if integral else 0.0
 return [float(d.actuator_force[0]),position,sd,idot,advanced]
for kind in ['hinge','slide','ball','free']:
 for parent in [False,True]:
  if kind in ['hinge','slide'] and parent:continue
  for so3 in [False,True] if kind=='ball' else [False]:
   world=f'<body name="b"><joint name="j" type="{kind}"/><geom size=".1" mass="1"/></body>'
   act='<orientation joint="j" kp="4" kv=".3" input="quat"/>' if so3 else f'<general {"jointinparent" if parent else "joint"}="j" gear="1.3 -.2 .4 .3 -.5 .2"/>'
   m=model(act,world)
   for trial in range(12):
    d=mujoco.MjData(m);d.qpos[:]=[rng.uniform(-1,1) for _ in range(m.nq)];mujoco.mj_forward(m,d)
    q=d.qpos[3:7] if kind=='free' else d.qpos[:4] if kind=='ball' else np.array([1.,0,0,0])
    a=[int(m.jnt_type[0]),m.nv,0,d.qpos[0] if kind in ['hinge','slide'] else 0,*q,*m.actuator_gear[0],int(parent),int(so3)]
    add('joint-'+kind+('-parent' if parent else '')+('-so3' if so3 else ''),9,a,rowdata(m,d))
world='''<body name="base" pos=".1 .2 .3"><joint name="j0" type="slide" axis="1 0 0"/><joint name="j1" type="hinge" axis="0 0 1"/><geom size=".05" mass="1"/>
<body name="tip" pos=".2 .1 .1"><joint name="j2" axis="0 1 0"/><geom size=".05" mass="1"/><site name="s" pos=".2 0 .1" quat=".9 .1 .2 .3"/></body>
<body name="ref" pos="-.1 .2 .3"><joint name="j3" axis="1 0 0"/><geom size=".05" mass="1"/><site name="r" pos="0 .2 0" quat=".8 -.1 .3 .2"/></body></body>'''
for ref in [False,True]:
 for so3 in [False,True] if ref else [False]:
  act=('<orientation site="s" refsite="r" input="quat" kp="4" kv=".3"/>' if so3 else '<general site="s" '+('refsite="r" ' if ref else '')+'gear="1.2 -.3 .1 .2 -.4 .7"/>')
  m=model(act,world)
  for trial in range(20):
   d=mujoco.MjData(m);d.qpos[:]=[rng.uniform(-1,1) for _ in range(4)];mujoco.mj_forward(m,d)
   s=mujoco.mj_name2id(m,mujoco.mjtObj.mjOBJ_SITE,'s');r=mujoco.mj_name2id(m,mujoco.mjtObj.mjOBJ_SITE,'r');jp=np.zeros((3,4));jr=jp.copy();rp=jp.copy();rr=jp.copy()
   mujoco.mj_jacSite(m,d,jp,jr,s);mujoco.mj_jacSite(m,d,rp,rr,r)
   sq=np.zeros(4);rq=np.zeros(4);mujoco.mju_mulQuat(sq,m.site_quat[s],d.xquat[m.site_bodyid[s]]);mujoco.mju_mulQuat(rq,m.site_quat[r],d.xquat[m.site_bodyid[r]])
   a=[*d.site_xpos[s],*d.site_xpos[r],*d.site_xmat[s],*d.site_xmat[r],*sq,*rq,*m.actuator_gear[0],*jp.ravel(),*jr.ravel(),*rp.ravel(),*rr.ravel(),*common(m,m.site_bodyid[s],m.site_bodyid[r]),int(ref),int(so3)]
   add('site'+('-reference' if ref else '')+('-so3' if so3 else ''),10,a,rowdata(m,d))
# Actual C slider crank and tendon sparse patterns.
for trn in ['slider','fixed-tendon']:
 act='<general cranksite="s" slidersite="r" cranklength="1.1" gear="-2"/>' if trn=='slider' else '<general tendon="t" gear="-2"/>'
 tendon='<tendon><fixed name="t"><joint joint="j0" coef="1"/><joint joint="j2" coef="-.3"/></fixed></tendon>' if trn=='fixed-tendon' else ''
 m=model(act,world,tendon)
 for trial in range(20):
  d=mujoco.MjData(m);d.qpos[:]=[rng.uniform(-.1,.1) for _ in range(4)];mujoco.mj_forward(m,d)
  if trn=='slider':
   s=0;r=1;axis=d.site_xmat[r].reshape(3,3)[:,2];disp=d.site_xpos[s]-d.site_xpos[r]
   jsp=np.zeros((3,4));ja=jsp.copy();jc=jsp.copy();mujoco.mj_jacPointAxis(m,d,jsp,ja,d.site_xpos[r],axis,int(m.site_bodyid[r]));mujoco.mj_jacSite(m,d,jc,None,s)
   a=[*axis,*disp,1.1,-2,*ja.ravel(),*(jc-jsp).ravel()];expected=rowdata(m,d)
   # Probe returns 8 extra geometry fields before the actual transmission.
   av=float(np.dot(disp,axis));det=av*av+1.1**2-float(np.dot(disp,disp));sd=math.sqrt(det) if det>0 else 0;da=disp*(1-av/sd) if det>0 else disp;dv=axis*(1-av/sd)+disp/sd if det>0 else axis
   expected=[av-sd,*da,*dv,int(det>0),*expected];code=8
  else:
   jac=np.zeros(4);mask=[0]*4;n=int(m.ten_J_rownnz[0]);adr=int(m.ten_J_rowadr[0])
   for k in range(n):col=int(m.ten_J_colind[adr+k]);jac[col]=d.ten_J[adr+k];mask[col]=1
   a=[d.ten_length[0],-2,*jac,*mask];expected=rowdata(m,d);code=11
  add('C-'+trn,code,a,expected)
# Stateful model comparison uses actual C fwdActuation plus extracted mj_nextActivation.
for category in ['pid','dc']:
 configurations=[(True,True,True,True,True),(False,False,False,False,False),(False,True,True,True,False),(True,False,False,True,True)]
 if category=='dc':configurations=list(itertools.product([False,True],repeat=5))
 for stateful,integ,thermal,bristle,slew in configurations:
  if category=='pid' and integ and slew:slew=False  # stable XML limitation: actdim=2 PID
  if category=='pid':act=f'<pid joint="j" kp="3" kv=".4" ki="{.7 if integ else 0}" imax=".5" slewmax="{2 if slew else 0}" input="pos vel ff"/>'
  else:
   attrs='inductance="0 .02" ' if stateful else ''
   attrs+='thermal="2 10 0 .003 20 20" ' if thermal else ''
   attrs+='lugre="30 .1 .2 .3 .1" ' if bristle else ''
   act=f'<dcmotor joint="j" motorconst=".2" resistance="2" input="pos vel ff voltage" controller=".5 {.8 if integ else 0} .2 {2 if slew else 0} .5 12" cogging=".05 3 .2" {attrs}/>'
  m=model(act)
  m.actuator_forcelimited[0]=1;m.actuator_forcerange[0]=[-2,2]
  for trial in range(8 if category=='dc' else 40):
   d=mujoco.MjData(m);d.qpos[0]=rng.uniform(-1,1);d.qvel[0]=rng.uniform(-2,2);d.ctrl[:]=[rng.uniform(-1,1) for _ in range(m.nu)];d.act[:]=[rng.uniform(-1,1) for _ in range(m.na)];m.actuator_actearly[0]=trial%2
   if category=='dc' and stateful:m.actuator_dynprm[0,1]=.1 if trial%3==0 else 0.0
   if category=='dc':m.actuator_forcerange[0]=[-.05,.05] if trial%3==1 else [-2,2]
   mujoco.mj_forward(m,d)
   gain=m.actuator_gainprm[0];dyn=m.actuator_dynprm[0];bias=m.actuator_biasprm[0];spec=int(m.actuator_ctrlspec[0]);u=[0.]*4;adr=0
   for k,bit in enumerate([1,2,4,8]):
    if spec&bit:u[k]=d.ctrl[adr];adr+=1
   a=[*u,spec,d.actuator_length[0],d.actuator_velocity[0],m.opt.timestep,trial%2,1,*m.actuator_forcerange[0],*gain,*dyn,*bias,*d.act]+[0.]*(5-m.na)
   # For PID force limits are applied by the shared pipeline; compare unclamped force.
   if category=='pid':
    a[10]=0.0
    m.actuator_forcelimited[0]=0;mujoco.mj_fwdActuation(m,d)
    add('C-pid',5,a,pid_fields(m,d,u,integ,slew))
   else:
    ndot=list(d.act_dot)+[0.]*(5-m.na);nxt=[b.mj_nextActivation(m._address,d._address,0,k,float(d.act_dot[k])) for k in range(m.na)]+[0.]*(5-m.na)
    expected=[d.actuator_force[0],None,None,None,*ndot,*nxt]
    # Slot states outside actnum are passed as zero and preserved by candidate.
    resistance=gain[0]
    temp_slot=int(slew)+int(integ) if thermal else -1
    if temp_slot>=0:resistance*=1+gain[2]*(d.act[temp_slot]+dyn[4]-gain[3])
    # Voltage/effective control are private intermediates: force, all derivatives,
    # and all advanced states are compared to C. They are ignored below.
    expected=[float(x) if x is not None else 0. for x in expected]
    add('C-dc',6,a,expected)
# Periodic PID setpoints on a ball transmission, with separate integral/slew states.
for use_integral in [False,True]:
 m=model(f'<pid joint="j" gear=".5 .2 -.3" kp="3" kv=".4" ki="{.7 if use_integral else 0}" imax=".5" slewmax="{0 if use_integral else 2}" input="pos vel ff"/>','<body><joint name="j" type="ball"/><geom size=".1"/></body>')
 period=2*math.pi*mujoco.mju_norm3(m.actuator_gear[0,:3])
 for trial in range(30):
  d=mujoco.MjData(m);d.qpos[:]=[rng.uniform(-1,1) for _ in range(4)];d.qvel[:]=[rng.uniform(-2,2) for _ in range(3)];d.ctrl[:]=[rng.uniform(-12,12),rng.uniform(-1,1),rng.uniform(-1,1)];d.act[:]=rng.uniform(-1,1);m.actuator_actearly[0]=trial%2;mujoco.mj_forward(m,d)
  a=[*d.ctrl,0,7,d.actuator_length[0],d.actuator_velocity[0],m.opt.timestep,trial%2,0,period,0,*m.actuator_gainprm[0],*m.actuator_dynprm[0],*m.actuator_biasprm[0],*d.act]+[0.]*(5-m.na)
  add('C-pid-periodic',5,a,pid_fields(m,d,list(d.ctrl),use_integral,not use_integral))
# SO3 full actuator force including vector norm saturation and quaternion sign.
for chart in ['quat','expmap']:
 m=model(f'<orientation joint="j" kp="4" kv=".3" input="{chart}" forcelimited="true" forcerange="0 .8"/>','<body><joint name="j" type="ball"/><geom size=".1" mass="1"/></body>')
 for trial in range(80):
  d=mujoco.MjData(m);d.qpos[:]=[rng.uniform(-1,1) for _ in range(4)];d.qvel[:]=[rng.uniform(-2,2) for _ in range(3)];d.ctrl[:]=[rng.uniform(-1,1) for _ in range(m.nu)];mujoco.mj_forward(m,d)
  target=np.zeros(4)
  if chart=='quat':target[:]=d.ctrl
  else:target[:3]=d.ctrl
  add('C-so3-'+chart,14 if chart=='quat' else 18,[*target,*d.actuator_length,*d.actuator_velocity,*m.actuator_gainprm[0],*m.actuator_biasprm[0],1,.8],d.actuator_force)
# Adhesion: active, gap and mixed contacts with both cone types.
for cone,dimension in itertools.product(['pyramidal','elliptic'],[1,3,4,6]):
 for height in [.09,.111,.25]:
  w='<geom type="plane" size="2 2 .1"/><body name="b" pos="0 0 '+str(height)+'"><joint type="slide" axis="1 0 0"/><joint type="slide" axis="0 1 0"/><joint type="slide" axis="0 0 1"/><joint type="hinge" axis="0 0 1"/><geom type="sphere" size=".1" margin=".02" gap=".005"/><geom type="sphere" size=".08" pos=".3 0 0" margin=".02" gap=".005"/></body>'
  w=w.replace('<geom ',f'<geom condim="{dimension}" ')
  m=model('<adhesion body="b" gain="1" ctrlrange="0 1"/>',w);m.opt.cone=int(mujoco.mjtCone.mjCONE_PYRAMIDAL if cone=='pyramidal' else mujoco.mjtCone.mjCONE_ELLIPTIC)
  d=mujoco.MjData(m);mujoco.mj_forward(m,d);weights=np.zeros(d.nefc);gap=np.zeros(4);counter=0
  for contact in d.contact[:d.ncon]:
   if contact.geom[0]<0 or contact.geom[1]<0:continue
   if 1 not in m.geom_bodyid[np.array(contact.geom)]:continue
   if contact.exclude==0:
    counter+=1;adr=contact.efc_address
    if contact.dim==1 or cone=='elliptic':weights[adr]=1
    else:weights[adr:adr+2*(contact.dim-1)]=.5/(contact.dim-1)
   elif contact.exclude==1:
    counter+=1;j1=np.zeros((3,4));j2=j1.copy();mujoco.mj_jac(m,d,j1,None,contact.pos,int(m.geom_bodyid[contact.geom[0]]));mujoco.mj_jac(m,d,j2,None,contact.pos,int(m.geom_bodyid[contact.geom[1]]));gap+=contact.frame.reshape(3,3)[0]@(j2-j1)
  active=np.zeros(4)
  if d.nefc:mujoco.mj_mulJacTVec(m,d,active,weights)
  add('C-adhesion-'+cone+f'-dim{dimension}',12,[*active,*gap,counter],rowdata(m,d))
# Topology mask, including roots and separate branches.
for parents in [(-1,0,1,2),(-1,-1,0,1),(-1,0,0,2)]:
 for first in range(-1,4):
  for second in range(-1,4):
   def ancestors(node):
    found=set()
    while node>=0:found.add(node);node=parents[node]
    return found
   expected=[int(k in ancestors(first)&ancestors(second)) for k in range(4)]
   add('common-ancestor-mask',17,[*parents,first,second],expected)
# Exact filter advancement from the C helper, including tiny time constants.
for tau in [1e-15,.0001,.01,10.]:
 m=model(f'<general joint="j" dyntype="filterexact" dynprm="{tau}"/>')
 for trial in range(15):
  d=mujoco.MjData(m);d.act[0]=rng.uniform(-1,1);d.ctrl[0]=rng.uniform(-1,1);mujoco.mj_forward(m,d)
  expected=b.mj_nextActivation(m._address,d._address,0,0,float(d.act_dot[0]))
  add('C-filterexact',15,[d.act[0],d.act_dot[0],m.opt.timestep,tau],[expected])
# Full muscle force combines active gain and passive bias, including actearly.
m=model('<muscle joint="j" lengthrange="0 1"/>')
for trial in range(80):
 d=mujoco.MjData(m);d.qpos[0]=rng.uniform(-.5,2);d.qvel[0]=rng.uniform(-2,2)
 d.ctrl[0]=rng.uniform(0,1);d.act[0]=rng.uniform(0,1);m.actuator_actearly[0]=trial%2
 mujoco.mj_forward(m,d)
 activation=b.mj_nextActivation(m._address,d._address,0,0,float(d.act_dot[0])) if trial%2 else d.act[0]
 add('C-muscle-force',20,[d.actuator_length[0],d.actuator_velocity[0],*m.actuator_lengthrange[0],m.actuator_acc0[0],activation,*m.actuator_gainprm[0],*m.actuator_biasprm[0]],[d.actuator_force[0]])
# Run exact same cases with checks enabled and optimized build.
mode=os.environ.get('ACTUATION_MODE','validation');exe=Path('/var/tmp/sparkling-actuators-20260930/build')/mode/'bin/actuation_probe'
input_text=''.join(str(code)+' '+' '.join(format(x,'.17e') for x in a)+'\n' for _,code,a,_,_,_ in cases)
r=subprocess.run([str(exe)],input=input_text,text=True,capture_output=True)
if r.returncode:raise RuntimeError(r.stderr+'\n'+r.stdout[-2000:])
lines=r.stdout.splitlines();assert len(lines)==len(cases),(len(lines),len(cases))
fail=[];maxerr={}
for i,((label,code,a,expected,atol,rtol),line) in enumerate(zip(cases,lines)):
 got=list(map(float,line.split()))
 if len(got)!=len(expected):fail.append({'case':i,'label':label,'lengths':[len(got),len(expected)]});continue
 for k,(x,y) in enumerate(zip(got,expected)):
  if code==6 and k in [1,2,3]:continue
  err=abs(x-y);maxerr[label]=max(maxerr.get(label,0),err/(1+abs(y)))
  if not math.isfinite(x) or err>atol+rtol*abs(y):
   fail.append({'case':i,'label':label,'field':k,'got':x,'expected':y,'inputs':a[:95]});break
result={'passed':not fail,'cases':len(cases),'mode':mode,'seed':3140930,'counts':labels,'max_scaled_error':maxerr,'failures':fail[:20],'input_sha256':hashlib.sha256(input_text.encode()).hexdigest(),'expected_sha256':hashlib.sha256(json.dumps([x[3] for x in cases]).encode()).hexdigest(),'sources':{str(f.relative_to(here)):hashlib.sha256(f.read_bytes()).hexdigest() for d in ['src','base','tests'] for f in (here/d).iterdir() if f.is_file()},'binary_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'reference_library_sha256':hashlib.sha256(lib.read_bytes()).hexdigest()}
(here/'evidence'/('numerics-'+mode+'.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['sources','failures']},indent=2));print(json.dumps(fail[:8],indent=2))
raise SystemExit(0 if not fail else 1)
