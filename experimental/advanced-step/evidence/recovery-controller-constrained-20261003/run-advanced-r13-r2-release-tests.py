from pathlib import Path
import subprocess,json
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');tests=root/'experimental/advanced-step/tests';binary=Path('/var/tmp/sparkling-services-advanced-constrained-r13-r2-20261003/build/release/bin');py='/var/tmp/sparkling-movement-env/bin/python';records=[]
tasks=[('edges',[py,str(tests/'controller_edges.py'),'--bin-dir',str(binary),'--out','/var/tmp/sparkling-services-advanced-controller-edges-r13-r2-release-20261003']),('smooth',[py,str(tests/'compare.py'),'--binary',str(binary/'advanced_probe'),'--out','/var/tmp/sparkling-services-advanced-smooth-r13-r2-release-20261003'])]
for domain,reference in [('fixed','/var/tmp/sparkling-services-advanced-constrained-r13-newton-pyramidal-20261003'),('mobile','/var/tmp/sparkling-services-advanced-constrained-r13-mobile-newton-20261003')]:
 tasks.append((domain,[py,str(tests/'replay_outputs.py'),'--binary',str(binary/'constrained_advanced_probe'),'--reference',reference,'--out',f'/var/tmp/sparkling-services-advanced-constrained-r13-r2-release-replay-{domain}-20261003']))
for name,cmd in tasks:
 log=Path('/var/tmp')/('advanced-r13-r2-release-'+name+'.log')
 with log.open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,timeout=150)
 records.append(dict(name=name,command=cmd,log=str(log),exit=r.returncode));print(name,r.returncode,log.read_text()[-180:],flush=True)
Path('/var/tmp/advanced-r13-r2-release-runs.json').write_text(json.dumps(records,indent=2)+'\n')
raise SystemExit(any(x['exit']for x in records))
