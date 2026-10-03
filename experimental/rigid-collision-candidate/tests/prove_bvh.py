"""Minimal functional helpers, then whole-unit proof/flow diagnostics."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

from common import environment, ROOT


def run(out, selected=None, check_timeout=3):
    source=out/'source';unit='mj-rigid_bvh.adb';code=(source/'src'/unit).read_text()
    reports=out/'bvh-proofs';reports.mkdir(exist_ok=False);runs=[]
    for name,flow in [('Merge_Bounds',False),('Append_Id',False),(None,True),(None,False)]:
        label=name or ('whole-flow' if flow else 'whole-proof')
        if selected and label not in selected:
            continue
        env=environment();env.update(RIGID_MODE='validation',RIGID_BUILD_ROOT=str(reports/label))
        cmd=['gnatprove','-P',str(source/'rigid.gpr'),'-u',unit,'-j1','--report=all','--checks-as-errors=on']
        cmd+=['--mode=flow'] if flow else ['--prover=cvc5,z3,altergo','--timeout='+str(check_timeout),'--memlimit=650','--steps=0','--proof=per_check','--counterexamples=off','--no-inlining']
        if name:
            m=re.search(r'^   procedure '+name+r'\b',code,re.M)
            cmd+=['--limit-subp='+unit+':'+str(code[:m.start()].count('\n')+1)]
        r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','150','--',*cmd],env=env,text=True,capture_output=True,timeout=170)
        (reports/(label+'.log')).write_text(r.stdout+r.stderr)
        for p in (Path(env['RIGID_BUILD_ROOT'])/'validation/obj/gnatprove').glob('*.spark'):
            shutil.copyfile(p,reports/(label+'--'+p.name))
        report=reports/(label+'--mj-rigid_bvh.spark')
        entries=[]
        if report.is_file():
            data=json.loads(report.read_text())
            entries=[e for kind in ('proof','flow','warn_error') for e in data.get(kind,[])]
        open_checks=sum(e.get('severity') not in ('info','warning') for e in entries)
        runs.append(dict(label=label,exit=r.returncode,command=cmd,
                         proved=sum(e.get('severity')=='info' for e in entries),open=open_checks,
                         passed=r.returncode==0 and report.is_file() and open_checks==0))
        print(label,r.returncode,flush=True)
        (reports/'summary.json').write_text(json.dumps(dict(
          sources={str(f.relative_to(source)):hashlib.sha256(f.read_bytes()).hexdigest()
                   for f in source.rglob('*') if f.is_file() and f.suffix in ('.adb','.ads','.gpr')},
          runs=runs,scope='Helper contracts and explicit full-unit diagnostics; unproved whole-unit obligations remain engineering work.'),indent=2)+'\n')
    return runs


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    p.add_argument('--scope',action='append',choices=['Merge_Bounds','Append_Id','whole-flow','whole-proof'])
    p.add_argument('--timeout',type=int,default=3)
    a=p.parse_args();runs=run(a.out.resolve(),a.scope,a.timeout)
    raise SystemExit(any(not row['passed'] for row in runs))
