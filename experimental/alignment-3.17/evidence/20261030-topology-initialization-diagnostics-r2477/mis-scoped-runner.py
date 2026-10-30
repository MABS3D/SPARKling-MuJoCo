"""Prove a native-reader minimum on a frozen, correctly versioned full closure."""
import argparse,hashlib,json,os,re,shutil,subprocess,time
from pathlib import Path
import sys
sys.path.insert(0, '/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/dynamics-derivatives-candidate/tests')
from build import ROOT,environment

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--wall-seconds',type=int,choices=[240,600,900],default=240);p.add_argument('--strategy',choices=['per_check','per_path','progressive'],default='per_check');p.add_argument('--only',required=True);p.add_argument('--analysis-root',type=Path);p.add_argument('--models',action='store_true');p.add_argument('--composite',action='store_true');a=p.parse_args()
    assert not (a.models and a.composite)
    a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False);source=a.build/'source'
    hashes=json.loads((a.build/'sources.json').read_text())
    def unchanged():return all(digest(source/n)==v for n,v in hashes.items())
    assert unchanged();unit='mj-data'
    path=source/'experimental/smooth/src'/(unit+'.adb')
    locations=[i for i,line in enumerate(path.read_text().splitlines(),1) if re.match(r'\s*(?:function|procedure) '+a.only+r'\b',line)]
    whole=a.only=='whole-unit'
    if not whole and not locations:
        path=path.with_suffix('.ads')
        locations=[i for i,line in enumerate(path.read_text().splitlines(),1) if re.match(r'\s*(?:function|procedure) '+a.only+r'\b',line)]
    if not whole:
        # A local contract declaration can precede the body. Select the body,
        # not both source locations, for the minimum GNATprove scope.
        lines=path.read_text().splitlines()
        bodies=[]
        for line in locations:
            declaration='\n'.join(lines[line-1:])
            # Header aspects can precede "is" on a body. Ignore comments,
            # strings and parameter/aspect parentheses; a top-level semicolon
            # ends a declaration, while a top-level "is" starts its body.
            depth=0
            for token in re.finditer(r'--[^\n]*|"(?:[^"]|"")*"|\bis\b|[();]',declaration):
                value=token[0]
                if value.startswith(('--','"')):continue
                if value=='(':depth+=1
                elif value==')':depth-=1
                elif depth==0:
                    if value=='is':bodies.append(line)
                    break
        locations=bodies
        assert len(locations)==1,locations
    env=environment();analysis=a.analysis_root or (a.out/'analysis');env['DERIVATIVES_BUILD_ROOT']=str(analysis);env['DERIVATIVES_MODE']='validation'
    project=source/'experimental/dynamics-derivatives-candidate/derivatives.gpr'
    if a.models:
        project=a.out/'models.gpr'
        folders=[source/'src',source/'src/gen',source/'experimental/smooth/src',Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnatprove/gnatprove-x86_64-linux-16.1.0-1/include/spark'),Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnatprove/gnatprove-x86_64-linux-16.1.0-1/include/spark/full')]
        project.write_text('project Models is\n for Source_Dirs use ('+', '.join('"'+str(f)+'"' for f in folders)+');\n for Object_Dir use "'+str(analysis)+'";\n for Create_Missing_Dirs use "True";\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off");\n end Compiler;\nend Models;\n')
    command=['gnatprove','-P',str(project),
        '-u',unit+'.adb','--no-inlining',
        '--prover=cvc5,z3,altergo','--timeout=30','--memlimit=4000','--steps=0','--proof='+a.strategy,
        '-j1','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
    if not whole:command.append('--limit-subp='+path.name+':'+str(locations[0]))
    command.append('--limit-line=mj-data.adb:1139')
    shutil.copyfile(Path(__file__),a.out/'runner.py');shutil.copyfile(ROOT/'tools/guarded.py',a.out/'guarded.py')
    start_wall=time.time();start=time.monotonic()
    with (a.out/'proof.log').open('w') as log:
        run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','8000','--timeout',str(a.wall_seconds),'--',*command],
            env=env,cwd=source,stdout=log,stderr=subprocess.STDOUT)
    record=dict(subprogram=a.only,exit=run.returncode,command=command,seconds=time.monotonic()-start,
        analysis_root=str(analysis),incremental_ali_cache=True,source_hashes_unchanged=unchanged(),sources_sha256=digest(a.build/'sources.json'),passed=False)
    reports=list(analysis.rglob(unit+'.spark'))
    record['fresh_scoped_report']=len(reports)==1 and reports[0].stat().st_mtime >= start_wall
    if record['fresh_scoped_report']:
        data=json.loads(reports[0].read_text());shutil.copyfile(reports[0],a.out/'unit.spark.json')
        entries=[x for kind in ['proof','flow','warn_error'] for x in data.get(kind,[])]
        record.update(checks=sum(x.get('severity')=='info' for x in entries),proof_checks=len(data.get('proof',[])),
            flow_checks=len(data.get('flow',[])),warnings=[x for x in entries if x.get('severity')=='warning'],
            open=[x for x in entries if x.get('severity') not in ['info','warning']],
            coverage=bool(data.get('spark')) and all(v=='all' for v in data['spark'].values())
                and not any(data.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume'])
                and data.get('progress')=='PROGRESS_PROOF' and data.get('stop_reason')=='STOP_REASON_NONE')
        record['representation_complete']='generation of data representation information failed' not in (a.out/'proof.log').read_text()
        record['obligations_closed']=record['representation_complete'] and run.returncode==0 and record['source_hashes_unchanged'] and record['coverage'] and not record['open']
        record['passed']=record['obligations_closed'] and not record['warnings']
    record['scope']='Diagnostic only: Arms initialization loop invariant, not whole builder safety/functional proof.'
    record['whole_subprogram_proven']=False
    (a.out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
    print(a.only,record['passed'],record.get('checks'),flush=True)
    if not record['passed']:print((a.out/'proof.log').read_text()[-5000:])
    raise SystemExit(not record['passed'])
if __name__=='__main__':main()
