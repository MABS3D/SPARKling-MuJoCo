#!/usr/bin/env python3
"""Whole scalar-contact trajectories; paired native C/Ada CPU and wall samples."""
from pathlib import Path
import argparse,hashlib,json,math,os,platform,random,statistics,subprocess
import mujoco
from compare import DEFAULT,xml
from evidence import snapshot,digest
ap=argparse.ArgumentParser();ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--cpu',type=int,default=12);ap.add_argument('--pairs',type=int,default=21);args=ap.parse_args()
source_hashes=snapshot()
assert args.pairs>=5
args.out.parent.mkdir(parents=True,exist_ok=True)
model_path=args.out.parent/'benchmark-model.mjb'
model_xml=xml(DEFAULT)
(args.out.parent/'benchmark-model.xml').write_text(model_xml)
mujoco.mj_saveModel(mujoco.MjModel.from_xml_string(model_xml),str(model_path),None)
os.environ['CONTACT_MODEL_PATH']=str(model_path)
os.sched_setaffinity(0,{args.cpu});rng=random.Random(20260929);results=[]
for fixture,name in enumerate(['fall-impact-rest','resting','detaching','free-flight']):
 samples=[]
 for k in range(args.pairs):
  sample={}
  for backend in ([0,1] if k%2==0 else [1,0]):
   r=subprocess.run([str(args.binary),str(backend),str(fixture),'1000','8'],capture_output=True,text=True)
   if r.returncode:raise RuntimeError((r.returncode,r.stdout,r.stderr))
   sample[str(backend)]=json.loads(r.stdout)
  samples.append(sample)
 ratios=[x['1']['cpu_ns']/x['0']['cpu_ns'] for x in samples]
 med=statistics.median(ratios);boots=sorted(statistics.median(rng.choices(ratios,k=len(ratios))) for _ in range(10000));lo,hi=boots[250],boots[9749]
 row={'fixture':name,'median_ada_over_c':med,'mad_ratio':statistics.median(abs(x-med) for x in ratios),'bootstrap_95':[lo,hi],'status':'faster' if hi<1 else 'slower' if lo>1 else 'inconclusive','samples':samples}
 for b,key in [('0','c'),('1','ada')]:
  ns=[x[b]['cpu_ns']/(1000*8) for x in samples]
  row[key+'_ns']=statistics.median(ns);row[key+'_p95_average_ns']=sorted(ns)[math.ceil(.95*len(ns))-1]
 results.append(row);print(name,round(med,4),[round(lo,4),round(hi,4)],flush=True)
report={'source_sha256':source_hashes,'model_sha256':digest(model_path),'python_mujoco_library_sha256':digest(next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))),'native_library_sha256':digest('/var/tmp/sparkling-movement-c/build/lib/libmujoco.so.3.14.0'),'platform':platform.platform(),'cpu':args.cpu,'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0],'pairs':args.pairs,'steps_per_trajectory':1000,'trajectories_per_sample':8,'binary_sha256':hashlib.sha256(args.binary.read_bytes()).hexdigest(),'scope':'one vertical slider and one frictionless plane-sphere contact; specialized scalar pipeline versus full C mj_step; not general contact or simulator parity','results':results}
assert source_hashes==snapshot()
args.out.write_text(json.dumps(report,indent=2)+'\n')
