#!/usr/bin/env python3
"""Checked/release C differentials, including whole scalar muscle actuator steps."""
import argparse,ctypes,json,math,random,subprocess
from pathlib import Path
from evidence import HERE,ROOT,snapshot,tool_env,provenance
from reference import build_reference
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
out=args.out.resolve();out.mkdir(parents=True,exist_ok=True);env=tool_env();hashes=snapshot()
lib=ctypes.CDLL(str(build_reference(out/'reference')))
D=ctypes.c_double;A2=D*2;A9=D*9;A3=D*3
signatures={'mju_muscleGainLength':[D,D,D],'mju_muscleGain':[D,D,ctypes.POINTER(D),D,ctypes.POINTER(D)],'mju_muscleBias':[D,ctypes.POINTER(D),D,ctypes.POINTER(D)],'mju_muscleDynamicsTimescale':[D,D,D,D],'mju_muscleDynamics':[D,D,ctypes.POINTER(D)],'mju_sigmoid':[D]}
for n,a in signatures.items():getattr(lib,n).argtypes=a;getattr(lib,n).restype=D
p0=[.75,1.05,-1,200,.5,1.6,1.5,1.3,1.2];d0=[.01,.04,0]
rng=random.Random(20260930);cases=[]
def add(op,values,expected,label):
    cases.append((str(op)+' '+' '.join(format(x,'.17g') for x in values),list(expected),label))
def clip(x,r):return r[0] if x<r[0] else r[1] if x>r[1] else x
def add_step(length,velocity,acc,ctrl,act,h,r,p,b,dp,flags,cr=(0,1),ar=(0,1),fr=(-1e10,1e10),label='scalar-step',expected=None):
    if expected is None:
        c=clip(ctrl,cr) if flags[0] else ctrl
        dot=lib.mju_muscleDynamics(c,act,A3(*dp))
        nxt=act+dot*h
        if flags[1]:nxt=clip(nxt,ar)
        gain=lib.mju_muscleGain(length,velocity,A2(*r),acc,A9(*p))
        bias=lib.mju_muscleBias(length,A2(*r),acc,A9(*b))
        force=gain*(nxt if flags[3] else act)+bias
        if flags[2]:force=clip(force,fr)
        valid=abs(nxt)<=1e10
        expected=[0 if valid else 1,nxt if valid else act,gain,bias,dot,nxt,force]
    add(6,[length,velocity,acc,ctrl,act,h,*r,*p,*b,*dp,*flags,*cr,*ar,*fr],expected,label)
# Every piecewise boundary, both sides by one representable double.
for lmin,lmax in [(.5,1.6),(1,1),(-1e10,1e10),(2,-2),(-1,-.5),(1.5,3)]:
    for pivot in [lmin,.5*(lmin+1),1,.5*(1+lmax),lmax]:
        for x in [math.nextafter(pivot,-math.inf),pivot,math.nextafter(pivot,math.inf)]:
            add(1,[x,lmin,lmax],[lib.mju_muscleGainLength(x,lmin,lmax)],'length-boundary')
for i in range(800):
    lo,hi=sorted([rng.uniform(-10,10),rng.uniform(-10,10)])
    x=rng.uniform(-15,15) if i%2 else rng.choice([-1e30,1e30])
    add(1,[x,lo,hi],[lib.mju_muscleGainLength(x,lo,hi)],'length-random')
for i in range(2000):
    p=p0.copy();r=[0,1];acc=1
    if i%3==0:
        p=[rng.choice([-1e10,-1,0,1e-15,1,1e10]) for _ in p]
        r=[rng.choice([-1e10,-1,0,1e-15,1,1e10]) for _ in r]
        acc=rng.choice([-1e10,0,1e-15,1,1e10])
    else:
        p[2]=rng.choice([-1,50,200]);p[4]=rng.uniform(.1,.9);p[5]=rng.uniform(1.1,2.5)
        p[6]=rng.uniform(.1,5);p[8]=rng.uniform(1,3);acc=rng.uniform(.1,10)
    length=rng.uniform(-2,4);vel=rng.uniform(-10,10)
    add(2,[length,vel,acc,*r,*p],[lib.mju_muscleGain(length,vel,A2(*r),acc,A9(*p))],'gain-random')
    add(3,[length,acc,*r,*p],[lib.mju_muscleBias(length,A2(*r),acc,A9(*p))],'bias-random')
# Normalized velocity -1, 0 and fvmax-1 and normalized passive/active length boundaries.
for pivot in [-1,0,p0[8]-1]:
    for v in [math.nextafter(pivot,-math.inf),pivot,math.nextafter(pivot,math.inf)]:
        p=p0.copy();p[0:2]=[0,1];p[6]=1
        add(2,[.8,v,1,0,1,*p],[lib.mju_muscleGain(.8,v,A2(0,1),1,A9(*p))],'velocity-boundary')
for pivot in [.5,.75,1,1.3,1.6]:
    p=p0.copy();p[0:2]=[0,1]
    for l in [math.nextafter(pivot,-math.inf),pivot,math.nextafter(pivot,math.inf)]:
        add(3,[l,1,0,1,*p],[lib.mju_muscleBias(l,A2(0,1),1,A9(*p))],'bias-boundary')
for w in [-1,0,math.nextafter(1e-15,0),1e-15,math.nextafter(1e-15,math.inf),.2]:
    for x in [-1,-w*.5,0,w*.5,1]:
        add(4,[x,.01,.04,w],[lib.mju_muscleDynamicsTimescale(x,.01,.04,w)],'timescale-boundary')
for i in range(1000):
    vals=[rng.uniform(-1e11,1e11) for _ in range(3)]+[rng.choice([-1,0,1e-15,.2,1e10])]
    add(4,vals,[lib.mju_muscleDynamicsTimescale(*vals)],'timescale-random')
for i in range(1500):
    c,a=[rng.choice([-1e10,-1,0,.5,1,2,1e10]) for _ in range(2)]
    dp=[rng.choice([-1e10,0,1e-15,.01,.04,1e10]),rng.choice([-1e10,0,1e-15,.04,1e10]),rng.choice([-1,0,1e-15,.2,1e10])]
    add(5,[c,a,*dp],[lib.mju_muscleDynamics(c,a,A3(*dp))],'dynamics-random')
for x in [-1e30,-1,0,math.nextafter(0,1),.25,.5,.75,math.nextafter(1,0),1,2,1e30]:
    add(7,[x],[lib.mju_sigmoid(x)],'sigmoid-boundary')
for i in range(1200):
    flags=[(i>>j)&1 for j in range(4)]
    p=p0.copy();bp=p0.copy();dp=d0.copy();dp[2]=rng.choice([0,.2])
    if i%2:bp[2]=120;bp[7]=2.2
    add_step(rng.uniform(-2,4),rng.uniform(-5,5),rng.uniform(.2,2),rng.uniform(-1,2),rng.uniform(-.2,1.2),.001,[0,1],p,bp,dp,flags,fr=(-30,10))
# Oversized Euler increments test Numeric_Limit rollback, and the clamp that avoids it.
for flags in [[0,0,0,0],[0,0,0,1],[0,1,0,1],[1,1,1,1]]:
    add_step(.5,0,1,1,-1e10,1e10,[0,1],p0,p0,[0,0,.2],flags,label='rollback')
# Feedback trajectories alternate early activation and smoothing, using the C state as input.
for pattern in range(4):
    act=.3;dp=[.01,.04,.2 if pattern&1 else 0];flags=[1,1,1,1 if pattern&2 else 0]
    for step in range(300):
        length=.1+(step%73)/40;vel=-2+(step%31)/8;ctrl=.2 if step%2 else .8
        add_step(length,vel,1,ctrl,act,.001,[0,1],p0,p0,dp,flags,fr=(-100,0),label='trajectory')
        act=clip(act+lib.mju_muscleDynamics(ctrl,act,A3(*dp))*.001,(0,1))
# Actual MuJoCo engine invokes these kernels through muscle joint/tendon transmissions.
import mujoco
assert mujoco.__version__=='3.14.0',mujoco.__version__
engine_cases=0
for tendon in [False,True]:
    for early in [False,True]:
        trans='tendon="t"' if tendon else 'joint="j"'
        tendon_xml='<tendon><fixed name="t"><joint joint="j" coef="2"/></fixed></tendon>' if tendon else ''
        xml=f'''<mujoco><option timestep=".001" gravity="0 0 0"/><worldbody><body><joint name="j" type="slide" axis="1 0 0"/><geom size=".1" mass="1"/></body></worldbody>{tendon_xml}<actuator><general {trans} dyntype="muscle" gaintype="muscle" biastype="muscle" dynprm=".01 .04 .2" gainprm=".75 1.05 -1 200 .5 1.6 1.5 1.3 1.2" biasprm=".75 1.05 120 200 .5 1.6 1.5 2.2 1.2" lengthrange=".1 1.9" actearly="{str(early).lower()}" ctrllimited="true" ctrlrange="0 1" actlimited="true" actrange="0 1" forcelimited="true" forcerange="-150 0"/></actuator></mujoco>'''
        m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
        for i in range(80):
            d.qpos[0]=.1+(i%23)/12;d.qvel[0]=-2+(i%17)/4
            d.ctrl[0]=-.2+(i%7)/4;d.act[0]=-.1+(i%13)/10
            mujoco.mj_forward(m,d)
            l=float(d.actuator_length[0]);v=float(d.actuator_velocity[0]);acc=float(m.actuator_acc0[0]);r=list(m.actuator_lengthrange[0]);p=list(m.actuator_gainprm[0,:9]);bp=list(m.actuator_biasprm[0,:9]);dp=list(m.actuator_dynprm[0,:3]);ctrl=float(d.ctrl[0]);act=float(d.act[0]);dot=float(d.act_dot[0]);force=float(d.actuator_force[0])
            gain=lib.mju_muscleGain(l,v,A2(*r),acc,A9(*p));bias=lib.mju_muscleBias(l,A2(*r),acc,A9(*bp))
            mujoco.mj_step(m,d);nxt=float(d.act[0]);expected=[0,nxt,gain,bias,dot,nxt,force]
            add_step(l,v,acc,ctrl,act,.001,r,p,bp,dp,[1,1,1,int(early)],fr=(-150,0),label='engine-tendon' if tendon else 'engine-joint',expected=expected)
            engine_cases+=1
payload='\n'.join(x[0] for x in cases)+'\n';records=[]
for mode in ['validation','release']:
    env['MUSCLE_BUILD_ROOT']=str(out/'build');env['MUSCLE_MODE']=mode
    cmd=['gprbuild','-P',str(HERE/'muscle.gpr'),'-j2']
    build=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,text=True)
    (out/(mode+'-build.log')).write_text(build.stdout+build.stderr);assert build.returncode==0,build.stdout+build.stderr
    run=subprocess.run([str(out/'build'/mode/'bin/muscle_probe')],input=payload,capture_output=True,text=True,env=env)
    assert run.returncode==0,run.stderr
    rows=run.stdout.splitlines();assert len(rows)==len(cases),(len(rows),len(cases))
    max_rel=0;exact=0;different=[];counts={}
    for i,(row,(_,wanted,label)) in enumerate(zip(rows,cases)):
        actual=list(map(float,row.split()));assert len(actual)==len(wanted)
        counts[label]=counts.get(label,0)+1
        for a,b in zip(actual,wanted):
            assert math.isfinite(a) and math.isfinite(b),(i,a,b)
            rel=abs(a-b)/max(1,abs(b));max_rel=max(max_rel,rel)
            if a==b:exact+=1
            if rel>2e-13:different.append({'index':i,'label':label,'actual':a,'expected':b,'relative':rel})
    records.append({'mode':mode,'cases':len(cases),'scalar_comparisons':sum(len(x[1]) for x in cases),'exact_comparisons':exact,'max_relative_error_scaled_by_max_1':max_rel,'failed':different,'coverage':counts,'engine_cases':engine_cases})
    assert not different,different[:10]
assert snapshot()==hashes,'source changed during checks'
(out/'checks.json').write_text(json.dumps({'passed':True,'sources':hashes,'environment':provenance(env),'reference_flags':__import__('reference').FLAGS,'engine_version':mujoco.__version__,'runs':records},indent=2)+'\n')
print(json.dumps(records,indent=2))
