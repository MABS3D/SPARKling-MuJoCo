"""Prove selected controller routines on an existing immutable build closure."""
import argparse
import hashlib
import json
import re
import resource
import shutil
import subprocess
import time
from pathlib import Path
from build import environment, ROOT


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--name',action='append')
    p.add_argument('--whole',action='store_true')
    p.add_argument('--flow',action='store_true')
    p.add_argument('--budget',type=int,default=240)
    p.add_argument('--stack-mb',type=int,default=64)
    p.add_argument('--project',default='advanced.gpr')
    p.add_argument('--unit',default='mj-data-advanced_control')
    p.add_argument('--part',choices=['ads','adb'],default='adb',
                   help='source part containing the selected minimum target')
    p.add_argument('--timeout',type=int,default=5)
    p.add_argument('--memlimit',type=int,default=700)
    p.add_argument('--provers',default='cvc5,z3,altergo')
    p.add_argument('--no-inlining',action='store_true')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    manifest=json.loads((a.build/'manifest.json').read_text())
    snap=a.build/'source';unit=a.unit
    for name,h in manifest['sources'].items():
        assert hashlib.sha256((snap/name).read_bytes()).hexdigest()==h,name
    (a.out/'sources.json').write_text(json.dumps(manifest,indent=2)+'\n')
    project=snap/'experimental/advanced-step'/a.project
    names=a.name or ['Capture_Evaluation','Restore_Evaluation']
    targets=[('whole',None)] if a.whole or a.flow else []
    if not targets:
        locations={}
        bodies = [snap/name for name in manifest['sources']
                  if name.endswith('/'+unit+'.'+a.part)]
        assert len(bodies) == 1, 'selected unit source must be unique in the frozen manifest'
        for i,line in enumerate(bodies[0].read_text().splitlines(),1):
            m=re.match(r'\s*(?:function|procedure) (\w+)\b',line)
            # Private forward declarations precede their bodies in this unit.
            if m and m[1] in names:locations[m[1]]=f'{unit}.{a.part}:{i}'
        targets=[(name,locations[name]) for name in names if name in locations]
        assert len(targets)==len(names),'unknown target'
    resource.setrlimit(resource.RLIMIT_STACK,(a.stack_mb*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    env=environment();env['ADVANCED_MODE']='validation'
    results=[]
    for label,limit in targets:
        env['ADVANCED_BUILD_ROOT']=str(a.out/label)
        cmd=['gnatprove','-f','-P',str(project),'-u',unit+'.adb','--prover='+a.provers,
            '--timeout='+str(a.timeout),'--steps=0','--memlimit='+str(a.memlimit),'--proof=per_check','--level=2','-j1',
            '--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
        if limit:cmd.append('--limit-subp='+limit)
        if a.flow:cmd+=['--mode=flow']
        if a.flow or a.no_inlining:cmd+=['--no-inlining']
        start=time.monotonic()
        proc=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2800',
            '--min-free-mb','700','--timeout',str(a.budget),'--',*cmd],env=env,text=True,capture_output=True)
        (a.out/(label+'.log')).write_text(proc.stdout+proc.stderr)
        record=dict(label=label,exit=proc.returncode,seconds=time.monotonic()-start,command=cmd,stack_mb=a.stack_mb,
                    driver_sha256=driver_sha256, sources_unchanged_after=all(
                        hashlib.sha256((snap/name).read_bytes()).hexdigest()==h
                        for name,h in manifest['sources'].items()))
        report=next((a.out/label).rglob(unit+'.spark'),None)
        if report:
            data=json.loads(report.read_text());shutil.copyfile(report,a.out/(label+'.spark.json'))
            entries=[x for k in ['proof','flow','warn_error'] for x in data.get(k,[])]
            expected_stop = 'STOP_REASON_FLOW_MODE' if a.flow else 'STOP_REASON_NONE'
            record.update(proof_checks=sum(x.get('severity')=='info' for x in data.get('proof',[])),
                flow_checks=sum(x.get('severity')=='info' for x in data.get('flow',[])),
                progress=data.get('progress'), stop_reason=data.get('stop_reason'),
                expected_stop_reason=expected_stop,
                open=[x for x in entries if x.get('severity') not in ['info','warning']],
                warnings=[x for x in entries if x.get('severity')=='warning'],
                coverage=bool(data.get('spark')) and all(x=='all' for x in data['spark'].values())
                    and not any(data.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume'])
                    and data.get('stop_reason')==expected_stop
                    and (not a.flow or data.get('progress')=='PROGRESS_FLOW'))
        record['verified']=(proc.returncode==0 and record['sources_unchanged_after'] and record.get('coverage',False)
            and not record.get('open',[None]) and record.get('flow_checks' if a.flow else 'proof_checks',0)>0)
        results.append(record);(a.out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
        print(label,record.get('proof_checks'),record.get('flow_checks'),
              len(record['open']) if 'open' in record else None,record['verified'],flush=True)
        if not record['verified']:print((proc.stdout+proc.stderr)[-3500:])
        if report is None or not record.get('coverage',False):
            break  # Do not repeat a failed compilation, unsupported construct or guard expiry.
    raise SystemExit(not all(x['verified'] for x in results))

if __name__=='__main__':main()
