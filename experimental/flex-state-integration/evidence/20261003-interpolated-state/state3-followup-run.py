import json,os,subprocess,time,hashlib
from pathlib import Path
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');out=Path(__file__).parent
python='/var/tmp/sparkling-movement-env/bin/python';old=Path('/var/tmp/sparkling-recovery-flex-interpolated-state2-20261003')
base=Path('/var/tmp/sparkling-recovery-flex-interpolated-state3-20261003');release=Path('/var/tmp/sparkling-recovery-flex-interpolated-state3-release-20261003')
env=os.environ.copy();env['OPENBLAS_NUM_THREADS']='1';rows=[]
def run(name,args,limit=None):
 cmd=([python,str(root/'tools/guarded.py'),'--cap-mb','2500','--timeout',str(limit),'--'] if limit else [])+args
 start=time.monotonic()
 with (out/(name+'.log')).open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env,cwd=root)
 row=dict(name=name,exit=r.returncode,seconds=time.monotonic()-start,command=cmd);rows.append(row)
 (out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True);return r.returncode
if run('validation-build',[python,str(root/'experimental/flex-state-integration/tests/build.py'),'--base',str(old),'--refresh-owned','--out',str(base)]):raise SystemExit(1)
manifest=json.loads((base/'manifest.json').read_text());kernel=json.loads(Path('/var/tmp/sparkling-recovery-flex-interpolation9-20261003/manifest.json').read_text())
assert all(manifest['sources'][n]==h for n,h in kernel['sources'].items() if n.endswith('mj-flex_interpolation.ads') or n.endswith('mj-flex_interpolation.adb'))
run('flow',[python,str(root/'experimental/flex-state-integration/tests/prove.py'),'--build',str(base),'--out',str(base)+'-flow','--only','flow'])
tests=base/'source/experimental/flex-state-integration/tests'
for profile,build in [('validation',base),('release',release)]:
 if profile=='release':
  if run('release-build',[python,str(root/'experimental/flex-state-integration/tests/build.py'),'--base',str(base),'--out',str(release),'--mode','release']):break
 binary=build/'build'/profile/'bin/flex_state_probe';cases=out/(profile+'-interpolated');ordinary=out/(profile+'-ordinary')
 run(profile+'-interpolated',[python,str(tests/'compare_interpolated_state.py'),'--binary',str(binary),'--out',str(cases),'--samples','8'],600)
 run(profile+'-ordinary',[python,str(tests/'compare.py'),'--binary',str(binary),'--out',str(ordinary),'--samples','8'],180)
 run(profile+'-policy',[python,str(tests/'policy.py'),'--binary',str(binary),'--fixtures',str(ordinary),'--out',str(out/(profile+'-policy'))],60)
 run(profile+'-interpolated-policy',[python,str(tests/'policy_interpolation.py'),'--binary',str(binary),'--fixtures',str(cases),'--out',str(out/(profile+'-interpolated-policy'))],60)
raise SystemExit(any(r['exit'] for r in rows))
