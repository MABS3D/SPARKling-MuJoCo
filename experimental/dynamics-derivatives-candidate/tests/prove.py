"""Prove minimal kernels first, then the whole unchanged unit."""
import argparse, hashlib, json, re, shutil, subprocess, sys
from pathlib import Path
from build import environment, ROOT, HERE

def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    p.add_argument('--build',type=Path,required=True);p.add_argument('--only');a=p.parse_args()
    a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False);src=a.out/'src';src.mkdir()
    paths=['src/mj.ads','src/mj-types.ads',
        'experimental/dynamics-derivatives-candidate/src/mj-derivative_kernels.ads',
        'experimental/dynamics-derivatives-candidate/src/mj-derivative_kernels.adb']
    hashes={}
    for rel in paths:
        f=a.build/'source'/rel;data=f.read_bytes();(src/f.name).write_bytes(data)
        hashes[rel]=hashlib.sha256(data).hexdigest()
    project=a.out/'proof.gpr';project.write_text('project Proof is\n for Source_Dirs use ("src");\n for Object_Dir use "obj";\n for Create_Missing_Dirs use "True";\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off");\n end Compiler;\nend Proof;\n')
    (a.out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    targets=[]
    for suffix in ['ads','adb']:
        for n,line in enumerate((src/('mj-derivative_kernels.'+suffix)).read_text().splitlines(),1):
            m=re.match(r'\s*(?:function|procedure) (\w+)',line)
            if m and (suffix=='adb' or m[1]=='Within'):
                targets.append((m[1],f'mj-derivative_kernels.{suffix}:{n}'))
    if a.only:targets=[x for x in targets if x[0]==a.only]
    else:targets.append(('whole-unit',None))
    records=[]
    for name,limit in targets:
        command=['gnatprove','-f','-P',str(project),'-u','mj-derivative_kernels.ads',
            '--prover=cvc5,z3,altergo','--timeout=10','--memlimit=500','--steps=0',
            '--proof=per_path','-j1','--checks-as-errors=on','--warnings=continue',
            '--report=all','--counterexamples=off']
        if limit:command.append('--limit-subp='+limit)
        r=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),
            '--cap-mb','2400','--timeout','180','--',*command],env=environment(),capture_output=True,text=True)
        (a.out/(name+'.log')).write_text(r.stdout+r.stderr)
        report=a.out/'obj/gnatprove/mj-derivative_kernels.spark';rec=dict(name=name,command=command,exit=r.returncode)
        if report.exists():
            d=json.loads(report.read_text());shutil.copyfile(report,a.out/(name+'.spark.json'))
            checks=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[])]
            rec.update(proof_checks=sum(x.get('severity')=='info' for x in d.get('proof',[])),
              flow_checks=sum(x.get('severity')=='info' for x in d.get('flow',[])),
              complete_coverage=bool(d.get('spark')) and all(v=='all' for v in d.get('spark',{}).values())
                and not any(d.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume']),
              checks=sum(x.get('severity')=='info' for x in checks),
              open=[x for x in checks if x.get('severity') not in ['info','warning']],
              warnings=[x for x in checks if x.get('severity')=='warning'])
            if not limit:
                rec['complete_coverage']=(not d['skip_proof'] and not d['skip_flow_proof']
                    and not d['pragma_assume'] and all(v=='all' for v in d['spark'].values())
                    and d['progress']=='PROGRESS_PROOF' and d['stop_reason']=='STOP_REASON_NONE')
                rec['entities']=[d['entities'][k]['name'] for k,v in d['spark'].items() if v=='all']
        # Within is the specification itself: a total Boolean expression over
        # scalar parameters, with no arithmetic or separate implementation.
        # GNATprove emits only termination/dependency flow checks for it.
        # Keep that zero-proof count explicit; the whole unit must have proof VCs.
        rec['expression_definition_only']=(name=='Within' and rec.get('proof_checks')==0)
        rec['passed']=bool(r.returncode==0 and 'open' in rec and not rec['open']
            and (rec.get('proof_checks',0)>0 or rec['expression_definition_only'])
            and not rec['warnings'] and rec.get('complete_coverage'))
        records.append(rec);(a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
        print(name,rec['passed'],rec.get('checks'),flush=True)
        if not rec['passed']:print((r.stdout+r.stderr)[-2500:],flush=True)
    raise SystemExit(0 if records and all(x['passed'] for x in records) else 1)
if __name__=='__main__':main()
