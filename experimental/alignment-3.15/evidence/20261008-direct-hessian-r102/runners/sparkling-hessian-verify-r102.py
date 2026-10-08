from pathlib import Path
import subprocess,json,hashlib,time
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
py='/var/tmp/sparkling-movement315-env/bin/python'
rows=[]
for label,cmd in [
 ('native',[py,str(root/'experimental/alignment-3.15/tests/build_hessian.py'),'--engine','/var/tmp/sparkling-alignment-315-hessian-engine-r102-20261008','--out','/var/tmp/sparkling-alignment-315-hessian-native-r102-20261008','--python',py,'--reference','/var/tmp/sparkling-alignment-315-foundation-r6-20261007/source/mujoco']),
 ('release',[py,str(root/'experimental/alignment-3.15/tests/build_flex.py'),'--foundation','/var/tmp/sparkling-alignment-315-foundation-r6-20261007','--out','/var/tmp/sparkling-alignment-315-hessian-release-r102-20261008','--python',py,'--mode','release']),
 ('production',['/var/tmp/sparkling-movement-env/bin/python',str(root/'experimental/alignment-3.15/tests/build_flex.py'),'--foundation','/var/tmp/sparkling-alignment-314-foundation-r2-20261007','--out','/var/tmp/sparkling-alignment-314-hessian-regression-r102-20261008','--python','/var/tmp/sparkling-movement-env/bin/python','--mode','release','--production-regression'])]:
 start=time.monotonic();r=subprocess.run(cmd,cwd=root)
 rows.append(dict(label=label,command=cmd,exit=r.returncode,seconds=time.monotonic()-start,runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()))
 Path('/var/tmp/sparkling-hessian-verify-r102.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(label,r.returncode,flush=True)
 if r.returncode:raise SystemExit(r.returncode)
