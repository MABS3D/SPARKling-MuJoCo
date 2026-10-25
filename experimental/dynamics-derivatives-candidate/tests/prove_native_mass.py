"""Prove the native storage minima before the composed unit, with strict receipts."""
import argparse, hashlib, json, re, shutil, subprocess, time
from pathlib import Path
from build import ROOT, environment

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--patterns',action='store_true');p.add_argument('--only')
    a=p.parse_args();a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
    src=a.out/'src';src.mkdir();hashes={}
    runner_hash=digest(Path(__file__));guard_hash=digest(ROOT/'tools/guarded.py')
    shutil.copyfile(Path(__file__),a.out/'runner.py');shutil.copyfile(ROOT/'tools/guarded.py',a.out/'guarded.py')
    unit='mj-native_mass_patterns' if a.patterns else 'mj-native_mass_kernels'
    paths=['src/mj.ads','src/mj-types.ads',
        'experimental/dynamics-derivatives-candidate/src/mj-native_mass_kernels.ads',
        'experimental/dynamics-derivatives-candidate/src/mj-native_mass_kernels.adb']
    if a.patterns:paths += ['experimental/dynamics-derivatives-candidate/src/mj-native_mass_patterns.'+ext for ext in ['ads','adb']]
    for rel in paths:
        original=(ROOT/rel if a.patterns and 'mj-native_mass_patterns.' in rel else a.build/'source'/rel);shutil.copyfile(original,src/original.name);hashes[rel]=digest(original)
    (a.out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    project=a.out/'proof.gpr';project.write_text('project Proof is\n for Source_Dirs use ("src");\n for Object_Dir use "obj";\n for Create_Missing_Dirs use "True";\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off");\n end Compiler;\nend Proof;\n')
    targets=[]
    for ext in ['ads','adb']:
        path=src/(unit+'.'+ext)
        for n,line in enumerate(path.read_text().splitlines(),1):
            m=re.match(r'\s*(?:function|procedure) (\w+)',line)
            if m and (ext=='adb' or a.patterns or m[1]=='Bounded'):targets.append((m[1],path.name+':'+str(n)))
    body_names={name for name,limit in targets if '.adb:' in limit}
    targets=[(name,limit) for name,limit in targets if '.adb:' in limit or name not in body_names]
    if a.only:targets=[x for x in targets if x[0]==a.only]
    else:targets.append(('whole-unit',None))
    assert targets, 'Unknown proof selection'
    records=[]
    for name,limit in targets:
        command=['gnatprove','-f','-P',str(project),'-u',unit+'.ads',
            '--prover=cvc5,z3,altergo','--timeout=3','--memlimit=650','--steps=0',
            '--proof=per_check','-j1','--checks-as-errors=on','--warnings=continue',
            '--report=all','--counterexamples=off']
        if limit:command.append('--limit-subp='+limit)
        for stale in (a.out/'obj').rglob(unit+'.spark'):stale.unlink()
        start=time.monotonic()
        run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','240','--',*command],
            env=environment(),capture_output=True,text=True)
        log=a.out/(name+'.log');log.write_text(run.stdout+run.stderr)
        reports=list((a.out/'obj').rglob(unit+'.spark'))
        record=dict(name=name,exit=run.returncode,command=command,seconds=time.monotonic()-start,passed=False,
            runner_sha256=runner_hash,guard_sha256=guard_hash)
        if len(reports)==1:
            report=json.loads(reports[0].read_text());shutil.copyfile(reports[0],a.out/(name+'.spark.json'))
            entries=[x for kind in ['proof','flow','warn_error'] for x in report.get(kind,[])]
            record.update(proof_checks=len(report.get('proof',[])),flow_checks=len(report.get('flow',[])),
                checks=sum(x.get('severity')=='info' for x in entries),
                warnings=[x for x in entries if x.get('severity')=='warning'],
                open=[x for x in entries if x.get('severity') not in ['info','warning']],
                complete_coverage=bool(report.get('spark')) and all(v=='all' for v in report['spark'].values())
                    and not any(report.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume'])
                    and report.get('progress')=='PROGRESS_PROOF' and report.get('stop_reason')=='STOP_REASON_NONE')
            record['passed']=(run.returncode==0 and record['complete_coverage'] and not record['open']
                and not record['warnings'] and (record['proof_checks']>0 or name in ['Bounded','Overlap','Input_Layout']))
        record['expression_definition_only']=(name in ['Bounded','Overlap','Input_Layout'] and record.get('proof_checks')==0)
        record['source_hashes_unchanged']=all(digest((ROOT/n if a.patterns and 'mj-native_mass_patterns.' in n else a.build/'source'/n))==v and digest(src/Path(n).name)==v for n,v in hashes.items())
        record['passed'] = record['passed'] and record['source_hashes_unchanged']
        records.append(record);(a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
        print(name,record['passed'],record.get('checks'),flush=True)
        if not record['passed']:print(log.read_text()[-3500:],flush=True)
    raise SystemExit(0 if all(r['passed'] for r in records) else 1)
if __name__=='__main__':main()
