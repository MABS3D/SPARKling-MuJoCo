from pathlib import Path
import subprocess,time,json,os
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');out=Path(__file__).parent
python='/var/tmp/sparkling-movement-env/bin/python';tests=Path('/var/tmp/sparkling-recovery-flex-interpolated-state-runner4-20261003');rows=[]
env=os.environ.copy();env['OPENBLAS_NUM_THREADS']='1'
for profile,build in [('validation','/var/tmp/sparkling-recovery-flex-interpolated-state2-20261003'),('release','/var/tmp/sparkling-recovery-flex-interpolated-state2-release-20261003')]:
 args=[python,str(root/'tools/guarded.py'),'--cap-mb','2500','--timeout','600','--',python,str(tests/'compare_interpolated_state.py'),'--binary',build+'/build/'+profile+'/bin/flex_state_probe','--out',str(out/profile),'--samples','8']
 start=time.monotonic()
 with (out/(profile+'.log')).open('w') as f:r=subprocess.run(args,cwd=root,env=env,stdout=f,stderr=subprocess.STDOUT)
 row=dict(profile=profile,exit=r.returncode,seconds=time.monotonic()-start,command=args);rows.append(row)
 out.joinpath('results.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
raise SystemExit(any(r['exit'] for r in rows))
