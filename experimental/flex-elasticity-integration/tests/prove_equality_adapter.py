"""FLEX producer/admission proofs against an already frozen runtime closure."""
import argparse, hashlib, json, re, shutil, subprocess, time
from pathlib import Path
from build import ROOT, environment

def subprogram_profile(lines, line):
    """Conservative textual profile for overloaded spec/body correspondence."""
    text='\n'.join(part.split('--',1)[0] for part in lines[line-1:])
    depth=0
    for token in re.finditer(r'\(|\)|;|\b(?:is|with)\b',text,re.IGNORECASE):
        value=token.group().lower()
        if value=='(':depth+=1
        elif value==')':depth-=1
        elif depth==0:
            return re.sub(r'\s+','',text[:token.start()]).lower()
    return None

def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--analysis-build',type=Path,help='Reuse analysis only for this exact frozen source manifest')
    p.add_argument('--scope',choices=['chain','storage','model','engine','columns','ranges','rows','admission','load','flow','whole',
        'factory','release','allocation','loading-whole','loading-flow',
        'materials-load','materials-vertex','materials-edge','materials-row-first','materials-metric','materials-element','materials-flex','materials-source-range','materials-whole','materials-flow',
        *['ancestors-'+s for s in ('last','advance','reverse','count','links','column','unfold-pair','unfold-column','shift','merge','build','whole','flow')]],required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    source=a.build.resolve()/'source';manifest=json.loads((a.build/'manifest.json').read_text())
    for name,h in manifest['sources'].items():
        assert hashlib.sha256((source/name).read_bytes()).hexdigest()==h,name
    (a.out/'sources.json').write_text(json.dumps(manifest,indent=2)+'\n')
    ancestors=a.scope.startswith('ancestors-')
    materials=a.scope.startswith('materials-')
    scope=(a.scope.removeprefix('materials-') if materials else
        a.scope.removeprefix('ancestors-') if ancestors else a.scope)
    loader_scopes=('columns','ranges','rows','admission','load','allocation')
    loading=(scope.startswith('loading-') or (scope in loader_scopes and
        (source/'experimental/flex-elasticity-integration/src/mj-data-flex_elasticity-loading.adb').is_file()))
    if scope.startswith('loading-'):scope=scope.removeprefix('loading-')
    unit=('mj-data-flex_elasticity-material_loading' if materials else
        'mj-flex_ancestors' if ancestors else
        'mj-data-flex_elasticity'+('-loading' if loading else
            '' if scope in (*loader_scopes,'factory','release') else '-equalities'))
    path=source/'experimental/flex-elasticity-integration/src'/f'{unit}.adb'
    lines=path.read_text().splitlines();limit=None;limit_file=unit+'.adb';target_name=None
    if scope not in ('flow','whole'):
        definitions=[i for i,line in enumerate(lines,1) if re.match(r'\s*procedure Append_Edges\b',line)]
        names={'chain':'Edge_Chain','storage':'Append_Storage','columns':'Copy_Edge_Columns',
               'ranges':'Copy_Flex_Edge_Ranges','rows':'Copy_Edge_Rows',
               'admission':'Load_Edge_Layout','load':'Load','allocation':'Allocate',
               'factory':'Create_Forces','release':'Free_Forces'}
        if ancestors:names={'last':'Last_Dof','advance':'Advance','reverse':'Reverse_Chain',
            'count':'Merged_Count','links':'Links_Valid','column':'Descending_Column',
            'unfold-pair':'Unfold_Pair','unfold-column':'Unfold_Column','shift':'Shift_Suffix','merge':'Merge','build':'Build'}
        if materials:names={'load':'Load','vertex':'Load_Vertex','edge':'Load_Edge',
            'row-first':'Packed_Row_First','metric':'Load_Metric','element':'Load_Element','flex':'Load_Flex','source-range':'Source_Range_Lemma'}
        if scope in names:
            target_name=names[scope]
            matches=[i for i,line in enumerate(lines,1) if re.match(r'\s*(?:procedure|function) '+target_name+r'\b',line)]
            if not matches:
                limit_file=unit+'.ads'
                matches=[i for i,line in enumerate(path.with_suffix('.ads').read_text().splitlines(),1)
                    if re.match(r'\s*(?:procedure|function) '+target_name+r'\b',line)]
            assert len(matches)==1,'Requested subprogram definition must be unique.'
            limit=matches[0]
        else:
            limit=definitions[0 if scope=='model' else 1]
            target_name=re.match(r'\s*(?:procedure|function)\s+(\w+)',lines[limit-1]).group(1)
    command=['gnatprove','-P',str(source/'experimental/flex-elasticity-integration/flex_constrained.gpr'),
        '-u',unit+'.adb','-j1','--report=all','--checks-as-errors=on','--warnings=continue','--no-inlining']
    if scope=='flow':command+=['--mode=flow']
    else:
        command+=['--mode=prove','--prover=cvc5,z3,altergo','--timeout=3','--memlimit=650',
            '--steps=0','--proof=per_check','--counterexamples=off']
        if limit is not None:command+=['--limit-subp='+limit_file+':'+str(limit)]
    analysis=a.analysis_build.resolve() if a.analysis_build else a.out.resolve()/'build'
    signature=hashlib.sha256((a.build/'manifest.json').read_bytes()).hexdigest()
    if a.analysis_build:
        analysis.mkdir(parents=True,exist_ok=True)
        stamp=analysis/'source-manifest.sha256'
        if stamp.exists():assert stamp.read_text().strip()==signature,'Analysis source mismatch'
        else:stamp.write_text(signature+'\n')
    #  A guarded failure may leave the previous limited proof in the shared
    #  analysis cache. Never attribute that report to this invocation.
    previous_reports=list(analysis.rglob(unit+'.spark'))
    for previous in previous_reports:previous.unlink()
    env=environment();env.update(FLEX_BUILD_ROOT=str(analysis),FLEX_MODE='validation')
    started=time.monotonic()
    with (a.out/'proof.log').open('w') as log:
        run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','240','--',*command],
            env=env,stdout=log,stderr=subprocess.STDOUT)
    reports=list(analysis.rglob(unit+'.spark'))
    report=reports[0] if len(reports)==1 else None
    result=dict(scope=a.scope,limit=limit,limit_file=limit_file,exit=run.returncode,command=command,
        seconds=time.monotonic()-started,runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    if len(reports)>1:result['report_rejected']='Multiple reports for the requested unit.'
    if report:
        d=json.loads(report.read_text());shutil.copyfile(report,a.out/'unit.spark.json')
        selected=[d.get('entities',{}).get(k,{}) for k,v in d.get('spark',{}).items() if v=='all']
        requested={(limit_file,limit)}
        #  Public subprogram reports can locate the specification instead of
        #  the body. Match its unique declaration and entity name as well.
        if limit is not None:
            spec=path.with_suffix('.ads')
            if spec.is_file():
                spec_lines=spec.read_text().splitlines()
                declarations=[i for i,line in enumerate(spec_lines,1)
                    if re.match(r'\s*(?:procedure|function)\s+'+re.escape(target_name)+r'\b',line)]
                if len(declarations)>1:
                    profile=subprogram_profile(lines,limit)
                    declarations=[i for i in declarations if profile is not None
                        and subprogram_profile(spec_lines,i)==profile]
                if len(declarations)==1:requested.add((unit+'.ads',declarations[0]))
        result['report_scope_matches']=(limit is None or any(
            (loc.get('file'),loc.get('line')) in requested
            and (loc.get('file')==unit+'.adb' or
                entity.get('name','').lower().endswith('.'+target_name.lower()))
            for entity in selected for loc in entity.get('sloc',[])))
        if not result['report_scope_matches']:
            result['report_rejected']='Report does not cover the requested subprogram.'
            report=None
    if report:
        entries=[e for kind in ('proof','flow','warn_error') for e in d.get(kind,[])]
        result.update(proof_checks=len(d.get('proof',[])),flow_checks=len(d.get('flow',[])),
            checks=sum(e.get('severity')=='info' for e in entries),
            open=[e for e in entries if e.get('severity') not in ('info','warning')],
            warnings=[e for e in entries if e.get('severity')=='warning'])
        result['entities']=[d['entities'][k]['name'] for k,v in d['spark'].items() if v=='all']
        result['scope_coverage_complete']=(all(k in d for k in ('skip_proof','skip_flow_proof','pragma_assume'))
            and not d.get('skip_proof') and not d.get('skip_flow_proof')
            and not d.get('pragma_assume') and all(v=='all' for v in d['spark'].values())
            and d.get('progress')==('PROGRESS_FLOW' if scope=='flow' else 'PROGRESS_PROOF')
            and d.get('stop_reason')=='STOP_REASON_NONE')
        result['complete_coverage']=scope=='whole' and result['scope_coverage_complete']
        if scope=='whole':
            unit_text=path.read_text()+('\n'+path.with_suffix('.ads').read_text() if path.with_suffix('.ads').is_file() else '')
            expected={name.lower() for name in re.findall(r'^\s*(?:function|procedure)\s+(\w+)',unit_text,re.MULTILINE)}
            proved={name.rsplit('.',1)[-1].lower() for name in result['entities']}
            result['missing_entities']=sorted(expected-proved)
            result['complete_coverage'] &= not result['missing_entities']
    result['obligations_closed']=(run.returncode==0 and report is not None
        and result.get('scope_coverage_complete',False)
        and not result.get('open',[])
        and (limit is None or result.get('proof_checks',0)>0))
    if scope=='whole':result['obligations_closed'] &= result.get('complete_coverage',False)
    result['passed']=result['obligations_closed'] and not result.get('warnings',[])
    result['claim']=('Whole unit contracts only; admission/caller obligations remain separate.'
        if scope=='whole' else 'Minimal scope only; no whole producer or caller Gold claim.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result.get(k) for k in ('scope','exit','checks','proof_checks','flow_checks','passed')}))
    raise SystemExit(not result['passed'])
if __name__=='__main__':main()
