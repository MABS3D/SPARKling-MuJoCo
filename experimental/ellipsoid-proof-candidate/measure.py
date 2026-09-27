from pathlib import Path
import sys,os,subprocess,json,hashlib,itertools
import numpy as np
import mujoco
root=Path('/var/tmp/sparkling-ellipsoid-proof-20260928');repo=root/'work'
sys.path.insert(0,str(repo/'tests/movement_performance'))
from run import parse,stats,ratio,reference
out=root/sys.argv[1];out.mkdir()
binaries={'candidate':root/'release/bin/movement_bench','baseline':root/'release-baseline/bin/movement_bench','c':Path('/var/tmp/sparkling-fluid-20260927/movement_c')}
os.sched_setaffinity(0,{12});rng=np.random.default_rng(20260928)
steps=100;samples=12;blocks=24;cases=[];records=[]
orders=list(itertools.permutations(binaries))
models=['fluid_ellipsoid_ellipsoid_all','fluid_ellipsoid_multiple','fluid_ellipsoid_sphere_all','fluid_flags_both_off','fluid_ellipsoid_chain24','fluid_ellipsoid_star24','fluid_ellipsoid_branches24']
fixtures=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/fluid-candidate/fixtures')
for name in models:
 path=fixtures/(name+'.xml');m=mujoco.MjModel.from_xml_path(str(path));mp=out/(name+'.mjb');mujoco.mj_saveModel(m,str(mp))
 for state in range(3):
  q=m.qpos0+rng.uniform(-.25,.25,m.nq);v=rng.uniform(-.5,.5,m.nv);ctrl=rng.uniform(-.4,.4,m.nu);applied=rng.uniform(-.1,.1,m.nv)
  data=' '.join(format(x,'.17g') for x in np.concatenate((q,v,ctrl,applied)))+'\n'
  key=name+'-'+str(state);(out/(key+'.input')).write_text(data)
  expected=reference(m,q,v,ctrl,applied,.125,steps);timings={k:[] for k in binaries};alltimings={k:[] for k in binaries};error=0
  for block in range(blocks):
   order=orders[block%len(orders)]
   for variant in order:
    run=subprocess.run([str(binaries[variant]),str(mp),str(steps),str(samples),'2'],input=data,text=True,capture_output=True,check=True,timeout=30)
    rows=parse(run.stdout)
    for row in rows:
     for field in ('qpos','qvel','time'):
      actual=np.asarray(row[field]);ref=expected[field];delta=abs(actual-ref)
      assert actual.shape==ref.shape and np.all(delta<=2e-10+2e-10*abs(ref)),(key,variant,field,delta)
      error=max(error,float(max(delta,default=0)))
    ns=[row['seconds']*1e9/steps for row in rows];timings[variant].append(float(np.median(ns)));alltimings[variant].extend(ns)
    records.append({'case':key,'block':block,'variant':variant,'order':order,'rows':rows})
  item={'case':key,'nv':m.nv,'max_absolute_error':error,'ns':{k:stats(x) for k,x in alltimings.items()},'candidate_over_baseline':ratio(timings['candidate'],timings['baseline'],rng),'candidate_over_c':ratio(timings['candidate'],timings['c'],rng)};cases.append(item)
  (out/'results.json').write_text(json.dumps({'complete':False,'summary':cases,'records':records},indent=2));print(key,item['candidate_over_baseline'],flush=True)
manifest={'complete':True,'blocks':blocks,'samples':samples,'steps':steps,'cpu':12,'seed':20260928,'binaries':{k:{'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for k,p in binaries.items()},'summary':cases,'records':records}
(out/'results.json').write_text(json.dumps(manifest,indent=2))
