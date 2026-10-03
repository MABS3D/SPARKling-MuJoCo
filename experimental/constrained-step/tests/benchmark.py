"""Whole-step timing: alternating native C/Ada loops, trajectory checked separately."""
import argparse,ctypes,hashlib,json,os,platform,subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import fixtures,model_xml
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
p.add_argument('--repeats',type=int,default=15);p.add_argument('--steps',type=int,default=100)
p.add_argument('--forces',action='store_true',help='Time the newly joined smooth-force/constraint workloads')
a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
wheel=Path(mujoco.__file__).parent;lib=wheel/'libmujoco.so.3.14.0';native=a.out/'benchmark.so'
cmd=['gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',str(Path(__file__).with_suffix('.c')),
 '-I'+str(wheel/'include'),str(lib),'-Wl,-rpath,'+str(wheel),'-o',str(native)]
subprocess.run(cmd,check=True)
f=ctypes.CDLL(str(native)).constrained_time;f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int];f.restype=ctypes.c_double
models=[(n,x) for n,x in fixtures() if n in ['sphere_Newton_3_0.2','coupled_limits_friction','box_multiple','shared_ancestors']]
for n in ([] if a.forces else [4,8,16]):
 body=''.join(f'<body pos="{.4*(i%4)} {.4*(i//4)} .095"><joint type="free"/><geom type="sphere" size=".1" mass="1"/></body>' for i in range(n))
 models.append((f'{n}_free_bodies',model_xml(body)))
if a.forces:
 from compare_forces import mixed_xml
 models=[(f'{joint}-{kind}-{fluid}',mixed_xml(joint,kind,early,fluid))
         for joint,kind,early,fluid in [('slide','integrator',False,'box'),
          ('hinge','filter',True,'ellipsoid'),('ball','filterexact',True,'box'),
          ('free','muscle',True,'ellipsoid')]]
results=[]
for name,xml in models:
 m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path))
 q=m.qpos0.copy();v=np.linspace(-.03,.03,m.nv);force=np.linspace(-.05,.05,m.nv)
 ctrl=np.linspace(.2,.4,m.nu);act=np.full(m.na,.3)
 data=f'1 {a.steps}\n'+' '.join(format(x,'.17g') for x in [0,*q,*v,*force,*ctrl,*act])+ '\n'
 times={'ada':[],'c':[]};states={}
 for repeat in range(a.repeats+2):
  for lang in (['ada','c'] if repeat%2==0 else ['c','ada']):
   if lang=='ada':
    run=subprocess.run([str(a.binary),str(path),'benchmark'],input=data,text=True,capture_output=True,check=True,timeout=180)
    lines=run.stdout.splitlines();assert lines[0].startswith('seconds '),run.stdout
    duration=float(lines[0].split()[1]);states[lang]=np.fromstring(lines[1][6:],sep=' ')
    if m.na:
     assert lines[2].startswith('activation '),run.stdout
     states[lang]=np.r_[states[lang],np.fromstring(lines[2][11:],sep=' ')]
   else:
    mujoco.mj_resetData(m,d);d.qpos[:]=q;d.qvel[:]=v;d.qfrc_applied[:]=force;d.ctrl[:]=ctrl;d.act[:]=act
    duration=f(m._address,d._address,a.steps);states[lang]=np.r_[d.qpos,d.qvel,d.time,d.act].copy()
   if repeat>=2:times[lang].append(duration/a.steps*1e6)
  if not np.allclose(states['ada'],states['c'],atol=3e-6,rtol=1e-8):raise AssertionError((name,np.max(abs(states['ada']-states['c']))))
 summaries={lang:{'median_us':float(np.median(t)),'p10_us':float(np.percentile(t,10)),
                  'p90_us':float(np.percentile(t,90)),'p95_us':float(np.percentile(t,95))} for lang,t in times.items()}
 row=dict(model=name,nv=m.nv,nefc=d.nefc,steps=a.steps,repeats=a.repeats,trajectory_max_abs=float(np.max(abs(states['ada']-states['c']))),
  times_us=times,summary=summaries,ratio=summaries['ada']['median_us']/summaries['c']['median_us'])
 results.append(row);print({k:v for k,v in row.items() if k!='times_us'},flush=True)
(a.out/'results.json').write_text(json.dumps(dict(reference=mujoco.__version__,reference_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),
 binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),hardware=platform.uname()._asdict(),
 affinity=sorted(os.sched_getaffinity(0)),
 cpu=Path('/proc/cpuinfo').read_text().split('model name')[1].splitlines()[0],command=cmd,results=results),indent=2)+'\n')
