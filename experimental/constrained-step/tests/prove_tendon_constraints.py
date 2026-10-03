"""Freeze the row-kernel closure; smallest subprograms, then full-unit proof."""
import argparse, hashlib, json, re, shutil, subprocess, time
from pathlib import Path
from build import ROOT, environment

def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--timeout',type=int,default=5)
    p.add_argument('--only');p.add_argument('--proof',default='per_check');a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False);source=a.out/'source';source.mkdir()
    files=['src/mj.ads','src/mj-types.ads','src/mj-types.adb',
      'experimental/constraint-assembly-candidate/src/mj-constraint_assembly.ads',
      'experimental/constraint-assembly-candidate/src/mj-constraint_assembly.adb',
      'experimental/constrained-step/src/mj-tendon_constraint_kernels.ads',
      'experimental/constrained-step/src/mj-tendon_constraint_kernels.adb']
    hashes={}
    for name in files:
        f=ROOT/name
        if not f.exists():continue
        data=f.read_bytes();(source/f.name).write_bytes(data);hashes[name]=hashlib.sha256(data).hexdigest()
    (a.out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    project=a.out/'proof.gpr';project.write_text('''project Proof is
      for Source_Dirs use ("source");
      for Object_Dir use external ("TENDON_PROOF_OBJECTS");
      for Create_Missing_Dirs use "True";
      package Compiler is
        for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off", "-gnata");
      end Compiler;
    end Proof;
''')
    targets=[(m[1],i) for i,line in enumerate((source/'mj-tendon_constraint_kernels.adb').read_text().splitlines(),1)
             if (m:=re.match(r'\s*(?:function|procedure) (\w+)',line))]+[('whole',None)]
    if a.only:targets=[t for t in targets if t[0] in a.only.split(',')]
    if not targets:raise ValueError('Unknown target')
    records=[]
    for label,line in targets:
        if label=='whole' and any(r['exit'] or r.get('open',1) or r.get('warnings',1) for r in records):
            break
        env=environment();env['TENDON_PROOF_OBJECTS']=str(a.out/label/'obj')
        cmd=['gnatprove','-P',str(project),'-u','mj-tendon_constraint_kernels.adb','--prover=cvc5,z3,altergo',
          '--timeout='+str(a.timeout),'--memlimit=600','--steps=0','--proof='+a.proof,'-j1',
          '--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
        if line:cmd+=['--limit-subp=mj-tendon_constraint_kernels.adb:'+str(line)]
        start=time.monotonic();r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2400','--min-free-mb','12000','--timeout','240' if label=='whole' else '180','--',*cmd],env=env,capture_output=True,text=True)
        (a.out/(label+'.log')).write_text(r.stdout+r.stderr)
        record=dict(label=label,exit=r.returncode,seconds=time.monotonic()-start,command=cmd)
        report=next((f for f in (a.out/label).rglob('mj-tendon_constraint_kernels.spark')),None)
        if report:
            d=json.loads(report.read_text());shutil.copyfile(report,a.out/(label+'.spark.json'))
            entries=[m for k in ['proof','flow','warn_error'] for m in d.get(k,[])]
            record.update(checks=sum(m.get('severity')=='info' for m in entries),
              open=sum(m.get('severity') not in ('info','warning') for m in entries),warnings=sum(m.get('severity')=='warning' for m in entries))
            if line is None:
                record['complete_coverage'] = (not d['skip_proof'] and not d['skip_flow_proof']
                    and not d['pragma_assume'] and all(v == 'all' for v in d['spark'].values())
                    and d['progress'] == 'PROGRESS_PROOF' and d['stop_reason'] == 'STOP_REASON_NONE')
                record['entities'] = sorted(d['entities'][k]['name'] for k in d['spark'])
        records.append(record);print({k:v for k,v in record.items() if k!='command'},flush=True)
        (a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
    if any(r['exit']!=0 or r.get('open',1) or r.get('warnings',1)
        or (r['label']=='whole' and not r.get('complete_coverage')) for r in records):raise SystemExit(1)
if __name__=='__main__':main()
