"""Minimal subprograms first, then fresh complete-unit evidence; flow is separate."""
import argparse,json,re,shutil,subprocess,time,resource
from pathlib import Path
from build import environment,ROOT
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--only-integration',action='store_true');a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
(a.out/'sources.json').write_text((a.build/'manifest.json').read_text())
snap=a.build/'source';project=snap/'experimental/advanced-step/advanced.gpr'
body=snap/'experimental/advanced-step/src/mj-advanced_state.adb'
targets=[(m[1],f'mj-advanced_state.adb:{i}') for i,line in enumerate(body.read_text().splitlines(),1)
         if (m:=re.match(r'\s*function (\w+)',line))]
targets += [('whole',None),('integration-flow',None)]
if a.only_integration:targets=targets[-1:]
records=[]
for label,limit in targets:
 env=environment();env['ADVANCED_BUILD_ROOT']=str(a.out/label);env['ADVANCED_MODE']='validation'
 cmd=['gnatprove','-P',str(project),'-u','mj-data-advanced.adb' if label=='integration-flow' else 'mj-advanced_state.adb',
      '--prover=cvc5,z3,altergo','--timeout=5','--memlimit=700','--steps=0','--proof=per_check','-j1',
      '--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
 if limit:cmd += ['--limit-subp='+limit]
 if label=='integration-flow':cmd+=['--mode=flow','--no-inlining']
 start=time.monotonic()
 run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2600','--timeout','110','--',*cmd],
                    env=env,capture_output=True,text=True)
 (a.out/(label+'.log')).write_text(run.stdout+run.stderr)
 record=dict(label=label,exit=run.returncode,seconds=time.monotonic()-start,command=cmd)
 reports=list((a.out/label).rglob('*.spark'))
 unit='mj-data-advanced' if label=='integration-flow' else 'mj-advanced_state'
 report=next((p for p in reports if p.stem==unit),None)
 if report:
  d=json.loads(report.read_text());shutil.copyfile(report,a.out/(label+'.spark.json'))
  entries=[m for kind in ['proof','flow','warn_error'] for m in d.get(kind,[])]
  record.update(proof_checks=sum(m.get('severity')=='info' for m in d.get('proof',[])),
                flow_checks=sum(m.get('severity')=='info' for m in d.get('flow',[])),
                coverage=bool(d.get('spark')) and all(v=='all' for v in d.get('spark',{}).values()) and not any(d.get(k) for k in ('skip_proof','skip_flow_proof','pragma_assume')),
                passed=sum(m.get('severity')=='info' for m in entries),
                open=sum(m.get('severity') not in ('info','warning') for m in entries),
                warnings=sum(m.get('severity')=='warning' for m in entries))
 record['verified']=(run.returncode==0 and record.get('coverage',False) and record.get('open',1)==0 and (record.get('flow_checks',0)>0 if label=='integration-flow' else record.get('proof_checks',0)>0))
 records.append(record);print(record,flush=True)
(a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
raise SystemExit(0 if records and all(r['verified'] for r in records) else 1)
