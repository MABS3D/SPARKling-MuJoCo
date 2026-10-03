from pathlib import Path
import subprocess,json
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');tests=root/'experimental/advanced-step/tests';binary=Path('/var/tmp/sparkling-services-advanced-constrained-r14-r1-20261003/build/validation/bin');py='/var/tmp/sparkling-movement-env/bin/python';records=[]
jobs=[('edges','controller_edges.py',['--bin-dir',str(binary)],'/var/tmp/sparkling-services-advanced-controller-edges-r14-r1-20261003'),('min','compare_constrained.py',['--binary',str(binary/'constrained_advanced_probe'),'--only','combo_','--samples','2','--steps','10'],'/var/tmp/sparkling-services-advanced-constrained-r14-min-20261003'),('smooth','compare.py',['--binary',str(binary/'advanced_probe')],'/var/tmp/sparkling-services-advanced-smooth-r14-r1-20261003'),('fixed','compare_constrained.py',['--binary',str(binary/'constrained_advanced_probe')],'/var/tmp/sparkling-services-advanced-constrained-r14-fixed-20261003'),('mobile','compare_constrained.py',['--binary',str(binary/'constrained_advanced_probe'),'--contact-mobility','free-carrier'],'/var/tmp/sparkling-services-advanced-constrained-r14-mobile-20261003'),('parent',str(root/'experimental/constrained-step/tests/compare.py'),['--binary',str(binary/'constrained_probe'),'--samples','2'],'/var/tmp/sparkling-services-advanced-constrained-r14-parent-regression-20261003')]
for name,script,extra,out in jobs:
 command=[py,str(tests/script),*extra,'--out',out];log=Path('/var/tmp/advanced-r14-r1-'+name+'.log')
 with log.open('w')as f:p=subprocess.run(command,stdout=f,stderr=subprocess.STDOUT,timeout=180)
 record=dict(name=name,command=command,exit=p.returncode,log=str(log));records.append(record)
 print(name,p.returncode,log.read_text()[-300:],flush=True)
 Path('/var/tmp/advanced-r14-r1-runs.json').write_text(json.dumps(records,indent=2)+'\n')
raise SystemExit(any(r['exit']for r in records))
