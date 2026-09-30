#!/usr/bin/env python3
from pathlib import Path
import argparse,hashlib,json,math,os,platform,random,statistics,subprocess
import mujoco
ap=argparse.ArgumentParser();ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--pairs',type=int,default=12);a=ap.parse_args();assert a.pairs>=6
assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
x='''<mujoco><option timestep=".002" gravity="0 0 -9.81" integrator="Euler" solver="PGS" jacobian="dense" iterations="100" tolerance="1e-12"><flag warmstart="disable"/></option><worldbody><geom name="floor" type="plane" size="1 1 .1"/><body name="b"><joint type="slide" axis="0 0 1"/><geom name="ball" type="sphere" size=".1" mass="2"/></body></worldbody><contact><pair geom1="floor" geom2="ball" condim="1" margin=".01" gap=".02" solref=".02 1" solimp=".9 .95 .001 .5 2"/></contact><actuator><general body="b" dyntype="filterexact" dynprm=".02" gainprm="4" actearly="true" ctrllimited="true" ctrlrange="0 1" actlimited="true" actrange="0 1"/></actuator></mujoco>'''
(a.out/'model.xml').write_text(x);m=mujoco.MjModel.from_xml_string(x);path=(a.out/'model.mjb').resolve();mujoco.mj_saveModel(m,str(path));env=os.environ.copy();env['CONTACT_MODEL_PATH']=str(path)
os.sched_setaffinity(0,{12});rng=random.Random(20260930);rows=[]
for fixture,name in enumerate(['fall-impact-rest','active-contact','gap-contact','free-flight']):
 samples=[]
 for k in range(a.pairs):
  row={}
  for b in ([0,1] if k%2==0 else [1,0]):
   p=subprocess.run([str(a.binary),str(b),str(fixture),'1000','8'],env=env,text=True,capture_output=True)
   assert p.returncode==0,(fixture,b,p.returncode,p.stdout,p.stderr)
   row[str(b)]=json.loads(p.stdout)
  samples.append(row)
 ratios=[r['1']['cpu_ns']/r['0']['cpu_ns'] for r in samples];med=statistics.median(ratios);boots=sorted(statistics.median(rng.choices(ratios,k=len(ratios))) for _ in range(5000));lo,hi=boots[125],boots[4874]
 row=dict(name=name,cpu_ada_over_c=med,bootstrap_95=[lo,hi],mad=statistics.median(abs(v-med) for v in ratios),raw=samples)
 for b,label in [('0','c'),('1','ada')]:
  ns=[r[b]['cpu_ns']/8000 for r in samples];row[label+'_ns']=statistics.median(ns);row[label+'_p95_average_ns']=sorted(ns)[math.ceil(.95*len(ns))-1]
 rows.append(row);print(name,round(med,4),[round(lo,4),round(hi,4)],flush=True)
report=dict(reference=mujoco.__version__,scope='Specialized 1-DOF plane/sphere contact, body adhesion and filterexact activation versus full native mj_step. This does not establish general simulator parity.',host='shared',pairs=a.pairs,cpu=12,steps=1000,repeats=8,platform=platform.platform(),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),c_library_sha256=hashlib.sha256(Path('/var/tmp/sparkling-movement-c/build/lib/libmujoco.so.3.14.0').read_bytes()).hexdigest(),results=rows)
(a.out/'results.json').write_text(json.dumps(report,indent=2))
