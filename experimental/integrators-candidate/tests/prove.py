import argparse, pathlib, json, hashlib, subprocess, sys
from build import environment, ROOT

def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--unit',default='mj-integration_kernels');p.add_argument('--only');p.add_argument('--whole',action='store_true');a=p.parse_args()
 a.out.mkdir(parents=True,exist_ok=False);src=a.out/'source';src.mkdir();hashes={}
 for f in [ROOT/'src/mj.ads',ROOT/'src/mj-types.ads',*[(ROOT/'experimental/integrators-candidate/src'/(a.unit+ext)) for ext in ('.ads','.adb')]]:
  data=f.read_bytes();(src/f.name).write_bytes(data);hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
 (a.out/'manifest.json').write_text(json.dumps(hashes,indent=2)+'\n')
 project=a.out/'proof.gpr';project.write_text('project Proof is\n for Source_Dirs use ("source");\n for Object_Dir use "obj";\n for Create_Missing_Dirs use "True";\n package Compiler is for Default_Switches ("Ada") use ("-gnat2022","-ffp-contract=off"); end Compiler;\nend Proof;\n')
 targets=[('whole',None)] if a.whole else []
 if not a.whole:
  for n,line in enumerate((src/(a.unit+'.ads')).read_text().splitlines(),1):
   if line.strip().startswith('function '):
    name=line.strip().split()[1]
    if a.only is None or name==a.only:targets.append((name,n))
 records=[]
 for index,(name,line) in enumerate(targets):
  cmd=['gnatprove','-P',str(project),'-u',a.unit+'.adb','--mode=prove','--proof=per_path','--timeout=5','--steps=0','--prover=cvc5,z3,altergo','--counterexamples=off','--checks-as-errors=on','-j1']
  if line:cmd+=['--limit-subp='+a.unit+'.ads:'+str(line)]
  run=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','180','--',*cmd],env=environment(),capture_output=True,text=True)
  (a.out/(str(index)+'.log')).write_text(run.stdout+run.stderr)
  report=a.out/'obj/gnatprove'/(a.unit+'.spark')
  record=dict(name=name,exit=run.returncode,command=cmd,verified=False)
  if report.exists():
   (a.out/(str(index)+'.spark.json')).write_bytes(report.read_bytes())
   d=json.loads(report.read_text());messages=[m for k in ['proof','flow','warn_error'] for m in d.get(k,[])]
   record.update(proof_checks=sum(m.get('severity')=='info' for m in d.get('proof',[])),flow_checks=sum(m.get('severity')=='info' for m in d.get('flow',[])),open=[m for m in messages if m.get('severity') not in ['info','warning']],coverage=bool(d.get('spark')) and all(v=='all' for v in d.get('spark',{}).values()) and not any(d.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume']))
   record['verified']=run.returncode==0 and record['coverage'] and record['proof_checks']>0 and not record['open']
  records.append(record);print(name,run.returncode,record.get('proof_checks'),record['verified'],flush=True)
 (a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n');raise SystemExit(0 if records and all(r['verified'] for r in records) else 1)
if __name__=='__main__':main()
