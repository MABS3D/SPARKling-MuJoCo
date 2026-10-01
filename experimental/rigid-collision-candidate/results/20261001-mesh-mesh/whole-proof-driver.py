from pathlib import Path
import sys,subprocess,json,hashlib
sys.path.insert(0,'/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/rigid-collision-candidate/tests')
from common import environment,ROOT
snapshot=Path('/var/tmp/sparkling-meshmesh-final-20261001/source');out=Path('/var/tmp/sparkling-meshmesh-proof-final-20261001');out.mkdir(exist_ok=False)
rows=[]
for unit in ['mj-convex_assets.adb','mj-contact_incidence.adb']:
 env=environment();env['RIGID_MODE']='validation';env['RIGID_BUILD_ROOT']=str(out/unit)
 cmd=['gnatprove','-P',str(snapshot/'rigid.gpr'),'-u',unit,'-j1','--checks-as-errors=on','--report=all','--level=2','--prover=cvc5,altergo','--timeout=5','--counterexamples=off']
 with (out/(unit+'.log')).open('w') as log:
  r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','150','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
 rows.append(dict(unit=unit,exitcode=r.returncode,command=cmd,source_sha256=hashlib.sha256((snapshot/'src'/unit).read_bytes()).hexdigest()))
 (out/'summary.json').write_text(json.dumps(rows,indent=2)+'\n');print(unit,r.returncode,flush=True)
