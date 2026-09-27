from pathlib import Path
import sys,json,os,subprocess,hashlib
import numpy as np, mujoco
root=Path(__file__).resolve().parent;R=root.parents[2];sys.path.insert(0,str(R/'tests/movement_performance'));import run as bench
build=Path(sys.argv[1]);out=Path(sys.argv[2]);blocks=int(sys.argv[3]);assert blocks%2==0;out.mkdir(exist_ok=False);inputs=root/'fixtures';rng=np.random.default_rng(7281);os.sched_setaffinity(0,{12})
man=json.loads((build/'manifest.json').read_text());bins={k:Path(v['binary']) for k,v in man['builds'].items()};records=[];summaries=[]
for name in json.loads((inputs/'cases.json').read_text()):
 model=mujoco.MjModel.from_xml_path(str(inputs/(name+'.xml')));mujoco.mj_saveModel(model,str(out/(name+'.mjb')))
 data=(inputs/(name+'.input')).read_text();expected=json.loads((inputs/(name+'.expected.json')).read_text());times={k:[] for k in bins};worst={k:0. for k in bins}
 for block in range(blocks):
  order=['ada','c'] if block%2==0 else ['c','ada']
  for v in order:
   cmd=[str(bins[v]),str(out/(name+'.mjb')),'100','4','2'];r=subprocess.run(cmd,input=data,text=True,capture_output=True,timeout=60)
   if r.returncode:raise RuntimeError((name,v,r.stdout,r.stderr))
   rows=[]
   for line in r.stdout.splitlines():
    key,*values=line.split()
    if key=='sample':rows.append({'seconds':float(values[0])})
    else:rows[-1][key]=list(map(float,values))
   assert len(rows)==4
   for row in rows:
    for k in ['qpos','qvel','time','act']:
     x=np.array(expected[k]);y=np.array(row[k]);error=abs(x-y);assert y.shape==x.shape and np.all(error<=2e-10+2e-10*abs(x)),(name,v,k,error.max())
     worst[v]=max(worst[v],float(error.max(initial=0)))
   times[v].append(float(np.median([r['seconds']*1e7 for r in rows])));records.append(dict(case=name,block=block,variant=v,order=order,rows=rows))
 summary=dict(case=name,stats_ns={k:bench.stats(t) for k,t in times.items()},ratio=bench.ratio(times['ada'],times['c'],rng),errors=worst,timings_ns=times);summaries.append(summary)
 print(name,round(summary['ratio']['median'],3),flush=True)
 (out/'results.json').write_text(json.dumps(dict(complete=False,summary=summaries,records=records)))
(out/'results.json').write_text(json.dumps(dict(complete=True,blocks=blocks,cpu=12,steps=100,samples=4,warmups=2,build=str(build),manifest_sha256=hashlib.sha256((build/'manifest.json').read_bytes()).hexdigest(),summary=summaries,records=records),indent=2))
