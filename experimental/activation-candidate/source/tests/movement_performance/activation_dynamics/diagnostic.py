from pathlib import Path
import sys,subprocess,json,re,os
import numpy as np, mujoco,mujoco
root=Path(__file__).resolve().parent;sys.path.insert(0,str(root.parent));import run as h
build=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(exist_ok=False);os.sched_setaffinity(0,{12});rng=np.random.default_rng(45928);raw=[];summary=[]
ref='filterexact-24dof-24act';src=root/'fixtures';xml=(src/(ref+'.xml')).read_text();initial=np.fromstring((src/(ref+'.input')).read_text(),sep=' ');n=u=24;initial[2*n:2*n+u]=0;initial[3*n+u:]=0
models={}
for mode in ['none','integrator','filter','filterexact']:
 text=xml.replace('dyntype="filterexact"',f'dyntype="{mode}"')
 if mode=='none':text=re.sub(r' actearly="[^"]*"| actlimited="[^"]*"| actrange="[^"]*"','',text)
 m=mujoco.MjModel.from_xml_string(text);path=out/(mode+'.mjb');mujoco.mj_saveModel(m,str(path));data=initial[:3*n+u] if mode=='none' else initial;models[mode]=(path,' '.join(map(str,data))+'\n')
 d=mujoco.MjData(m);d.qpos[:]=initial[:n];d.qvel[:]=initial[n:2*n];d.qfrc_applied[:]=initial[2*n+u:3*n+u];d.time=.125
 for _ in range(100):mujoco.mj_step(m,d)
 if mode=='none':expected=(d.qpos.copy(),d.qvel.copy())
 else:assert np.array_equal(expected[0],d.qpos) and np.array_equal(expected[1],d.qvel)
for mode in ['integrator','filter','filterexact']:
 labels=['ada-none','c-none','ada-active','c-active'];times={k:[] for k in labels}
 for b in range(24):
  order=labels[b%4:]+labels[:b%4]
  for label in order:
   variant=label.split('-')[0];which='none' if label.endswith('none') else mode;path,data=models[which];binary=build/('bin/movement_bench' if variant=='ada' else 'movement_c');p=subprocess.run([str(binary),str(path),'100','4','2'],input=data,text=True,capture_output=True,timeout=60);assert p.returncode==0,(label,p.stderr)
   values=[float(line.split()[1])*1e7 for line in p.stdout.splitlines() if line.startswith('sample ')];times[label].append(float(np.median(values)));raw.append(dict(mode=mode,block=b,label=label,stdout=p.stdout))
 s=dict(mode=mode,stats={k:h.stats(v) for k,v in times.items()},ratio_none=h.ratio(times['ada-none'],times['c-none'],rng),ratio_active=h.ratio(times['ada-active'],times['c-active'],rng),increment_ns={v:float(np.median(np.array(times[v+'-active'])-times[v+'-none'])) for v in ['ada','c']},timings=times);summary.append(s);print(mode,s['ratio_none'],s['ratio_active'],s['increment_ns'],flush=True)
(out/'results.json').write_text(json.dumps(dict(note='Zero controls/activation only for cost attribution; nonzero workload acceptance is measured separately.',summary=summary,raw=raw),indent=2))
