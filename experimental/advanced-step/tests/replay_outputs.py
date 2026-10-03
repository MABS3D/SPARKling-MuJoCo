"""Replay persisted differential inputs and require identical native output."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
runs=[]
for inp in sorted(a.reference.glob('*.input')):
    model=inp.with_suffix('.mjb');before=inp.with_suffix('.output');cmd=[str(a.binary),str(model),'loads'];start=time.monotonic()
    r=subprocess.run(cmd,input=inp.read_bytes(),capture_output=True,timeout=180)
    actual=r.stdout+r.stderr;after=a.out/before.name;after.write_bytes(actual)
    runs.append(dict(model=inp.stem,command=cmd,exit=r.returncode,identical=actual==before.read_bytes(),
        seconds=time.monotonic()-start,input_sha256=digest(inp),model_sha256=digest(model),
        before_sha256=digest(before),after_sha256=digest(after)))
    if r.returncode or not runs[-1]['identical']:print(inp.stem,'FAIL',flush=True)
(a.out/'results.json').write_text(json.dumps(dict(binary_sha256=digest(a.binary),reference=str(a.reference),
    reference_results_sha256=digest(a.reference/'results.json'),models=len(runs),passed=sum(x['exit']==0 and x['identical']for x in runs),records=runs),indent=2)+'\n')
print('identical models',sum(x['exit']==0 and x['identical']for x in runs),'/',len(runs),flush=True)
raise SystemExit(not all(x['exit']==0 and x['identical']for x in runs))
