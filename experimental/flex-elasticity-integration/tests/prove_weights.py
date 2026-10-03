"""Minimal, frozen proof boundary for C element distance/normalization."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,HERE,environment

def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
 p.add_argument('--scope',action='append',choices=['Distance','Inverse_Distance','Reciprocal','Scaled_Weight','Normalize','whole'])
 a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False);source=a.out/'source';source.mkdir()
 paths=[ROOT/'src/mj.ads',ROOT/'src/mj-types.ads',HERE/'src/mj-flex_contact_weights.ads',HERE/'src/mj-flex_contact_weights.adb']
 hashes={}
 for f in paths:
  data=f.read_bytes();(source/f.name).write_bytes(data);hashes[str(f.relative_to(ROOT))]=hashlib.sha256(data).hexdigest()
 project=source/'weights.gpr';project.write_text('''project Weights is
 for Source_Dirs use (".");
 for Object_Dir use external ("WEIGHT_PROOF_ROOT") & "/obj";
 for Create_Missing_Dirs use "True";
 package Compiler is
  for Default_Switches ("Ada") use ("-gnat2022","-gnata","-gnato","-ffp-contract=off");
 end Compiler;
end Weights;
''')
 receipt=dict(sources=hashes,project_sha256=hashlib.sha256(project.read_bytes()).hexdigest(),complete=False,scopes=[])
 (a.out/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
 for scope in a.scope or ['Distance','Inverse_Distance','Reciprocal','Scaled_Weight','Normalize','whole']:
  env=environment();env['WEIGHT_PROOF_ROOT']=str((a.out/scope).resolve())
  cmd=['gnatprove','-P',str(project.resolve()),'-u','mj-flex_contact_weights.adb','-j1','--mode=prove',
    '--report=all','--checks-as-errors=on','--warnings=continue','--no-inlining','--prover=cvc5,z3,altergo',
    '--timeout=3','--memlimit=650','--steps=0','--proof=per_check','--counterexamples=off']
  if scope!='whole':
   line=next(i for i,s in enumerate((source/'mj-flex_contact_weights.adb').read_text().splitlines(),1)
     if re.match(r'\s*(?:procedure|function) '+scope+r'\b',s))
   cmd+=['--limit-subp=mj-flex_contact_weights.adb:'+str(line)]
  start=time.monotonic()
  with (a.out/(scope+'.log')).open('w') as log:
   run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2200','--timeout','180','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
  report=next((a.out/scope).rglob('mj-flex_contact_weights.spark'),None);entries=[]
  if report:
   data=json.loads(report.read_text());shutil.copyfile(report,a.out/(scope+'.spark.json'))
   entries=[x for key in ('proof','flow','warn_error') for x in data.get(key,[])]
  opened=sum(x.get('severity') not in ('info','warning') for x in entries)
  row=dict(scope=scope,exit=run.returncode,seconds=time.monotonic()-start,command=cmd,
    checks=sum(x.get('severity')=='info' for x in entries),open=opened,
    warnings=sum(x.get('severity')=='warning' for x in entries),passed=run.returncode==0 and report is not None and opened==0)
  receipt['scopes'].append(row);(a.out/'results.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(row),flush=True)
 receipt['complete']=True;(a.out/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
 raise SystemExit(any(not row['passed'] for row in receipt['scopes']))
if __name__=='__main__':main()
